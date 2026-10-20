import 'package:flutter/material.dart';
import '../../../core/localization/app_locale.dart';
import '../../../core/network/api_client.dart';
import '../../../core/theme/app_colors.dart';
import '../../../models/offer_model.dart';
import '../../../services/location_service.dart';


import '../../brand_detail/presentation/brand_detail_screen.dart';
import '../../../main.dart';

class _NotifItem {
  final String title;
  final String body;
  final String timeAgo;
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final OfferModel? linkedOffer;
  bool isRead;

  _NotifItem({
    required this.title,
    required this.body,
    required this.timeAgo,
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    this.linkedOffer,
    this.isRead = false,
  });
}

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final List<_NotifItem> _notifications = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadLiveNotifications();
  }

  Future<void> _loadLiveNotifications() async {
    // 1. Sync GPS location with backend geofencing engine to detect in-range deals
    await LocationService().syncLocationWithBackend();

    final offers = await ApiClient.instance.getOffers();
    final redemptions = await ApiClient.instance.getMyRedemptions();
    final dbNotifications = await ApiClient.instance.getUserNotifications();



    final List<_NotifItem> items = [];

    // Map offers by ID for linking
    final offersMap = <String, OfferModel>{};
    for (final o in offers) {
      offersMap[o.id] = o;
    }

    // A. Real DB Geofence Proximity & Alert Notifications
    for (final n in dbNotifications) {
      final rawTitle = n["title"]?.toString() ?? "";
      final rawBody = n["body"]?.toString() ?? "";
      final brand = n["brand_name"]?.toString() ?? "";
      final isRead = n["is_read"] == true;
      final offerId = n["offer_id"]?.toString();
      final linkedOffer = offerId != null ? offersMap[offerId] : null;

      String displayTitle = rawTitle.isNotEmpty ? rawTitle : (isArabic ? "ØªÙ†Ø¨ÙŠÙ‡ Ø§Ù‚ØªØ±Ø§Ø¨ Ù…Ù† Ù…ØªØ¬Ø± ðŸ“" : "Proximity Alert ðŸ“");
      String displayBody = rawBody;

      if (isArabic) {
        if (rawTitle.contains("You're near") || rawTitle.contains("near") || rawTitle.contains("Proximity")) {
          displayTitle = "ðŸ“ Ø£Ù†Øª Ø¨Ø§Ù„Ù‚Ø±Ø¨ Ù…Ù† ${brand.isNotEmpty ? brand : (linkedOffer?.brandName ?? 'Ù…ØªØ¬Ø± Ø´Ø±ÙŠÙƒ')}!";
        } else if (rawTitle.contains("Deal") || rawTitle.contains("Offer") || rawTitle.contains("Drop")) {
          displayTitle = "ðŸ”¥ Ø¹Ø±Ø¶ Ø¬Ø¯ÙŠØ¯ Ù…Ù† ${brand.isNotEmpty ? brand : (linkedOffer?.brandName ?? 'Ù…ØªØ¬Ø± Ø´Ø±ÙŠÙƒ')}!";
        }

        if (rawBody.contains("Exclusive") || rawBody.contains("Tap to redeem") || rawBody.contains("available at")) {
          displayBody = "Ø®ØµÙ… Ø­ØµØ±ÙŠ Ù…ØªØ§Ø­ Ø§Ù„Ø¢Ù†. Ø§Ø¶ØºØ· Ù„ÙØªØ­ Ø±Ù…Ø² Ø§Ù„Ù‚Ø³ÙŠÙ…Ø© Ø¨Ø§Ù„Ø±Ù‚Ù… Ø§Ù„ÙˆØ¸ÙŠÙÙŠ!";
        } else if (rawBody.contains("launched") || rawBody.contains("discount")) {
          displayBody = "ØªÙ… Ø¥Ø·Ù„Ø§Ù‚ Ø®ØµÙ… Ø¬Ø¯ÙŠØ¯ Ù„Ù…ÙˆØ¸ÙÙŠ Ø§Ù„Ø¯ÙˆÙ„Ø©. Ø§Ø¶ØºØ· Ù„Ù„Ø§Ø·Ù„Ø§Ø¹ Ø¹Ù„Ù‰ Ø§Ù„ØªÙØ§ØµÙŠÙ„!";
        }
      }

      items.add(
        _NotifItem(
          title: displayTitle,
          body: displayBody,
          timeAgo: isArabic ? "ØªÙ†Ø¨ÙŠÙ‡ Ø§Ù‚ØªØ±Ø§Ø¨ ðŸ“" : "Proximity Alert ðŸ“",
          icon: Icons.location_on_rounded,
          iconColor: const Color(0xFFE11D48),
          iconBg: const Color(0xFFFFE4E6),
          linkedOffer: linkedOffer,
          isRead: isRead,
        ),
      );
    }

    // B. Real redemption receipts from DB
    for (final r in redemptions) {
      final brand = r["brand_name"] ?? (isArabic ? "Ø§Ù„Ù…ØªØ¬Ø± Ø§Ù„Ø´Ø±ÙŠÙƒ" : "Partner Brand");
      final saved = (r["amount_saved_kd"] as num?)?.toDouble() ?? 0.0;
      final dateStr = r["redeemed_at"];
      String timeAgo = isArabic ? "Ù…Ø¤Ø®Ø±Ø§Ù‹" : "Recently";
      if (dateStr != null) {
        final dt = DateTime.tryParse(dateStr);
        if (dt != null) {
          final diff = DateTime.now().difference(dt);
          if (diff.inMinutes < 60) {
            timeAgo = isArabic ? "Ù…Ù†Ø° ${diff.inMinutes} Ø¯Ù‚ÙŠÙ‚Ø©" : "${diff.inMinutes}m ago";
          } else if (diff.inHours < 24) {
            timeAgo = isArabic ? "Ù…Ù†Ø° ${diff.inHours} Ø³Ø§Ø¹Ø©" : "${diff.inHours}h ago";
          } else {
            timeAgo = isArabic ? "Ù…Ù†Ø° ${diff.inDays} ÙŠÙˆÙ…" : "${diff.inDays}d ago";
          }
        }
      }

      items.add(
        _NotifItem(
          title: isArabic ? "ØªÙ… Ø§Ø³ØªØ®Ø¯Ø§Ù… Ø§Ù„Ø®ØµÙ… ÙÙŠ $brand âœ…" : "Discount Redeemed at $brand âœ…",
          body: isArabic
              ? "ØªÙ… ØªØ£ÙƒÙŠØ¯ Ø±Ù…Ø² Ø®ØµÙ… ÙˆÙØ±Ø© ÙÙŠ $brand. ÙˆÙÙ‘Ø±Øª ${saved.toStringAsFixed(3)} Ø¯.Ùƒ!"
              : "Your Wafra privilege code was validated at $brand. You saved ${saved.toStringAsFixed(3)} KD!",
          timeAgo: timeAgo,
          icon: Icons.check_circle_rounded,
          iconColor: AppColors.greenSuccess,
          iconBg: const Color(0xFFDCFCE7),
          isRead: false,
        ),
      );
    }

    // Only real notifications from DB and verified shop redemptions are displayed

    if (mounted) {
      setState(() {
        _notifications.clear();
        _notifications.addAll(items);
        _isLoading = false;
      });
    }
  }

  int get _unreadCount => _notifications.where((n) => !n.isRead).length;

  void _markAllRead() {
    setState(() {
      for (final n in _notifications) {
        n.isRead = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = themeModeNotifier.value == ThemeMode.dark;
    final bgColor = isDark ? const Color(0xFF0F172A) : AppColors.background;
    final cardBg = isDark ? const Color(0xFF1E293B) : Colors.white;
    final textCol = isDark ? Colors.white : AppColors.textPrimary;
    final textMutedCol = isDark ? const Color(0xFF94A3B8) : AppColors.textSecondary;
    final borderColor = isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: cardBg,
        elevation: 0.5,
        leading: Navigator.canPop(context)
            ? IconButton(
                icon: Icon(Icons.arrow_back_ios_rounded, color: textCol, size: 20),
                onPressed: () => Navigator.pop(context),
              )
            : null,
        title: Row(
          children: [
            Text(
              isArabic ? "Ø§Ù„Ø¥Ø´Ø¹Ø§Ø±Ø§Øª" : "Notifications",
              style: TextStyle(
                color: textCol,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            if (_unreadCount > 0) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  "$_unreadCount",
                  style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh_rounded, color: textCol),
            onPressed: () {
              setState(() => _isLoading = true);
              _loadLiveNotifications();
            },
          ),
          if (_unreadCount > 0)
            TextButton(
              onPressed: _markAllRead,
              child: Text(
                isArabic ? "ØªØ­Ø¯ÙŠØ¯ Ø§Ù„ÙƒÙ„ ÙƒÙ…Ù‚Ø±ÙˆØ¡" : "Mark all read",
                style: const TextStyle(color: AppColors.primaryBlue, fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ),
        ],
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                onRefresh: _loadLiveNotifications,
                child: _notifications.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.notifications_none_rounded, size: 54, color: isDark ? Colors.grey.shade600 : Colors.grey.shade400),
                            const SizedBox(height: 12),
                            Text(
                              isArabic ? "Ù„Ø§ ØªÙˆØ¬Ø¯ Ø¥Ø´Ø¹Ø§Ø±Ø§Øª Ø­Ø§Ù„ÙŠØ§Ù‹" : "No notifications right now",
                              style: TextStyle(color: textMutedCol, fontSize: 15, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        itemCount: _notifications.length,
                        separatorBuilder: (context, index) => Divider(height: 1, indent: 72, endIndent: 16, color: borderColor),
                        itemBuilder: (context, index) {
                          final item = _notifications[index];
                          return InkWell(
                            onTap: () {
                              setState(() => item.isRead = true);
                              if (item.linkedOffer != null) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => BrandDetailScreen(offer: item.linkedOffer!),
                                  ),
                                );
                              }
                            },
                            child: Container(
                              color: item.isRead
                                  ? Colors.transparent
                                  : (isDark ? AppColors.primaryBlue.withOpacity(0.12) : Colors.blue.withOpacity(0.04)),
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: 44,
                                    height: 44,
                                    decoration: BoxDecoration(
                                      color: isDark ? item.iconBg.withOpacity(0.25) : item.iconBg,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(item.icon, color: item.iconColor, size: 22),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Expanded(
                                              child: Text(
                                                item.title,
                                                style: TextStyle(
                                                  fontWeight: item.isRead ? FontWeight.w600 : FontWeight.bold,
                                                  fontSize: 14,
                                                  color: textCol,
                                                ),
                                              ),
                                            ),
                                            Text(
                                              item.timeAgo,
                                              style: TextStyle(fontSize: 11, color: isDark ? Colors.grey.shade400 : AppColors.textMuted),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          item.body,
                                          style: TextStyle(
                                            fontSize: 12.5,
                                            color: textMutedCol,
                                            height: 1.35,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (!item.isRead) ...[
                                    const SizedBox(width: 8),
                                    Container(
                                      width: 8,
                                      height: 8,
                                      margin: const EdgeInsets.only(top: 6),
                                      decoration: const BoxDecoration(
                                        color: AppColors.primaryBlue,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
      ),
    );
  }
}
