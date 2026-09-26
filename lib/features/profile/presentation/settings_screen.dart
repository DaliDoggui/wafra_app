import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../auth/presentation/login_screen.dart';
import 'notification_preferences_screen.dart';
import 'personal_info_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _emailNotifications = true;
  bool _useCurrentLocation = true;
  bool _lightMode = true;
  double _rangeDistance = 1000;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 18, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Settings",
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(18.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // User Header Summary
              const Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: AppColors.darkNavy,
                    child: Icon(Icons.person, color: Colors.white),
                  ),
                  SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Foulen Ben Foulen",
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      Text(
                        "text@example.com",
                        style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Account Section
              _buildSectionHeader("Account"),
              _buildSettingsCard([
                _buildTile("Personal Information", Icons.person_outline, onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const PersonalInfoScreen()));
                }),
                const Divider(height: 1),
                _buildTile("Change Password", Icons.lock_outline, onTap: () {}),
                const Divider(height: 1),
                _buildSwitchTile("Email Notifications", Icons.email_outlined, _emailNotifications, (val) {
                  setState(() => _emailNotifications = val);
                }),
              ]),

              const SizedBox(height: 20),

              // Location & Distance Section
              _buildSectionHeader("Location & Distance"),
              _buildSettingsCard([
                _buildTile("Select range distance", Icons.location_searching, subtitle: "${_rangeDistance.round()}m", onTap: () {
                  _showRangeDistanceModal(context);
                }),
                const Divider(height: 1),
                _buildSwitchTile("Use my current location", Icons.my_location, _useCurrentLocation, (val) {
                  setState(() => _useCurrentLocation = val);
                }),
                const Divider(height: 1),
                _buildTile("Preferred Location", Icons.map_outlined, subtitle: "Kuwait City", onTap: () {}),
              ]),

              const SizedBox(height: 20),

              // App Preferences Section
              _buildSectionHeader("App Preferences"),
              _buildSettingsCard([
                _buildTile("Language", Icons.language, subtitle: "English", onTap: () {
                  _showLanguageModal(context);
                }),
                const Divider(height: 1),
                _buildSwitchTile("Appearance (Light Mode)", Icons.brightness_6_outlined, _lightMode, (val) {
                  setState(() => _lightMode = val);
                }),
                const Divider(height: 1),
                _buildTile("Notification Preferences", Icons.notifications_none_outlined, onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationPreferencesScreen()));
                }),
              ]),

              const SizedBox(height: 20),

              // Danger Zone Card
              _buildSettingsCard([
                ListTile(
                  onTap: () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                      (route) => false,
                    );
                  },
                  leading: const Icon(Icons.logout, color: Colors.red),
                  title: const Text(
                    "Disconnect",
                    style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                ),
              ]),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, left: 4.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.bold,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }

  Widget _buildSettingsCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildTile(String title, IconData icon, {String? subtitle, VoidCallback? onTap}) {
    return ListTile(
      onTap: onTap,
      leading: Icon(icon, color: AppColors.textPrimary, size: 20),
      title: Text(
        title,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (subtitle != null)
            Text(subtitle, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
          const SizedBox(width: 4),
          const Icon(Icons.arrow_forward_ios, size: 14, color: AppColors.textMuted),
        ],
      ),
    );
  }

  Widget _buildSwitchTile(String title, IconData icon, bool value, ValueChanged<bool> onChanged) {
    return ListTile(
      leading: Icon(icon, color: AppColors.textPrimary, size: 20),
      title: Text(
        title,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
      ),
      trailing: Switch(
        value: value,
        activeTrackColor: AppColors.primaryBlue,
        onChanged: onChanged,
      ),
    );
  }

  void _showRangeDistanceModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("Select Range Distance", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              Text("Maximum Distance: ${_rangeDistance.round()} meters", style: const TextStyle(color: AppColors.primaryBlue, fontWeight: FontWeight.bold)),
              Slider(
                value: _rangeDistance,
                min: 100,
                max: 5000,
                divisions: 49,
                activeColor: AppColors.primaryBlue,
                onChanged: (val) {
                  setModalState(() => _rangeDistance = val);
                  setState(() => _rangeDistance = val);
                },
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(ctx),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  minimumSize: const Size.fromHeight(48),
                ),
                child: const Text("Apply", style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showLanguageModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 16),
          const Text("Select Language", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ListTile(title: const Text("English"), trailing: const Icon(Icons.check, color: AppColors.primaryBlue), onTap: () => Navigator.pop(ctx)),
          ListTile(title: const Text("العربية (Arabic)"), onTap: () => Navigator.pop(ctx)),
          ListTile(title: const Text("Français (French)"), onTap: () => Navigator.pop(ctx)),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
