import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import 'settings_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        title: const Text(
          "Profile",
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: AppColors.textPrimary),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              // User Avatar & Info
              const CircleAvatar(
                radius: 40,
                backgroundColor: AppColors.darkNavy,
                child: Icon(Icons.person, size: 48, color: Colors.white),
              ),
              const SizedBox(height: 12),
              const Text(
                "Foulen Ben Foulen",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 2),
              const Text(
                "text@example.com",
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),

              const SizedBox(height: 24),

              // 3 Stat Summary Boxes Card (Matching Screenshot 3)
              Container(
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatBox("10", "Saved Offers"),
                    Container(height: 36, width: 1, color: Colors.grey.shade200),
                    _buildStatBox("10", "Used Deals"),
                    Container(height: 36, width: 1, color: Colors.grey.shade200),
                    _buildStatBox("10 KD", "Total Savings"),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Options Menu List Card (Matching Screenshot 3)
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  children: [
                    _buildProfileTile(
                      icon: Icons.receipt_long_outlined,
                      title: "My Orders",
                      subtitle: "View your purchases",
                      onTap: () {},
                    ),
                    const Divider(height: 1, indent: 50),
                    _buildProfileTile(
                      icon: Icons.favorite_border,
                      title: "Saved Offers",
                      subtitle: "Your favorite deals",
                      onTap: () {},
                    ),
                    const Divider(height: 1, indent: 50),
                    _buildProfileTile(
                      icon: Icons.notifications_none_outlined,
                      title: "Notifications",
                      subtitle: "Deal updates and alerts",
                      onTap: () {},
                    ),
                    const Divider(height: 1, indent: 50),
                    _buildProfileTile(
                      icon: Icons.help_outline,
                      title: "Help & Support",
                      subtitle: "Get help when you need",
                      onTap: () {},
                    ),
                    const Divider(height: 1, indent: 50),
                    _buildProfileTile(
                      icon: Icons.settings_outlined,
                      title: "Settings",
                      subtitle: "Account and preferences...",
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const SettingsScreen()),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatBox(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildProfileTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      onTap: onTap,
      leading: Icon(icon, color: AppColors.textPrimary, size: 22),
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 14,
          color: AppColors.textPrimary,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
      ),
      trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: AppColors.textMuted),
    );
  }
}
