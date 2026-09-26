class OfferModel {
  final String id;
  final String brandName;
  final String brandLogoEmoji;
  final String bannerImageUrl;
  final String categoryId;
  final String categoryName;
  final String discountTagText; // e.g. "40% OFF!" or "60% OFF!"
  final String subtitleText;     // e.g. "Up To 40% Off"
  final String expiresText;      // e.g. "Expires In 6 Days"
  final String distanceText;     // e.g. "140m Away. Estimated 2 Min Walk."
  final double distanceMeters;
  final String locationBranch;   // e.g. "Available At All Branches"
  final String description;
  final bool isSaved;

  const OfferModel({
    required this.id,
    required this.brandName,
    required this.brandLogoEmoji,
    required this.bannerImageUrl,
    required this.categoryId,
    required this.categoryName,
    required this.discountTagText,
    required this.subtitleText,
    required this.expiresText,
    required this.distanceText,
    required this.distanceMeters,
    required this.locationBranch,
    required this.description,
    this.isSaved = false,
  });
}

final List<OfferModel> dummyOffersList = [
  const OfferModel(
    id: "off_mcd",
    brandName: "McDonald's",
    brandLogoEmoji: "🍔",
    bannerImageUrl: "https://images.unsplash.com/photo-1561758033-d89a9ad46330?w=600",
    categoryId: "cat_food",
    categoryName: "Food & Beverages",
    discountTagText: "40% OFF!",
    subtitleText: "Up To 40% Off",
    expiresText: "Expires In 6 Days",
    distanceText: "Your Destination Is 140m Away. Estimated 2 Min Walk.",
    distanceMeters: 140,
    locationBranch: "Available At All Branches",
    description: "Enjoy exclusive 40% discount on all McDonald's meal combos for ministry employees across all branches in Kuwait.",
    isSaved: true,
  ),
  const OfferModel(
    id: "off_sbx",
    brandName: "STARBUCKS",
    brandLogoEmoji: "☕",
    bannerImageUrl: "https://images.unsplash.com/photo-1501339847302-ac426a4a7cbb?w=600",
    categoryId: "cat_food",
    categoryName: "Food & Beverages",
    discountTagText: "60% OFF!",
    subtitleText: "Up To 60% Off",
    expiresText: "Expires In 6 Days",
    distanceText: "350m Away • The Avenues Mall",
    distanceMeters: 350,
    locationBranch: "The Avenues Mall & All Branches",
    description: "Better Coffee, Bigger Smile! Get up to 60% discount on handcrafted beverages & food.",
    isSaved: false,
  ),
  const OfferModel(
    id: "off_sephora",
    brandName: "Sephora",
    brandLogoEmoji: "💄",
    bannerImageUrl: "https://images.unsplash.com/photo-1522337360788-8b13dee7a37e?w=600",
    categoryId: "cat_beauty",
    categoryName: "Beauty & Health",
    discountTagText: "25% OFF!",
    subtitleText: "Up To 25% Off",
    expiresText: "Expires In 12 Days",
    distanceText: "500m Away • 360 Mall",
    distanceMeters: 500,
    locationBranch: "360 Mall Branch",
    description: "Exclusive cosmetics and fragrance discount for ministry staff.",
    isSaved: true,
  ),
  const OfferModel(
    id: "off_xcite",
    brandName: "X-cite Electronics",
    brandLogoEmoji: "💻",
    bannerImageUrl: "https://images.unsplash.com/photo-1526738549149-8e07eca6c147?w=600",
    categoryId: "cat_electronics",
    categoryName: "Electronics",
    discountTagText: "15% OFF!",
    subtitleText: "Up To 15% Off",
    expiresText: "Expires In 4 Days",
    distanceText: "750m Away • Al Kout Mall",
    distanceMeters: 750,
    locationBranch: "Al Kout Mall Branch",
    description: "Save 15% on latest gadgets, laptops, and mobile accessories.",
    isSaved: false,
  ),
];
