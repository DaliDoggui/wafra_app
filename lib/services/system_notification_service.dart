import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// SystemNotificationService handles real OS-level push notifications
/// (Status bar, lock screen, heads-up notifications) even when the app is
/// minimized or outside the foreground.
class SystemNotificationService {
  static final SystemNotificationService _instance =
      SystemNotificationService._internal();
  factory SystemNotificationService() => _instance;
  SystemNotificationService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();
  bool _isInitialized = false;

  /// Callback when user taps a system notification from outside the app
  static void Function(String? payload)? onNotificationTapped;

  Future<void> init() async {
    if (_isInitialized) return;
    if (kIsWeb) return; // Web does not support native mobile notification plugin

    try {
      // 1. Android Notification Channel Settings
      const AndroidInitializationSettings initializationSettingsAndroid =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      // 2. iOS / macOS Notification Settings
      const DarwinInitializationSettings initializationSettingsDarwin =
          DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      // 3. Linux Settings
      const LinuxInitializationSettings initializationSettingsLinux =
          LinuxInitializationSettings(defaultActionName: 'Open Wafra');

      const InitializationSettings initializationSettings =
          InitializationSettings(
        android: initializationSettingsAndroid,
        iOS: initializationSettingsDarwin,
        macOS: initializationSettingsDarwin,
        linux: initializationSettingsLinux,
      );

      await _notificationsPlugin.initialize(
        initializationSettings,
        onDidReceiveNotificationResponse: (NotificationResponse response) {
          onNotificationTapped?.call(response.payload);
        },
      );

      // 4. Request Android 13+ (TIRAMISU / API 33+) Runtime Notification Permission
      final androidPlugin = _notificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      if (androidPlugin != null) {
        await androidPlugin.requestNotificationsPermission();
      }

      // 5. Request iOS Notification Permission
      final darwinPlugin = _notificationsPlugin
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>();
      if (darwinPlugin != null) {
        await darwinPlugin.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
      }

      _isInitialized = true;
      debugPrint("✅ SystemNotificationService initialized successfully");

      // Auto-schedule daily deals reminder for when the app is closed
      await scheduleDailyNotification();
    } catch (e) {
      debugPrint("⚠️ SystemNotificationService init failed: $e");
    }
  }

  /// Schedules a repeating daily notification that fires even when the app is closed
  Future<void> scheduleDailyNotification({
    int id = 9999,
    String title = "وفرة الكويت - عروض وصفقات اليوم ☀️",
    String body = "عروض وخصومات حصرية جديدة أضيفت لموظفي الدولة في الكويت. تفقّد التطبيق الآن لتوفير المزيد!",
  }) async {
    if (kIsWeb) return;
    if (!_isInitialized) {
      await init();
    }

    try {
      const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
        'wafra_daily_channel',
        'Wafra Daily Kuwait Deals',
        channelDescription: 'Daily notifications for new Kuwait merchant discounts',
        importance: Importance.high,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
        playSound: true,
        enableVibration: true,
        styleInformation: BigTextStyleInformation(
          "عروض وخصومات حصرية جديدة أضيفت لموظفي الدولة في الكويت. تفقّد التطبيق الآن لتوفير المزيد!",
          contentTitle: "وفرة الكويت - عروض وصفقات اليوم ☀️",
          summaryText: "Wafra Daily Kuwait Picks",
        ),
      );

      const DarwinNotificationDetails darwinDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      const NotificationDetails platformDetails = NotificationDetails(
        android: androidDetails,
        iOS: darwinDetails,
      );

      await _notificationsPlugin.periodicallyShow(
        id,
        title,
        body,
        RepeatInterval.daily,
        platformDetails,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      );
      debugPrint("⏰ Daily background deals notification scheduled");
    } catch (e) {
      debugPrint("⚠️ Failed to schedule daily notification: $e");
    }
  }

  /// Sends a real OS-level heads-up & lock screen notification
  Future<void> showSystemNotification({
    int id = 1001,
    required String title,
    required String body,
    String? payload,
  }) async {
    if (kIsWeb) return;
    if (!_isInitialized) {
      await init();
    }

    try {
      // High-importance Android channel for heads-up and lockscreen display
      final AndroidNotificationDetails androidDetails =
          AndroidNotificationDetails(
        'wafra_geofence_channel',
        'Wafra Geofence Alerts',
        channelDescription:
            'Real-time proximity alerts when near partner stores with active discounts',
        importance: Importance.max,
        priority: Priority.high,
        ticker: 'Wafra Geofence Deal',
        icon: '@mipmap/ic_launcher',
        showWhen: true,
        enableVibration: true,
        playSound: true,
        styleInformation: BigTextStyleInformation(
          body,
          contentTitle: title,
          summaryText: 'Wafra Privilege Deal',
        ),
      );

      const DarwinNotificationDetails darwinDetails =
          DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      final NotificationDetails platformDetails = NotificationDetails(
        android: androidDetails,
        iOS: darwinDetails,
        macOS: darwinDetails,
      );

      await _notificationsPlugin.show(
        id,
        title,
        body,
        platformDetails,
        payload: payload,
      );
      debugPrint("📱 System notification fired: $title");
    } catch (e) {
      debugPrint("⚠️ Failed to fire system notification: $e");
    }
  }
}
