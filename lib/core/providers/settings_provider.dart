import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider extends ChangeNotifier {
  static const _langKey = 'language';
  String _language = 'en';

  String get language => _language;
  Locale get locale => Locale(_language);

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    _language = prefs.getString(_langKey) ?? 'en';
    notifyListeners();
  }

  Future<void> setLanguage(String lang) async {
    if (_language == lang) return;
    _language = lang;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_langKey, lang);
    notifyListeners();
  }
}
