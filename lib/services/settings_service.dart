import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SettingsService {
  static const String baseUrl = 'http://localhost:3000/api';
  final _storage = const FlutterSecureStorage();

  Future<Map<String, String>> _getHeaders() async {
    final token = await _storage.read(key: 'auth_token');
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  Future<Map<String, dynamic>> getSettings() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/settings'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {
          'themeMode': 'system',
          'currency': 'USD',
          'currencySymbol': '\$',
        };
      }
    } catch (e) {
      return {
        'themeMode': 'system',
        'currency': 'USD',
        'currencySymbol': '\$',
      };
    }
  }

  Future<bool> updateSettings({
    required String themeMode,
    required String currency,
    required String currencySymbol,
  }) async {
    try {
      final headers = await _getHeaders();
      final response = await http.put(
        Uri.parse('$baseUrl/settings'),
        headers: headers,
        body: jsonEncode({
          'themeMode': themeMode,
          'currency': currency,
          'currencySymbol': currencySymbol,
        }),
      );

      return response.statusCode == 200;
    } catch (e) {
      throw Exception('Error updating settings: ${e.toString()}');
    }
  }
}
