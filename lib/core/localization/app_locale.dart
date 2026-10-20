import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../main.dart';

final ValueNotifier<Locale> appLocaleNotifier = ValueNotifier<Locale>(const Locale('en'));
final ValueNotifier<String> appLocationNotifier = ValueNotifier<String>('Kuwait City');

bool get isArabic => appLocaleNotifier.value.languageCode == 'ar';

Future<void> setAppLocale(String languageCode) async {
  appLocaleNotifier.value = Locale(languageCode);
  try {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('wafra_locale', languageCode);
  } catch (_) {}
}

Future<void> setAppThemeMode(ThemeMode mode) async {
  themeModeNotifier.value = mode;
  try {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('wafra_theme_mode', mode == ThemeMode.dark ? 'dark' : 'light');
  } catch (_) {}
}

Future<void> initPreferences() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    final lang = prefs.getString('wafra_locale');
    if (lang != null && (lang == 'ar' || lang == 'en')) {
      appLocaleNotifier.value = Locale(lang);
    }
    final themeStr = prefs.getString('wafra_theme_mode');
    if (themeStr != null) {
      themeModeNotifier.value = themeStr == 'dark' ? ThemeMode.dark : ThemeMode.light;
    }
    final loc = prefs.getString('wafra_preferred_city');
    if (loc != null && loc.isNotEmpty) {
      appLocationNotifier.value = loc;
    }
  } catch (_) {}
}

String tr(String key) {
  if (isArabic) {
    return _arabicTranslations[key] ?? _englishTranslations[key] ?? key;
  }
  return _englishTranslations[key] ?? key;
}

const Map<String, String> _englishTranslations = {
  'app_title': 'Wafra - More for Less',
  'home': 'Home',
  'deals': 'Deals',
  'categories': 'Categories',
  'orders': 'Orders',
  'profile': 'Profile',
  'settings': 'Settings',
  'account': 'Account',
  'personal_info': 'Personal Information',
  'change_password': 'Change Password',
  'email_notifications': 'Email Notifications',
  'location_distance': 'Location & Distance',
  'select_range_distance': 'Select range distance',
  'use_current_location': 'Use my current location',
  'preferred_location': 'Preferred Location',
  'app_preferences': 'App Preferences',
  'language': 'Language',
  'appearance': 'Appearance',
  'light_mode': 'Light Mode',
  'dark_mode': 'Dark Mode',
  'notification_preferences': 'Notification Preferences',
  'legal_privacy': 'Legal & Privacy',
  'privacy_policy': 'Privacy Policy',
  'terms_conditions': 'Terms & Conditions',
  'welcome_back': 'Welcome Back',
  'worker_id': 'Worker ID',
  'total_savings': 'Total Savings',
  'total_money_saved': 'Total Money Saved',
  'recent_redemptions': 'Recent Redemptions',
  'used_deals': 'Used Deals',
  'saved_offers': 'Saved Offers',
  'interests': 'Interests',
  'interests_subtitle': 'Select categories to receive targeted flash deal alerts',
  'change_email': 'Change Email',
  'change_phone': 'Add / Change Phone',
  'save_changes': 'Save Changes',
  'apply': 'Apply',
  'cancel': 'Cancel',
  'show_qr_cashier': 'Show This QR Code To Cashier At Checkout',
  'expires_in': 'Expires in',
  'qr_expired': 'QR Code Expired!',
  'listening_scan': 'Listening for cashier scan... (Live)',
  'view_deal': 'View Deal',
  'stacked_promo': 'Stacked Promo Active',
  'hello': 'Hello',
  'search_placeholder': 'Search for stores, deals, or categories...',
  'special_offers': 'Special Offers',
  'trending_deals': 'Trending Deals',
  'popular_brands': 'Popular Brands',
  'featured_deals': 'Featured Deals',
  'view_all': 'View All',
  'near_you': 'Nearby Offer',
  'redeem': 'Redeem',
  'get_directions': 'Get Directions',
  'get_discount': 'Get Discount',
  'about_offer': 'About This Offer',
  'discount_applied': 'Discount Applied! 🎉',
  'discount_applied_sub': 'Successfully verified and applied by cashier',
  'you_saved': 'You Saved:',
  'original_bill': 'Original Bill',
  'discount_deducted': 'Discount Deducted',
  'you_paid': 'You Paid at Cashier',
  'processed_by_cashier': 'Processed by Cashier',
  'done': 'Done',
  'back_to_home': 'Back to Home',
  'no_offers_found': 'No offers available at the moment',
  'no_saved_offers': 'No saved offers yet',
  'search_saved': 'Search saved offers...',
  'all': 'All',
  'logout': 'Log Out',
  'logout_confirm': 'Are you sure you want to log out?',
  'confirm': 'Confirm',
  'token': 'Security Token',
  'flash_offer': 'Special Flash Offer',
  'stacked_discount_desc': 'Stacked Promo: Base + Special Offer',
  'available_branches': 'Available At All Branches',
  'notifications': 'Notifications',
  'notifications_subtitle': 'Deal updates and alerts',
  'my_orders': 'My Orders',
  'my_orders_subtitle': 'View your discount redemptions',
  'help_support': 'Help & Support',
  'help_support_subtitle': 'Get help when you need',
  'browse_categories': 'Browse Categories',
  'disconnect': 'Disconnect',
  'delete_account': 'Delete Account',
  'no_notifications': 'No notifications right now',
  'mark_all_read': 'Mark all read',
  'savings_summary': 'Savings Summary',
  'kd_saved': 'KD Saved',
  'completed_orders': 'Completed Orders',
  'avg_discount': 'Avg. Discount',
  'brands_used': 'Brands Used',
  'this_month': 'This Month',
  'this_year': 'This Year',
  'saved': 'Saved',
  'original': 'Original',
  'paid': 'Paid',
  'receipt_code': 'Receipt Code',
  'view_receipt': 'View Receipt',
  'proximity_alert': 'Proximity Alert',
  'live_offer': 'Live Offer',
  'account_active': 'Account Active',
  'just_now': 'Just now',
  'tap_unlock_voucher': 'Tap to unlock voucher with Worker ID',
};

const Map<String, String> _arabicTranslations = {
  'app_title': 'وفرة - وفّر أكثر',
  'home': 'الرئيسية',
  'deals': 'العروض',
  'categories': 'التصنيفات',
  'orders': 'الطلبات',
  'profile': 'حسابي',
  'settings': 'الإعدادات',
  'account': 'الحساب',
  'personal_info': 'المعلومات الشخصية',
  'change_password': 'تغيير كلمة المرور',
  'email_notifications': 'إشعارات البريد الإلكتروني',
  'location_distance': 'الموقع والنطاق الجغرافي',
  'select_range_distance': 'تحديد مسافة البحث',
  'use_current_location': 'استخدام موقعي الحالي',
  'preferred_location': 'الموقع والمدينة المفضلة',
  'app_preferences': 'تفضيلات التطبيق',
  'language': 'اللغة',
  'appearance': 'المظهر والشاشة',
  'light_mode': 'الوضع الفاتح (Light Mode)',
  'dark_mode': 'الوضع الداكن (Dark Mode)',
  'notification_preferences': 'تفضيلات الإشعارات',
  'legal_privacy': 'الشروط والسياسات',
  'privacy_policy': 'سياسة الخصوصية',
  'terms_conditions': 'الشروط والأحكام',
  'welcome_back': 'أهلاً بك من جديد',
  'worker_id': 'رقم الموظف',
  'total_savings': 'إجمالي التوفير',
  'total_money_saved': 'إجمالي المبالغ الموفّرة',
  'recent_redemptions': 'سجل الخصومات الأخير',
  'used_deals': 'العروض المستخدمة',
  'saved_offers': 'العروض المحفوظة',
  'interests': 'اهتماماتك وتفضيلاتك',
  'interests_subtitle': 'اختر اهتماماتك لتصلك إشعارات وتخفيضات مخصصة لك',
  'change_email': 'تغيير البريد الإلكتروني',
  'change_phone': 'إضافة / تغيير رقم الهاتف',
  'save_changes': 'حفظ التعديلات',
  'apply': 'تطبيق',
  'cancel': 'إلغاء',
  'show_qr_cashier': 'أظهر هذا الرمز للكاشير عند الدفع',
  'expires_in': 'ينتهي خلال',
  'qr_expired': 'انتهت صلاحية الرمز!',
  'listening_scan': 'بانتظار مسح الكاشير... (مباشر)',
  'view_deal': 'عرض التفاصيل',
  'stacked_promo': 'عرض ترويجي مضاعف مفعّل',
  'hello': 'مرحباً',
  'search_placeholder': 'ابحث عن المتاجر، العروض، أو التصنيفات...',
  'special_offers': 'عروض خاصة حصرية',
  'trending_deals': 'العروض الشائعة',
  'popular_brands': 'أشهر العلامات التجارية',
  'featured_deals': 'عروض مميزة',
  'view_all': 'عرض الكل',
  'near_you': 'عرض قريب منك',
  'redeem': 'استخدام الخصم',
  'get_directions': 'الاتجاهات للفرع',
  'get_discount': 'الحصول على الخصم',
  'about_offer': 'حول هذا العرض',
  'discount_applied': 'تم تطبيق الخصم بنجاح! 🎉',
  'discount_applied_sub': 'تم التحقق وتطبيق الخصم بنجاح من قبل الكاشير',
  'you_saved': 'وفرت بمبلغ:',
  'original_bill': 'الفاتورة الأصلية',
  'discount_deducted': 'قيمة الخصم المستقطع',
  'you_paid': 'المبلغ المدفوع للكاشير',
  'processed_by_cashier': 'تم بواسطة الكاشير',
  'done': 'تم',
  'back_to_home': 'العودة للرئيسية',
  'no_offers_found': 'لا توجد عروض متاحة حالياً',
  'no_saved_offers': 'لا توجد عروض محفوظة حتى الآن',
  'search_saved': 'ابحث في العروض المحفوظة...',
  'all': 'الكل',
  'logout': 'تسجيل الخروج',
  'logout_confirm': 'هل أنت متأكد من تسجيل الخروج من الحساب؟',
  'confirm': 'تأكيد',
  'token': 'رمز الأمان',
  'flash_offer': 'عرض خاص إضافي',
  'stacked_discount_desc': 'خصم مضاعف: الخصم الأساسي + العرض الخاص',
  'available_branches': 'متوفر في جميع الفروع',
  'notifications': 'الإشعارات',
  'notifications_subtitle': 'تنبيهات العروض والتخفيضات',
  'my_orders': 'طلباتي',
  'my_orders_subtitle': 'عرض سجل الخصومات المستخدمة',
  'help_support': 'المساعدة والدعم',
  'help_support_subtitle': 'احصل على المساعدة والإجابات',
  'browse_categories': 'تصفح التصنيفات',
  'disconnect': 'تسجيل الخروج',
  'delete_account': 'حذف الحساب',
  'no_notifications': 'لا توجد إشعارات حالياً',
  'mark_all_read': 'تحديد الكل كمقروء',
  'savings_summary': 'ملخص التوفير',
  'kd_saved': 'د.ك موفّرة',
  'completed_orders': 'الطلبات المكتملة',
  'avg_discount': 'متوسط الخصم',
  'brands_used': 'المتاجر المستفاد منها',
  'this_month': 'هذا الشهر',
  'this_year': 'هذه السنة',
  'saved': 'وفّرت',
  'original': 'الأصلي',
  'paid': 'المدفوع',
  'receipt_code': 'رقم الإيصال',
  'view_receipt': 'عرض الإيصال',
  'proximity_alert': 'تنبيه اقتراب',
  'live_offer': 'عرض مفعّل',
  'account_active': 'الحساب مفعّل',
  'just_now': 'الآن',
  'tap_unlock_voucher': 'اضغط لفتح القسيمة بالرقم الوظيفي',
};
