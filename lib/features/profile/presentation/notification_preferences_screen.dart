import 'package:flutter/material.dart';
import '../../../core/localization/app_locale.dart';
import '../../../core/theme/app_colors.dart';
import '../../../main.dart';

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
    final isDark = themeModeNotifier.value == ThemeMode.dark;
    final bgColor = isDark ? const Color(0xFF0F172A) : AppColors.background;
    final cardBg = isDark ? const Color(0xFF1E293B) : Colors.white;
    final textCol = isDark ? Colors.white : AppColors.textPrimary;
    final textMutedCol = isDark ? const Color(0xFF94A3B8) : AppColors.textSecondary;
    final borderColor = isDark ? const Color(0xFF334155) : Colors.grey.shade200;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: cardBg,
        elevation: 0.5,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, size: 18, color: textCol),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          isArabic ? "تفضيلات الإشعارات" : "Notification Preferences",
          style: TextStyle(
            color: textCol,
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
                title: Text(
                  isArabic ? "الإشعارات العامة" : "Notifications",
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: textCol),
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

              // Sub-Preferences Card
              Container(
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: borderColor),
                ),
                child: Column(
                  children: [
                    _buildNotifTile(
                      title: isArabic ? "عروض جديدة" : "New Offers",
                      subtitle: isArabic ? "احصل على إشعارات بالعروض والخصومات الجديدة" : "Get notified about new discounts and deals",
                      value: _newOffers,
                      textCol: textCol,
                      textMutedCol: textMutedCol,
                      onChanged: (val) => setState(() => _newOffers = val),
                    ),
                    Divider(height: 1, color: borderColor),
                    _buildNotifTile(
                      title: isArabic ? "متاجر قريبة" : "Near Stores",
                      subtitle: isArabic ? "تنبيه عند اقترابك من المتاجر الشريكة" : "Get notified when stores are near your location",
                      value: _nearStores,
                      textCol: textCol,
                      textMutedCol: textMutedCol,
                      onChanged: (val) => setState(() => _nearStores = val),
                    ),
                    Divider(height: 1, color: borderColor),
                    _buildNotifTile(
                      title: isArabic ? "تخفيضات الأسعار" : "Price Drops",
                      subtitle: isArabic ? "تنبيه عند انخفاض الأسعار والخصومات الإضافية" : "Get notified when prices drop",
                      value: _priceDrops,
                      textCol: textCol,
                      textMutedCol: textMutedCol,
                      onChanged: (val) => setState(() => _priceDrops = val),
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // Save Button
              ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(isArabic ? "تم حفظ تفضيلات الإشعارات بنجاح!" : "Notification preferences saved successfully!"),
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
                child: Text(
                  isArabic ? "حفظ" : "Save",
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
    required Color textCol,
    required Color textMutedCol,
    required ValueChanged<bool> onChanged,
  }) {
    return SwitchListTile(
      value: value,
      activeTrackColor: AppColors.primaryBlue,
      onChanged: onChanged,
      title: Text(
        title,
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: textCol),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(fontSize: 12, color: textMutedCol),
      ),
    );
  }
}
