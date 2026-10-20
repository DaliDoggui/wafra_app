import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../main_layout.dart';
import 'login_screen.dart';

class VerificationStatusScreen extends StatefulWidget {
  final bool isInitiallyApproved;

  const VerificationStatusScreen({
    super.key,
    this.isInitiallyApproved = false,
  });

  @override
  State<VerificationStatusScreen> createState() => _VerificationStatusScreenState();
}

class _VerificationStatusScreenState extends State<VerificationStatusScreen> {
  late bool _isApproved;

  @override
  void initState() {
    super.initState();
    _isApproved = widget.isInitiallyApproved;
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
        title: const Text(
          'Verification Status',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 16),

              // Status Icon Burst
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  color: _isApproved ? const Color(0xFFE8F5E9) : const Color(0xFFFFF7ED),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: _isApproved ? const Color(0x3D10B981) : const Color(0x3DF97316),
                      blurRadius: 20,
                      spreadRadius: 4,
                    ),
                  ],
                ),
                child: Center(
                  child: Container(
                    width: 66,
                    height: 66,
                    decoration: BoxDecoration(
                      color: _isApproved ? AppColors.greenSuccess : const Color(0xFFF97316),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _isApproved ? Icons.verified_rounded : Icons.hourglass_top_rounded,
                      color: Colors.white,
                      size: 36,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Status Title
              Text(
                _isApproved ? 'Ministry ID Verified' : 'Under Review by Ministry',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: _isApproved ? const Color(0xFF1E293B) : const Color(0xFF9A3412),
                ),
              ),
              const SizedBox(height: 8),

              // Status Description
              Text(
                _isApproved
                    ? 'Your ministry credentials have been verified successfully. You now have full access to all partner discounts!'
                    : 'Your worker ID card was uploaded and submitted to the Ministry for official verification. This usually takes 24 hours.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 28),

              // Timeline Progress Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  children: [
                    _buildTimelineStep(
                      step: '1',
                      title: 'Documents Submitted',
                      subtitle: 'Front & back of worker ID received',
                      isCompleted: true,
                    ),
                    _buildTimelineLine(isCompleted: true),
                    _buildTimelineStep(
                      step: '2',
                      title: 'Ministry Database Check',
                      subtitle: _isApproved ? 'Employee identity confirmed' : 'Matching Worker ID with employee records',
                      isCompleted: _isApproved,
                      isInProgress: !_isApproved,
                    ),
                    _buildTimelineLine(isCompleted: _isApproved),
                    _buildTimelineStep(
                      step: '3',
                      title: 'Dynamic QR Code Active',
                      subtitle: _isApproved ? 'Ready to scan at partner stores' : 'Unlocked upon approval',
                      isCompleted: _isApproved,
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // Action Button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () {
                    if (_isApproved) {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (_) => const MainLayout()),
                        (route) => false,
                      );
                    } else {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (_) => const LoginScreen()),
                        (route) => false,
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(26),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    _isApproved ? 'Start Exploring Deals' : 'Back to Login / العودة لتسجيل الدخول',
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTimelineStep({
    required String step,
    required String title,
    required String subtitle,
    bool isCompleted = false,
    bool isInProgress = false,
  }) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: isCompleted
                ? AppColors.greenSuccess
                : (isInProgress ? const Color(0xFFF97316) : Colors.grey.shade200),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: isCompleted
                ? const Icon(Icons.check, color: Colors.white, size: 18)
                : Text(
                    step,
                    style: TextStyle(
                      color: isInProgress ? Colors.white : Colors.grey.shade600,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 11.5,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTimelineLine({required bool isCompleted}) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(left: 15),
        height: 20,
        width: 2,
        color: isCompleted ? AppColors.greenSuccess : Colors.grey.shade300,
      ),
    );
  }
}
