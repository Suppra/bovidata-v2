import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsController with ChangeNotifier {
  static const String _themeKey = 'theme_mode';
  static const String _notificationsKey = 'notifications_enabled';
  static const String _autoSyncKey = 'auto_sync_enabled';
  static const String _languageKey = 'language';

  ThemeMode _themeMode = ThemeMode.system;
  bool _notificationsEnabled = true;
  bool _autoSyncEnabled = true;
  String _language = 'es';

  // Getters
  ThemeMode get themeMode => _themeMode;
  bool get isDarkMode => _themeMode == ThemeMode.dark;
  bool get isLightMode => _themeMode == ThemeMode.light;
  bool get isSystemMode => _themeMode == ThemeMode.system;
  bool get notificationsEnabled => _notificationsEnabled;
  bool get autoSyncEnabled => _autoSyncEnabled;
  String get language => _language;

  SettingsController() {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Cargar tema
    final themeIndex = prefs.getInt(_themeKey) ?? 0;
    _themeMode = ThemeMode.values[themeIndex];
    
    // Cargar otras configuraciones
    _notificationsEnabled = prefs.getBool(_notificationsKey) ?? true;
    _autoSyncEnabled = prefs.getBool(_autoSyncKey) ?? true;
    _language = prefs.getString(_languageKey) ?? 'es';
    
    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode themeMode) async {
    _themeMode = themeMode;
    notifyListeners();
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_themeKey, themeMode.index);
  }

  Future<void> toggleThemeMode() async {
    switch (_themeMode) {
      case ThemeMode.light:
        await setThemeMode(ThemeMode.dark);
        break;
      case ThemeMode.dark:
        await setThemeMode(ThemeMode.system);
        break;
      case ThemeMode.system:
        await setThemeMode(ThemeMode.light);
        break;
    }
  }

  Future<void> setNotifications(bool enabled) async {
    _notificationsEnabled = enabled;
    notifyListeners();
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_notificationsKey, enabled);
  }

  Future<void> setAutoSync(bool enabled) async {
    _autoSyncEnabled = enabled;
    notifyListeners();
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_autoSyncKey, enabled);
  }

  Future<void> setLanguage(String languageCode) async {
    _language = languageCode;
    notifyListeners();
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_languageKey, languageCode);
  }

  String getThemeModeText() {
    switch (_themeMode) {
      case ThemeMode.light:
        return 'Claro';
      case ThemeMode.dark:
        return 'Oscuro';
      case ThemeMode.system:
        return 'Sistema';
    }
  }

  IconData getThemeModeIcon() {
    switch (_themeMode) {
      case ThemeMode.light:
        return Icons.light_mode;
      case ThemeMode.dark:
        return Icons.dark_mode;
      case ThemeMode.system:
        return Icons.brightness_auto;
    }
  }
}