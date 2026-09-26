import 'package:flutter/material.dart';
import 'core/theme/app_colors.dart';
import 'features/onboarding/presentation/onboarding_screen.dart';

void main() {
  runApp(const WafraDiscountApp());
}

class WafraDiscountApp extends StatelessWidget {
  const WafraDiscountApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Wafra - More for Less',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primaryBlue,
          primary: AppColors.primaryBlue,
        ),
        scaffoldBackgroundColor: AppColors.background,
        useMaterial3: true,
        fontFamily: 'Roboto',
      ),
      home: const OnboardingScreen(),
    );
  }
}
