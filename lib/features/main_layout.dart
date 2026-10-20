import 'package:flutter/material.dart';
import '../core/localization/app_locale.dart';
import '../core/theme/app_colors.dart';
import '../main.dart';
import 'categories/presentation/categories_screen.dart';
import 'home/presentation/home_dashboard.dart';
import 'profile/presentation/profile_screen.dart';
import 'saved/presentation/saved_offers_screen.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeModeNotifier,
      builder: (context, themeMode, _) {
        return ValueListenableBuilder<Locale>(
          valueListenable: appLocaleNotifier,
          builder: (context, locale, _) {
            final isDark = themeMode == ThemeMode.dark;
            final navBg = isDark ? const Color(0xFF1E293B) : Colors.white;
            final borderColor = isDark ? const Color(0xFF334155) : Colors.grey.shade200;
            final unselectedColor = isDark ? Colors.grey.shade400 : Colors.black87;

            return Scaffold(
              body: IndexedStack(
                key: ValueKey('${locale.languageCode}_${themeMode.name}'),
                index: _currentIndex,
                children: const [
                  HomeDashboard(),
                  CategoriesScreen(),
                  SavedOffersScreen(),
                  ProfileScreen(),
                ],
              ),
              bottomNavigationBar: Container(
                decoration: BoxDecoration(
                  color: navBg,
                  border: Border(top: BorderSide(color: borderColor)),
                ),
                child: BottomNavigationBar(
                  currentIndex: _currentIndex,
                  onTap: (index) => setState(() => _currentIndex = index),
                  type: BottomNavigationBarType.fixed,
                  backgroundColor: navBg,
                  selectedItemColor: AppColors.primaryBlue,
                  unselectedItemColor: unselectedColor,
                  showSelectedLabels: false,
                  showUnselectedLabels: false,
                  elevation: 0,
                  items: [
                    BottomNavigationBarItem(
                      icon: const Icon(Icons.home_outlined, size: 24),
                      activeIcon: const Icon(Icons.home, size: 26, color: AppColors.primaryBlue),
                      label: tr('home'),
                    ),
                    BottomNavigationBarItem(
                      icon: const Icon(Icons.grid_view_outlined, size: 24),
                      activeIcon: const Icon(Icons.grid_view, size: 26, color: AppColors.primaryBlue),
                      label: tr('categories'),
                    ),
                    BottomNavigationBarItem(
                      icon: const Icon(Icons.favorite_outline, size: 24),
                      activeIcon: const Icon(Icons.favorite, size: 26, color: AppColors.primaryBlue),
                      label: tr('saved_offers'),
                    ),
                    BottomNavigationBarItem(
                      icon: const Icon(Icons.person_outline, size: 24),
                      activeIcon: const Icon(Icons.person, size: 26, color: AppColors.primaryBlue),
                      label: tr('profile'),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
