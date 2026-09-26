import 'package:flutter/material.dart';

class AppColors {
  static const Color primaryBlue = Color(0xFF0066FF);       // Wafra Vibrant Electric Blue
  static const Color darkNavy = Color(0xFF0F172A);          // Dark Navy text & logo color
  static const Color background = Color(0xFFF4F5F9);        // Soft Light Grayish Blue Background
  static const Color cardBg = Colors.white;
  
  static const Color discountYellow = Color(0xFFFFE600);    // Bright Yellow Discount Badge
  static const Color discountYellowText = Color(0xFF000000);
  
  static const Color textPrimary = Color(0xFF1E293B);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color textMuted = Color(0xFF94A3B8);
  
  static const Color border = Color(0xFFE2E8F0);
  static const Color greenSuccess = Color(0xFF10B981);
  static const Color redError = Color(0xFFEF4444);

  static const LinearGradient logoGradient = LinearGradient(
    colors: [Color(0xFF00C6FF), Color(0xFF0066FF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
