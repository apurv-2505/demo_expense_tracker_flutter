import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class BudgetService {
  static const String baseUrl = 'http://localhost:3000/api';
  final _storage = const FlutterSecureStorage();

  Future<Map<String, String>> _getHeaders() async {
    final token = await _storage.read(key: 'auth_token');
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  Future<double> getBudget() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/budget'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return (data['monthlyBudget'] as num).toDouble();
      } else {
        return 5000.0;
      }
    } catch (e) {
      return 5000.0;
    }
  }

  Future<bool> updateBudget(double monthlyBudget) async {
    try {
      final headers = await _getHeaders();
      final response = await http.put(
        Uri.parse('$baseUrl/budget'),
        headers: headers,
        body: jsonEncode({'monthlyBudget': monthlyBudget}),
      );

      return response.statusCode == 200;
    } catch (e) {
      throw Exception('Error updating budget: ${e.toString()}');
    }
  }
}
