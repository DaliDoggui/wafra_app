import 'package:flutter/material.dart';
import '../../../core/localization/app_locale.dart';
import '../../../core/network/api_client.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/wafra_image_widget.dart';
import '../../../models/category_model.dart';
import '../../../models/offer_model.dart';
import '../../brand_detail/presentation/brand_detail_screen.dart';
import '../../../main.dart';

class MerchantItem {
  final String id;
  final String name;
  final String emoji;
  final String imageUrl;
  final String category;
  final String discountTag;
  final String branches;
  final String offerId;

  const MerchantItem({
    required this.id,
    required this.name,
    required this.emoji,
    required this.imageUrl,
    required this.category,
    required this.discountTag,
    required this.branches,
    required this.offerId,
  });
}

class AllMerchantsScreen extends StatefulWidget {
  const AllMerchantsScreen({super.key});

  @override
  State<AllMerchantsScreen> createState() => _AllMerchantsScreenState();
}

class _AllMerchantsScreenState extends State<AllMerchantsScreen> {
  String _searchQuery = "";
  String _selectedCategory = "All";
  List<MerchantItem> _merchants = [];
  List<OfferModel> _offers = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final merchantsData = await ApiClient.instance.getMerchants();
    final offers = await ApiClient.instance.getOffers();
    final List<MerchantItem> items = [];

    for (final m in merchantsData) {
      final mId = m["id"] ?? "";
      final defDisc = (m["default_discount"] as num?)?.toDouble() ?? 20.0;
      final specDisc = (m["special_discount"] as num?)?.toDouble() ?? 0.0;
      final allowMult = m["allow_multiple_discounts"] != false;
      String tag = "${defDisc.toInt()}% OFF";
      if (specDisc > 0) {
        final total = allowMult ? (defDisc + specDisc) : specDisc;
        tag = "🔥 ${total.toInt()}% OFF";
      } else if (m["discount_tag"] != null && m["discount_tag"].toString().isNotEmpty) {
        tag = m["discount_tag"].toString();
      }
      items.add(
        MerchantItem(
          id: mId,
          name: m["name"] ?? "Partner Store",
          emoji: m["emoji"] ?? "🏬",
          imageUrl: m["image_url"] ?? "",
          category: m["category"] ?? "Retail",
          discountTag: tag,
          branches: m["branches"] ?? m["address"] ?? "Kuwait",
          offerId: "deal_$mId",
        ),
      );
    }

    if (items.isEmpty && offers.isNotEmpty) {
      for (final o in offers) {
        items.add(
          MerchantItem(
            id: o.id,
            name: o.brandName,
            emoji: o.brandLogoEmoji,
            imageUrl: o.brandLogoUrl,
            category: o.categoryName,
            discountTag: o.discountTagText,
            branches: o.locationBranch,
            offerId: o.id,
          ),
        );
      }
    }

    if (mounted) {
      setState(() {
        _merchants = items;
        _offers = offers;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = themeModeNotifier.value == ThemeMode.dark;
    final bgColor = isDark ? const Color(0xFF0F172A) : AppColors.background;
    final cardBg = isDark ? const Color(0xFF1E293B) : Colors.white;
    final textCol = isDark ? Colors.white : AppColors.textPrimary;
    final textSecondary = isDark ? const Color(0xFF94A3B8) : AppColors.textSecondary;
    final borderColor = isDark ? const Color(0xFF334155) : Colors.grey.shade200;

    final filteredMerchants = _merchants.where((merchant) {
      if (_selectedCategory != "All") {
        final matchesCat = CategoryModel.matchFilter(
          _selectedCategory,
          categoryName: merchant.category,
          brandName: merchant.name,
        );
        if (!matchesCat) return false;
      }
      if (_searchQuery.isNotEmpty) {
        final q = _searchQuery.toLowerCase();
        final matches = merchant.name.toLowerCase().contains(q) ||
            merchant.category.toLowerCase().contains(q) ||
            merchant.branches.toLowerCase().contains(q);
        if (!matches) return false;
      }
      return true;
    }).toList();

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: cardBg,
        elevation: 0.5,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, size: 18, color: textCol),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          isArabic ? "المتاجر الشريكة" : "Partner Merchants",
          style: TextStyle(
            color: textCol,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Search Bar
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: borderColor),
                ),
                child: TextField(
                  style: TextStyle(color: textCol),
                  onChanged: (val) => setState(() => _searchQuery = val.trim()),
                  decoration: InputDecoration(
                    icon: Icon(Icons.search, color: textSecondary, size: 20),
                    hintText: isArabic ? "البحث في المتاجر والفروع..." : "Search partner shops or branches...",
                    hintStyle: TextStyle(fontSize: 13, color: textSecondary),
                    border: InputBorder.none,
                  ),
                ),
              ),
            ),

            // Category Chips (Horizontal)
            SizedBox(
              height: 48,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                children: [
                  _buildChip("All", isArabic ? "الكل" : "All", cardBg, borderColor, textCol),
                  _buildChip("Food", isArabic ? "مطاعم" : "Food", cardBg, borderColor, textCol),
                  _buildChip("Fashion", isArabic ? "أزياء" : "Fashion", cardBg, borderColor, textCol),
                  _buildChip("Electronics", isArabic ? "إلكترونيات" : "Electronics", cardBg, borderColor, textCol),
                  _buildChip("Beauty", isArabic ? "تجميل" : "Beauty", cardBg, borderColor, textCol),
                  _buildChip("Health", isArabic ? "صحة" : "Health", cardBg, borderColor, textCol),
                  _buildChip("Retail", isArabic ? "تسوق" : "Retail", cardBg, borderColor, textCol),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // Merchants List
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : filteredMerchants.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.storefront_outlined, size: 54, color: isDark ? Colors.grey.shade600 : Colors.grey.shade400),
                              const SizedBox(height: 12),
                              Text(
                                isArabic ? "لم يتم العثور على متاجر" : "No partner merchants found",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: textCol,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                isArabic ? "المتاجر المعتمدة ستظهر هنا فور إضافتها من لوحة التحكم." : "Approved partner stores will appear here immediately.",
                                textAlign: TextAlign.center,
                                style: TextStyle(fontSize: 12, color: textSecondary),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                          itemCount: filteredMerchants.length,
                          itemBuilder: (context, index) {
                            final merchant = filteredMerchants[index];

                            OfferModel matchingOffer;
                            try {
                              matchingOffer = _offers.firstWhere(
                                (o) => o.id == merchant.offerId || o.brandName.toLowerCase() == merchant.name.toLowerCase(),
                              );
                            } catch (_) {
                              matchingOffer = OfferModel(
                                id: merchant.offerId,
                                brandName: merchant.name,
                                brandLogoEmoji: merchant.emoji,
                                brandLogoUrl: merchant.imageUrl,
                                bannerImageUrl: merchant.imageUrl,
                                categoryId: merchant.category.toLowerCase(),
                                categoryName: merchant.category,
                                discountTagText: merchant.discountTag,
                                subtitleText: isArabic ? "خصم رسمي لموظفي الدولة" : "Official civil service discount",
                                expiresText: isArabic ? "ساري حتى 2028" : "Valid until 2028",
                                distanceText: isArabic ? "الكويت" : "Kuwait",
                                distanceMeters: 350,
                                locationBranch: merchant.branches,
                                description: isArabic ? "خصم حصري لموظفي الوزارات والجهات الحكومية." : "Official partner store privilege for ministry staff.",
                              );
                            }

                            return Card(
                              color: cardBg,
                              margin: const EdgeInsets.only(bottom: 12),
                              elevation: 0,
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
                                      builder: (_) => BrandDetailScreen(offer: matchingOffer),
                                    ),
                                  );
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(14.0),
                                  child: Row(
                                    children: [
                                      WafraImageWidget(
                                        imageUrl: merchant.imageUrl,
                                        width: 58,
                                        height: 58,
                                        fit: BoxFit.cover,
                                        borderRadius: BorderRadius.circular(12),
                                        fallbackEmoji: merchant.emoji,
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
                                                    merchant.name,
                                                    style: TextStyle(
                                                      fontSize: 15,
                                                      fontWeight: FontWeight.bold,
                                                      color: textCol,
                                                    ),
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                ),
                                                Container(
                                                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                                  decoration: BoxDecoration(
                                                    color: AppColors.discountYellow,
                                                    borderRadius: BorderRadius.circular(6),
                                                  ),
                                                  child: Text(
                                                    merchant.discountTag,
                                                    style: const TextStyle(
                                                      fontSize: 11,
                                                      fontWeight: FontWeight.bold,
                                                      color: Colors.black,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 3),
                                            Text(
                                              merchant.category,
                                              style: const TextStyle(
                                                fontSize: 12,
                                                color: AppColors.primaryBlue,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              merchant.branches,
                                              style: TextStyle(
                                                fontSize: 11,
                                                color: textSecondary,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Icon(
                                        isArabic ? Icons.arrow_back_ios : Icons.arrow_forward_ios,
                                        size: 14,
                                        color: textSecondary,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChip(String key, String displayTitle, Color cardBg, Color borderColor, Color textCol) {
    final isSelected = _selectedCategory == key;
    return GestureDetector(
      onTap: () => setState(() => _selectedCategory = key),
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryBlue : cardBg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primaryBlue : borderColor,
          ),
        ),
        child: Text(
          displayTitle,
          style: TextStyle(
            color: isSelected ? Colors.white : textCol,
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
