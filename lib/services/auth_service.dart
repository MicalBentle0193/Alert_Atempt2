import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService extends ChangeNotifier {
  static const _kLoggedInKey = 'wynford_logged_in';
  static const _kUsernameKey = 'wynford_username';

  bool _loggedIn = false;
  String? _username;

  bool get isLoggedIn => _loggedIn;
  String? get username => _username;

  AuthService() {
    _loadFromPrefs();
  }

  Future<void> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    _loggedIn = prefs.getBool(_kLoggedInKey) ?? false;
    _username = prefs.getString(_kUsernameKey);
    notifyListeners();
  }

  Future<void> _saveToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kLoggedInKey, _loggedIn);
    if (_username != null) {
      await prefs.setString(_kUsernameKey, _username!);
    } else {
      await prefs.remove(_kUsernameKey);
    }
  }

  // Simple, hardcoded authorized user for "making alerts" feature.
  // In production replace with secure auth backend.
  Future<bool> login(String username, String password) async {
    // Example authorized credentials:
    // username: admin
    // password: password123
    if (username.trim().toLowerCase() == 'admin' &&
        password == 'password123') {
      _loggedIn = true;
      _username = 'admin';
      await _saveToPrefs();
      notifyListeners();
      return true;
    }
    return false;
  }

  Future<void> logout() async {
    _loggedIn = false;
    _username = null;
    await _saveToPrefs();
    notifyListeners();
  }
}
