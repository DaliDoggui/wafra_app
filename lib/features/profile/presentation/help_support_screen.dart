import 'package:flutter/material.dart';
import '../../../core/localization/app_locale.dart';
import '../../../core/theme/app_colors.dart';
import '../../../main.dart';

class HelpSupportScreen extends StatefulWidget {
  const HelpSupportScreen({super.key});

  @override
  State<HelpSupportScreen> createState() => _HelpSupportScreenState();
}

class _HelpSupportScreenState extends State<HelpSupportScreen> {
  List<_FaqItem> _getFaqs() {
    if (isArabic) {
      return [
        _FaqItem(
          question: "كيف أحصل على الخصم في المتجر الشريك؟",
          answer:
              "تصفح التطبيق واختر العرض المناسب، ثم اضغط على المتجر واضغط \"الحصول على كود QR\". أظهر هذا الكود للكاشير في المتجر ليقوم بمسحه وتطبيق الخصم فوراً.",
        ),
        _FaqItem(
          question: "كيف تعمل تنبيهات الاقتراب الجغرافي؟",
          answer:
              "يستخدم وفرة موقعك لاكتشاف تواجدك على بعد 1000 متر من أي فرع شريك. عند دخولك النطاق، ستتلقى إشعاراً فورياً بالخصومات المتاحة هناك.",
        ),
        _FaqItem(
          question: "هل يمكن إعادة استخدام كود الـ QR؟",
          answer:
              "كلا، يتم إنشاء كل رمز QR بشكل ديناميكي وصالح للاستخدام لمرة واحدة فقط لمدة 5 دقائق لضمان الأمان. يتم إنشاء رمز جديد لكل عملية خصم.",
        ),
        _FaqItem(
          question: "من يحق له استخدام تطبيق وفرة؟",
          answer:
              "وفرة مخصص حصرياً لموظفي الوزارات والجهات الحكومية المعتمدة في دولة الكويت. يتم التحقق من الرقم الوظيفي والجهة الحكومية عند التسجيل.",
        ),
        _FaqItem(
          question: "ماذا أفعل إذا رفض المتجر قبول كود الـ QR؟",
          answer:
              "يرجى التواصل مع فريق الدعم الفني فوراً. تأكد من أن الكاشير يقوم بالمسح باستخدام تطبيق Wafra Merchant الرسمي الخاص بالمتاجر وليس قارئ QR عادي.",
        ),
        _FaqItem(
          question: "هل يمكنني حفظ العروض للرجوع إليها لاحقاً؟",
          answer:
              "نعم! اضغط على أيقونة القلب على أي عرض لحفظه. يمكنك الوصول لجميع عروضك المحفوظة من تبويب \"المحفوظات\" في شريط التنقل السفلي.",
        ),
      ];
    }
    return [
      _FaqItem(
        question: "How do I get a discount at a partner store?",
        answer:
            "Simply browse the app, find an offer you like, tap on the brand, and press \"Get QR Code\". Show this QR code to the cashier at the store — they will scan it and apply your discount instantly.",
      ),
      _FaqItem(
        question: "How does the proximity notification work?",
        answer:
            "Wafra uses your location to detect when you're within 1000 meters of a partner branch. When you enter this zone, you'll receive a push notification with the available discount.",
      ),
      _FaqItem(
        question: "Is my QR code reusable?",
        answer:
            "No. Each QR code is dynamically generated and valid for one-time use only. It expires after 5 minutes to ensure security. A new QR is generated each time you redeem a deal.",
      ),
      _FaqItem(
        question: "Who is eligible to use Wafra?",
        answer:
            "Wafra is exclusively available to verified government ministry employees in Kuwait. Your Worker ID and ministry affiliation are verified during registration.",
      ),
      _FaqItem(
        question: "What should I do if a store refuses my QR code?",
        answer:
            "Please contact our support team immediately via the chat button below. Make sure the cashier is scanning with the official Wafra Merchant App, not a regular QR scanner.",
      ),
      _FaqItem(
        question: "Can I save offers for later?",
        answer:
            "Yes! Tap the heart icon on any offer to save it. Access all your saved offers from the Saved tab in the bottom navigation bar.",
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final isDark = themeModeNotifier.value == ThemeMode.dark;
    final bgColor = isDark ? const Color(0xFF0F172A) : AppColors.background;
    final cardBg = isDark ? const Color(0xFF1E293B) : Colors.white;
    final textCol = isDark ? Colors.white : AppColors.textPrimary;
    final textMutedCol = isDark ? const Color(0xFF94A3B8) : AppColors.textSecondary;
    final borderColor = isDark ? const Color(0xFF334155) : Colors.grey.shade200;

    final faqs = _getFaqs();

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: cardBg,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded,
              size: 18, color: textCol),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          isArabic ? "المساعدة والدعم" : "Help & Support",
          style: TextStyle(
            color: textCol,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Divider(height: 1, color: borderColor),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Support Banner
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF0052CC), Color(0xFF338BFF)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryBlue.withValues(alpha: 0.25),
                    blurRadius: 14,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isArabic ? "نحن هنا لمساعدتك دائماً!" : "We're here to help!",
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          isArabic
                              ? "فريق الدعم متاح\nالأحد–الخميس، 8 صباحاً–5 مساءً (توقيت الكويت)"
                              : "Our support team is available\nSun–Thu, 8AM–5PM (Kuwait Time)",
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(Icons.support_agent_rounded,
                        color: Colors.white, size: 32),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 22),

            // Quick Contact Options
            Text(
              isArabic ? "تواصل معنا" : "Contact Us",
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: textMutedCol),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _buildContactCard(
                    icon: Icons.chat_bubble_outline_rounded,
                    label: isArabic ? "محادثة فورية" : "Live Chat",
                    sub: isArabic ? "رد فوري" : "Instant reply",
                    color: AppColors.primaryBlue,
                    bg: isDark ? const Color(0xFF1E3A8A).withOpacity(0.4) : const Color(0xFFE0EAFF),
                    cardBg: cardBg,
                    borderColor: borderColor,
                    textColor: textCol,
                    subColor: textMutedCol,
                    onTap: () => _showComingSoon(context, isArabic ? "المحادثة الفورية" : "Live Chat"),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildContactCard(
                    icon: Icons.email_outlined,
                    label: isArabic ? "راسلنا" : "Email Us",
                    sub: "support@wafra.kw",
                    color: const Color(0xFF8B5CF6),
                    bg: isDark ? const Color(0xFF4C1D95).withOpacity(0.4) : const Color(0xFFF3E8FF),
                    cardBg: cardBg,
                    borderColor: borderColor,
                    textColor: textCol,
                    subColor: textMutedCol,
                    onTap: () => _showComingSoon(context, isArabic ? "البريد الإلكتروني" : "Email"),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildContactCard(
                    icon: Icons.phone_outlined,
                    label: isArabic ? "اتصل بنا" : "Call Us",
                    sub: "+965 2200 0000",
                    color: AppColors.greenSuccess,
                    bg: isDark ? const Color(0xFF064E3B).withOpacity(0.4) : const Color(0xFFDCFCE7),
                    cardBg: cardBg,
                    borderColor: borderColor,
                    textColor: textCol,
                    subColor: textMutedCol,
                    onTap: () => _showComingSoon(context, isArabic ? "الاتصال الهاتفي" : "Phone"),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 22),

            // FAQ Section
            Text(
              isArabic ? "الأسئلة الشائعة" : "Frequently Asked Questions",
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: textMutedCol),
            ),
            const SizedBox(height: 10),
            Container(
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: borderColor),
              ),
              child: Column(
                children: faqs.asMap().entries.map((entry) {
                  final i = entry.key;
                  final faq = entry.value;
                  return Column(
                    children: [
                      if (i > 0) Divider(height: 1, color: borderColor),
                      _buildFaqTile(faq, textCol, textMutedCol),
                    ],
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildContactCard({
    required IconData icon,
    required String label,
    required String sub,
    required Color color,
    required Color bg,
    required Color cardBg,
    required Color borderColor,
    required Color textColor,
    required Color subColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: borderColor),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(height: 6),
            Text(label,
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    color: textColor)),
            const SizedBox(height: 2),
            Text(sub,
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 9, color: subColor)),
          ],
        ),
      ),
    );
  }

  Widget _buildFaqTile(_FaqItem faq, Color textColor, Color subColor) {
    return ExpansionTile(
      tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
      iconColor: AppColors.primaryBlue,
      collapsedIconColor: subColor,
      title: Text(
        faq.question,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
      children: [
        Text(
          faq.answer,
          style: TextStyle(
            fontSize: 12,
            color: subColor,
            height: 1.6,
          ),
        ),
      ],
    );
  }

  void _showComingSoon(BuildContext context, String channel) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(isArabic ? "خدمة $channel ستتوفر قريباً!" : "$channel support coming soon!"),
        backgroundColor: AppColors.primaryBlue,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}

class _FaqItem {
  final String question;
  final String answer;

  _FaqItem({required this.question, required this.answer});
}
