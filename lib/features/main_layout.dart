import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
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

  final List<Widget> _screens = const [
    HomeDashboard(),
    CategoriesScreen(),
    SavedOffersScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Colors.grey.shade200)),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: AppColors.primaryBlue,
          unselectedItemColor: Colors.black87,
          showSelectedLabels: false,
          showUnselectedLabels: false,
          elevation: 0,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined, size: 24),
              activeIcon: Icon(Icons.home, size: 26, color: AppColors.primaryBlue),
              label: "Home",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.grid_view_outlined, size: 24),
              activeIcon: Icon(Icons.grid_view, size: 26, color: AppColors.primaryBlue),
              label: "Categories",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.favorite_outline, size: 24),
              activeIcon: Icon(Icons.favorite, size: 26, color: AppColors.primaryBlue),
              label: "Saved",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline, size: 24),
              activeIcon: Icon(Icons.person, size: 26, color: AppColors.primaryBlue),
              label: "Profile",
            ),
          ],
        ),
      ),
    );
  }
}
