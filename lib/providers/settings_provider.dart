import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider with ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;
  String _currency = 'USD';
  String _currencySymbol = '\$';
  
  ThemeMode get themeMode => _themeMode;
  String get currency => _currency;
  String get currencySymbol => _currencySymbol;

  static const String _themeModeKey = 'theme_mode';
  static const String _currencyKey = 'currency';
  static const String _currencySymbolKey = 'currency_symbol';

  Future<void> loadSettings() async {
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
    
    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    notifyListeners();
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeModeKey, mode.toString());
  }

  Future<void> setCurrency(String currency, String symbol) async {
    _currency = currency;
    _currencySymbol = symbol;
    notifyListeners();
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_currencyKey, currency);
    await prefs.setString(_currencySymbolKey, symbol);
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
