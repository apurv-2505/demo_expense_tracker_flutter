import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/settings_service.dart';

class SettingsProvider with ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;
  String _currency = 'USD';
  String _currencySymbol = '\$';
  final SettingsService _settingsService = SettingsService();
  bool _useBackend = false;

  ThemeMode get themeMode => _themeMode;
  String get currency => _currency;
  String get currencySymbol => _currencySymbol;

  static const String _themeModeKey = 'theme_mode';
  static const String _currencyKey = 'currency';
  static const String _currencySymbolKey = 'currency_symbol';

  Future<void> loadSettings() async {
    if (_useBackend) {
      try {
        final settings = await _settingsService.getSettings();
        final themeModeString = settings['themeMode'] as String?;
        if (themeModeString != null) {
          _themeMode = _parseThemeMode(themeModeString);
        }
        _currency = settings['currency'] as String? ?? 'USD';
        _currencySymbol = settings['currencySymbol'] as String? ?? '\$';
      } catch (e) {
        await _loadFromLocalStorage();
      }
    } else {
      await _loadFromLocalStorage();
    }

    notifyListeners();
  }

  Future<void> _loadFromLocalStorage() async {
    final prefs = await SharedPreferences.getInstance();

    final themeModeString = prefs.getString(_themeModeKey);
    if (themeModeString != null) {
      _themeMode = ThemeMode.values.firstWhere(
        (mode) => mode.toString() == themeModeString,
        orElse: () => ThemeMode.system,
      );
    }

    _currency = prefs.getString(_currencyKey) ?? 'USD';
    _currencySymbol = prefs.getString(_currencySymbolKey) ?? '\$';
  }

  ThemeMode _parseThemeMode(String mode) {
    switch (mode) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  String _themeModeToString(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'light';
      case ThemeMode.dark:
        return 'dark';
      default:
        return 'system';
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    notifyListeners();

    if (_useBackend) {
      try {
        await _settingsService.updateSettings(
          themeMode: _themeModeToString(mode),
          currency: _currency,
          currencySymbol: _currencySymbol,
        );
      } catch (e) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_themeModeKey, mode.toString());
      }
    } else {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_themeModeKey, mode.toString());
    }
  }

  Future<void> setCurrency(String currency, String symbol) async {
    _currency = currency;
    _currencySymbol = symbol;
    notifyListeners();

    if (_useBackend) {
      try {
        await _settingsService.updateSettings(
          themeMode: _themeModeToString(_themeMode),
          currency: currency,
          currencySymbol: symbol,
        );
      } catch (e) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_currencyKey, currency);
        await prefs.setString(_currencySymbolKey, symbol);
      }
    } else {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_currencyKey, currency);
      await prefs.setString(_currencySymbolKey, symbol);
    }
  }

  Map<String, String> get availableCurrencies => {
    'USD': '\$',
    'EUR': '€',
    'GBP': '£',
    'INR': '₹',
    'JPY': '¥',
    'CNY': '¥',
    'AUD': 'A\$',
    'CAD': 'C\$',
    'CHF': 'Fr',
    'SEK': 'kr',
  };
}
