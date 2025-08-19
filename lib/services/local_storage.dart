import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/alert_model.dart';

class LocalStorageService {
  static const _keyZips = 'user_zip_codes';
  static const _keyHistory = 'alert_history';

  Future<void> saveZips(List<String> zips) async {
    final sp = await SharedPreferences.getInstance();
    await sp.setStringList(_keyZips, zips);
  }

  Future<List<String>> loadZips() async {
    final sp = await SharedPreferences.getInstance();
    return sp.getStringList(_keyZips) ?? [];
  }

  Future<void> saveAlertToHistory(WynfordAlert alert) async {
    final sp = await SharedPreferences.getInstance();
    final list = sp.getStringList(_keyHistory) ?? [];
    list.add(alert.toJson());
    await sp.setStringList(_keyHistory, list);
  }

  Future<List<WynfordAlert>> loadHistory() async {
    final sp = await SharedPreferences.getInstance();
    final list = sp.getStringList(_keyHistory) ?? [];
    return list.map((s) => WynfordAlert.fromMap(jsonDecode(s) as Map<String, dynamic>)).toList();
  }
}
