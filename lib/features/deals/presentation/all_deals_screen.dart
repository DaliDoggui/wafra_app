import 'package:flutter/material.dart';
import '../../../core/localization/app_locale.dart';
import '../../../core/network/api_client.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/wafra_image_widget.dart';
import '../../../core/widgets/discount_badge.dart';
import '../../../models/category_model.dart';
import '../../../models/offer_model.dart';
import '../../brand_detail/presentation/brand_detail_screen.dart';
import '../../../main.dart';

class AllDealsScreen extends StatefulWidget {
  final String? initialCategoryFilter;

  const AllDealsScreen({super.key, this.initialCategoryFilter});

  @override
  State<AllDealsScreen> createState() => _AllDealsScreenState();
}

class _AllDealsScreenState extends State<AllDealsScreen> {
  String _searchQuery = "";
  String _selectedCategory = "All";
  final Set<String> _savedOfferIds = {};
  List<OfferModel> _liveOffers = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    if (widget.initialCategoryFilter != null) {
      _selectedCategory = widget.initialCategoryFilter!;
    }
    _loadLiveOffers();
  }

  Future<void> _loadLiveOffers() async {
    final offers = await ApiClient.instance.getOffers();
    if (mounted) {
      setState(() {
        _liveOffers = offers;
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
    final textMutedCol = isDark ? const Color(0xFF94A3B8) : AppColors.textSecondary;
    final borderColor = isDark ? const Color(0xFF334155) : Colors.grey.shade200;

    final filteredOffers = _liveOffers.where((offer) {
      // Category filter
      if (_selectedCategory != "All") {
        final matchesCat = CategoryModel.matchFilter(
          _selectedCategory,
          categoryId: offer.categoryId,
          categoryName: offer.categoryName,
          brandName: offer.brandName,
        );
        if (!matchesCat) return false;
      }
      // Search filter
      if (_searchQuery.isNotEmpty) {
        final q = _searchQuery.toLowerCase();
        final matchesSearch = offer.brandName.toLowerCase().contains(q) ||
            offer.subtitleText.toLowerCase().contains(q) ||
            offer.discountTagText.toLowerCase().contains(q);
        if (!matchesSearch) return false;
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
          isArabic ? "جميع العروض" : "All Deals",
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
                    icon: Icon(Icons.search, color: textMutedCol, size: 20),
                    hintText: isArabic ? "البحث في جميع العروض والمتاجر..." : "Search all deals, brands...",
                    hintStyle: TextStyle(fontSize: 13, color: textMutedCol),
                    border: InputBorder.none,
                  ),
                ),
              ),
            ),

            // Horizontal Filter Chips
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
                  _buildChip("Travel", isArabic ? "سياحة" : "Travel", cardBg, borderColor, textCol),
                  _buildChip("Sports", isArabic ? "رياضة" : "Sports", cardBg, borderColor, textCol),
                ],
              ),
            ),

            const SizedBox(height: 4),

            // Deals Count Summary
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    isArabic
                        ? "${filteredOffers.length} عروض متوفرة"
                        : "${filteredOffers.length} Deals Available",
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: textMutedCol,
                    ),
                  ),
                  Text(
                    isArabic ? "الترتيب: الأكثر طلباً" : "Sorted by: Popular",
                    style: TextStyle(
                      fontSize: 12,
                      color: textMutedCol,
                    ),
                  ),
                ],
              ),
            ),

            // Offers List
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : filteredOffers.isEmpty
                      ? Center(
                          child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.search_off_rounded, size: 48, color: isDark ? Colors.grey.shade600 : Colors.grey.shade400),
                          const SizedBox(height: 12),
                          Text(
                            isArabic ? "لم يتم العثور على عروض" : "No deals found",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: textCol,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            isArabic ? "جرب البحث بكلمة أو تصنيف آخر" : "Try searching for another keyword or category",
                            style: TextStyle(fontSize: 12, color: textMutedCol),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      itemCount: filteredOffers.length,
                      itemBuilder: (context, index) {
                        final offer = filteredOffers[index];
                        final isFav = _savedOfferIds.contains(offer.id);

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
                                    width: 85,
                                    height: 85,
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
                                        const SizedBox(height: 5),
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
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: textMutedCol,
                                          ),
                                        ),
                                        const SizedBox(height: 3),
                                        Text(
                                          offer.expiresText,
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: textMutedCol,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  IconButton(
                                    icon: Icon(
                                      isFav ? Icons.favorite : Icons.favorite_border,
                                      color: isFav ? Colors.red : Colors.grey,
                                      size: 22,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        if (isFav) {
                                          _savedOfferIds.remove(offer.id);
                                        } else {
                                          _savedOfferIds.add(offer.id);
                                        }
                                      });
                                    },
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
