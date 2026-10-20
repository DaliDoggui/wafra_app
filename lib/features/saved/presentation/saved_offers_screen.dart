import 'package:flutter/material.dart';
import '../../../core/localization/app_locale.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/wafra_image_widget.dart';
import '../../../models/offer_model.dart';
import '../../../core/widgets/discount_badge.dart';
import '../../../services/realtime_sync_service.dart';
import '../../../main.dart';
import '../../brand_detail/presentation/brand_detail_screen.dart';

class SavedOffersScreen extends StatefulWidget {
  const SavedOffersScreen({super.key});

  @override
  State<SavedOffersScreen> createState() => _SavedOffersScreenState();
}

class _SavedOffersScreenState extends State<SavedOffersScreen> {
  String _searchQuery = "";

  @override
  void initState() {
    super.initState();
    RealTimeSyncService.instance.addListener(_onSyncChanged);
    RealTimeSyncService.instance.initialize();
  }

  @override
  void dispose() {
    RealTimeSyncService.instance.removeListener(_onSyncChanged);
    super.dispose();
  }

  void _onSyncChanged() {
    if (mounted) setState(() {});
  }

  List<OfferModel> get _savedOffers {
    final service = RealTimeSyncService.instance;
    return service.allOffers.where((o) => service.isOfferSaved(o.id)).toList();
  }

  void _toggleSave(OfferModel offer) async {
    await RealTimeSyncService.instance.toggleSave(offer.id);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isArabic
              ? "تمت إزالة ${offer.brandName} من العروض المحفوظة"
              : "Removed ${offer.brandName} from saved offers",
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = themeModeNotifier.value == ThemeMode.dark;
    final cardBg = isDark ? const Color(0xFF1E293B) : Colors.white;
    final borderColor = isDark ? const Color(0xFF334155) : Colors.grey.shade200;
    final textCol = isDark ? Colors.white : AppColors.textPrimary;
    final textSecondary = isDark ? const Color(0xFF94A3B8) : AppColors.textSecondary;

    final filtered = _savedOffers.where((o) {
      if (_searchQuery.isEmpty) return true;
      final q = _searchQuery.toLowerCase();
      return o.brandName.toLowerCase().contains(q) ||
          o.subtitleText.toLowerCase().contains(q) ||
          o.categoryName.toLowerCase().contains(q);
    }).toList();

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F172A) : AppColors.background,
      appBar: AppBar(
        backgroundColor: cardBg,
        elevation: 0.5,
        automaticallyImplyLeading: false,
        title: Text(
          tr("saved_offers"),
          style: TextStyle(
            color: textCol,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh_rounded, color: textCol),
            onPressed: () {
              RealTimeSyncService.instance.syncAll();
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Search Bar at Top
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: borderColor),
                ),
                child: TextField(
                  onChanged: (val) => setState(() => _searchQuery = val.trim()),
                  style: TextStyle(color: textCol),
                  decoration: InputDecoration(
                    icon: const Icon(Icons.search, color: AppColors.textMuted, size: 20),
                    hintText: tr("search_saved"),
                    hintStyle: const TextStyle(fontSize: 13, color: AppColors.textMuted),
                    border: InputBorder.none,
                  ),
                ),
              ),
            ),

            // Saved List
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async => RealTimeSyncService.instance.syncAll(),
                child: filtered.isEmpty
                    ? Center(
                        child: SingleChildScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.bookmark_border_rounded, size: 54, color: Colors.grey.shade400),
                              const SizedBox(height: 12),
                              Text(
                                tr("no_saved_offers"),
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: textCol,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                isArabic ? "اضغط على رمز القلب في أي عرض لحفظه هنا." : "Tap the heart icon on any deal to save it here.",
                                textAlign: TextAlign.center,
                                style: TextStyle(fontSize: 12, color: textSecondary),
                              ),
                            ],
                          ),
                        ),
                      )
                    : ListView.builder(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: filtered.length,
                        itemBuilder: (context, index) {
                          final offer = filtered[index];
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
                                          DiscountBadge(offer: offer, fontSize: 10),
                                          const SizedBox(height: 4),
                                          Text(
                                            offer.brandName,
                                            style: TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.bold,
                                              color: textCol,
                                            ),
                                          ),
                                          Text(
                                            offer.subtitleText,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: textSecondary,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            offer.expiresText,
                                            style: const TextStyle(
                                              fontSize: 11,
                                              color: AppColors.textMuted,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                          IconButton(
                                            icon: const Icon(Icons.favorite, color: Colors.red),
                                            onPressed: () => _toggleSave(offer),
                                            tooltip: isArabic ? 'إزالة من المحفوظات' : 'Remove from saved',
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
