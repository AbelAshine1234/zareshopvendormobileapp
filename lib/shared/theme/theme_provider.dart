import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app_themes.dart';

class ThemeProvider extends ChangeNotifier {
  static const String _themeKey = 'selected_theme';
  
  AppThemeData _currentTheme = AppThemes.green; // Default theme
  AppThemeType _currentThemeType = AppThemeType.green;
  
  AppThemeData get currentTheme => _currentTheme;
  AppThemeType get currentThemeType => _currentThemeType;
  
  ThemeProvider() {
    _loadTheme();
  }
  
  // Load saved theme from SharedPreferences
  Future<void> _loadTheme() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final themeIndex = prefs.getInt(_themeKey) ?? AppThemeType.green.index;
      
      if (themeIndex >= 0 && themeIndex < AppThemeType.values.length) {
        _currentThemeType = AppThemeType.values[themeIndex];
        _currentTheme = AppThemes.getTheme(_currentThemeType);
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error loading theme: $e');
    }
  }
  
  // Save theme to SharedPreferences
  Future<void> _saveTheme() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_themeKey, _currentThemeType.index);
    } catch (e) {
      debugPrint('Error saving theme: $e');
    }
  }
  
  // Change theme
  Future<void> setTheme(AppThemeType themeType) async {
    if (_currentThemeType != themeType) {
      _currentThemeType = themeType;
      _currentTheme = AppThemes.getTheme(themeType);
      notifyListeners();
      await _saveTheme();
    }
  }
  
  // Check if theme is selected
  bool isThemeSelected(AppThemeType themeType) {
    return _currentThemeType == themeType;
  }
  
  // Get Flutter ThemeData
  ThemeData get themeData => AppThemes.generateThemeData(_currentTheme);
}
