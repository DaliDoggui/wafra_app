import 'package:flutter/material.dart';
import '../../../core/localization/app_locale.dart';
import '../../../core/network/api_client.dart';
import '../../../core/theme/app_colors.dart';
import '../../../main.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _currentController = TextEditingController();
  final _newController = TextEditingController();
  final _confirmController = TextEditingController();

  bool _hideCurrentPw = true;
  bool _hideNewPw = true;
  bool _hideConfirmPw = true;
  bool _isLoading = false;

  // Password strength
  int get _strengthScore {
    final p = _newController.text;
    int score = 0;
    if (p.length >= 8) score++;
    if (p.contains(RegExp(r'[A-Z]'))) score++;
    if (p.contains(RegExp(r'[0-9]'))) score++;
    if (p.contains(RegExp(r'[!@#\$%^&*(),.?":{}|<>]'))) score++;
    return score;
  }

  String get _strengthLabel {
    switch (_strengthScore) {
      case 0:
      case 1:
        return isArabic ? "ضعيفة" : "Weak";
      case 2:
        return isArabic ? "مقبولة" : "Fair";
      case 3:
        return isArabic ? "جيدة" : "Good";
      case 4:
        return isArabic ? "قوية" : "Strong";
      default:
        return "";
    }
  }

  Color get _strengthColor {
    switch (_strengthScore) {
      case 0:
      case 1:
        return AppColors.redError;
      case 2:
        return Colors.orange;
      case 3:
        return Colors.amber;
      case 4:
        return AppColors.greenSuccess;
      default:
        return Colors.grey;
    }
  }

  @override
  void dispose() {
    _currentController.dispose();
    _newController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = themeModeNotifier.value == ThemeMode.dark;
    final bgColor = isDark ? const Color(0xFF0F172A) : AppColors.background;
    final cardBg = isDark ? const Color(0xFF1E293B) : Colors.white;
    final textCol = isDark ? Colors.white : AppColors.textPrimary;
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
          isArabic ? "تغيير كلمة المرور" : "Change Password",
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
                    child: const Icon(Icons.lock_outline_rounded,
                        size: 38, color: AppColors.primaryBlue),
                  ),
                ),

                _buildLabel(isArabic ? "كلمة المرور الحالية" : "Current Password"),
                _buildPasswordField(
                  controller: _currentController,
                  hint: isArabic ? "أدخل كلمة المرور الحالية" : "Enter your current password",
                  hidden: _hideCurrentPw,
                  onToggle: () => setState(() => _hideCurrentPw = !_hideCurrentPw),
                  validator: (val) => val == null || val.isEmpty
                      ? (isArabic ? "مطلوب" : "Required")
                      : null,
                ),

                const SizedBox(height: 18),
                _buildLabel(isArabic ? "كلمة المرور الجديدة" : "New Password"),
                _buildPasswordField(
                  controller: _newController,
                  hint: isArabic ? "8 أحرف على الأقل" : "Min 8 characters",
                  hidden: _hideNewPw,
                  onToggle: () => setState(() => _hideNewPw = !_hideNewPw),
                  onChanged: (_) => setState(() {}),
                  validator: (val) {
                    if (val == null || val.isEmpty) return isArabic ? "مطلوب" : "Required";
                    if (val.length < 8) return isArabic ? "8 أحرف على الأقل" : "Min 8 characters";
                    return null;
                  },
                ),

                // Strength bar
                if (_newController.text.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Row(
                    children: List.generate(4, (i) {
                      return Expanded(
                        child: Container(
                          margin: EdgeInsets.only(right: i < 3 ? 6 : 0),
                          height: 4,
                          decoration: BoxDecoration(
                            color: i < _strengthScore
                                ? _strengthColor
                                : Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "${isArabic ? 'قوة كلمة المرور: ' : 'Password strength: '}$_strengthLabel",
                    style: TextStyle(
                        fontSize: 11,
                        color: _strengthColor,
                        fontWeight: FontWeight.w600),
                  ),
                ],

                const SizedBox(height: 18),
                _buildLabel(isArabic ? "تأكيد كلمة المرور الجديدة" : "Confirm New Password"),
                _buildPasswordField(
                  controller: _confirmController,
                  hint: isArabic ? "أعد إدخال كلمة المرور الجديدة" : "Re-enter new password",
                  hidden: _hideConfirmPw,
                  onToggle: () =>
                      setState(() => _hideConfirmPw = !_hideConfirmPw),
                  validator: (val) {
                    if (val == null || val.isEmpty) return isArabic ? "مطلوب" : "Required";
                    if (val != _newController.text) {
                      return isArabic ? "كلمات المرور غير متطابقة" : "Passwords do not match";
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 12),

                // Tips
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.primaryBlue.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isArabic ? "نصائح لكلمة مرور قوية:" : "Tips for a strong password:",
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : AppColors.textPrimary),
                      ),
                      const SizedBox(height: 6),
                      _Tip(isArabic ? "8 أحرف على الأقل" : "At least 8 characters"),
                      _Tip(isArabic ? "حرف كبير واحد على الأقل (A-Z)" : "At least one uppercase letter (A-Z)"),
                      _Tip(isArabic ? "رقم واحد على الأقل (0-9)" : "At least one number (0-9)"),
                      _Tip(isArabic ? "رمز خاص واحد على الأقل (!@#...)" : "At least one special character (!@#...)"),
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
                          isArabic ? "تحديث كلمة المرور" : "Update Password",
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

  Widget _buildLabel(String text) {
    final isDark = themeModeNotifier.value == ThemeMode.dark;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : AppColors.textPrimary),
      ),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String hint,
    required bool hidden,
    required VoidCallback onToggle,
    String? Function(String?)? validator,
    void Function(String)? onChanged,
  }) {
    final isDark = themeModeNotifier.value == ThemeMode.dark;
    final cardBg = isDark ? const Color(0xFF1E293B) : Colors.white;
    final borderColor = isDark ? const Color(0xFF334155) : Colors.grey.shade300;
    final textColor = isDark ? Colors.white : Colors.black87;

    return TextFormField(
      controller: controller,
      obscureText: hidden,
      onChanged: onChanged,
      validator: validator,
      style: TextStyle(color: textColor),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 13),
        filled: true,
        fillColor: cardBg,
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
        suffixIcon: IconButton(
          icon: Icon(
            hidden ? Icons.visibility_off_outlined : Icons.visibility_outlined,
            color: AppColors.textMuted,
            size: 20,
          ),
          onPressed: onToggle,
        ),
      ),
    );
  }

  void _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    
    final res = await ApiClient.instance.changePassword(
      oldPassword: _currentController.text.trim(),
      newPassword: _newController.text.trim(),
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (res["success"] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isArabic ? "تم تحديث كلمة المرور بنجاح!" : (res["message"] ?? "Password updated successfully!")),
          backgroundColor: AppColors.greenSuccess,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isArabic ? "فشل تحديث كلمة المرور. تأكد من كلمة المرور الحالية" : (res["message"] ?? "Failed to update password")),
          backgroundColor: AppColors.redError,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }
}

class _Tip extends StatelessWidget {
  final String text;
  const _Tip(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Row(
        children: [
          const Icon(Icons.check_circle_outline_rounded,
              size: 13, color: AppColors.primaryBlue),
          const SizedBox(width: 6),
          Text(text,
              style: const TextStyle(
                  fontSize: 11, color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}
