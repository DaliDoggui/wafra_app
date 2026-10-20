import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/network/api_client.dart';
import '../../../core/theme/app_colors.dart';
import '../../main_layout.dart';

class OtpVerificationScreen extends StatefulWidget {
  final String? targetPhone;
  final String? targetEmail;
  final bool isProfileUpdate;

  const OtpVerificationScreen({
    super.key,
    this.targetPhone,
    this.targetEmail,
    this.isProfileUpdate = false,
  });

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final List<TextEditingController> _controllers = List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  bool _isLoading = false;
  bool _isResending = false;
  int _secondsRemaining = 59;
  Timer? _timer;
  String? _previewCode;

  String get _destination => widget.targetPhone ?? widget.targetEmail ?? "+965 1234 5678";
  bool get _isEmailChannel => widget.targetEmail != null;

  @override
  void initState() {
    super.initState();
    _startCountdown();
    _sendInitialOtp();
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  void _startCountdown() {
    _timer?.cancel();
    setState(() => _secondsRemaining = 59);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        setState(() => _secondsRemaining--);
      } else {
        timer.cancel();
      }
    });
  }

  Future<void> _sendInitialOtp() async {
    final res = await ApiClient.instance.sendOtp(
      _destination,
      channel: _isEmailChannel ? "email" : "sms",
    );
    if (!mounted) return;
    if (res["code"] != null) {
      setState(() => _previewCode = res["code"].toString());
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Verification code sent to $_destination (Code: ${res['code']})"),
          backgroundColor: AppColors.primaryBlue,
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  Future<void> _handleResend() async {
    if (_secondsRemaining > 0 || _isResending) return;
    setState(() => _isResending = true);
    final res = await ApiClient.instance.sendOtp(
      _destination,
      channel: _isEmailChannel ? "email" : "sms",
    );
    if (!mounted) return;
    setState(() => _isResending = false);
    _startCountdown();
    if (res["code"] != null) {
      setState(() => _previewCode = res["code"].toString());
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("New code dispatched! (Code: ${res['code']})"),
          backgroundColor: AppColors.greenSuccess,
        ),
      );
    }
  }

  String _getEnteredCode() {
    return _controllers.map((c) => c.text.trim()).join();
  }

  void _handleVerify() async {
    final code = _getEnteredCode();
    if (code.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please enter the complete 6-digit verification code"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);
    final verifyRes = await ApiClient.instance.verifyOtp(_destination, code);
    if (!mounted) return;

    if (verifyRes["success"] != true) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(verifyRes["message"] ?? "Invalid verification code"),
          backgroundColor: Colors.red.shade700,
        ),
      );
      return;
    }

    if (widget.isProfileUpdate) {
      final res = await ApiClient.instance.requestProfileUpdate(
        phone: widget.targetPhone,
        email: widget.targetEmail,
      );
      if (!mounted) return;
      setState(() => _isLoading = false);
      if (res["success"] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(res["message"] ?? "Verified! Request submitted for Admin approval."),
            backgroundColor: AppColors.greenSuccess,
          ),
        );
        Navigator.pop(context);
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(res["message"] ?? "Submission failed"),
            backgroundColor: Colors.red.shade700,
          ),
        );
      }
    } else {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Phone & Identity successfully verified!"),
          backgroundColor: AppColors.greenSuccess,
        ),
      );
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const MainLayout()),
        (route) => false,
      );
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
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: AppColors.primaryBlue,
                child: Icon(
                  _isEmailChannel ? Icons.mark_email_read_outlined : Icons.sms_outlined,
                  color: Colors.white,
                  size: 30,
                ),
              ),
              const SizedBox(height: 16),

              Text(
                _isEmailChannel ? "Email Verification" : "Phone SMS Verification",
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.darkNavy,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                "We have sent a 6-digit verification code to\n$_destination",
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.4),
              ),

              if (_previewCode != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.primaryBlue.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.primaryBlue.withOpacity(0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.info_outline_rounded, size: 14, color: AppColors.primaryBlue),
                      const SizedBox(width: 6),
                      Text(
                        "Code: $_previewCode",
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryBlue,
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 32),

              // 6 Interactive OTP Digit Input Boxes
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(6, (index) {
                  return SizedBox(
                    width: 44,
                    height: 54,
                    child: TextField(
                      controller: _controllers[index],
                      focusNode: _focusNodes[index],
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryBlue,
                      ),
                      inputFormatters: [
                        LengthLimitingTextInputFormatter(1),
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: EdgeInsets.zero,
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: AppColors.primaryBlue, width: 2),
                        ),
                      ),
                      onChanged: (val) {
                        if (val.isNotEmpty && index < 5) {
                          _focusNodes[index + 1].requestFocus();
                        } else if (val.isEmpty && index > 0) {
                          _focusNodes[index - 1].requestFocus();
                        }
                        if (_getEnteredCode().length == 6) {
                          _handleVerify();
                        }
                      },
                    ),
                  );
                }),
              ),

              const SizedBox(height: 20),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _secondsRemaining > 0
                        ? "Resend code in 00:${_secondsRemaining.toString().padLeft(2, '0')}"
                        : "Didn't receive code? ",
                    style: TextStyle(
                      fontSize: 12,
                      color: _secondsRemaining > 0 ? AppColors.textMuted : AppColors.textSecondary,
                    ),
                  ),
                  if (_secondsRemaining == 0)
                    GestureDetector(
                      onTap: _isResending ? null : _handleResend,
                      child: Text(
                        _isResending ? "Sending..." : "Resend Now",
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryBlue,
                        ),
                      ),
                    ),
                ],
              ),

              const SizedBox(height: 32),

              ElevatedButton(
                onPressed: _isLoading ? null : _handleVerify,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(52),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(26),
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
                        "Verify & Continue",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
