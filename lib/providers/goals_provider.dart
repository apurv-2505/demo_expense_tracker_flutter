import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/financial_goal.dart';

class GoalsProvider with ChangeNotifier {
  final List<FinancialGoal> _goals = [];
  bool _isLoaded = false;

  List<FinancialGoal> get goals => [..._goals];

  bool get isLoaded => _isLoaded;

  List<FinancialGoal> get activeGoals =>
      _goals.where((goal) => !goal.isCompleted).toList();

  List<FinancialGoal> get completedGoals =>
      _goals.where((goal) => goal.isCompleted).toList();

  Future<void> loadGoals() async {
    if (_isLoaded) return;

    final prefs = await SharedPreferences.getInstance();
    final goalsJson = prefs.getString('financial_goals');

    if (goalsJson != null) {
      final List<dynamic> decoded = json.decode(goalsJson);
      _goals.clear();
      _goals.addAll(decoded.map((item) => FinancialGoal.fromJson(item)));
    }

    _isLoaded = true;
    notifyListeners();
  }

  Future<void> _saveGoals() async {
    final prefs = await SharedPreferences.getInstance();
    final goalsJson = json.encode(_goals.map((g) => g.toJson()).toList());
    await prefs.setString('financial_goals', goalsJson);
  }

  Future<void> addGoal(FinancialGoal goal) async {
    _goals.add(goal);
    await _saveGoals();
    notifyListeners();
  }

  Future<void> updateGoal(String id, FinancialGoal updatedGoal) async {
    final index = _goals.indexWhere((goal) => goal.id == id);
    if (index != -1) {
      _goals[index] = updatedGoal;
      await _saveGoals();
      notifyListeners();
    }
  }

  Future<void> deleteGoal(String id) async {
    _goals.removeWhere((goal) => goal.id == id);
    await _saveGoals();
    notifyListeners();
  }

  Future<void> addToGoal(String id, double amount) async {
    final index = _goals.indexWhere((goal) => goal.id == id);
    if (index != -1) {
      final goal = _goals[index];
      _goals[index] = goal.copyWith(
        currentAmount: goal.currentAmount + amount,
      );
      await _saveGoals();
      notifyListeners();
    }
  }
}
