import 'package:flutter/foundation.dart';
import '../models/expense.dart';

class ExpenseProvider with ChangeNotifier {
  final List<Expense> _expenses = [];
  double _monthlyBudget = 5000.0;

  List<Expense> get expenses => [..._expenses];

  double get monthlyBudget => _monthlyBudget;

  void setMonthlyBudget(double budget) {
    _monthlyBudget = budget;
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
        .where((expense) =>
            expense.date.isAfter(currentMonth.subtract(const Duration(days: 1))) &&
            expense.date.isBefore(nextMonth))
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

    final currentMonthExpenses = _expenses.where((expense) =>
        expense.date.isAfter(currentMonth.subtract(const Duration(days: 1))) &&
        expense.date.isBefore(nextMonth));

    final Map<ExpenseCategory, double> categoryTotals = {};

    for (var expense in currentMonthExpenses) {
      categoryTotals[expense.category] =
          (categoryTotals[expense.category] ?? 0) + expense.amount;
    }

    return categoryTotals;
  }

  void addExpense(Expense expense) {
    _expenses.add(expense);
    notifyListeners();
  }

  void updateExpense(String id, Expense updatedExpense) {
    final index = _expenses.indexWhere((expense) => expense.id == id);
    if (index != -1) {
      _expenses[index] = updatedExpense;
      notifyListeners();
    }
  }

  void deleteExpense(String id) {
    _expenses.removeWhere((expense) => expense.id == id);
    notifyListeners();
  }

  List<Expense> getExpensesByCategory(ExpenseCategory? category) {
    if (category == null) return expenses;
    return _expenses.where((expense) => expense.category == category).toList();
  }

  List<Expense> getExpensesByDateRange(DateTime start, DateTime end) {
    return _expenses
        .where((expense) =>
            expense.date.isAfter(start.subtract(const Duration(days: 1))) &&
            expense.date.isBefore(end.add(const Duration(days: 1))))
        .toList();
  }
}
