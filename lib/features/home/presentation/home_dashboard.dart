import 'package:flutter/material.dart';
import '../../../core/localization/app_locale.dart';
import '../../../core/network/api_client.dart';
import '../../../core/theme/app_colors.dart';
import '../../../models/category_model.dart';
import '../../../models/offer_model.dart';
import '../../brand_detail/presentation/brand_detail_screen.dart';
import '../../categories/presentation/categories_screen.dart';
import '../../deals/presentation/all_deals_screen.dart';
import '../../merchants/presentation/all_merchants_screen.dart';
import '../../notifications/presentation/notifications_screen.dart';
import '../../../services/location_service.dart';
import '../../../services/realtime_sync_service.dart';
import '../../../services/system_notification_service.dart';
import '../../../core/widgets/wafra_push_notification_banner.dart';
import '../../../core/widgets/wafra_image_widget.dart';
import '../../../core/widgets/discount_badge.dart';
import '../../../main.dart';
import 'widgets/select_city_modal.dart';

class HomeDashboard extends StatefulWidget {
  const HomeDashboard({super.key});

  @override
  State<HomeDashboard> createState() => _HomeDashboardState();
}

class _HomeDashboardState extends State<HomeDashboard> {
  String _selectedCity = "Kuwait City";
  List<OfferModel> _liveOffers = [];
  bool _isLoading = true;
  Map<String, dynamic>? _nearbyProximityAlert;
  OfferModel? _matchedAlertOffer;
  int _unreadNotifsCount = 0;
  bool _hasAutoTriggeredDemo = false;
  int _demoIndex = 0;
  int? _lastProcessedNotifId;

  @override
  void initState() {
    super.initState();
    _selectedCity = appLocationNotifier.value;
    appLocationNotifier.addListener(_onAppLocationChanged);
    RealTimeSyncService.instance.initialize();
    RealTimeSyncService.instance.addListener(_onRealtimeOffersUpdated);
    _fetchLiveOffers();
  }

  @override
  void dispose() {
    appLocationNotifier.removeListener(_onAppLocationChanged);
    RealTimeSyncService.instance.removeListener(_onRealtimeOffersUpdated);
    super.dispose();
  }

  void _onAppLocationChanged() {
    if (mounted && _selectedCity != appLocationNotifier.value) {
      setState(() {
        _selectedCity = appLocationNotifier.value;
      });
      _fetchDailyPicksForCity(_selectedCity);
    }
  }

  void _onRealtimeOffersUpdated() {
    if (mounted) {
      final updated = RealTimeSyncService.instance.allOffers;
      if (updated.isNotEmpty) {
        setState(() {
          _liveOffers = updated;
        });
      }
    }
  }

  /// Check for any new offer drops published by merchants across Kuwait
  Future<void> _checkForNewOfferDrops() async {
    final notifs = await ApiClient.instance.getUserNotifications();
    for (final n in notifs) {
      final type = n["type"]?.toString();
      final id = (n["id"] as num?)?.toInt() ?? 0;
      final isRead = n["is_read"] == true;

      if (type == "OFFER_DROP" && !isRead) {
        if (_lastProcessedNotifId == null || id > _lastProcessedNotifId!) {
          _lastProcessedNotifId = id;
          final title = n["title"]?.toString() ?? "🎉 New Deal Drop!";
          final body = n["body"]?.toString() ?? "A partner merchant dropped a new offer!";
          final offerId = n["offer_id"]?.toString();

          if (mounted) {
            // 1. In-app frosted glass push banner
            WafraPushNotificationBanner.show(
              context,
              title: title,
              body: body,
              timeAgo: isArabic ? "عرض جديد" : "New Drop",
              onTap: () {
                if (_liveOffers.isNotEmpty) {
                  final match = _liveOffers.firstWhere(
                    (o) => o.id == offerId,
                    orElse: () => _liveOffers.first,
                  );
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => BrandDetailScreen(offer: match),
                    ),
                  );
                }
              },
            );

            // 2. OS-level lock screen notification outside the app
            SystemNotificationService().showSystemNotification(
              id: 8000 + id,
              title: title,
              body: body,
              payload: offerId,
            );

            ApiClient.instance.markNotificationAsRead(id);
          }
          break;
        }
      }
    }
  }

  /// Daily reminder based on user's city location
  Future<void> _fetchDailyPicksForCity(String city, {bool notify = true}) async {
    final data = await ApiClient.instance.getDailyPicks(city);
    if (data != null && notify && mounted) {
      final title = data["reminder_title"]?.toString() ?? (isArabic ? "☀️ عروض اليوم في $city!" : "☀️ Daily Picks for $city!");
      final body = data["reminder_body"]?.toString() ?? (isArabic ? "اكتشف أفضل الخصومات اليوم في $city!" : "Discover today's top discounts in $city!");

      // 1. In-app glassmorphic banner
      WafraPushNotificationBanner.show(
        context,
        title: title,
        body: body,
        timeAgo: isArabic ? "تذكير يومي" : "Daily Reminder",
      );

      // 2. OS-level lock screen push notification outside the app
      await SystemNotificationService().showSystemNotification(
        id: 7000 + city.hashCode.abs() % 1000,
        title: title,
        body: body,
      );
    }
  }

  void _triggerDemoNotification() {
    final demosEn = [
      {
        "title": "📍 Starbucks is only 50m away!",
        "body": "Enjoy 20% OFF on all coffee & drinks. Tap to redeem with your Worker ID.",
        "brand": "STARBUCKS",
        "tag": "20% OFF",
        "dist": "50m",
      },
      {
        "title": "🔥 KFC is right beside you! (10m)",
        "body": "25% OFF on all Zinger and Family meals today. Instant voucher ready.",
        "brand": "KFC",
        "tag": "25% OFF",
        "dist": "10m",
      },
      {
        "title": "📍 G Café is right nearby! (200m)",
        "body": "20% OFF on all specialty brews today. Show Worker ID at cashier.",
        "brand": "G Café",
        "tag": "20% OFF",
        "dist": "200m",
      },
    ];

    final demosAr = [
      {
        "title": "📍 ستاربكس على بعد 50 متراً فقط!",
        "body": "استمتع بخصم 20% على جميع أنواع القهوة والمشروبات. اضغط للاستخدام برقمك الوظيفي.",
        "brand": "ستاربكس",
        "tag": "خصم 20%",
        "dist": "50 م",
      },
      {
        "title": "🔥 كنتاكي بجانبك مباشرة! (10 م)",
        "body": "خصم 25% على وجبات الزنجر والعائلية اليوم. قسيمتك جاهزة فوراً.",
        "brand": "كنتاكي",
        "tag": "خصم 25%",
        "dist": "10 م",
      },
      {
        "title": "📍 جي كافيه قريب منك جداً! (200 م)",
        "body": "خصم 20% على جميع المشروبات المختصة اليوم. أظهر بطاقة العمل عند الكاشير.",
        "brand": "G Café",
        "tag": "خصم 20%",
        "dist": "200 م",
      },
    ];

    final demos = isArabic ? demosAr : demosEn;
    final demo = demos[_demoIndex % demos.length];
    _demoIndex++;

    OfferModel? matchingOffer;
    for (final o in _liveOffers) {
      if (o.brandName.toLowerCase().contains(demo["brand"]!.toLowerCase())) {
        matchingOffer = o;
        break;
      }
    }
    matchingOffer ??= _liveOffers.isNotEmpty ? _liveOffers.first : null;

    WafraPushNotificationBanner.show(
      context,
      title: demo["title"]!,
      body: demo["body"]!,
      timeAgo: isArabic ? "الآن" : "Just now",
      brandName: demo["brand"],
      discountTag: demo["tag"],
      distanceText: demo["dist"],
      onTap: () {
        if (matchingOffer != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => BrandDetailScreen(offer: matchingOffer!),
            ),
          );
        }
      },
    );

    // Fire real OS-level System Notification (heads-up & lockscreen outside the app)
    SystemNotificationService().showSystemNotification(
      id: 3000 + _demoIndex,
      title: demo["title"]!,
      body: demo["body"]!,
      payload: matchingOffer?.id,
    );
  }

  Future<void> _fetchLiveOffers() async {
    setState(() => _isLoading = true);
    final offers = await ApiClient.instance.getOffers();

    // Check Geolocation with backend
    Map<String, dynamic>? geoAlert;
    OfferModel? alertOffer;
    try {
      final geoRes = await LocationService().syncLocationWithBackend();
      if (geoRes != null && (geoRes["in_range_count"] as num? ?? 0) > 0) {
        final inRange = geoRes["in_range_offers"] as List?;
        if (inRange != null && inRange.isNotEmpty) {
          geoAlert = inRange.first as Map<String, dynamic>;
          final oId = geoAlert["offer_id"]?.toString();
          alertOffer = offers.firstWhere((o) => o.id == oId, orElse: () => offers.first);
        }
      }
    } catch (_) {}

    int notifsCount = 0;
    try {
      notifsCount = await ApiClient.instance.getUnreadNotificationsCount();
    } catch (_) {}

    if (mounted) {
      setState(() {
        _liveOffers = offers;
        _nearbyProximityAlert = geoAlert;
        _matchedAlertOffer = alertOffer;
        _unreadNotifsCount = notifsCount > 0 ? notifsCount : (geoAlert != null ? 1 : 0);
        _isLoading = false;
      });

      // Check if any merchant dropped a new offer across Kuwait
      _checkForNewOfferDrops();

      if (!_hasAutoTriggeredDemo) {
        _hasAutoTriggeredDemo = true;
        Future.delayed(const Duration(milliseconds: 900), () {
          if (!mounted) return;
          if (geoAlert != null && alertOffer != null) {
            WafraPushNotificationBanner.show(
              context,
              title: "📍 ${geoAlert['brand_name']} is nearby! (${(geoAlert['distance_meters'] as num?)?.round() ?? 50}m)",
              body: "${geoAlert['discount_tag']} active now. Tap to redeem with your Worker ID.",
              timeAgo: "Just now",
              brandName: geoAlert['brand_name'],
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => BrandDetailScreen(offer: alertOffer!),
                  ),
                );
              },
            );
          } else {
            _triggerDemoNotification();
          }
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = themeModeNotifier.value == ThemeMode.dark;
    final bgColor = isDark ? const Color(0xFF0F172A) : AppColors.background;
    final cardBg = isDark ? const Color(0xFF1E293B) : Colors.white;
    final textPrimary = isDark ? Colors.white : AppColors.textPrimary;
    final textSecondary = isDark ? const Color(0xFF94A3B8) : AppColors.textSecondary;
    final textMuted = isDark ? const Color(0xFF64748B) : AppColors.textMuted;
    final borderColor = isDark ? const Color(0xFF334155) : Colors.grey.shade200;

    final clientName = ApiClient.instance.currentUser?['full_name'] ?? 'Civil Servant';

    final uniqueMerchants = <String, OfferModel>{};
    for (final o in _liveOffers) {
      uniqueMerchants.putIfAbsent(o.brandName, () => o);
    }

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _fetchLiveOffers,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(18.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Bar: Official Wafra Logo & Location Picker & Notifications
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: _unreadNotifsCount > 0
                          ? Badge(
                              label: Text("$_unreadNotifsCount"),
                              backgroundColor: const Color(0xFFE11D48),
                              child: Icon(Icons.notifications_outlined,
                                  color: textPrimary, size: 24),
                            )
                          : Icon(Icons.notifications_outlined,
                              color: textPrimary, size: 24),
                      onPressed: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const NotificationsScreen()),
                        );
                        if (mounted) {
                          final count = await ApiClient.instance.getUnreadNotificationsCount();
                          setState(() => _unreadNotifsCount = count);
                        }
                      },
                    ),
                    Image.asset(
                      'assets/images/wafra_logo.png',
                      height: 38,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) => const Text(
                        'Wafra',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: AppColors.primaryBlue,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        showModalBottomSheet(
                          context: context,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                          ),
                          builder: (context) => SelectCityModal(
                            currentCity: _selectedCity,
                            onCitySelected: (city) {
                              setState(() {
                                _selectedCity = city;
                              });
                              appLocationNotifier.value = city;
                              _fetchDailyPicksForCity(city);
                            },
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: cardBg,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: borderColor),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.location_on, size: 14, color: AppColors.primaryBlue),
                            const SizedBox(width: 4),
                            Text(
                              _selectedCity,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: textPrimary,
                              ),
                            ),
                            Icon(Icons.keyboard_arrow_down, size: 16, color: textPrimary),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 18),

                // Greeting (Strictly using registered client's name)
                Text(
                  "${tr('hello')}, $clientName",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: textPrimary,
                  ),
                ),

                const SizedBox(height: 14),

                // Search Bar
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    color: cardBg,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: borderColor),
                  ),
                  child: TextField(
                    style: TextStyle(color: textPrimary),
                    decoration: InputDecoration(
                      icon: Icon(Icons.search, color: textMuted, size: 20),
                      hintText: tr("search_placeholder"),
                      hintStyle: TextStyle(fontSize: 13, color: textMuted),
                      border: InputBorder.none,
                    ),
                  ),
                ),

                const SizedBox(height: 18),

                // Live Geolocation Range Proximity Alert Banner
                if (_nearbyProximityAlert != null && _matchedAlertOffer != null)
                  Container(
                    margin: const EdgeInsets.only(bottom: 18),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF0284C7), Color(0xFF0369A1)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF0284C7).withOpacity(0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.near_me_rounded, color: Colors.white, size: 22),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                isArabic
                                    ? "بالقرب من ${_nearbyProximityAlert!['brand_name']}! 🎉"
                                    : "Near ${_nearbyProximityAlert!['brand_name']}! 🎉",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13.5,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                isArabic
                                    ? "${_nearbyProximityAlert!['discount_tag']} متاح في فرع ${_nearbyProximityAlert!['branch']}"
                                    : "${_nearbyProximityAlert!['discount_tag']} active at ${_nearbyProximityAlert!['branch']}",
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.9),
                                  fontSize: 11.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => BrandDetailScreen(offer: _matchedAlertOffer!),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: const Color(0xFF0284C7),
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                            elevation: 0,
                          ),
                          child: Text(
                            isArabic ? "استخدام" : "Redeem",
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  ),

                // Dynamic Featured Banner Card
                if (_liveOffers.isNotEmpty)
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => BrandDetailScreen(offer: _liveOffers.first),
                        ),
                      );
                    },
                    child: Container(
                      height: 160,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.12),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            WafraImageWidget(
                              imageUrl: _liveOffers.first.bannerImageUrl.isNotEmpty
                                  ? _liveOffers.first.bannerImageUrl
                                  : "https://images.unsplash.com/photo-1544787219-7f47ccb76574?w=800",
                              fit: BoxFit.cover,
                              fallbackEmoji: _liveOffers.first.brandLogoEmoji,
                            ),
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.black.withOpacity(0.85),
                                    Colors.black.withOpacity(0.25),
                                  ],
                                  begin: Alignment.centerLeft,
                                  end: Alignment.centerRight,
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  DiscountBadge(offer: _liveOffers.first, fontSize: 11),
                                  const SizedBox(height: 6),
                                  Text(
                                    _liveOffers.first.brandName,
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                      height: 1.1,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    _liveOffers.first.subtitleText,
                                    style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.amber,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      isArabic ? "عرض الصفقة" : "View Deal >",
                                      style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.primaryBlue,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                else
                  Container(
                    height: 150,
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      gradient: const LinearGradient(
                        colors: [Color(0xFF0F172A), Color(0xFF1E3A8A)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.discountYellow,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            isArabic ? "مزايا وفرة" : "WAFRA PRIVILEGES",
                            style: const TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          isArabic ? "المنصة الرسمية\nلمزايا الموظفين" : "Official Ministry\nPrivileges Platform",
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            height: 1.15,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          isArabic ? "خصومات حصرية لموظفي الخدمة المدنية عبر المتاجر الشريكة" : "Exclusive civil service discounts across partner stores",
                          style: const TextStyle(fontSize: 11, color: Colors.white70),
                        ),
                      ],
                    ),
                  ),

                const SizedBox(height: 20),

                // Categories Row (Horizontal scroll)
                SizedBox(
                  height: 80,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: categoriesList.length,
                    itemBuilder: (context, index) {
                      final cat = categoriesList[index];
                      return InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => CategoriesScreen(initialCategory: cat),
                            ),
                          );
                        },
                        child: Container(
                          width: 70,
                          margin: const EdgeInsets.only(right: 12),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: cat.iconBgColor,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(cat.icon, color: AppColors.primaryBlue, size: 22),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                cat.localizedTitle.split(" ").first,
                                textAlign: TextAlign.center,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: textPrimary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 20),

                // "Featured Deals" Section Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      tr("featured_deals"),
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: textPrimary,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const AllDealsScreen(),
                          ),
                        );
                      },
                      child: Text(
                        tr("view_all"),
                        style: TextStyle(
                          color: textSecondary,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),

                // Featured Deals List Cards (Strictly live from DB)
                if (_isLoading)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 24.0),
                      child: CircularProgressIndicator(),
                    ),
                  )
                else if (_liveOffers.isEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
                    decoration: BoxDecoration(
                      color: cardBg,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: borderColor),
                    ),
                    child: Column(
                      children: [
                        Icon(Icons.storefront_outlined, size: 48, color: Colors.grey.shade400),
                        const SizedBox(height: 10),
                        Text(
                          tr("no_offers_found"),
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: textPrimary),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          isArabic ? "المتاجر التي يتم إنشاؤها ستظهر هنا فوراً." : "Offers added by partner stores will appear here immediately.",
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 12, color: textSecondary),
                        ),
                      ],
                    ),
                  )
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _liveOffers.length,
                    itemBuilder: (context, index) {
                      final offer = _liveOffers[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        elevation: 0,
                        color: cardBg,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: BorderSide(color: borderColor),
                        ),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => BrandDetailScreen(offer: offer),
                              ),
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Row(
                              children: [
                                WafraImageWidget(
                                  imageUrl: offer.brandLogoUrl,
                                  width: 80,
                                  height: 80,
                                  fit: BoxFit.cover,
                                  borderRadius: BorderRadius.circular(12),
                                  fallbackEmoji: offer.brandLogoEmoji,
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      DiscountBadge(offer: offer, fontSize: 10.5),
                                      const SizedBox(height: 4),
                                      Text(
                                        offer.brandName,
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                          color: textPrimary,
                                        ),
                                      ),
                                      Text(
                                        offer.subtitleText,
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: textSecondary,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        offer.expiresText,
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: textMuted,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                ListenableBuilder(
                                  listenable: RealTimeSyncService.instance,
                                  builder: (context, _) {
                                    final isFav = RealTimeSyncService.instance.isOfferSaved(offer.id);
                                    return IconButton(
                                      icon: Icon(
                                        isFav ? Icons.favorite : Icons.favorite_border,
                                        color: isFav ? AppColors.discountYellow : textMuted,
                                      ),
                                      onPressed: () {
                                        RealTimeSyncService.instance.toggleSave(offer.id);
                                      },
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),

                const SizedBox(height: 16),

                // "Top Merchants" Section Header (Only if real merchants exist)
                if (uniqueMerchants.isNotEmpty) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        tr("popular_brands"),
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: textPrimary,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const AllMerchantsScreen(),
                            ),
                          );
                        },
                        child: Text(
                          tr("view_all"),
                          style: TextStyle(
                            color: textSecondary,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),

                  // Top Merchants Circular Logos Horizontal List
                  SizedBox(
                    height: 60,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: uniqueMerchants.values.map((offer) {
                        return _MerchantCircleLogo(
                          imageUrl: offer.brandLogoUrl,
                          emojiFallback: offer.brandLogoEmoji,
                          name: offer.brandName,
                          offer: offer,
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MerchantCircleLogo extends StatelessWidget {
  final String imageUrl;
  final String emojiFallback;
  final String name;
  final OfferModel? offer;

  const _MerchantCircleLogo({
    required this.imageUrl,
    required this.emojiFallback,
    required this.name,
    this.offer,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (offer != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => BrandDetailScreen(offer: offer!),
            ),
          );
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const AllMerchantsScreen(),
            ),
          );
        }
      },
      child: Container(
        margin: const EdgeInsets.only(right: 14),
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.grey.shade300, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: WafraImageWidget(
          imageUrl: imageUrl,
          width: 52,
          height: 52,
          fit: BoxFit.cover,
          borderRadius: BorderRadius.circular(26),
          fallbackEmoji: emojiFallback,
        ),
      ),
    );
  }
}
