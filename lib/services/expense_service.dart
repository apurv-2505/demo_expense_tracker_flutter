import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/expense.dart';

class ExpenseService {
  static const String baseUrl = 'http://localhost:3000/api';
  final _storage = const FlutterSecureStorage();

  Future<Map<String, String>> _getHeaders() async {
    final token = await _storage.read(key: 'auth_token');
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  Future<List<Expense>> getExpenses() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/expenses'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> expensesJson = data['expenses'];
        return expensesJson.map((json) => Expense.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load expenses');
      }
    } catch (e) {
      throw Exception('Error fetching expenses: ${e.toString()}');
    }
  }

  Future<bool> addExpense(Expense expense) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/expenses'),
        headers: headers,
        body: jsonEncode(expense.toJson()),
      );

      return response.statusCode == 201;
    } catch (e) {
      throw Exception('Error adding expense: ${e.toString()}');
    }
  }

  Future<bool> updateExpense(String id, Expense expense) async {
    try {
      final headers = await _getHeaders();
      final response = await http.put(
        Uri.parse('$baseUrl/expenses/$id'),
        headers: headers,
        body: jsonEncode(expense.toJson()),
      );

      return response.statusCode == 200;
    } catch (e) {
      throw Exception('Error updating expense: ${e.toString()}');
    }
  }

  Future<bool> deleteExpense(String id) async {
    try {
      final headers = await _getHeaders();
      final response = await http.delete(
        Uri.parse('$baseUrl/expenses/$id'),
        headers: headers,
      );

      return response.statusCode == 200;
    } catch (e) {
      throw Exception('Error deleting expense: ${e.toString()}');
    }
  }

  Future<bool> deleteAllExpenses() async {
    try {
      final headers = await _getHeaders();
      final response = await http.delete(
        Uri.parse('$baseUrl/expenses'),
        headers: headers,
      );

      return response.statusCode == 200;
    } catch (e) {
      throw Exception('Error deleting all expenses: ${e.toString()}');
    }
  }
}
