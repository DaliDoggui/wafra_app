import '../../../core/localization/app_locale.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
import '../../../core/network/api_client.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/image_picker_helper.dart';
import '../../../models/category_model.dart';
import '../../../services/realtime_sync_service.dart';
import '../../../main.dart';
import '../../auth/presentation/login_screen.dart';
import '../../categories/presentation/categories_screen.dart';
import '../../notifications/presentation/notifications_screen.dart';
import '../../orders/presentation/my_orders_screen.dart';
import '../../saved/presentation/saved_offers_screen.dart';
import 'change_password_screen.dart';
import 'help_support_screen.dart';
import 'settings_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    RealTimeSyncService.instance.addListener(_onSyncChanged);
    RealTimeSyncService.instance.initialize();
  }

  @override
  void dispose() {
    RealTimeSyncService.instance.removeListener(_onSyncChanged);
    super.dispose();
  }

  void _onSyncChanged() {
    if (mounted) setState(() {});
  }

  void _changeProfilePhoto() {
    final urlController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text("Change Profile Photo", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              "Choose an image from your device or paste a photo URL.",
              style: TextStyle(fontSize: 12.5, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () async {
                final dataUrl = await pickImageAsDataUrl();
                if (dataUrl != null && dataUrl.isNotEmpty) {
                  await ApiClient.instance.updateProfilePhoto(dataUrl);
                  if (ctx.mounted) Navigator.pop(ctx);
                  if (mounted) {
                    setState(() {});
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Profile photo updated!"), backgroundColor: AppColors.primaryBlue),
                    );
                  }
                }
              },
              icon: const Icon(Icons.file_upload_outlined, size: 18),
              label: const Text("Choose Photo File"),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
            const SizedBox(height: 12),
            const Center(child: Text("— OR PASTE IMAGE URL —", style: TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold))),
            const SizedBox(height: 10),
            TextField(
              controller: urlController,
              decoration: InputDecoration(
                hintText: "https://...",
                hintStyle: const TextStyle(fontSize: 12),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () async {
              final text = urlController.text.trim();
              if (text.isNotEmpty) {
                await ApiClient.instance.updateProfilePhoto(text);
                if (ctx.mounted) Navigator.pop(ctx);
                if (mounted) {
                  setState(() {});
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Profile photo updated!"), backgroundColor: AppColors.primaryBlue),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryBlue, foregroundColor: Colors.white),
            child: const Text("Apply"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = ApiClient.instance.currentUser;
    final fullName = user?["full_name"]?.toString() ?? "Kuwait Civil Servant";
    final email = user?["email"]?.toString() ?? "employee@wafra.kw";
    final civilId = user?["civil_id"]?.toString() ?? "";
    final ministry = user?["ministry"]?.toString() ?? "Civil Service Commission";

    final sync = RealTimeSyncService.instance;
    final savedOffers = sync.savedCount.toString();
    final usedDeals = sync.usedDealsCount.toString();
    final totalSavings = sync.totalSavingsKd.toStringAsFixed(1);

    final initial = fullName.trim().isNotEmpty ? fullName.trim().substring(0, 1).toUpperCase() : "W";
    final photoUrl = user?["profile_photo"]?.toString() ?? "";

    Widget avatarWidget;
    if (photoUrl.startsWith("data:image")) {
      try {
        final base64Part = photoUrl.contains(",") ? photoUrl.split(",").last : photoUrl;
        avatarWidget = CircleAvatar(
          radius: 42,
          backgroundImage: MemoryImage(base64Decode(base64Part)),
        );
      } catch (_) {
        avatarWidget = CircleAvatar(
          radius: 42,
          backgroundColor: AppColors.darkNavy,
          child: Text(initial, style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white)),
        );
      }
    } else if (photoUrl.startsWith("http")) {
      avatarWidget = CircleAvatar(
        radius: 42,
        backgroundImage: NetworkImage(photoUrl),
      );
    } else {
      avatarWidget = CircleAvatar(
        radius: 42,
        backgroundColor: AppColors.darkNavy,
        child: Text(initial, style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white)),
      );
    }

    final isDark = themeModeNotifier.value == ThemeMode.dark;
    final cardBg = isDark ? const Color(0xFF1E293B) : Colors.white;
    final borderColor = isDark ? const Color(0xFF334155) : Colors.grey.shade200;
    final textCol = isDark ? Colors.white : AppColors.textPrimary;
    final textSecondary = isDark ? const Color(0xFF94A3B8) : AppColors.textSecondary;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F172A) : AppColors.background,
      appBar: AppBar(
        backgroundColor: cardBg,
        elevation: 0.5,
        title: Text(
          tr("profile"),
          style: TextStyle(
            color: textCol,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.settings_outlined, color: textCol),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              ).then((_) => RealTimeSyncService.instance.refreshStats());
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
              GestureDetector(
                onTap: _changeProfilePhoto,
                child: Stack(
                  children: [
                    avatarWidget,
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: AppColors.primaryBlue,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: const Icon(Icons.camera_alt, color: Colors.white, size: 14),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Text(
                fullName,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: textCol,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                email,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 8),

              // Ministry & Civil ID Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.primaryBlue.withValues(alpha: 0.25)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.verified_user_outlined, size: 14, color: AppColors.primaryBlue),
                    const SizedBox(width: 6),
                    Text(
                      "$ministry ${civilId.isNotEmpty ? '• ID: $civilId' : ''}",
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryBlue,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // 3 Stat Summary Boxes — all tappable → My Orders
              GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const MyOrdersScreen()),
                ),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                  decoration: BoxDecoration(
                    color: cardBg,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: borderColor),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatBox(savedOffers, tr("saved_offers"), textCol: textCol, textSecondary: textSecondary),
                      Container(height: 36, width: 1, color: borderColor),
                      _buildStatBox(usedDeals, tr("used_deals"), textCol: textCol, textSecondary: textSecondary),
                      Container(height: 36, width: 1, color: borderColor),
                      _buildStatBox("$totalSavings KD", tr("total_savings"), textCol: textCol, textSecondary: textSecondary),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Options Menu List Card
              Container(
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: borderColor),
                ),
                child: Column(
                  children: [
                    _buildProfileTile(
                      icon: Icons.receipt_long_outlined,
                      title: isArabic ? "طلباتي" : "My Orders",
                      subtitle: isArabic ? "عرض سجل الخصومات المستخدمة" : "View your discount redemptions",
                      textCol: textCol,
                      textSecondary: textSecondary,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const MyOrdersScreen()),
                        );
                      },
                    ),
                    Divider(height: 1, indent: 50, color: borderColor),
                    _buildProfileTile(
                      icon: Icons.favorite_border,
                      title: isArabic ? "العروض المحفوظة" : "Saved Offers",
                      subtitle: isArabic ? "عروضك وتخفيضاتك المفضلة" : "Your favorite deals",
                      textCol: textCol,
                      textSecondary: textSecondary,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const SavedOffersScreen()),
                        );
                      },
                    ),
                    Divider(height: 1, indent: 50, color: borderColor),
                    _buildProfileTile(
                      icon: Icons.lock_outline_rounded,
                      title: isArabic ? "تغيير كلمة المرور" : "Change Password",
                      subtitle: isArabic ? "تحديث أمان الحساب وكلمة السر" : "Update your account security",
                      textCol: textCol,
                      textSecondary: textSecondary,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const ChangePasswordScreen()),
                        );
                      },
                    ),
                    Divider(height: 1, indent: 50, color: borderColor),
                    _buildProfileTile(
                      icon: Icons.notifications_none_outlined,
                      title: isArabic ? "الإشعارات" : "Notifications",
                      subtitle: isArabic ? "تنبيهات العروض والتخفيضات" : "Deal updates and alerts",
                      textCol: textCol,
                      textSecondary: textSecondary,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const NotificationsScreen()),
                        );
                      },
                    ),
                    Divider(height: 1, indent: 50, color: borderColor),
                    _buildProfileTile(
                      icon: Icons.help_outline,
                      title: isArabic ? "المساعدة والدعم" : "Help & Support",
                      subtitle: isArabic ? "احصل على المساعدة والإجابات" : "Get help when you need",
                      textCol: textCol,
                      textSecondary: textSecondary,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const HelpSupportScreen()),
                        );
                      },
                    ),
                    Divider(height: 1, indent: 50, color: borderColor),
                    _buildProfileTile(
                      icon: Icons.settings_outlined,
                      title: isArabic ? "الإعدادات" : "Settings",
                      subtitle: isArabic ? "الحساب والتفضيلات..." : "Account and preferences...",
                      textCol: textCol,
                      textSecondary: textSecondary,
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

              const SizedBox(height: 20),

              // Quick Category Shortcuts
              Align(
                alignment: isArabic ? Alignment.centerRight : Alignment.centerLeft,
                child: Text(
                  isArabic ? "تصفح التصنيفات" : "Browse Categories",
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: textCol,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: categoriesList.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 0.85,
                ),
                itemBuilder: (context, index) {
                  final cat = categoriesList[index];
                  return GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => CategoriesScreen(initialCategory: cat),
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF1E293B) : cat.iconBgColor,
                            borderRadius: BorderRadius.circular(14),
                            border: isDark ? Border.all(color: borderColor) : null,
                          ),
                          child: Icon(cat.icon,
                              color: AppColors.primaryBlue, size: 22),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          cat.localizedTitle.split(" ").first,
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: textCol,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),

              const SizedBox(height: 20),

              // Disconnect & Delete
              Container(
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: borderColor),
                ),
                child: Column(
                  children: [
                    _buildDangerTile(
                      title: isArabic ? "تسجيل الخروج" : "Disconnect",
                      icon: Icons.logout_rounded,
                      onTap: () => _showConfirmationModal(context, "Disconnect", cardBg, textCol, textSecondary),
                    ),
                    Divider(height: 1, indent: 16, color: borderColor),
                    _buildDangerTile(
                      title: isArabic ? "حذف الحساب" : "Delete Account",
                      icon: Icons.delete_outline_rounded,
                      isDestructive: true,
                      onTap: () => _showConfirmationModal(context, "Delete", cardBg, textCol, textSecondary),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatBox(String value, String label, {Color? textCol, Color? textSecondary}) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: textCol ?? AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: textSecondary ?? AppColors.textSecondary,
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
    Color? textCol,
    Color? textSecondary,
  }) {
    return ListTile(
      onTap: onTap,
      leading: Icon(icon, color: textCol ?? AppColors.textPrimary, size: 22),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 14,
          color: textCol ?? AppColors.textPrimary,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(fontSize: 11, color: textSecondary ?? AppColors.textSecondary),
      ),
      trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: AppColors.textMuted),
    );
  }

  Widget _buildDangerTile({
    required String title,
    required IconData icon,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return ListTile(
      onTap: onTap,
      leading: Icon(icon,
          color: isDestructive ? AppColors.textMuted : Colors.red, size: 20),
      title: Text(
        title,
        style: TextStyle(
          color: isDestructive ? AppColors.textMuted : Colors.red,
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
    );
  }

  void _showConfirmationModal(BuildContext context, String actionType, Color cardBg, Color textCol, Color textSecondary) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: cardBg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                actionType == "Disconnect" ? "Log Out?" : "Delete Account?",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: textCol,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                actionType == "Disconnect"
                    ? "You will be logged out of your session on this device."
                    : "This will permanently remove your account, saved offers, and redemption history. This action cannot be undone.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: textSecondary),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  Navigator.pop(ctx);
                  if (actionType == "Disconnect") {
                    await ApiClient.instance.logout();
                  } else {
                    final res = await ApiClient.instance.deleteAccount();
                    if (context.mounted && !res["success"]) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(res["message"] ?? "Failed to delete account")),
                      );
                      return;
                    }
                  }
                  if (context.mounted) {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                      (route) => false,
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade600,
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(46),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: Text(
                  actionType == "Disconnect" ? "Log Out" : "Permanently Delete",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 12),
              GestureDetector(
                onTap: () => Navigator.pop(ctx),
                child: const Text("Cancel",
                    style:
                        TextStyle(fontSize: 13, color: AppColors.textMuted)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
