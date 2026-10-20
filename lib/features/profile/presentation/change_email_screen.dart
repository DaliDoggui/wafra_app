import 'package:flutter/material.dart';
import '../../../core/localization/app_locale.dart';
import '../../../core/network/api_client.dart';
import '../../../core/theme/app_colors.dart';
import '../../../main.dart';

class ChangeEmailScreen extends StatefulWidget {
  const ChangeEmailScreen({super.key});

  @override
  State<ChangeEmailScreen> createState() => _ChangeEmailScreenState();
}

class _ChangeEmailScreenState extends State<ChangeEmailScreen> {
  final _formKey = GlobalKey<FormState>();
  final _newEmailController = TextEditingController();
  final _confirmEmailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _hidePassword = true;
  bool _isLoading = false;

  String get _currentEmail =>
      ApiClient.instance.currentUser?["email"]?.toString() ?? "member@wafra.kw";

  @override
  void dispose() {
    _newEmailController.dispose();
    _confirmEmailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = themeModeNotifier.value == ThemeMode.dark;
    final bgColor = isDark ? const Color(0xFF0F172A) : AppColors.background;
    final cardBg = isDark ? const Color(0xFF1E293B) : Colors.white;
    final textCol = isDark ? Colors.white : AppColors.textPrimary;
    final textSecondary = isDark ? const Color(0xFF94A3B8) : AppColors.textSecondary;
    final borderColor = isDark ? const Color(0xFF334155) : Colors.grey.shade200;

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
          isArabic ? "تغيير البريد الإلكتروني" : "Change Email",
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
                    child: const Icon(Icons.email_outlined,
                        size: 38, color: AppColors.primaryBlue),
                  ),
                ),

                // Current Email (read-only)
                Text(
                  isArabic ? "البريد الإلكتروني الحالي" : "Current Email",
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: textCol),
                ),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E293B) : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: borderColor),
                  ),
                  child: Text(
                    _currentEmail,
                    style: TextStyle(
                        fontSize: 14,
                        color: textSecondary,
                        fontWeight: FontWeight.w500),
                  ),
                ),

                const SizedBox(height: 20),
                Text(
                  isArabic ? "البريد الإلكتروني الجديد" : "New Email",
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: textCol),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _newEmailController,
                  keyboardType: TextInputType.emailAddress,
                  style: TextStyle(color: textCol),
                  decoration: _inputDecoration(
                    isArabic ? "أدخل البريد الإلكتروني الجديد" : "Enter new email address",
                    isDark, cardBg, borderColor,
                  ),
                  validator: (val) {
                    if (val == null || val.isEmpty) return isArabic ? "مطلوب" : "Required";
                    if (!val.contains('@') || !val.contains('.')) {
                      return isArabic ? "أدخل بريداً إلكترونياً صالحاً" : "Enter a valid email address";
                    }
                    if (val == _currentEmail) {
                      return isArabic ? "يجب أن يكون البريد مختلفاً عن الحالي" : "New email must be different from current";
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 18),
                Text(
                  isArabic ? "تأكيد البريد الإلكتروني الجديد" : "Confirm New Email",
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: textCol),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _confirmEmailController,
                  keyboardType: TextInputType.emailAddress,
                  style: TextStyle(color: textCol),
                  decoration: _inputDecoration(
                    isArabic ? "أعد إدخال البريد الإلكتروني الجديد" : "Re-enter new email address",
                    isDark, cardBg, borderColor,
                  ),
                  validator: (val) {
                    if (val == null || val.isEmpty) return isArabic ? "مطلوب" : "Required";
                    if (val != _newEmailController.text) {
                      return isArabic ? "البريد الإلكتروني غير متطابق" : "Emails do not match";
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 18),
                Text(
                  isArabic ? "كلمة المرور الحالية" : "Current Password",
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: textCol),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _passwordController,
                  obscureText: _hidePassword,
                  style: TextStyle(color: textCol),
                  decoration: _inputDecoration(
                    isArabic ? "أدخل كلمة المرور للتأكيد" : "Enter your password to confirm",
                    isDark,
                    cardBg,
                    borderColor,
                    suffix: IconButton(
                      icon: Icon(
                        _hidePassword
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: AppColors.textMuted,
                        size: 20,
                      ),
                      onPressed: () =>
                          setState(() => _hidePassword = !_hidePassword),
                    ),
                  ),
                  validator: (val) =>
                      val == null || val.isEmpty ? (isArabic ? "مطلوب" : "Required") : null,
                ),

                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.amber.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                        color: Colors.amber.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.admin_panel_settings_outlined,
                          size: 16, color: Colors.amber),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          isArabic
                              ? "ملاحظة: تغيير البريد الإلكتروني الرسمي يتطلب موافقة الإدارة. سيتم إرسال طلبك فوراً."
                              : "Notice: Changing your official email requires Admin approval. Your request will be queued immediately.",
                          style: const TextStyle(
                              fontSize: 11, color: AppColors.textSecondary),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 28),

                ElevatedButton(
                  onPressed: _isLoading ? null : _handleSubmit,
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
                          isArabic ? "إرسال الطلب للموافقة" : "Submit Request for Approval",
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

  InputDecoration _inputDecoration(String hint, bool isDark, Color cardBg, Color borderColor, {Widget? suffix}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 13),
      filled: true,
      fillColor: cardBg,
      suffixIcon: suffix,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: borderColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: borderColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide:
            const BorderSide(color: AppColors.primaryBlue, width: 1.5),
      ),
    );
  }

  void _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    final res = await ApiClient.instance.requestProfileUpdate(
      email: _newEmailController.text.trim(),
    );
    if (!mounted) return;
    setState(() => _isLoading = false);
    if (res["success"] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isArabic ? "تم إرسال طلب تعديل البريد للإدارة بنجاح!" : (res["message"] ?? "Email change submitted for Admin approval!")),
          backgroundColor: Colors.orange.shade800,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isArabic ? "فشل طلب تعديل البريد الإلكتروني" : (res["message"] ?? "Failed to request email change")),
          backgroundColor: Colors.red.shade700,
        ),
      );
    }
  }
}
