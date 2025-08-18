import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';

class NotificationService {
  NotificationService._private();
  static final NotificationService instance = NotificationService._private();

  static final FlutterLocalNotificationsPlugin _local = FlutterLocalNotificationsPlugin();
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  static Future<void> initialize() async {
    // Request permissions
    if (Platform.isIOS) {
      await _messaging.requestPermission(alert: true, badge: true, sound: true);
    }

    // Local notification initialization
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings();
    const initSettings = InitializationSettings(android: androidInit, iOS: iosInit);
    await _local.initialize(initSettings, onDidReceiveNotificationResponse: (payload) {});

    // Foreground message handler
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      _showLocalNotification(message);
    });

    // Background/terminated handling is configured in Android/iOS native layers

    // Subscribe public users to topic
    await _messaging.subscribeToTopic('public');
  }

  static Future<void> _showLocalNotification(RemoteMessage message) async {
    final androidDetails = AndroidNotificationDetails(
      'wynford_alerts',
      'Wynford Alerts',
      channelDescription: 'Weather alerts and warnings',
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
      sound: const RawResourceAndroidNotificationSound('scary_alert'), // custom Android sound name without extension
    );
    const iOSDetails = DarwinNotificationDetails(sound: 'scary_alert.wav'); // custom iOS sound filename

    final platform = NotificationDetails(android: androidDetails, iOS: iOSDetails);
    await _local.show(
      message.hashCode,
      message.notification?.title ?? 'Warning',
      message.notification?.body ?? '',
      platform,
      payload: null,
    );
  }

  Future<String?> getToken() => _messaging.getToken();
}
