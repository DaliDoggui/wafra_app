

class OrderModel {
  final String id;
  final String brandName;
  final String brandLogoEmoji;
  final String categoryName;
  final String branchName;
  final DateTime redeemedAt;
  final double originalPrice;
  final double discountPercent;
  final double savedAmount;
  final double finalPrice;
  final String receiptCode;

  const OrderModel({
    required this.id,
    required this.brandName,
    required this.brandLogoEmoji,
    required this.categoryName,
    required this.branchName,
    required this.redeemedAt,
    required this.originalPrice,
    required this.discountPercent,
    required this.savedAmount,
    required this.finalPrice,
    required this.receiptCode,
  });

  String get discountTagText =>
      "${discountPercent.toStringAsFixed(0)}% OFF";

  String get savedText =>
      "+${savedAmount.toStringAsFixed(3)} KD";

  String get finalPriceText =>
      "${finalPrice.toStringAsFixed(3)} KD";
}


// Clean initial empty list - populated exclusively from live backend database
final List<OrderModel> dummyOrdersList = [];
