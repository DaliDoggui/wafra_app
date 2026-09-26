import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../models/category_model.dart';
import '../../../models/offer_model.dart';
import '../../brand_detail/presentation/brand_detail_screen.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  CategoryModel? selectedCategory;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: selectedCategory != null
            ? IconButton(
                icon: const Icon(Icons.arrow_back_ios, size: 18, color: AppColors.textPrimary),
                onPressed: () => setState(() => selectedCategory = null),
              )
            : const SizedBox(),
        title: Text(
          selectedCategory == null ? "Categories" : selectedCategory!.title,
          style: const TextStyle(
            color: AppColors.textPrimary,
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
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: TextField(
                  decoration: InputDecoration(
                    icon: const Icon(Icons.search, color: AppColors.textMuted, size: 20),
                    hintText: selectedCategory == null
                        ? "Search for categories..."
                        : "Search for store....",
                    hintStyle: const TextStyle(fontSize: 13, color: AppColors.textMuted),
                    border: InputBorder.none,
                  ),
                ),
              ),
            ),

            // Content List
            Expanded(
              child: selectedCategory == null
                  ? _buildCategoryList()
                  : _buildSubCategoryOffersList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: categoriesList.length,
      itemBuilder: (context, index) {
        final cat = categoriesList[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 10),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: BorderSide(color: Colors.grey.shade200),
          ),
          child: ListTile(
            onTap: () {
              setState(() => selectedCategory = cat);
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
              cat.title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: AppColors.textPrimary,
              ),
            ),
            subtitle: Text(
              cat.subtitle,
              style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
            ),
            trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: AppColors.textMuted),
          ),
        );
      },
    );
  }

  Widget _buildSubCategoryOffersList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: dummyOffersList.length,
      itemBuilder: (context, index) {
        final offer = dummyOffersList[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: Colors.grey.shade200),
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
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      width: 85,
                      height: 85,
                      color: Colors.amber.shade50,
                      child: Center(
                        child: Text(offer.brandLogoEmoji, style: const TextStyle(fontSize: 40)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.discountYellow,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            offer.discountTagText,
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          offer.brandName,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          offer.subtitleText,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
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
