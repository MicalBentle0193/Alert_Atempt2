import 'dart:async';
import 'package:flutter/material.dart';
import '../models/alert_model.dart';
import '../services/api_service.dart';
import '../services/local_storage.dart';

class AlertProvider extends ChangeNotifier {
  final ApiService api;
  final LocalStorageService storage;
  List<WynfordAlert> activeAlerts = [];
  List<WynfordAlert> history = [];
  List<String> subscribedZips = [];

  StreamSubscription? _dummySub;

  AlertProvider({required this.api, required this.storage});

  Future<void> init() async {
    subscribedZips = await storage.loadZips();
    await _fetchActive();
    history = await storage.loadHistory();
    // connect websocket
    api.connectWebSocket(subscribedZips, (alert) async {
      // add to active if relevant
      activeAlerts.insert(0, alert);
      await storage.saveAlertToHistory(alert);
      history.insert(0, alert);
      notifyListeners();
    });
  }

  Future<void> _fetchActive() async {
    try {
      activeAlerts = await api.fetchActiveAlerts();
      notifyListeners();
    } catch (_) {}
  }

  Future<void> updateZips(List<String> zips) async {
    subscribedZips = zips;
    await storage.saveZips(zips);
    api.updateSubscription(zips);
    notifyListeners();
  }

  Future<void> refresh() async {
    await _fetchActive();
  }

  @override
  void dispose() {
    api.disconnectWebSocket();
    _dummySub?.cancel();
    super.dispose();
  }
}
