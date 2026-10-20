import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/network/api_client.dart';
import '../../../core/theme/app_colors.dart';
import '../../main_layout.dart';
import 'worker_id_verification_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _workerIdController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _agreedToTerms = true;
  bool _isGoogleLoading = false;
  bool _isLoading = false;

  void _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;
    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Passwords do not match"), backgroundColor: Colors.red),
      );
      return;
    }

    final civilId = _workerIdController.text.trim().toUpperCase();
    final workerIdRegex = RegExp(r'^[A-Z]{2}-\d{6}$');
    if (!workerIdRegex.hasMatch(civilId)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("الرقم الوظيفي يجب أن يكون بصيغة WF-123456 (حرفين ثم 6 أرقام)"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    final res = await ApiClient.instance.register(
      civilId: civilId,
      fullName: _fullNameController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (res["success"] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Account created! Please upload your Worker ID card."),
          backgroundColor: AppColors.primaryBlue,
        ),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => WorkerIdVerificationScreen(
            civilId: civilId,
            fullName: _fullNameController.text.trim(),
          ),
        ),
      );
    } else {
      final msg = res["message"] ?? "Registration failed";
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg), backgroundColor: Colors.red.shade700),
      );
    }
  }

  void _handleGoogleSignUp() async {
    setState(() => _isGoogleLoading = true);
    try {
      await GoogleSignIn.instance.initialize();
      final account = await GoogleSignIn.instance.authenticate();
      final idToken = account.authentication.idToken;

      final res = await ApiClient.instance.loginWithGoogle(
        email: account.email,
        name: account.displayName,
        photoUrl: account.photoUrl,
        idToken: idToken,
      );
      if (!mounted) return;
      setState(() => _isGoogleLoading = false);
      if (res["success"] == true) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const MainLayout()),
          (route) => false,
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(res["message"] ?? "Google Registration failed"),
            backgroundColor: Colors.red.shade700,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isGoogleLoading = false);
      final errStr = e.toString();
      if (!errStr.contains("canceled") && !errStr.contains("cancelled") && !errStr.contains("dismissed")) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Google Sign-Up: $errStr"),
            backgroundColor: Colors.red.shade700,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 18, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/images/wafra_logo.png',
                  height: 70,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 14),

                const Text(
                  "Create Your Account",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.darkNavy,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  "Start saving and enjoying deals today",
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),

                const SizedBox(height: 20),

                // Google Sign Up Button
                OutlinedButton(
                  onPressed: _isGoogleLoading ? null : _handleGoogleSignUp,
                  style: OutlinedButton.styleFrom(
                    backgroundColor: Colors.white,
                    side: BorderSide(color: Colors.grey.shade300),
                    minimumSize: const Size.fromHeight(48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                  child: _isGoogleLoading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text("G", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.red)),
                            SizedBox(width: 10),
                            Text(
                              "Sign up with Google / Gmail",
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                ),

                const SizedBox(height: 16),

                // Divider Or Register with email
                Row(
                  children: [
                    Expanded(child: Divider(color: Colors.grey.shade300)),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12.0),
                      child: Text(
                        "Or register with email",
                        style: TextStyle(fontSize: 11, color: AppColors.textMuted),
                      ),
                    ),
                    Expanded(child: Divider(color: Colors.grey.shade300)),
                  ],
                ),

                const SizedBox(height: 16),

                _buildInputField("Full Name", "e.g. Salem Al-Ahmad", _fullNameController),
                const SizedBox(height: 12),
                _buildInputField("Email Address", "salem@example.com", _emailController),
                const SizedBox(height: 12),
                _buildInputField("Worker ID", "WF-123456", _workerIdController, isCivilId: true),
                const SizedBox(height: 12),
                _buildInputField("Password", "••••••••", _passwordController, isPassword: true),
                const SizedBox(height: 12),
                _buildInputField("Confirm Password", "••••••••", _confirmPasswordController, isPassword: true),

                const SizedBox(height: 12),

                // Terms checkbox
                Row(
                  children: [
                    Checkbox(
                      value: _agreedToTerms,
                      activeColor: AppColors.primaryBlue,
                      onChanged: (val) => setState(() => _agreedToTerms = val ?? true),
                    ),
                    const Expanded(
                      child: Text(
                        "I agree to the Terms & Conditions and Privacy Policy",
                        style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 18),

                // Submit / Create Account Button
                ElevatedButton(
                  onPressed: _isLoading ? null : _handleRegister,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    foregroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                    elevation: 0,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : const Text(
                          "Create Account & Submit ID",
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputField(
    String label,
    String hint,
    TextEditingController controller, {
    bool isPassword = false,
    bool isCivilId = false,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword,
      keyboardType: isCivilId ? TextInputType.text : TextInputType.text,
      textCapitalization: isCivilId ? TextCapitalization.characters : TextCapitalization.none,
      inputFormatters: isCivilId
          ? [
              LengthLimitingTextInputFormatter(9),
            ]
          : null,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        filled: true,
        fillColor: Colors.white,
        counterText: isCivilId ? "" : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      ),
      validator: (val) {
        if (val == null || val.trim().isEmpty) return "Field required";
        if (isCivilId) {
          final clean = val.trim().toUpperCase();
          final workerIdRegex = RegExp(r'^[A-Z]{2}-\d{6}$');
          if (!workerIdRegex.hasMatch(clean)) return "Worker ID format must be WF-123456";
        }
        return null;
      },
    );
  }
}
