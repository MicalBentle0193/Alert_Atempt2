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
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    final ios = DarwinInitializationSettings(
      requestSoundPermission: true,
      requestBadgePermission: true,
      requestAlertPermission: true,
      onDidReceiveLocalNotification: _onDidReceiveLocalNotification,
    );

    final settings = InitializationSettings(android: android, iOS: ios);

    tz.initializeTimeZones();

    await _plugin.initialize(settings,
        onDidReceiveNotificationResponse: _onSelectNotification);
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
    // iOS older versions: handle if needed
  }

  void _onSelectNotification(NotificationResponse response) {
    // handle tap if needed
  }

  Future<void> showImmediate({
    required String title,
    required String body,
    int id = 0,
    String? payload,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'wynford_channel',
      'Wynford Alerts',
      channelDescription: 'Weather alerts and warnings',
      importance: Importance.max,
      priority: Priority.high,
      color: AndroidColor(0xff000000),
      visibility: NotificationVisibility.public,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final platform = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

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
        android: AndroidNotificationDetails('wynford_channel',
            'Wynford Alerts', channelDescription: 'Weather alerts and warnings'),
        iOS: DarwinNotificationDetails(),
      ),
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      androidAllowWhileIdle: true,
      payload: payload,
    );
  }
}
