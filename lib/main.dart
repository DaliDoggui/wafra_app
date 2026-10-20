import 'package:flutter/material.dart';
import 'core/localization/app_locale.dart';
import 'core/network/api_client.dart';
import 'core/theme/app_colors.dart';
import 'features/main_layout.dart';
import 'features/onboarding/presentation/onboarding_screen.dart';
import 'services/system_notification_service.dart';

final ValueNotifier<ThemeMode> themeModeNotifier =
    ValueNotifier<ThemeMode>(ThemeMode.light);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initPreferences();
  await SystemNotificationService().init();
  final hasSession = await ApiClient.instance.loadSavedSession();
  runApp(WafraDiscountApp(initialRouteIsDashboard: hasSession));
}

class WafraDiscountApp extends StatelessWidget {
  final bool initialRouteIsDashboard;
  const WafraDiscountApp({super.key, this.initialRouteIsDashboard = false});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeModeNotifier,
      builder: (context, currentMode, _) {
        return ValueListenableBuilder<Locale>(
          valueListenable: appLocaleNotifier,
          builder: (context, currentLocale, _) {
            return MaterialApp(
              title: currentLocale.languageCode == 'ar' ? 'وفرة - وفّر أكثر' : 'Wafra - More for Less',
              debugShowCheckedModeBanner: false,
              locale: currentLocale,
              themeMode: currentMode,
              theme: ThemeData(
                brightness: Brightness.light,
                colorScheme: ColorScheme.fromSeed(
                  seedColor: AppColors.primaryBlue,
                  primary: AppColors.primaryBlue,
                  brightness: Brightness.light,
                ),
                scaffoldBackgroundColor: AppColors.background,
                cardColor: Colors.white,
                useMaterial3: true,
                fontFamily: currentLocale.languageCode == 'ar' ? 'Arial' : 'Roboto',
              ),
              darkTheme: ThemeData(
                brightness: Brightness.dark,
                colorScheme: ColorScheme.fromSeed(
                  seedColor: AppColors.primaryBlue,
                  primary: AppColors.primaryBlue,
                  brightness: Brightness.dark,
                  surface: const Color(0xFF1E293B),
                ),
                scaffoldBackgroundColor: const Color(0xFF0F172A),
                cardColor: const Color(0xFF1E293B),
                useMaterial3: true,
                fontFamily: currentLocale.languageCode == 'ar' ? 'Arial' : 'Roboto',
              ),
              builder: (context, child) {
                return Directionality(
                  textDirection: currentLocale.languageCode == 'ar' ? TextDirection.rtl : TextDirection.ltr,
                  child: child ?? const SizedBox.shrink(),
                );
              },
              home: initialRouteIsDashboard
                  ? const MainLayout()
                  : const OnboardingScreen(),
            );
          },
        );
      },
    );
  }
}
