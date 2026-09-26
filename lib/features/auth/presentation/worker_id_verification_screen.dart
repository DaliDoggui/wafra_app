import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../main_layout.dart';

class WorkerIdVerificationScreen extends StatefulWidget {
  const WorkerIdVerificationScreen({super.key});

  @override
  State<WorkerIdVerificationScreen> createState() => _WorkerIdVerificationScreenState();
}

class _WorkerIdVerificationScreenState extends State<WorkerIdVerificationScreen> {
  bool _frontUploaded = false;
  bool _backUploaded = false;

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
        title: const Text(
          "Worker ID Verification",
          style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 16),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Please Upload your Worker ID",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                "Upload a clear photo of your official ministry or civil worker card.",
                style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),

              const SizedBox(height: 24),

              // Upload Front Card
              _buildUploadBox(
                title: "Upload your Worker ID (Front)",
                isUploaded: _frontUploaded,
                onTap: () => setState(() => _frontUploaded = true),
              ),

              const SizedBox(height: 16),

              // Upload Back Card
              _buildUploadBox(
                title: "Upload your Worker ID (Back)",
                isUploaded: _backUploaded,
                onTap: () => setState(() => _backUploaded = true),
              ),

              const Spacer(),

              // Submit Button
              ElevatedButton(
                onPressed: () {
                  _showVerificationApprovedDialog(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(52),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(26),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  "Continue",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUploadBox({required String title, required bool isUploaded, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isUploaded ? Colors.blue.shade50 : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isUploaded ? AppColors.primaryBlue : Colors.grey.shade300,
            width: isUploaded ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              isUploaded ? Icons.check_circle : Icons.cloud_upload_outlined,
              color: isUploaded ? AppColors.primaryBlue : AppColors.textMuted,
              size: 28,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                isUploaded ? "$title (Uploaded)" : title,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: isUploaded ? AppColors.primaryBlue : AppColors.textPrimary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showVerificationApprovedDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircleAvatar(
              radius: 30,
              backgroundColor: AppColors.greenSuccess,
              child: Icon(Icons.check, color: Colors.white, size: 36),
            ),
            const SizedBox(height: 16),
            const Text(
              "Verified",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              "Your Worker ID verification request has been approved!\n\nWelcome to Wafra",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const MainLayout()),
                  (route) => false,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
                foregroundColor: Colors.white,
                minimumSize: const Size.fromHeight(44),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(22),
                ),
              ),
              child: const Text("Continue"),
            ),
          ],
        ),
      ),
    );
  }
}
