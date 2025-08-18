import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/foundation.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  NotificationService._internal();
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    final ios = DarwinInitializationSettings(
      requestSoundPermission: true,
      requestBadgePermission: true,
      requestAlertPermission: true,
      onDidReceiveLocalNotification: _onDidReceiveLocalNotification,
    );

    final settings = InitializationSettings(iOS: ios);

    tz.initializeTimeZones();

    await _plugin.initialize(
      settings,
      onDidReceiveNotificationResponse: _onSelectNotification,
    );

    if (!kIsWeb) {
      await _requestPermissions();
    }
  }

  Future<void> _requestPermissions() async {
    await _plugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
  }

  static void _onDidReceiveLocalNotification(
      int id, String? title, String? body, String? payload) {
    // Handle iOS <10 local notification if needed
  }

  void _onSelectNotification(NotificationResponse response) {
    // Handle notification tap
  }

  Future<void> showImmediate({
    required String title,
    required String body,
    int id = 0,
    String? payload,
  }) async {
    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final platform = NotificationDetails(iOS: iosDetails);

    await _plugin.show(id, title, body, platform, payload: payload);
  }

  Future<void> schedule({
    required String title,
    required String body,
    required DateTime scheduledDate,
    int id = 0,
    String? payload,
  }) async {
    await _plugin.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduledDate, tz.local),
      const NotificationDetails(
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      androidAllowWhileIdle: false, // ignored on iOS
      payload: payload,
    );
  }
}
