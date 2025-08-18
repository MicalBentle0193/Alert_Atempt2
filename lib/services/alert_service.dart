import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'package:wynford_weather_alerts/models/alert_model.dart';
import 'package:wynford_weather_alerts/services/notification_service.dart';

class AlertService extends ChangeNotifier {
  static const _kAlertsKey = 'wynford_alerts_v1';

  final List<WeatherAlert> _alerts = [];

  List<WeatherAlert> get alerts =>
      List.unmodifiable(_alerts)..sort((a, b) => b.createdAt.compareTo(a.createdAt));

  AlertService() {
    _loadAlerts();
  }

  Future<void> _loadAlerts() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kAlertsKey);
    if (raw != null && raw.isNotEmpty) {
      try {
        final List<dynamic> list = jsonDecode(raw);
        _alerts.clear();
        for (final item in list) {
          _alerts.add(WeatherAlert.fromJson(Map<String, dynamic>.from(item)));
        }
        notifyListeners();
      } catch (_) {
        // ignore parsing errors, start fresh
      }
    }
  }

  Future<void> _saveAlerts() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = jsonEncode(_alerts.map((e) => e.toJson()).toList());
    await prefs.setString(_kAlertsKey, raw);
  }

  Future<void> createAlert({
    required String title,
    required String message,
    required String author,
    bool notifyImmediate = true,
  }) async {
    final newAlert = WeatherAlert(
      id: const Uuid().v4(),
      title: title.trim(),
      message: message.trim(),
      author: author,
      createdAt: DateTime.now(),
    );
    _alerts.add(newAlert);
    await _saveAlerts();
    notifyListeners();

    if (notifyImmediate) {
      await NotificationService().showImmediate(
        title: 'Weather Alert: ${newAlert.title}',
        body: newAlert.message,
        id: DateTime.now().millisecondsSinceEpoch.remainder(100000),
        payload: newAlert.id,
      );
    }
  }

  Future<void> clearAlerts() async {
    _alerts.clear();
    await _saveAlerts();
    notifyListeners();
  }
}
