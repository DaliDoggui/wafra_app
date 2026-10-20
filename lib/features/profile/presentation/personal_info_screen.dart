import 'dart:convert';
import 'package:flutter/material.dart';
import '../../../core/localization/app_locale.dart';
import '../../../core/network/api_client.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/image_picker_helper.dart';
import '../../../main.dart';
import 'change_email_screen.dart';
import 'change_phone_screen.dart';

class PersonalInfoScreen extends StatefulWidget {
  const PersonalInfoScreen({super.key});

  @override
  State<PersonalInfoScreen> createState() => _PersonalInfoScreenState();
}

class _PersonalInfoScreenState extends State<PersonalInfoScreen> {
  final List<String> _interests = [
    "Food", "Drinks", "Sweets", "Health",
    "Fitness", "Sports", "Games", "Fashion",
    "Accessories", "Travel", "Hotels", "Clothing"
  ];

  static const Map<String, String> _interestTranslations = {
    "Food": "مطاعم",
    "Drinks": "مشروبات",
    "Sweets": "حلويات",
    "Health": "صحة",
    "Fitness": "لياقة",
    "Sports": "رياضة",
    "Games": "ألعاب",
    "Fashion": "أزياء",
    "Accessories": "إكسسوارات",
    "Travel": "سفر",
    "Hotels": "فنادق",
    "Clothing": "ملابس",
  };

  final Set<String> _selectedInterests = {"Food", "Health", "Fitness", "Fashion"};
  bool _isLoadingInterests = false;

  @override
  void initState() {
    super.initState();
    _loadProfileAndInterests();
  }

  Future<void> _loadProfileAndInterests() async {
    setState(() => _isLoadingInterests = true);
    await ApiClient.instance.fetchUserProfile();
    final savedInterests = await ApiClient.instance.getUserInterests();
    if (savedInterests.isNotEmpty && mounted) {
      setState(() {
        _selectedInterests.clear();
        _selectedInterests.addAll(savedInterests);
      });
    }
    if (mounted) setState(() => _isLoadingInterests = false);
  }

  void _showEditNameDialog() {
    final currentName = ApiClient.instance.currentUser?["full_name"]?.toString() ?? "";
    final nameController = TextEditingController(text: currentName);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Text(
          isArabic ? "طلب تعديل الاسم" : "Request Name Change",
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.amber.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.amber.shade300),
              ),
              child: Text(
                isArabic
                    ? "ملاحظة: تخضع طلبات تغيير الاسم لمراجعة وتدقيق الإدارة قبل تفعيلها."
                    : "Notice: Name changes must be verified and approved by the Administrator before taking effect.",
                style: const TextStyle(fontSize: 11.5, color: Colors.brown),
              ),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: isArabic ? "الاسم الكامل" : "Full Name",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(isArabic ? "إلغاء" : "Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              final newName = nameController.text.trim();
              if (newName.isNotEmpty && newName != currentName) {
                Navigator.pop(ctx);
                final res = await ApiClient.instance.requestProfileUpdate(fullName: newName);
                if (mounted) {
                  setState(() {});
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(isArabic ? "تم إرسال طلب تعديل الاسم للإدارة بنجاح!" : (res["message"] ?? "Name change submitted for Admin approval!")),
                      backgroundColor: Colors.orange.shade800,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryBlue, foregroundColor: Colors.white),
            child: Text(isArabic ? "إرسال للموافقة" : "Submit for Approval"),
          ),
        ],
      ),
    );
  }

  void _changeProfilePhoto() {
    final urlController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Text(
          isArabic ? "تغيير الصورة الشخصية" : "Change Profile Photo",
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              isArabic
                  ? "اختر صورة من هاتفك أو أدخل رابط الصورة."
                  : "Choose an image from your device or paste a photo URL.",
              style: const TextStyle(fontSize: 12.5, color: AppColors.textSecondary),
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
                      SnackBar(
                        content: Text(isArabic ? "تم تحديث الصورة الشخصية بنجاح!" : "Profile photo updated!"),
                        backgroundColor: AppColors.primaryBlue,
                      ),
                    );
                  }
                }
              },
              icon: const Icon(Icons.file_upload_outlined, size: 18),
              label: Text(isArabic ? "اختيار ملف صورة" : "Choose Photo File"),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
            const SizedBox(height: 12),
            Center(
              child: Text(
                isArabic ? "— أو ألصق رابط الصورة —" : "— OR PASTE IMAGE URL —",
                style: const TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold),
              ),
            ),
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
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(isArabic ? "إلغاء" : "Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              final text = urlController.text.trim();
              if (text.isNotEmpty) {
                await ApiClient.instance.updateProfilePhoto(text);
                if (ctx.mounted) Navigator.pop(ctx);
                if (mounted) {
                  setState(() {});
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(isArabic ? "تم تحديث الصورة الشخصية بنجاح!" : "Profile photo updated!"),
                      backgroundColor: AppColors.primaryBlue,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryBlue, foregroundColor: Colors.white),
            child: Text(isArabic ? "تطبيق" : "Apply"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = ApiClient.instance.currentUser;
    final photoUrl = user?["profile_photo"]?.toString() ?? "";
    final initial = (user?["full_name"]?.toString().trim().isNotEmpty ?? false)
        ? user!["full_name"].toString().trim().substring(0, 1).toUpperCase()
        : "W";

    Widget avatarWidget;
    if (photoUrl.startsWith("data:image")) {
      try {
        final base64Part = photoUrl.contains(",") ? photoUrl.split(",").last : photoUrl;
        avatarWidget = CircleAvatar(
          radius: 38,
          backgroundImage: MemoryImage(base64Decode(base64Part)),
        );
      } catch (_) {
        avatarWidget = CircleAvatar(
          radius: 38,
          backgroundColor: AppColors.darkNavy,
          child: Text(initial, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
        );
      }
    } else if (photoUrl.startsWith("http")) {
      avatarWidget = CircleAvatar(
        radius: 38,
        backgroundImage: NetworkImage(photoUrl),
      );
    } else {
      avatarWidget = CircleAvatar(
        radius: 38,
        backgroundColor: AppColors.darkNavy,
        child: Text(initial, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
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
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, size: 18, color: textCol),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          isArabic ? "المعلومات الشخصية" : "Personal Information",
          style: TextStyle(
            color: textCol,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Pending Approval Notice Banner
              if (user?["has_pending_update"] == true)
                Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade50,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.amber.shade400),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.pending_actions_rounded, color: Colors.amber, size: 24),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isArabic ? "طلب تحديث الحساب قيد المراجعة" : "Profile Update Under Review",
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.brown),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              isArabic
                                  ? "تم إرسال تعديلاتك إلى الإدارة وهي قيد المراجعة والتدقيق."
                                  : "Changes to your personal details are submitted and pending Admin verification.",
                              style: TextStyle(fontSize: 11.5, color: Colors.brown.shade800),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

              // User Avatar Card Header
              Center(
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: _changeProfilePhoto,
                      child: Stack(
                        children: [
                          avatarWidget,
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              padding: const EdgeInsets.all(5),
                              decoration: const BoxDecoration(
                                color: AppColors.primaryBlue,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.edit, size: 14, color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Builder(
                      builder: (context) {
                        final user = ApiClient.instance.currentUser;
                        final name = user?["full_name"]?.toString() ?? (isArabic ? "عضو وفرة" : "Wafra Member");
                        final email = user?["email"]?.toString() ?? "member@wafra.kw";
                        final civilId = user?["civil_id"]?.toString() ?? "";
                        return Column(
                          children: [
                            Text(
                              name,
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: textCol),
                            ),
                            Text(
                              civilId.isNotEmpty ? "$email • ${isArabic ? 'الرقم المدني:' : 'ID:'} $civilId" : email,
                              style: TextStyle(color: textSecondary, fontSize: 12),
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Interests Chips Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    isArabic ? "الاهتمامات المفضلة" : "Target Interests",
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: textCol),
                  ),
                  if (_isLoadingInterests)
                    const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2))
                  else
                    Text(
                      "${_selectedInterests.length} ${isArabic ? 'محدد' : 'selected'}",
                      style: const TextStyle(fontSize: 12, color: AppColors.primaryBlue, fontWeight: FontWeight.w600),
                    ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                isArabic
                    ? "اختر المجالات التي تهمك لنخصص لك الإشعارات والخصومات الأنسب."
                    : "Select deals you care about. We tailor notifications and discounts to your interests.",
                style: TextStyle(fontSize: 11.5, color: textSecondary),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _interests.map((interest) {
                  final isSelected = _selectedInterests.contains(interest);
                  final label = isArabic ? (_interestTranslations[interest] ?? interest) : interest;
                  return FilterChip(
                    selected: isSelected,
                    label: Text(label),
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : textCol,
                      fontSize: 12,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                    selectedColor: AppColors.primaryBlue,
                    backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(color: isSelected ? AppColors.primaryBlue : borderColor),
                    ),
                    onSelected: (val) async {
                      setState(() {
                        if (val) {
                          _selectedInterests.add(interest);
                        } else {
                          _selectedInterests.remove(interest);
                        }
                      });
                      await ApiClient.instance.updateUserInterests(_selectedInterests.toList());
                    },
                  );
                }).toList(),
              ),

              const SizedBox(height: 24),

              // Authentication Actions Card
              Text(
                isArabic ? "الملف الشخصي والتحقق" : "Profile & Authentication",
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: textCol),
              ),
              const SizedBox(height: 10),
              Container(
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: borderColor),
                ),
                child: Column(
                  children: [
                    ListTile(
                      leading: Icon(Icons.person_outline, size: 20, color: textCol),
                      title: Text(isArabic ? "تعديل الاسم الكامل" : "Edit Full Name", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: textCol)),
                      subtitle: Text(isArabic ? "يتطلب موافقة الإدارة" : "Requires Admin approval", style: TextStyle(fontSize: 11, color: textSecondary)),
                      trailing: Icon(isArabic ? Icons.arrow_back_ios : Icons.arrow_forward_ios, size: 14, color: textSecondary),
                      onTap: _showEditNameDialog,
                    ),
                    Divider(height: 1, color: borderColor),
                    ListTile(
                      leading: Icon(Icons.email_outlined, size: 20, color: textCol),
                      title: Text(isArabic ? "تغيير البريد الإلكتروني" : "Change Email", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: textCol)),
                      subtitle: Text(isArabic ? "يتطلب موافقة الإدارة" : "Requires Admin approval", style: TextStyle(fontSize: 11, color: textSecondary)),
                      trailing: Icon(isArabic ? Icons.arrow_back_ios : Icons.arrow_forward_ios, size: 14, color: textSecondary),
                      onTap: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const ChangeEmailScreen()),
                        );
                        if (mounted) setState(() {});
                      },
                    ),
                    Divider(height: 1, color: borderColor),
                    ListTile(
                      leading: Icon(Icons.phone_android_outlined, size: 20, color: textCol),
                      title: Text(isArabic ? "إضافة/تغيير رقم الهاتف" : "Add/Change Phone number", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: textCol)),
                      subtitle: Text(isArabic ? "يتطلب موافقة الإدارة" : "Requires Admin approval", style: TextStyle(fontSize: 11, color: textSecondary)),
                      trailing: Icon(isArabic ? Icons.arrow_back_ios : Icons.arrow_forward_ios, size: 14, color: textSecondary),
                      onTap: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const ChangePhoneScreen()),
                        );
                        if (mounted) setState(() {});
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
