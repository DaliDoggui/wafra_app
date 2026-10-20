import 'package:flutter/material.dart';
import '../core/localization/app_locale.dart';

class CategoryModel {
  final String id;
  final String title;
  final String titleAr;
  final String subtitle;
  final String subtitleAr;
  final IconData icon;
  final Color iconBgColor;

  const CategoryModel({
    required this.id,
    required this.title,
    required this.titleAr,
    required this.subtitle,
    required this.subtitleAr,
    required this.icon,
    required this.iconBgColor,
  });

  String get localizedTitle => isArabic ? titleAr : title;
  String get localizedSubtitle => isArabic ? subtitleAr : subtitle;

  /// Checks if an offer/brand belongs to THIS category.
  /// Strict: Food/Cafe brands will NEVER match Fashion, Electronics, etc.
  bool matchesOffer({String? categoryId, String? categoryName, String? brandName}) {
    final cId = (categoryId ?? "").toLowerCase().trim();
    final cName = (categoryName ?? "").toLowerCase().trim();
    final bName = (brandName ?? "").toLowerCase().trim();

    // Direct ID match
    if (cId == id.toLowerCase()) return true;

    // Check by category ID
    switch (id) {
      case "cat_food":
        if (cId == "cat_food" || cId == "food" || cId.contains("caf") || cId.contains("bakery")) return true;
        const foodKeywords = [
          "food", "beverage", "beverages", "drink", "drinks",
          "café", "cafe", "coffee", "tea", "bakery", "bakeries",
          "restaurant", "restaurants", "dining", "gourmet",
          "groceries", "grocery", "supermarket", "snack", "sweet", "sweets",
          "fast food", "burger", "pizza",
          "مطاعم", "مأكولات", "مقهى", "مقاهي", "كافيه", "قهوة", "مخبز", "مخابز", "سوبرماركت", "حلويات", "وجبات"
        ];
        final matchesByTerm = foodKeywords.any((k) => cName.contains(k) || cId.contains(k));
        final matchesByBrand = bName.contains("café") ||
            bName.contains("cafe") ||
            bName.contains("coffee") ||
            bName.contains("bakery") ||
            bName.contains("burger") ||
            bName.contains("restaurant");
        return matchesByTerm || matchesByBrand;

      case "cat_fashion":
        if (cId == "cat_fashion" || cId == "fashion") return true;
        // Strictly exclude food/drinks/cafes from fashion
        if (_isFoodRelated(cId, cName, bName)) return false;
        const fashionKeywords = [
          "fashion", "clothing", "clothes", "apparel", "shoes", "footwear",
          "accessories", "accessory", "jewelry", "bag", "bags", "boutique", "dress",
          "أزياء", "موضة", "ملابس", "أحذية", "إكسسوارات"
        ];
        return fashionKeywords.any((k) => cName.contains(k) || cId.contains(k));

      case "cat_electronics":
        if (cId == "cat_electronics" || cId == "electronics") return true;
        // Strictly exclude food/drinks/cafes from electronics
        if (_isFoodRelated(cId, cName, bName)) return false;
        const elecKeywords = [
          "electronics", "electronic", "tech", "technology", "phone", "phones",
          "smartphone", "smartphones", "laptop", "laptops", "computer", "computers",
          "gadget", "gadgets", "device", "devices", "mobile", "mobiles", "audio",
          "إلكترونيات", "أجهزة", "هواتف", "حواسيب", "تقنية", "جوال"
        ];
        return elecKeywords.any((k) => cName.contains(k) || cId.contains(k));

      case "cat_beauty":
        if (cId == "cat_beauty" || cId == "beauty") return true;
        if (_isFoodRelated(cId, cName, bName)) return false;
        const beautyKeywords = [
          "beauty", "health", "healthcare", "cosmetics", "cosmetic", "skincare",
          "makeup", "wellness", "spa", "salon", "pharmacy", "perfume", "fragrance",
          "optical", "optics", "clinic", "dental",
          "صحة", "جمال", "تجميل", "عناية", "مستحضرات", "عطور", "صيدلية", "بصريات"
        ];
        return beautyKeywords.any((k) => cName.contains(k) || cId.contains(k));

      case "cat_travel":
        if (cId == "cat_travel" || cId == "travel") return true;
        if (_isFoodRelated(cId, cName, bName)) return false;
        const travelKeywords = [
          "travel", "leisure", "hotel", "hotels", "flight", "flights", "airline",
          "resort", "tourism", "vacation", "trip", "entertainment", "cinema", "family", "park",
          "سفر", "سياحة", "فنادق", "طيران", "ترفيه", "سينما"
        ];
        return travelKeywords.any((k) => cName.contains(k) || cId.contains(k));

      case "cat_home":
        if (cId == "cat_home" || cId == "home") return true;
        if (_isFoodRelated(cId, cName, bName)) return false;
        const homeKeywords = [
          "home", "living", "furniture", "decor", "decoration", "appliance", "appliances",
          "kitchen", "interior", "bedding",
          "منزل", "ديكور", "أثاث", "مفروشات"
        ];
        return homeKeywords.any((k) => cName.contains(k) || cId.contains(k));

      case "cat_sports":
        if (cId == "cat_sports" || cId == "sports") return true;
        if (_isFoodRelated(cId, cName, bName)) return false;
        const sportsKeywords = [
          "sports", "sport", "fitness", "gym", "workout", "athletic", "outdoors", "crossfit",
          "رياضة", "لياقة", "نوادي", "جيم"
        ];
        return sportsKeywords.any((k) => cName.contains(k) || cId.contains(k));

      case "cat_services":
        if (cId == "cat_services" || cId == "services") return true;
        if (_isFoodRelated(cId, cName, bName)) return false;
        const servicesKeywords = [
          "services", "service", "automotive", "auto", "fuel", "car", "gas",
          "education", "school", "finance", "banking", "insurance", "consulting",
          "خدمات", "سيارات", "وقود", "تعليم", "مالية"
        ];
        return servicesKeywords.any((k) => cName.contains(k) || cId.contains(k));

      default:
        return cId == id.toLowerCase() || cName.contains(title.toLowerCase());
    }
  }

  static bool _isFoodRelated(String cId, String cName, String bName) {
    const foodTerms = [
      "food", "beverage", "café", "cafe", "coffee", "bakery", "restaurant",
      "dining", "gourmet", "groceries", "supermarket", "fast food", "burger",
      "مطاعم", "مأكولات", "مقهى", "كافيه", "قهوة", "مخبز", "حلويات", "وجبات", "سوبرماركت"
    ];
    return foodTerms.any((t) => cId.contains(t) || cName.contains(t) || bName.contains(t));
  }

  /// Global matcher for chips / category tabs
  static bool matchFilter(String filter, {String? categoryId, String? categoryName, String? brandName}) {
    final clean = filter.trim().toLowerCase();
    if (clean.isEmpty || clean == "all" || clean == "الكل") {
      return true;
    }
    // Find the category that corresponds to the filter string
    CategoryModel? target;
    for (final c in categoriesList) {
      final cShort = c.id.replaceFirst("cat_", "").toLowerCase();
      if (c.id.toLowerCase() == clean ||
          cShort == clean ||
          c.title.toLowerCase().contains(clean) ||
          c.titleAr.toLowerCase().contains(clean) ||
          clean.contains(cShort) ||
          clean.contains(c.title.toLowerCase())) {
        target = c;
        break;
      }
    }

    if (target == null) {
      for (final c in categoriesList) {
        if (c.matchesOffer(categoryId: clean, categoryName: clean, brandName: clean)) {
          target = c;
          break;
        }
      }
    }

    if (target == null) return false;

    return target.matchesOffer(
      categoryId: categoryId,
      categoryName: categoryName,
      brandName: brandName,
    );
  }
}

final List<CategoryModel> categoriesList = [
  const CategoryModel(
    id: "cat_food",
    title: "Food & Beverages",
    titleAr: "المطاعم والمأكولات",
    subtitle: "Restaurants, Cafés, Groceries...",
    subtitleAr: "مطاعم، مقاهي، سوبرماركت...",
    icon: Icons.fastfood_outlined,
    iconBgColor: Color(0xFFE0F2FE),
  ),
  const CategoryModel(
    id: "cat_fashion",
    title: "Fashion",
    titleAr: "الأزياء والموضة",
    subtitle: "Clothing, Shoes, Accessories...",
    subtitleAr: "ملابس، أحذية، إكسسوارات...",
    icon: Icons.checkroom_outlined,
    iconBgColor: Color(0xFFFCE7F3),
  ),
  const CategoryModel(
    id: "cat_electronics",
    title: "Electronics",
    titleAr: "الإلكترونيات والأجهزة",
    subtitle: "Phones, Laptops, Gadgets...",
    subtitleAr: "هواتف، حواسيب، أجهزة ذكية...",
    icon: Icons.devices_outlined,
    iconBgColor: Color(0xFFFEF3C7),
  ),
  const CategoryModel(
    id: "cat_beauty",
    title: "Beauty & Health",
    titleAr: "الصحة والجمال",
    subtitle: "Skincare, Cosmetics, Wellness...",
    subtitleAr: "عناية بالبشرة، مستحضرات، نوادي صحية...",
    icon: Icons.spa_outlined,
    iconBgColor: Color(0xFFDCFCE7),
  ),
  const CategoryModel(
    id: "cat_travel",
    title: "Travel & Leisure",
    titleAr: "السفر والترفيه",
    subtitle: "Flight, Hotels, Activities...",
    subtitleAr: "طيران، فنادق، فعاليات ترفيهية...",
    icon: Icons.flight_takeoff_outlined,
    iconBgColor: Color(0xFFE0E7FF),
  ),
  const CategoryModel(
    id: "cat_home",
    title: "Home & Living",
    titleAr: "المنزل والديكور",
    subtitle: "Furniture, Decor, appliances...",
    subtitleAr: "أثاث، ديكور، أجهزة منزلية...",
    icon: Icons.weekend_outlined,
    iconBgColor: Color(0xFFF3E8FF),
  ),
  const CategoryModel(
    id: "cat_sports",
    title: "Sports & Outdoors",
    titleAr: "الرياضة واللياقة",
    subtitle: "Fitness, Gear, Equipment...",
    subtitleAr: "نوادي لياقة، معدات، ملابس رياضية...",
    icon: Icons.sports_soccer_outlined,
    iconBgColor: Color(0xFFFFEDD5),
  ),
  const CategoryModel(
    id: "cat_services",
    title: "Services",
    titleAr: "الخدمات العامة",
    subtitle: "Education, Finance, more...",
    subtitleAr: "تعليم، خدمات مالية، استشارات...",
    icon: Icons.school_outlined,
    iconBgColor: Color(0xFFF1F5F9),
  ),
];

