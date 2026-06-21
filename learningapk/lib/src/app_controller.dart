import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'services/api_service.dart';

class AppController extends ChangeNotifier {
  AppController(this.api);

  final ApiService api;
  Map<String, dynamic>? user;
  bool busy = false;
  String? error;
  Locale locale = const Locale('en');

  bool get isAuthenticated => api.token != null;
  bool get isAdmin => user?['role'] == 'admin';
  String get languageCode => locale.languageCode;
  String localizedPath(String path) =>
      '$path${path.contains('?') ? '&' : '?'}lang=$languageCode';

  Future<void> restoreSession() async {
    final prefs = await SharedPreferences.getInstance();
    locale = Locale(prefs.getString('app_language') ?? 'en');
    api.token = prefs.getString('auth_token');
    if (api.token == null) return;
    try {
      final response = await api.get('/me');
      user = Map<String, dynamic>.from(response['data']['user'] as Map);
    } catch (_) {
      await _clearSession();
    }
  }

  Future<void> setLanguage(String languageCode) async {
    locale = Locale(languageCode);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('app_language', languageCode);
    notifyListeners();
  }

  void updateUser(Map<String, dynamic> updatedUser) {
    user = updatedUser;
    notifyListeners();
  }

  Future<bool> login(String login, String password) => _authenticate('/login', {
    'login': login.trim(),
    'password': password,
    'device_name': 'learn-laravel-android',
  });

  Future<bool> register(String name, String email, String password) =>
      _authenticate('/register', {
        'name': name.trim(),
        'email': email.trim(),
        'password': password,
        'password_confirmation': password,
        'device_name': 'learn-laravel-android',
      });

  Future<bool> _authenticate(String path, Map<String, dynamic> payload) async {
    _setBusy(true);
    try {
      final response = await api.post(path, payload);
      final data = Map<String, dynamic>.from(response['data'] as Map);
      api.token = data['token'] as String;
      user = Map<String, dynamic>.from(data['user'] as Map);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', api.token!);
      error = null;
      return true;
    } on ApiException catch (e) {
      error = e.message;
      return false;
    } finally {
      _setBusy(false);
    }
  }

  Future<void> logout() async {
    try {
      await api.post('/logout');
    } catch (_) {
      // Clear local access even when the server cannot be reached.
    }
    await _clearSession();
    notifyListeners();
  }

  Future<void> _clearSession() async {
    api.token = null;
    user = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
  }

  void clearError() {
    error = null;
    notifyListeners();
  }

  void _setBusy(bool value) {
    busy = value;
    notifyListeners();
  }
}
