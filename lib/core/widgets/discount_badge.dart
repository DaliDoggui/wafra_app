import 'package:flutter/material.dart';
import '../../models/offer_model.dart';
import '../theme/app_colors.dart';

class DiscountBadge extends StatelessWidget {
  final OfferModel? offer;
  final double? baseDiscount;
  final double? effectiveDiscount;
  final bool isSpecial;
  final String? fallbackText;
  final double fontSize;
  final bool showSpecialTag;

  const DiscountBadge({
    super.key,
    this.offer,
    this.baseDiscount,
    this.effectiveDiscount,
    this.isSpecial = false,
    this.fallbackText,
    this.fontSize = 12,
    this.showSpecialTag = true,
  });

  @override
  Widget build(BuildContext context) {
    final double base = offer?.defaultDiscount ?? baseDiscount ?? 20.0;
    final bool allowMult = offer?.allowMultipleDiscounts ?? true;
    final double eff = offer?.effectiveDiscount ?? effectiveDiscount ?? (offer?.isSpecialActive == true ? (allowMult ? (base + (offer?.specialDiscount ?? 0.0)) : (offer?.specialDiscount ?? base)) : base);
    final bool hasSpecial = offer?.isSpecialActive ?? (isSpecial || eff > base);

    if (hasSpecial && allowMult && eff > base) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFFEF3C7), Color(0xFFFDE68A)],
          ),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFFF59E0B), width: 1.2),
          boxShadow: [
            BoxShadow(
              color: Colors.amber.withOpacity(0.2),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (showSpecialTag) ...[
              const Text('🔥 ', style: TextStyle(fontSize: 11)),
            ],
            // Base crossed out (e.g. ~~20%~~)
            Text(
              '${base.toInt()}%',
              style: TextStyle(
                fontSize: fontSize * 0.9,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF94A3B8),
                decoration: TextDecoration.lineThrough,
                decorationColor: const Color(0xFFDC2626),
                decorationThickness: 2.2,
              ),
            ),
            const SizedBox(width: 5),
            // Stacked new discount (e.g. 70% OFF)
            Text(
              '${eff.toInt()}% OFF',
              style: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.w900,
                color: const Color(0xFFB45309),
                letterSpacing: -0.2,
              ),
            ),
          ],
        ),
      );
    }

    final displayText = offer?.discountTagText.isNotEmpty == true
        ? offer!.discountTagText
        : (fallbackText ?? '${base.toInt()}% OFF');

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.discountYellow,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        displayText,
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.w800,
          color: AppColors.discountYellowText,
        ),
      ),
    );
  }
}
