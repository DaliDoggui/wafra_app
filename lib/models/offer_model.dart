class OfferModel {
  final String id;
  final String brandName;
  final String brandLogoEmoji;
  final String brandLogoUrl;
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
  final double latitude;
  final double longitude;
  final bool isSaved;
  final double defaultDiscount;
  final double specialDiscount;
  final String? specialDiscountTitle;
  final double effectiveDiscount;
  final bool isSpecialActive;
  final bool allowMultipleDiscounts;

  const OfferModel({
    required this.id,
    required this.brandName,
    required this.brandLogoEmoji,
    required this.brandLogoUrl,
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
    this.latitude = 29.3759,
    this.longitude = 47.9774,
    this.isSaved = false,
    this.defaultDiscount = 20.0,
    this.specialDiscount = 0.0,
    this.specialDiscountTitle,
    this.effectiveDiscount = 20.0,
    this.isSpecialActive = false,
    this.allowMultipleDiscounts = true,
  });
}

// Clean initial empty list - strictly populated from live backend database
final List<OfferModel> dummyOffersList = [];
