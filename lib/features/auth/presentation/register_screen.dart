import 'package:flutter/material.dart';
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

  void _handleGoogleSignUp() async {
    setState(() => _isGoogleLoading = true);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
            ),
            SizedBox(width: 12),
            Text("Registering with Google Account..."),
          ],
        ),
        backgroundColor: AppColors.primaryBlue,
        duration: Duration(seconds: 2),
      ),
    );

    await Future.delayed(const Duration(milliseconds: 1500));
    if (!mounted) return;
    setState(() => _isGoogleLoading = false);

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const MainLayout()),
      (route) => false,
    );
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

                _buildInputField("Full Name", "Foulen Ben Foulen", _fullNameController),
                const SizedBox(height: 12),
                _buildInputField("Email or Phone Number", "you@example.com", _emailController),
                const SizedBox(height: 12),
                _buildInputField("Worker ID", "ID-123456", _workerIdController),
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

                // Continue Button -> Navigates to Worker ID Upload
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const WorkerIdVerificationScreen()),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    foregroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    "Continue",
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

  Widget _buildInputField(String label, String hint, TextEditingController controller, {bool isPassword = false}) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        filled: true,
        fillColor: Colors.white,
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
        if (val == null || val.isEmpty) return "Field required";
        return null;
      },
    );
  }
}
