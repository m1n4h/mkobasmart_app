// lib/themes/theme_provider.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;
  Locale _locale = const Locale('en');

  ThemeMode get themeMode => _themeMode;
  Locale get locale => _locale;

  ThemeProvider() {
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final themeModeString = prefs.getString('theme_mode');
    final localeCode = prefs.getString('locale_code');
    
    if (themeModeString != null) {
      _themeMode = themeModeString == 'light' 
          ? ThemeMode.light 
          : themeModeString == 'dark' 
              ? ThemeMode.dark 
              : ThemeMode.system;
    }
    
    if (localeCode != null) {
      _locale = Locale(localeCode);
    }
    
    notifyListeners();
  }

  Future<void> _savePreferences() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('theme_mode', 
        _themeMode == ThemeMode.light 
            ? 'light' 
            : _themeMode == ThemeMode.dark 
                ? 'dark' 
                : 'system');
    await prefs.setString('locale_code', _locale.languageCode);
  }

  void toggleTheme() {
    if (_themeMode == ThemeMode.light) {
      _themeMode = ThemeMode.dark;
    } else if (_themeMode == ThemeMode.dark) {
      _themeMode = ThemeMode.light;
    } else {
      _themeMode = ThemeMode.light;
    }
    _savePreferences();
    notifyListeners();
  }

  void setThemeMode(ThemeMode mode) {
    _themeMode = mode;
    _savePreferences();
    notifyListeners();
  }

  void toggleLocale() {
    if (_locale.languageCode == 'en') {
      _locale = const Locale('sw');
    } else {
      _locale = const Locale('en');
    }
    _savePreferences();
    notifyListeners();
  }

  void setLocale(Locale locale) {
    _locale = locale;
    _savePreferences();
    notifyListeners();
  }
}