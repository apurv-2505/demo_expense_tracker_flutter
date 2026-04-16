import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/expense.dart';

class StorageService {
  static const String _expensesKey = 'expenses';
  static const String _budgetKey = 'monthly_budget';

  Future<void> saveExpenses(List<Expense> expenses) async {
    final prefs = await SharedPreferences.getInstance();
    final expensesJson = expenses.map((e) => e.toJson()).toList();
    await prefs.setString(_expensesKey, jsonEncode(expensesJson));
  }

  Future<List<Expense>> loadExpenses() async {
    final prefs = await SharedPreferences.getInstance();
    final expensesString = prefs.getString(_expensesKey);
    
    if (expensesString == null || expensesString.isEmpty) {
      return [];
    }
    
    try {
      final List<dynamic> expensesJson = jsonDecode(expensesString);
      return expensesJson.map((json) => Expense.fromJson(json)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> saveBudget(double budget) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_budgetKey, budget);
  }

  Future<double> loadBudget() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(_budgetKey) ?? 5000.0;
  }

  Future<void> clearAllData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_expensesKey);
    await prefs.remove(_budgetKey);
  }

  Future<String> exportData() async {
    final prefs = await SharedPreferences.getInstance();
    final expensesString = prefs.getString(_expensesKey) ?? '[]';
    final budget = prefs.getDouble(_budgetKey) ?? 5000.0;
    
    final exportData = {
      'expenses': jsonDecode(expensesString),
      'budget': budget,
      'exportDate': DateTime.now().toIso8601String(),
    };
    
    return jsonEncode(exportData);
  }
}
