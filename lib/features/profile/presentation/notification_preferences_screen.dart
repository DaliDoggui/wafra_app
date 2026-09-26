import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class NotificationPreferencesScreen extends StatefulWidget {
  const NotificationPreferencesScreen({super.key});

  @override
  State<NotificationPreferencesScreen> createState() => _NotificationPreferencesScreenState();
}

class _NotificationPreferencesScreenState extends State<NotificationPreferencesScreen> {
  bool _masterNotifications = true;
  bool _newOffers = true;
  bool _nearStores = true;
  bool _priceDrops = true;

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
          "Notification Preferences",
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              // Master Notifications Switch
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text(
                  "Notifications",
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                ),
                trailing: Switch(
                  value: _masterNotifications,
                  activeTrackColor: AppColors.primaryBlue,
                  onChanged: (val) {
                    setState(() {
                      _masterNotifications = val;
                      _newOffers = val;
                      _nearStores = val;
                      _priceDrops = val;
                    });
                  },
                ),
              ),

              const SizedBox(height: 12),

              // Sub-Preferences Card (Matching Screenshot 3)
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  children: [
                    _buildNotifTile(
                      title: "New Offers",
                      subtitle: "Get notified about new discounts and deals",
                      value: _newOffers,
                      onChanged: (val) => setState(() => _newOffers = val),
                    ),
                    const Divider(height: 1),
                    _buildNotifTile(
                      title: "Near Stores",
                      subtitle: "Get notified when stores are near your location",
                      value: _nearStores,
                      onChanged: (val) => setState(() => _nearStores = val),
                    ),
                    const Divider(height: 1),
                    _buildNotifTile(
                      title: "Price Drops",
                      subtitle: "Get notified when prices drop",
                      value: _priceDrops,
                      onChanged: (val) => setState(() => _priceDrops = val),
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // Save Button (Capsule Vibrant Blue Button)
              ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Notification preferences saved successfully!"),
                      backgroundColor: AppColors.primaryBlue,
                    ),
                  );
                  Navigator.pop(context);
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
                  "Save",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNotifTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return SwitchListTile(
      value: value,
      activeTrackColor: AppColors.primaryBlue,
      onChanged: onChanged,
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.textPrimary),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
      ),
    );
  }
}
