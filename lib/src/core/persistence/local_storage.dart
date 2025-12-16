import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

final class LocalStorage {
  LocalStorage._(this._prefs);

  final SharedPreferences _prefs;

  static Future<LocalStorage> create() async {
    final prefs = await SharedPreferences.getInstance();
    return LocalStorage._(prefs);
  }

  Future<void> setString(String key, String value) async {
    await _prefs.setString(key, value);
  }

  String? getString(String key) => _prefs.getString(key);

  Future<void> remove(String key) async {
    await _prefs.remove(key);
  }

  Future<void> setJson(String key, Object value) async {
    await setString(key, jsonEncode(value));
  }

  Map<String, dynamic>? getJsonMap(String key) {
    final raw = getString(key);
    if (raw == null || raw.trim().isEmpty) return null;
    final decoded = jsonDecode(raw);
    return decoded is Map<String, dynamic> ? decoded : null;
  }

  List<dynamic>? getJsonList(String key) {
    final raw = getString(key);
    if (raw == null || raw.trim().isEmpty) return null;
    final decoded = jsonDecode(raw);
    return decoded is List ? decoded : null;
  }
}
