import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/localization/app_locale.dart';
import '../../../core/theme/app_colors.dart';
import '../../../main.dart';
import '../../auth/presentation/otp_verification_screen.dart';

class ChangePhoneScreen extends StatefulWidget {
  const ChangePhoneScreen({super.key});

  @override
  State<ChangePhoneScreen> createState() => _ChangePhoneScreenState();
}

class _ChangePhoneScreenState extends State<ChangePhoneScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  String _selectedCountryCode = "+965";
  bool _isLoading = false;

  final List<Map<String, String>> _countryCodes = [
    {"code": "+965", "flag": "🇰🇼", "name": "Kuwait", "nameAr": "الكويت"},
    {"code": "+966", "flag": "🇸🇦", "name": "Saudi Arabia", "nameAr": "المملكة العربية السعودية"},
    {"code": "+971", "flag": "🇦🇪", "name": "UAE", "nameAr": "الإمارات العربية المتحدة"},
    {"code": "+974", "flag": "🇶🇦", "name": "Qatar", "nameAr": "قطر"},
    {"code": "+973", "flag": "🇧🇭", "name": "Bahrain", "nameAr": "البحرين"},
    {"code": "+968", "flag": "🇴🇲", "name": "Oman", "nameAr": "عُمان"},
    {"code": "+20", "flag": "🇪🇬", "name": "Egypt", "nameAr": "مصر"},
    {"code": "+216", "flag": "🇹🇳", "name": "Tunisia", "nameAr": "تونس"},
    {"code": "+213", "flag": "🇩🇿", "name": "Algeria", "nameAr": "الجزائر"},
  ];

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = themeModeNotifier.value == ThemeMode.dark;
    final bgColor = isDark ? const Color(0xFF0F172A) : AppColors.background;
    final cardBg = isDark ? const Color(0xFF1E293B) : Colors.white;
    final textCol = isDark ? Colors.white : AppColors.textPrimary;
    final borderColor = isDark ? const Color(0xFF334155) : Colors.grey.shade200;
    final inputBorderColor = isDark ? const Color(0xFF334155) : Colors.grey.shade300;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: cardBg,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded,
              size: 18, color: textCol),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          isArabic ? "إضافة / تغيير رقم الهاتف" : "Add / Change Phone",
          style: TextStyle(
              color: textCol,
              fontWeight: FontWeight.bold,
              fontSize: 18),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Divider(height: 1, color: borderColor),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icon header
                Center(
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 24, top: 8),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.primaryBlue.withValues(alpha: 0.08),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.phone_android_rounded,
                        size: 38, color: AppColors.primaryBlue),
                  ),
                ),

                Text(
                  isArabic ? "رقم الهاتف" : "Phone Number",
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: textCol),
                ),
                const SizedBox(height: 8),

                // Country code + number row
                Container(
                  decoration: BoxDecoration(
                    color: cardBg,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: inputBorderColor),
                  ),
                  child: Row(
                    children: [
                      // Country code picker
                      InkWell(
                        onTap: () => _showCountryPicker(context),
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(14),
                          bottomLeft: Radius.circular(14),
                        ),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 16),
                          child: Row(
                            children: [
                              Text(
                                _countryCodes.firstWhere((c) =>
                                    c["code"] == _selectedCountryCode)["flag"]!,
                                style: const TextStyle(fontSize: 18),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                _selectedCountryCode,
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                    color: textCol),
                              ),
                              const Icon(Icons.arrow_drop_down,
                                  color: AppColors.textMuted, size: 18),
                            ],
                          ),
                        ),
                      ),
                      Container(
                          width: 1,
                          height: 28,
                          color: inputBorderColor),
                      // Phone number input
                      Expanded(
                        child: TextFormField(
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,
                          style: TextStyle(color: textCol),
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(10),
                          ],
                          decoration: InputDecoration(
                            hintText: isArabic ? "أدخل رقم الهاتف" : "Enter phone number",
                            hintStyle: const TextStyle(
                                color: AppColors.textMuted, fontSize: 13),
                            border: InputBorder.none,
                            contentPadding:
                                const EdgeInsets.symmetric(horizontal: 12),
                          ),
                          validator: (val) {
                            if (val == null || val.isEmpty) return isArabic ? "مطلوب" : "Required";
                            if (val.length < 7) {
                              return isArabic ? "أدخل رقم هاتف صالح" : "Enter a valid phone number";
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Info note
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.primaryBlue.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline_rounded,
                          size: 16, color: AppColors.primaryBlue),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          isArabic
                              ? "سيتم إرسال رمز تحقق OTP إلى هذا الرقم لتأكيد هويتك."
                              : "An OTP code will be sent to this number to verify your identity.",
                          style: const TextStyle(
                              fontSize: 11, color: AppColors.textSecondary),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 28),

                ElevatedButton(
                  onPressed: _isLoading ? null : _handleSendOtp,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    foregroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(52),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(26)),
                    elevation: 0,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2))
                      : Text(
                          isArabic ? "إرسال رمز التحقق OTP" : "Send OTP Code",
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showCountryPicker(BuildContext context) {
    final isDark = themeModeNotifier.value == ThemeMode.dark;
    final cardBg = isDark ? const Color(0xFF1E293B) : Colors.white;
    final textCol = isDark ? Colors.white : AppColors.textPrimary;

    showModalBottomSheet(
      context: context,
      backgroundColor: cardBg,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40, height: 4,
            decoration: BoxDecoration(
                color: isDark ? const Color(0xFF334155) : Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2)),
          ),
          const SizedBox(height: 12),
          Text(
            isArabic ? "اختر رمز الدولة" : "Select Country Code",
            style:
                TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: textCol),
          ),
          const SizedBox(height: 8),
          Flexible(
            child: ListView(
              shrinkWrap: true,
              children: _countryCodes.map((c) {
                return ListTile(
                  leading: Text(c["flag"]!,
                      style: const TextStyle(fontSize: 22)),
                  title: Text(
                    isArabic ? (c["nameAr"] ?? c["name"]!) : c["name"]!,
                    style: TextStyle(fontWeight: FontWeight.w600, color: textCol),
                  ),
                  trailing: Text(c["code"]!,
                      style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.bold)),
                  selected: c["code"] == _selectedCountryCode,
                  selectedTileColor:
                      AppColors.primaryBlue.withValues(alpha: 0.1),
                  onTap: () {
                    setState(() => _selectedCountryCode = c["code"]!);
                    Navigator.pop(ctx);
                  },
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  void _handleSendOtp() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;
    setState(() => _isLoading = false);
    final fullPhone = "$_selectedCountryCode ${_phoneController.text.trim()}";
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => OtpVerificationScreen(
          targetPhone: fullPhone,
          isProfileUpdate: true,
        ),
      ),
    );
  }
}
