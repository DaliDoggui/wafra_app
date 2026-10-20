import 'dart:async';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../../core/network/api_client.dart';
import '../../../core/theme/app_colors.dart';
import '../../../services/realtime_sync_service.dart';
import '../../../core/localization/app_locale.dart';
import '../../../main.dart';
import 'discount_affected_success_screen.dart';

class DynamicQrScreen extends StatefulWidget {
  final String brandName;
  final String? offerId;

  const DynamicQrScreen({
    super.key,
    required this.brandName,
    this.offerId,
  });

  @override
  State<DynamicQrScreen> createState() => _DynamicQrScreenState();
}

class _DynamicQrScreenState extends State<DynamicQrScreen> {
  Timer? _timer;
  Timer? _pollingTimer;
  int _secondsRemaining = 60;
  String _qrPayload = "WFR-LOADING";
  String _dynamicToken = "...";
  bool _isLoading = true;
  bool _hasClaimed = false;
  double _defaultDiscount = 20.0;
  double _specialDiscount = 0.0;
  String? _specialDiscountTitle;
  double _effectiveDiscount = 20.0;
  bool _isSpecialOffer = false;

  @override
  void initState() {
    super.initState();
    _fetchDynamicQr();
  }

  Future<void> _fetchDynamicQr() async {
    setState(() => _isLoading = true);
    final offerId = widget.offerId ?? "off_${widget.brandName.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '')}";
    final result = await ApiClient.instance.generateDynamicQr(offerId);

    if (mounted) {
      if (result != null) {
        setState(() {
          _dynamicToken = result["dynamic_token"] ?? "WFR-${DateTime.now().millisecondsSinceEpoch.toRadixString(16).toUpperCase()}";
          _qrPayload = result["qr_payload"] ?? _dynamicToken;
          _secondsRemaining = (result["seconds_remaining"] as int?) ?? 60;
          _defaultDiscount = (result["default_discount"] as num?)?.toDouble() ?? 20.0;
          _specialDiscount = (result["special_discount"] as num?)?.toDouble() ?? 0.0;
          _specialDiscountTitle = result["special_discount_title"]?.toString();
          _effectiveDiscount = (result["effective_discount"] as num?)?.toDouble() ?? (_defaultDiscount + _specialDiscount);
          _isSpecialOffer = result["is_special_offer"] == true || _specialDiscount > 0;
          _isLoading = false;
        });
        _startStatusPolling();
      } else {
        final fallback = "WFR-${DateTime.now().millisecondsSinceEpoch.toRadixString(16).toUpperCase()}";
        setState(() {
          _dynamicToken = fallback;
          _qrPayload = fallback;
          _secondsRemaining = 60;
          _isLoading = false;
        });
        _startStatusPolling();
      }
      _startCountdown();
    }
  }

  void _startStatusPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = Timer.periodic(const Duration(milliseconds: 1000), (timer) async {
      if (_hasClaimed || !mounted || _dynamicToken.isEmpty || _dynamicToken == "...") {
        return;
      }

      final statusData = await ApiClient.instance.checkRedemptionStatus(_dynamicToken);
      if (!mounted || _hasClaimed) return;

      if (statusData != null && statusData["status"] == "REDEEMED") {
        _hasClaimed = true;
        _timer?.cancel();
        _pollingTimer?.cancel();

        // Notify RealTimeSyncService so all screens sync instantly
        RealTimeSyncService.instance.onRedemptionApproved(statusData);

        // Instantly transition to the celebratory interface
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => DiscountAffectedSuccessScreen(redemptionData: statusData),
          ),
        );
      }
    });
  }

  void _startCountdown() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        setState(() => _secondsRemaining--);
      } else {
        _timer?.cancel();
        _pollingTimer?.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pollingTimer?.cancel();
    super.dispose();
  }

  String get _formattedTime {
    int minutes = _secondsRemaining ~/ 60;
    int seconds = _secondsRemaining % 60;
    return "${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    final isDark = themeModeNotifier.value == ThemeMode.dark;
    final bgColor = isDark ? const Color(0xFF0F172A) : AppColors.background;
    final cardBg = isDark ? const Color(0xFF1E293B) : Colors.white;
    final textCol = isDark ? Colors.white : AppColors.textPrimary;
    final textSecondary = isDark ? const Color(0xFF94A3B8) : AppColors.textSecondary;

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
          widget.brandName,
          style: TextStyle(
            color: textCol,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            children: [
              // Security info badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E293B) : Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: isDark ? const Color(0xFF334155) : Colors.blue.shade100),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.security_rounded, size: 16, color: AppColors.primaryBlue),
                    const SizedBox(width: 8),
                    Text(
                      "${tr('token')}: $_dynamicToken",
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryBlue,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              // Prominent Stacked Discount Badge
              if (_isSpecialOffer && _effectiveDiscount > _defaultDiscount)
                Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFEF3C7), Color(0xFFFDE68A)],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFF59E0B), width: 1.5),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.amber.withOpacity(0.25),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('🔥 ', style: TextStyle(fontSize: 18)),
                          Text(
                            '${_defaultDiscount.toInt()}%',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF94A3B8),
                              decoration: TextDecoration.lineThrough,
                              decorationColor: Color(0xFFDC2626),
                              decorationThickness: 2.8,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            isArabic ? 'خصم ${_effectiveDiscount.toInt()}%' : '${_effectiveDiscount.toInt()}% OFF',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFFB45309),
                              letterSpacing: -0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (_specialDiscountTitle != null && _specialDiscountTitle!.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(
                        _specialDiscountTitle!,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: isDark ? const Color(0xFFFCD34D) : const Color(0xFFB45309),
                        ),
                      ),
                    ],
                  ],
                )
              else
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.discountYellow,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Text(
                    isArabic ? 'خصم ${_effectiveDiscount.toInt()}%' : '${_effectiveDiscount.toInt()}% OFF',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: Colors.black,
                    ),
                  ),
                ),

              const Spacer(),

              // Large QR Code Container
              Container(
                padding: const EdgeInsets.all(24.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 20,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 240,
                        height: 240,
                        child: Center(child: CircularProgressIndicator()),
                      )
                    : QrImageView(
                        data: _qrPayload,
                        version: QrVersions.auto,
                        size: 240.0,
                      ),
              ),

              const SizedBox(height: 20),

              Text(
                tr("show_qr_cashier"),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: textSecondary,
                ),
              ),

              const SizedBox(height: 10),

              // Countdown Timer Text
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.timer_outlined,
                    size: 18,
                    color: _secondsRemaining > 10 ? AppColors.greenSuccess : Colors.red,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    _secondsRemaining > 0 ? "${tr('expires_in')} $_formattedTime" : tr("qr_expired"),
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: _secondsRemaining > 10 ? AppColors.greenSuccess : Colors.red,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 14),

              // Live Real-Time Detection Pill
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF064E3B).withOpacity(0.5) : const Color(0xFFF0FDF4),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFF16A34A)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(
                      width: 12,
                      height: 12,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Color(0xFF16A34A),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      tr("listening_scan"),
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF16A34A),
                      ),
                    ),
                  ],
                ),
              ),

              if (_secondsRemaining == 0) ...[
                const SizedBox(height: 12),
                TextButton.icon(
                  onPressed: _fetchDynamicQr,
                  icon: const Icon(Icons.refresh_rounded),
                  label: Text(isArabic ? "إنشاء رمز جديد" : "Generate New Code"),
                  style: TextButton.styleFrom(foregroundColor: AppColors.primaryBlue),
                ),
              ],

              const Spacer(),

              // Cancel Button
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(52),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(26),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  isArabic ? "تم / رجوع" : "Done / Back",
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
