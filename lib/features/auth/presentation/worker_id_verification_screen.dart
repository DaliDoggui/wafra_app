import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../../../core/network/api_client.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/image_picker_helper.dart';
import 'verification_status_screen.dart';

class WorkerIdVerificationScreen extends StatefulWidget {
  final String? civilId;
  final String? fullName;

  const WorkerIdVerificationScreen({
    super.key,
    this.civilId,
    this.fullName,
  });

  @override
  State<WorkerIdVerificationScreen> createState() => _WorkerIdVerificationScreenState();
}

class _WorkerIdVerificationScreenState extends State<WorkerIdVerificationScreen> {
  String? _frontDataUrl;
  Uint8List? _frontBytes;
  String? _backDataUrl;
  Uint8List? _backBytes;
  bool _isSubmitting = false;

  void _pickImage(bool isFront) async {
    try {
      final dataUrl = await pickImageAsDataUrl();
      if (dataUrl != null && dataUrl.isNotEmpty) {
        Uint8List? bytes;
        try {
          final base64Part = dataUrl.contains(',') ? dataUrl.split(',').last : dataUrl;
          bytes = base64Decode(base64Part);
        } catch (_) {}

        if (!mounted) return;
        setState(() {
          if (isFront) {
            _frontDataUrl = dataUrl;
            _frontBytes = bytes;
          } else {
            _backDataUrl = dataUrl;
            _backBytes = bytes;
          }
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isFront ? "Worker ID Front photo selected!" : "Worker ID Back photo selected!"),
            duration: const Duration(seconds: 2),
            backgroundColor: AppColors.primaryBlue,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error picking image: $e"), backgroundColor: Colors.red),
      );
    }
  }

  void _handleSubmit() async {
    if (_frontDataUrl == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please upload at least the front photo of your Worker ID"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    final targetCivilId = widget.civilId ?? ApiClient.instance.currentUser?["civil_id"] ?? "";

    if (targetCivilId.isNotEmpty) {
      final res = await ApiClient.instance.uploadCivilId(
        civilId: targetCivilId,
        frontDataUrl: _frontDataUrl!,
        backDataUrl: _backDataUrl,
      );
      if (res["success"] != true) {
        if (!mounted) return;
        setState(() => _isSubmitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(res["message"] ?? "Failed to upload Worker ID photos"),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
    }

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => const VerificationStatusScreen(isInitiallyApproved: false),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool canSubmit = _frontDataUrl != null;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 18, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Worker ID Verification",
          style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w800, fontSize: 16),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.verified_user_rounded, color: AppColors.primaryBlue, size: 14),
                    SizedBox(width: 6),
                    Text(
                      "Official PACI Authentication",
                      style: TextStyle(color: AppColors.primaryBlue, fontSize: 11.5, fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              const Text(
                "Upload Your Worker ID",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                "Upload clear photos of your official Worker ID (بطاقة مدنية) or Government Ministry Employee Card to activate ministry discounts.",
                style: TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.4),
              ),

              const SizedBox(height: 28),

              // Upload Front Card
              _buildUploadBox(
                title: "Worker ID Card (Front)",
                subtitle: "Front side with your photo & Worker ID number",
                isUploaded: _frontDataUrl != null,
                previewBytes: _frontBytes,
                onTap: () => _pickImage(true),
              ),

              const SizedBox(height: 18),

              // Upload Back Card
              _buildUploadBox(
                title: "Worker ID Card (Back)",
                subtitle: "Back side showing barcode & serial number",
                isUploaded: _backDataUrl != null,
                previewBytes: _backBytes,
                onTap: () => _pickImage(false),
              ),

              const SizedBox(height: 36),

              // Info notice
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.shield_outlined, color: AppColors.primaryBlue, size: 20),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        "Your documents are encrypted and reviewed solely by the Civil Service Commission.",
                        style: TextStyle(fontSize: 11.5, color: AppColors.textSecondary),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // Submit Button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: canSubmit && !_isSubmitting ? _handleSubmit : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: Colors.grey.shade300,
                    disabledForegroundColor: Colors.grey.shade600,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: canSubmit ? 2 : 0,
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : Text(
                          canSubmit ? "Submit for Verification" : "Upload Front ID to Continue",
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUploadBox({
    required String title,
    required String subtitle,
    required bool isUploaded,
    Uint8List? previewBytes,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isUploaded ? Colors.blue.shade50.withOpacity(0.5) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isUploaded ? AppColors.primaryBlue : Colors.grey.shade300,
            width: isUploaded ? 1.8 : 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            if (previewBytes != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.memory(
                  previewBytes,
                  width: 56,
                  height: 56,
                  fit: BoxFit.cover,
                ),
              )
            else
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: isUploaded ? AppColors.primaryBlue : const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  isUploaded ? Icons.check_circle_rounded : Icons.add_a_photo_outlined,
                  color: isUploaded ? Colors.white : AppColors.primaryBlue,
                  size: 26,
                ),
              ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: isUploaded ? AppColors.primaryBlue : AppColors.textPrimary,
                        ),
                      ),
                      if (isUploaded) ...[
                        const SizedBox(width: 6),
                        const Icon(Icons.verified_rounded, size: 16, color: AppColors.primaryBlue),
                      ],
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    isUploaded ? "Real card attached • Click to replace" : subtitle,
                    style: TextStyle(
                      fontSize: 11.5,
                      color: isUploaded ? AppColors.primaryBlue : AppColors.textMuted,
                      fontWeight: isUploaded ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              isUploaded ? Icons.replay_rounded : Icons.cloud_upload_outlined,
              color: isUploaded ? AppColors.primaryBlue : AppColors.textMuted,
              size: 22,
            ),
          ],
        ),
      ),
    );
  }
}
