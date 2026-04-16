import 'package:flutter/foundation.dart';
import '../models/expense.dart';
import '../services/storage_service.dart';

class ExpenseProvider with ChangeNotifier {
  final List<Expense> _expenses = [];
  double _monthlyBudget = 5000.0;
  final StorageService _storageService = StorageService();
  bool _isLoaded = false;

  List<Expense> get expenses => [..._expenses];

  double get monthlyBudget => _monthlyBudget;

  bool get isLoaded => _isLoaded;

  Future<void> loadData() async {
    if (_isLoaded) return;

    _expenses.clear();
    final loadedExpenses = await _storageService.loadExpenses();
    _expenses.addAll(loadedExpenses);

    _monthlyBudget = await _storageService.loadBudget();

    _isLoaded = true;
    notifyListeners();
  }

  Future<void> setMonthlyBudget(double budget) async {
    _monthlyBudget = budget;
    await _storageService.saveBudget(budget);
    notifyListeners();
  }

  double get totalExpenses {
    return _expenses.fold(0.0, (sum, expense) => sum + expense.amount);
  }

  double get currentMonthExpenses {
    final now = DateTime.now();
    final currentMonth = DateTime(now.year, now.month);
    final nextMonth = DateTime(now.year, now.month + 1);

    return _expenses
        .where(
          (expense) =>
              expense.date.isAfter(
                currentMonth.subtract(const Duration(days: 1)),
              ) &&
              expense.date.isBefore(nextMonth),
        )
        .fold(0.0, (sum, expense) => sum + expense.amount);
  }

  double get remainingBudget => _monthlyBudget - currentMonthExpenses;

  double get budgetProgress {
    if (_monthlyBudget == 0) return 0;
    return (currentMonthExpenses / _monthlyBudget).clamp(0.0, 1.0);
  }

  List<Expense> get recentExpenses {
    final sorted = [..._expenses]..sort((a, b) => b.date.compareTo(a.date));
    return sorted.take(5).toList();
  }

  Map<ExpenseCategory, double> get categoryWiseExpenses {
    final now = DateTime.now();
    final currentMonth = DateTime(now.year, now.month);
    final nextMonth = DateTime(now.year, now.month + 1);

    final currentMonthExpenses = _expenses.where(
      (expense) =>
          expense.date.isAfter(
            currentMonth.subtract(const Duration(days: 1)),
          ) &&
          expense.date.isBefore(nextMonth),
    );

    final Map<ExpenseCategory, double> categoryTotals = {};

    for (var expense in currentMonthExpenses) {
      categoryTotals[expense.category] =
          (categoryTotals[expense.category] ?? 0) + expense.amount;
    }

    return categoryTotals;
  }

  Future<void> addExpense(Expense expense) async {
    _expenses.add(expense);
    await _storageService.saveExpenses(_expenses);
    notifyListeners();
  }

  Future<void> updateExpense(String id, Expense updatedExpense) async {
    final index = _expenses.indexWhere((expense) => expense.id == id);
    if (index != -1) {
      _expenses[index] = updatedExpense;
      await _storageService.saveExpenses(_expenses);
      notifyListeners();
    }
  }

  Future<void> deleteExpense(String id) async {
    _expenses.removeWhere((expense) => expense.id == id);
    await _storageService.saveExpenses(_expenses);
    notifyListeners();
  }

  Future<String> exportData() async {
    return await _storageService.exportData();
  }

  Future<void> resetAllData() async {
    _expenses.clear();
    _monthlyBudget = 5000.0;
    await _storageService.clearAllData();
    notifyListeners();
  }

  List<Expense> getExpensesByCategory(ExpenseCategory? category) {
    if (category == null) return expenses;
    return _expenses.where((expense) => expense.category == category).toList();
  }

  List<Expense> getExpensesByDateRange(DateTime start, DateTime end) {
    return _expenses
        .where(
          (expense) =>
              expense.date.isAfter(start.subtract(const Duration(days: 1))) &&
              expense.date.isBefore(end.add(const Duration(days: 1))),
        )
        .toList();
  }
}
