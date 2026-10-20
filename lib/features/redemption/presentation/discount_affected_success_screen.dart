import 'package:flutter/material.dart';
import '../../../core/localization/app_locale.dart';
import '../../../core/theme/app_colors.dart';

class DiscountAffectedSuccessScreen extends StatelessWidget {
  final Map<String, dynamic> redemptionData;

  const DiscountAffectedSuccessScreen({
    super.key,
    required this.redemptionData,
  });

  @override
  Widget build(BuildContext context) {
    final brandName = redemptionData["brand_name"]?.toString() ?? "Partner Brand";
    final brandLogoEmoji = redemptionData["brand_logo_emoji"]?.toString() ?? "🎁";
    final brandLogoUrl = redemptionData["brand_logo_url"]?.toString() ?? "";
    final discountTag = redemptionData["discount_tag"]?.toString() ?? (isArabic ? "تم تفعيل الخصم" : "Discount Applied");
    final amountSavedKd = (redemptionData["amount_saved_kd"] as num?)?.toDouble() ?? 2.5;
    final originalAmount = (redemptionData["original_amount"] as num?)?.toDouble() ?? 10.0;
    final finalAmount = (redemptionData["final_amount"] as num?)?.toDouble() ?? (originalAmount - amountSavedKd);
    final branchName = redemptionData["branch_name"]?.toString() ?? (isArabic ? "فرع الكويت" : "Kuwait Branch");
    final totalSavingsKd = (redemptionData["user_total_savings_kd"] as num?)?.toDouble() ?? 10.0;
    final token = redemptionData["token"]?.toString() ?? "";
    final cashierName = redemptionData["cashier_name"]?.toString() ?? (isArabic ? "الكاشير" : "Cashier");
    final currency = isArabic ? "د.ك" : "KD";

    return Scaffold(
      backgroundColor: const Color(0xFFF0FDF4), // Gentle emerald tint
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            children: [
              const Spacer(flex: 1),

              // Animated Glowing Success Icon
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: const Color(0xFFDCFCE7),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF16A34A).withOpacity(0.25),
                      blurRadius: 30,
                      spreadRadius: 8,
                    ),
                  ],
                ),
                child: Center(
                  child: Container(
                    width: 72,
                    height: 72,
                    decoration: const BoxDecoration(
                      color: Color(0xFF16A34A),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check_rounded,
                      color: Colors.white,
                      size: 48,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Celebratory Titles
              Text(
                isArabic ? "تم تطبيق الخصم! 🎉" : "Discount Applied! 🎉",
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF14532D),
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                isArabic ? "تم تفعيل الخصم بنجاح من قبل الكاشير" : "Discount was verified and applied successfully by the cashier",
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF15803D),
                ),
              ),

              const SizedBox(height: 24),

              // Main Receipt Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 20,
                      offset: const Offset(0, 6),
                    ),
                  ],
                  border: Border.all(color: const Color(0xFFBBF7D0)),
                ),
                child: Column(
                  children: [
                    // Brand Info Row
                    Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            width: 50,
                            height: 50,
                            color: Colors.grey.shade100,
                            child: brandLogoUrl.isNotEmpty
                                ? Image.network(
                                    brandLogoUrl,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) => Center(
                                      child: Text(brandLogoEmoji, style: const TextStyle(fontSize: 26)),
                                    ),
                                  )
                                : Center(
                                    child: Text(brandLogoEmoji, style: const TextStyle(fontSize: 26)),
                                  ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                brandName,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              Text(
                                branchName,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.discountYellow,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            discountTag,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16.0),
                      child: Divider(height: 1),
                    ),

                    // Big Saved Amount Highlight Box
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0FDF4),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFF86EFAC)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.savings_rounded, color: Color(0xFF16A34A), size: 24),
                              const SizedBox(width: 8),
                              Text(
                                isArabic ? "وفّرت:" : "You Saved:",
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF166534),
                                ),
                              ),
                            ],
                          ),
                          Text(
                            "+ ${amountSavedKd.toStringAsFixed(3)} $currency",
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF15803D),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    _buildBreakdownRow(
                      isArabic ? "الفاتورة الأصلية" : "Original Bill",
                      "${originalAmount.toStringAsFixed(3)} $currency",
                    ),
                    const SizedBox(height: 8),
                    _buildBreakdownRow(
                      isArabic ? "الخصم المستقطع" : "Discount Deducted",
                      "- ${amountSavedKd.toStringAsFixed(3)} $currency",
                      isNegative: true,
                    ),
                    const SizedBox(height: 8),
                    _buildBreakdownRow(
                      isArabic ? "المدفوع عند الكاشير" : "You Paid at Cashier",
                      "${finalAmount.toStringAsFixed(3)} $currency",
                      isBold: true,
                    ),
                    const SizedBox(height: 8),
                    _buildBreakdownRow(
                      isArabic ? "تمت المعالجة بواسطة" : "Processed by Cashier",
                      cashierName,
                      isBold: false,
                    ),

                    if (token.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            isArabic ? "رمز الإيصال" : "Receipt Token",
                            style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                          ),
                          Text(token, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textMuted)),
                        ],
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Cumulative Savings Badge
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.account_balance_wallet_rounded, color: Colors.amber, size: 20),
                    const SizedBox(width: 10),
                    Text(
                      "${isArabic ? 'إجمالي توفيرك حتى الآن: ' : 'Total Lifetime Savings: '}${totalSavingsKd.toStringAsFixed(3)} $currency",
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 13.5,
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(flex: 2),

              // Done Button
              ElevatedButton(
                onPressed: () {
                  // Pop back to home/previous screens
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF16A34A),
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(54),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(27),
                  ),
                  elevation: 2,
                ),
                child: Text(
                  isArabic ? "تم / العودة للرئيسية" : "Done / Back to Home",
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBreakdownRow(String label, String value, {bool isNegative = false, bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: isBold ? AppColors.textPrimary : AppColors.textSecondary,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            color: isNegative
                ? const Color(0xFF16A34A)
                : (isBold ? AppColors.textPrimary : AppColors.textSecondary),
            fontWeight: isBold || isNegative ? FontWeight.bold : FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
