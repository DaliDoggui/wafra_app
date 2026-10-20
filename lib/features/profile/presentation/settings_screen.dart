import 'package:flutter/material.dart';
import '../../../core/network/api_client.dart';
import '../../../core/theme/app_colors.dart';
import '../../../main.dart';
import '../../home/presentation/widgets/select_city_modal.dart';
import 'change_password_screen.dart';
import 'notification_preferences_screen.dart';
import 'personal_info_screen.dart';

import '../../../core/localization/app_locale.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _emailNotifications = true;
  bool _useCurrentLocation = true;
  double _rangeDistance = 1000;
  late String _preferredLocation;

  @override
  void initState() {
    super.initState();
    _preferredLocation = appLocationNotifier.value;
    appLocationNotifier.addListener(_onLocationChanged);
  }

  void _onLocationChanged() {
    if (mounted && _preferredLocation != appLocationNotifier.value) {
      setState(() => _preferredLocation = appLocationNotifier.value);
    }
  }

  @override
  void dispose() {
    appLocationNotifier.removeListener(_onLocationChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = themeModeNotifier.value == ThemeMode.dark;
    final isDarkMode = isDark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F172A) : AppColors.background,
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, size: 18, color: isDark ? Colors.white : AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          tr("settings"),
          style: TextStyle(
            color: isDark ? Colors.white : AppColors.textPrimary,
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
              Builder(
                builder: (context) {
                  final user = ApiClient.instance.currentUser;
                  final name = user?["full_name"]?.toString() ?? "Wafra Member";
                  final email = user?["email"]?.toString() ?? "member@wafra.kw";
                  final ministry = user?["ministry"]?.toString() ?? "Kuwait Civil Service";

                  return Row(
                    children: [
                      const CircleAvatar(
                        radius: 24,
                        backgroundColor: AppColors.primaryBlue,
                        child: Icon(Icons.person, color: Colors.white),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              name,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: isDark ? Colors.white : AppColors.textPrimary,
                              ),
                            ),
                            Text(
                              "$email • $ministry",
                              style: TextStyle(color: isDark ? Colors.white60 : AppColors.textSecondary, fontSize: 12),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),

              const SizedBox(height: 24),

              // Account Section
              _buildSectionHeader(tr("account")),
              _buildSettingsCard(context, [
                _buildTile(context, tr("personal_info"), Icons.person_outline, onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const PersonalInfoScreen()));
                }),
                const Divider(height: 1),
                _buildTile(context, tr("change_password"), Icons.lock_outline, onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const ChangePasswordScreen()));
                }),
                const Divider(height: 1),
                _buildSwitchTile(context, tr("email_notifications"), Icons.email_outlined, _emailNotifications, (val) {
                  setState(() => _emailNotifications = val);
                }),
              ]),

              const SizedBox(height: 20),

              // Location & Distance Section
              _buildSectionHeader(tr("location_distance")),
              _buildSettingsCard(context, [
                _buildTile(context, tr("select_range_distance"), Icons.location_searching, subtitle: "${_rangeDistance.round()}m", onTap: () {
                  _showRangeDistanceModal(context);
                }),
                const Divider(height: 1),
                _buildSwitchTile(context, tr("use_current_location"), Icons.my_location, _useCurrentLocation, (val) {
                  setState(() => _useCurrentLocation = val);
                }),
                const Divider(height: 1),
                _buildTile(context, tr("preferred_location"), Icons.map_outlined, subtitle: _preferredLocation, onTap: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                    ),
                    builder: (ctx) => SelectCityModal(
                      currentCity: _preferredLocation,
                      onCitySelected: (city) {
                        setState(() => _preferredLocation = city);
                        appLocationNotifier.value = city;
                      },
                    ),
                  );
                }),
              ]),

              const SizedBox(height: 20),

              // App Preferences Section
              _buildSectionHeader(tr("app_preferences")),
              _buildSettingsCard(context, [
                _buildTile(
                  context,
                  tr("language"),
                  Icons.language,
                  subtitle: isArabic ? "العربية (Arabic)" : "English",
                  onTap: () {
                    _showLanguageModal(context);
                  },
                ),
                const Divider(height: 1),
                _buildSwitchTile(
                  context,
                  tr("dark_mode"),
                  Icons.dark_mode_outlined,
                  isDarkMode,
                  (val) {
                    setAppThemeMode(val ? ThemeMode.dark : ThemeMode.light);
                    setState(() {});
                  },
                ),
                const Divider(height: 1),
                _buildTile(context, tr("notification_preferences"), Icons.notifications_none_outlined, onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationPreferencesScreen()));
                }),
              ]),
              const SizedBox(height: 20),

              // Legal & Compliance
              _buildSectionHeader(tr("legal_privacy")),
              _buildSettingsCard(context, [
                _buildTile(context, tr("privacy_policy"), Icons.privacy_tip_outlined, onTap: () {
                  _showLegalDocumentModal(context, tr("privacy_policy"), isArabic ? _privacyPolicyTextAr : _privacyPolicyText);
                }),
                const Divider(height: 1),
                _buildTile(context, tr("terms_conditions"), Icons.description_outlined, onTap: () {
                  _showLegalDocumentModal(context, tr("terms_conditions"), isArabic ? _termsOfServiceTextAr : _termsOfServiceText);
                }),
              ]),
              const SizedBox(height: 20),
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

  Widget _buildSettingsCard(BuildContext context, List<Widget> children) {
    final isDark = themeModeNotifier.value == ThemeMode.dark;
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? const Color(0xFF334155) : Colors.grey.shade200),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildTile(BuildContext context, String title, IconData icon, {String? subtitle, VoidCallback? onTap}) {
    final isDark = themeModeNotifier.value == ThemeMode.dark;
    return ListTile(
      onTap: onTap,
      leading: Icon(icon, color: isDark ? Colors.white70 : AppColors.textPrimary, size: 20),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: isDark ? Colors.white : AppColors.textPrimary,
        ),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (subtitle != null)
            Text(
              subtitle,
              style: TextStyle(fontSize: 12, color: isDark ? Colors.white60 : AppColors.textSecondary),
            ),
          const SizedBox(width: 6),
          Icon(Icons.arrow_forward_ios, size: 14, color: isDark ? Colors.white38 : AppColors.textMuted),
        ],
      ),
    );
  }

  Widget _buildSwitchTile(BuildContext context, String title, IconData icon, bool value, ValueChanged<bool> onChanged) {
    final isDark = themeModeNotifier.value == ThemeMode.dark;
    return ListTile(
      leading: Icon(icon, color: isDark ? Colors.white70 : AppColors.textPrimary, size: 20),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: isDark ? Colors.white : AppColors.textPrimary,
        ),
      ),
      trailing: Switch(
        value: value,
        activeColor: AppColors.primaryBlue,
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
              Text(tr("select_range_distance"), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              Text(
                isArabic ? "أقصى مسافة: ${_rangeDistance.round()} متر" : "Maximum Distance: ${_rangeDistance.round()} meters",
                style: const TextStyle(color: AppColors.primaryBlue, fontWeight: FontWeight.bold),
              ),
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
                child: Text(tr("apply"), style: const TextStyle(color: Colors.white)),
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
          Text(tr("language"), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ListTile(
            title: const Text("English"),
            trailing: appLocaleNotifier.value.languageCode == 'en' ? const Icon(Icons.check, color: AppColors.primaryBlue) : null,
            onTap: () {
              setAppLocale('en');
              Navigator.pop(ctx);
              setState(() {});
            },
          ),
          ListTile(
            title: const Text("العربية (Arabic)"),
            trailing: appLocaleNotifier.value.languageCode == 'ar' ? const Icon(Icons.check, color: AppColors.primaryBlue) : null,
            onTap: () {
              setAppLocale('ar');
              Navigator.pop(ctx);
              setState(() {});
            },
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  void _showLegalDocumentModal(BuildContext context, String title, String content) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.85,
        maxChildSize: 0.95,
        minChildSize: 0.5,
        expand: false,
        builder: (_, scrollController) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          child: Column(
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const Divider(),
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  child: Text(
                    content,
                    style: const TextStyle(fontSize: 13, height: 1.6, color: AppColors.textSecondary),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static const String _privacyPolicyText = '''
Wafra Platform - Privacy Policy
Last Updated: October 2026

1. Introduction
Wafra ("we", "our", or "us") is dedicated to protecting your privacy and personal data. This Privacy Policy outlines how we collect, store, and process your personal information when using the Wafra application and civil servant savings network in the State of Kuwait.

2. Information We Collect
- Civil Information: Kuwait Civil ID number and affiliated Government Ministry or Public Institution to verify employee eligibility under State guidelines.
- Contact Information: Official email address, phone number, and account credentials.
- Location Data: Approximate and precise location data is utilized exclusively when the application is in foreground use to display nearby retail discounts and merchant branches. We DO NOT continuously track your background location.
- Transaction & Savings Data: QR redemption logs, savings accumulated in Kuwaiti Dinars (KWD), and discount history.

3. Account & Data Deletion
In accordance with Kuwait data protection principles and Apple/Google Store policies, users maintain full sovereignty over their account data. You may request immediate and permanent deletion of your account and related records directly within the Profile screen.

4. Data Security
All communications with the Wafra platform are encrypted using industry-standard TLS/SSL protocols. Worker credentials and cryptographic tokens are protected with salt hashing algorithms.

5. Contact Us
For questions regarding your privacy rights, please contact: privacy@wafra.kw
''';

  static const String _termsOfServiceText = '''
Wafra Platform - Terms & Conditions
Last Updated: October 2026

1. Acceptance of Terms
By creating an account or accessing the Wafra mobile application, you agree to comply with and be bound by these Terms of Service.

2. Eligibility
Wafra discount privileges are provided exclusively to verified public sector workers, civil servants, and authorized members within the State of Kuwait. Membership requires verification of official credentials.

3. Discount Usage & QR Redemptions
- Dynamic QR codes generated within the application are strictly personal, non-transferable, and possess a time-limited expiration window (60 seconds).
- Fraudulent redemption, unauthorized sharing, or attempting to duplicate discount tokens may result in immediate account suspension.

4. Merchant Terms
Discounts and offers are subject to merchant availability and specific store branch policies. Wafra acts as an intermediary discovery network.

5. Inquiries & Support
Customer and merchant support can be reached at support@wafra.kw.
''';

  static const String _privacyPolicyTextAr = '''
منصة وفرة - سياسة الخصوصية
آخر تحديث: أكتوبر 2026

1. المقدمة
تلتزم منصة وفرة بحماية خصوصيتك وبياناتك الشخصية. توضح هذه السياسة كيفية جمع معلوماتك وتخزينها ومعالجتها عند استخدام تطبيق وفرة وشبكة خصومات موظفي الدولة في دولة الكويت.

2. المعلومات التي نجمعها
- المعلومات المدنية: الرقم المدني الكويتي والجهة الحكومية أو الوزارة التابع لها للتحقق من أهلية الموظف.
- معلومات الاتصال: البريد الإلكتروني الرسمي، ورقم الهاتف، وبيانات الحساب.
- بيانات الموقع: نستخدم بيانات الموقع التقديرية والدقيقة فقط أثناء استخدام التطبيق في الواجهة لعرض الخصومات القريبة وفروع المتاجر الشريكة. نحن لا نتتبع موقعك في الخلفية بشكل دائم.
- بيانات المعاملات والتوفير: سجلات استرداد رموز QR، وإجمالي التوفير بالدينار الكويتي (د.ك)، وتاريخ الخصومات.

3. حذف الحساب والبيانات
وفقاً لمبادئ حماية البيانات وقوانين المتاجر، يمتلك المستخدم السيطرة الكاملة على بياناته. يمكنك طلب الحذف الفوري والنهائي لحسابك وجميع سجلاته من شاشة الملف الشخصي مباشرة.

4. أمان البيانات
جميع الاتصالات مشفرة باستخدام بروتوكولات TLS/SSL القياسية، وتُحفظ كلمات المرور وفق أعلى معايير التشفير الآمن.

5. تواصل معنا
لأي استفسارات بخصوص الخصوصية: privacy@wafra.kw
''';

  static const String _termsOfServiceTextAr = '''
منصة وفرة - الشروط والأحكام
آخر تحديث: أكتوبر 2026

1. قبول الشروط
بإنشاء حسابك أو تصفح تطبيق وفرة، فإنك توافق على الالتزام بهذه الشروط والأحكام.

2. الأهلية
مزايا وخصومات وفرة مخصصة حصرياً لموظفي القطاع الحكومي والخدمة المدنية الموثقين في دولة الكويت. يتطلب التسجيل إثبات الهوية الرسمية.

3. استخدام الخصومات ورموز QR
- رموز الاستجابة السريعة (QR) الصادرة داخل التطبيق شخصية وغير قابلة للتحويل، وتنتهي صلاحيتها خلال 60 ثانية لضمان الأمان.
- أي محاولة لمشاركة الرمز أو استخدامه بطريقة احتيالية قد تعرض الحساب للإيقاف الفوري.

4. شروط المتاجر الشريكة
تخضع العروض لتوفرها وسياسات فروع المتاجر الشريكة. تعمل منصة وفرة كوسيط موثوق لتقديم الخصومات.

5. الاستفسارات والدعم
يمكنكم التواصل مع فريق الدعم عبر البريد: support@wafra.kw
''';
}
