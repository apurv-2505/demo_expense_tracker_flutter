import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/expense_provider.dart';
import '../providers/settings_provider.dart';
import '../models/expense.dart';
import 'add_expense_screen.dart';

class ExpenseListScreen extends StatefulWidget {
  const ExpenseListScreen({super.key});

  @override
  State<ExpenseListScreen> createState() => _ExpenseListScreenState();
}

class _ExpenseListScreenState extends State<ExpenseListScreen> {
  ExpenseCategory? _selectedCategory;
  DateFilter _dateFilter = DateFilter.all;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('All Expenses'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
          ),
        ],
      ),
      body: Consumer2<ExpenseProvider, SettingsProvider>(
        builder: (context, expenseProvider, settingsProvider, child) {
          final filteredExpenses = _getFilteredExpenses(expenseProvider);

          if (filteredExpenses.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.receipt_long, size: 80, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'No expenses found',
                    style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Try adjusting your filters',
                    style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              if (_selectedCategory != null || _dateFilter != DateFilter.all)
                _buildActiveFilters(),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: filteredExpenses.length,
                  itemBuilder: (context, index) {
                    final expense = filteredExpenses[index];
                    return _buildExpenseItem(
                      context,
                      expense,
                      expenseProvider,
                      settingsProvider,
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  List<Expense> _getFilteredExpenses(ExpenseProvider provider) {
    List<Expense> expenses = provider.expenses;

    if (_selectedCategory != null) {
      expenses = expenses
          .where((expense) => expense.category == _selectedCategory)
          .toList();
    }

    final now = DateTime.now();
    switch (_dateFilter) {
      case DateFilter.today:
        final today = DateTime(now.year, now.month, now.day);
        final tomorrow = today.add(const Duration(days: 1));
        expenses = expenses
            .where(
              (expense) =>
                  expense.date.isAfter(
                    today.subtract(const Duration(days: 1)),
                  ) &&
                  expense.date.isBefore(tomorrow),
            )
            .toList();
        break;
      case DateFilter.thisWeek:
        final weekStart = now.subtract(Duration(days: now.weekday - 1));
        final weekStartDate = DateTime(
          weekStart.year,
          weekStart.month,
          weekStart.day,
        );
        expenses = expenses
            .where(
              (expense) => expense.date.isAfter(
                weekStartDate.subtract(const Duration(days: 1)),
              ),
            )
            .toList();
        break;
      case DateFilter.thisMonth:
        final monthStart = DateTime(now.year, now.month);
        final monthEnd = DateTime(now.year, now.month + 1);
        expenses = expenses
            .where(
              (expense) =>
                  expense.date.isAfter(
                    monthStart.subtract(const Duration(days: 1)),
                  ) &&
                  expense.date.isBefore(monthEnd),
            )
            .toList();
        break;
      case DateFilter.all:
        break;
    }

    expenses.sort((a, b) => b.date.compareTo(a.date));
    return expenses;
  }

  Widget _buildActiveFilters() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.grey[100],
      child: Row(
        children: [
          const Text(
            'Active Filters:',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 8),
          if (_selectedCategory != null)
            Chip(
              label: Text(_selectedCategory!.displayName),
              onDeleted: () {
                setState(() {
                  _selectedCategory = null;
                });
              },
              deleteIcon: const Icon(Icons.close, size: 18),
            ),
          if (_dateFilter != DateFilter.all)
            Padding(
              padding: const EdgeInsets.only(left: 8),
              child: Chip(
                label: Text(_dateFilter.displayName),
                onDeleted: () {
                  setState(() {
                    _dateFilter = DateFilter.all;
                  });
                },
                deleteIcon: const Icon(Icons.close, size: 18),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildExpenseItem(
    BuildContext context,
    Expense expense,
    ExpenseProvider provider,
    SettingsProvider settings,
  ) {
    final currencyFormat = NumberFormat.currency(
      symbol: settings.currencySymbol,
    );
    final dateFormat = DateFormat('MMM dd, yyyy');

    return Dismissible(
      key: Key(expense.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.symmetric(vertical: 4),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.delete, color: Colors.white, size: 32),
      ),
      confirmDismiss: (direction) async {
        return await showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Delete Expense'),
              content: const Text(
                'Are you sure you want to delete this expense?',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  style: TextButton.styleFrom(foregroundColor: Colors.red),
                  child: const Text('Delete'),
                ),
              ],
            );
          },
        );
      },
      onDismissed: (direction) async {
        await provider.deleteExpense(expense.id);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${expense.title} deleted'),
              action: SnackBarAction(
                label: 'UNDO',
                onPressed: () async {
                  await provider.addExpense(expense);
                },
              ),
            ),
          );
        }
      },
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        elevation: 2,
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8,
          ),
          leading: CircleAvatar(
            backgroundColor: _getCategoryColor(
              expense.category,
            ).withOpacity(0.2),
            child: Icon(
              _getCategoryIcon(expense.category),
              color: _getCategoryColor(expense.category),
            ),
          ),
          title: Text(
            expense.title,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.category, size: 14, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    expense.category.displayName,
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                  const SizedBox(width: 12),
                  Icon(Icons.calendar_today, size: 14, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    dateFormat.format(expense.date),
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                ],
              ),
              if (expense.note.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  expense.note,
                  style: TextStyle(
                    color: Colors.grey[500],
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                currencyFormat.format(expense.amount),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ],
          ),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AddExpenseScreen(expense: expense),
              ),
            );
          },
        ),
      ),
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        ExpenseCategory? tempCategory = _selectedCategory;
        DateFilter tempDateFilter = _dateFilter;

        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Filter Expenses'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Category',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        FilterChip(
                          label: const Text('All'),
                          selected: tempCategory == null,
                          onSelected: (selected) {
                            setDialogState(() {
                              tempCategory = null;
                            });
                          },
                        ),
                        ...ExpenseCategory.values.map((category) {
                          return FilterChip(
                            label: Text(category.displayName),
                            selected: tempCategory == category,
                            onSelected: (selected) {
                              setDialogState(() {
                                tempCategory = selected ? category : null;
                              });
                            },
                          );
                        }),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Date Range',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    ...DateFilter.values.map((filter) {
                      return RadioListTile<DateFilter>(
                        title: Text(filter.displayName),
                        value: filter,
                        groupValue: tempDateFilter,
                        onChanged: (value) {
                          setDialogState(() {
                            tempDateFilter = value!;
                          });
                        },
                        contentPadding: EdgeInsets.zero,
                      );
                    }),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _selectedCategory = tempCategory;
                      _dateFilter = tempDateFilter;
                    });
                    Navigator.of(context).pop();
                  },
                  child: const Text('Apply'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  IconData _getCategoryIcon(ExpenseCategory category) {
    switch (category) {
      case ExpenseCategory.food:
        return Icons.restaurant;
      case ExpenseCategory.transport:
        return Icons.directions_car;
      case ExpenseCategory.shopping:
        return Icons.shopping_bag;
      case ExpenseCategory.entertainment:
        return Icons.movie;
      case ExpenseCategory.bills:
        return Icons.receipt;
      case ExpenseCategory.health:
        return Icons.local_hospital;
      case ExpenseCategory.education:
        return Icons.school;
      case ExpenseCategory.other:
        return Icons.more_horiz;
    }
  }

  Color _getCategoryColor(ExpenseCategory category) {
    switch (category) {
      case ExpenseCategory.food:
        return Colors.orange;
      case ExpenseCategory.transport:
        return Colors.blue;
      case ExpenseCategory.shopping:
        return Colors.pink;
      case ExpenseCategory.entertainment:
        return Colors.purple;
      case ExpenseCategory.bills:
        return Colors.red;
      case ExpenseCategory.health:
        return Colors.green;
      case ExpenseCategory.education:
        return Colors.teal;
      case ExpenseCategory.other:
        return Colors.grey;
    }
  }
}

enum DateFilter { all, today, thisWeek, thisMonth }

extension DateFilterExtension on DateFilter {
  String get displayName {
    switch (this) {
      case DateFilter.all:
        return 'All Time';
      case DateFilter.today:
        return 'Today';
      case DateFilter.thisWeek:
        return 'This Week';
      case DateFilter.thisMonth:
        return 'This Month';
    }
  }
}
