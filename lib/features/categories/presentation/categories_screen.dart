import 'package:flutter/material.dart';
import '../../../core/localization/app_locale.dart';
import '../../../core/network/api_client.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/discount_badge.dart';
import '../../../core/widgets/wafra_image_widget.dart';
import '../../../models/category_model.dart';
import '../../../models/offer_model.dart';
import '../../brand_detail/presentation/brand_detail_screen.dart';
import '../../../main.dart';

class CategoriesScreen extends StatefulWidget {
  final CategoryModel? initialCategory;

  const CategoriesScreen({super.key, this.initialCategory});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  CategoryModel? selectedCategory;
  List<OfferModel> _liveOffers = [];
  bool _isLoading = true;
  String _searchQuery = "";

  @override
  void initState() {
    super.initState();
    selectedCategory = widget.initialCategory;
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
    final cardBg = isDark ? const Color(0xFF1E293B) : Colors.white;
    final borderColor = isDark ? const Color(0xFF334155) : Colors.grey.shade200;
    final textCol = isDark ? Colors.white : AppColors.textPrimary;
    final canPopRoute = Navigator.canPop(context);

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F172A) : AppColors.background,
      appBar: AppBar(
        backgroundColor: cardBg,
        elevation: 0.5,
        leading: selectedCategory != null
            ? IconButton(
                icon: Icon(Icons.arrow_back_ios, size: 18, color: textCol),
                onPressed: () {
                  if (widget.initialCategory != null && canPopRoute) {
                    Navigator.pop(context);
                  } else {
                    setState(() => selectedCategory = null);
                  }
                },
              )
            : (canPopRoute
                ? IconButton(
                    icon: Icon(Icons.arrow_back_ios, size: 18, color: textCol),
                    onPressed: () => Navigator.pop(context),
                  )
                : const SizedBox()),
        title: Text(
          selectedCategory == null ? tr("categories") : selectedCategory!.localizedTitle,
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
                  onChanged: (val) => setState(() => _searchQuery = val.trim().toLowerCase()),
                  style: TextStyle(color: textCol),
                  decoration: InputDecoration(
                    icon: const Icon(Icons.search, color: AppColors.textMuted, size: 20),
                    hintText: selectedCategory == null
                        ? (isArabic ? "ابحث في التصنيفات..." : "Search categories...")
                        : (isArabic
                            ? "ابحث في عروض ${selectedCategory!.localizedTitle}..."
                            : "Search offers in ${selectedCategory!.localizedTitle}..."),
                    hintStyle: const TextStyle(fontSize: 13, color: AppColors.textMuted),
                    border: InputBorder.none,
                  ),
                ),
              ),
            ),

            // Content List
            Expanded(
              child: selectedCategory == null
                  ? _buildCategoryList(isDark, cardBg, borderColor, textCol)
                  : _buildSubCategoryOffersList(isDark, cardBg, borderColor, textCol),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryList(bool isDark, Color cardBg, Color borderColor, Color textCol) {
    final filteredCategories = _searchQuery.isEmpty
        ? categoriesList
        : categoriesList.where((c) =>
            c.title.toLowerCase().contains(_searchQuery) ||
            c.titleAr.toLowerCase().contains(_searchQuery) ||
            c.subtitle.toLowerCase().contains(_searchQuery) ||
            c.subtitleAr.toLowerCase().contains(_searchQuery)).toList();

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: filteredCategories.length,
      itemBuilder: (context, index) {
        final cat = filteredCategories[index];
        return Card(
          color: cardBg,
          margin: const EdgeInsets.only(bottom: 10),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: BorderSide(color: borderColor),
          ),
          child: ListTile(
            onTap: () {
              setState(() {
                selectedCategory = cat;
                _searchQuery = "";
              });
            },
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: cat.iconBgColor,
                shape: BoxShape.circle,
              ),
              child: Icon(cat.icon, color: AppColors.primaryBlue, size: 20),
            ),
            title: Text(
              cat.localizedTitle,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: textCol,
              ),
            ),
            subtitle: Text(
              cat.localizedSubtitle,
              style: TextStyle(fontSize: 11, color: isDark ? Colors.white60 : AppColors.textSecondary),
            ),
            trailing: Icon(isArabic ? Icons.arrow_back_ios : Icons.arrow_forward_ios, size: 14, color: AppColors.textMuted),
          ),
        );
      },
    );
  }

  Widget _buildSubCategoryOffersList(bool isDark, Color cardBg, Color borderColor, Color textCol) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final cat = selectedCategory;
    final offers = _liveOffers.where((o) {
      final matchesCat = cat != null && cat.matchesOffer(
        categoryId: o.categoryId,
        categoryName: o.categoryName,
        brandName: o.brandName,
      );
      final matchesSearch = _searchQuery.isEmpty ||
          o.brandName.toLowerCase().contains(_searchQuery) ||
          o.subtitleText.toLowerCase().contains(_searchQuery);
      return matchesCat && matchesSearch;
    }).toList();

    // STRICT: Each brand must stick with its category! Never fallback to _liveOffers
    final displayOffers = offers;

    if (displayOffers.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E293B) : Colors.grey.shade100,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  cat?.icon ?? Icons.category_outlined,
                  size: 44,
                  color: isDark ? Colors.grey.shade500 : Colors.grey.shade400,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                isArabic ? "لا توجد عروض مضافة لهذا التصنيف حالياً" : "No offers available in this category yet",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: textCol,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 6),
              Text(
                isArabic
                    ? "سيتم إضافة عروض جديدة من المتاجر الشريكة قريباً"
                    : "New partner merchant offers will be listed here soon.",
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? Colors.white60 : AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: displayOffers.length,
      itemBuilder: (context, index) {
        final offer = displayOffers[index];
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
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? Colors.white60 : AppColors.textSecondary,
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
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
