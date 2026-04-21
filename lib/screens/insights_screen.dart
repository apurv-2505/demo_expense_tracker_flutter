import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/expense_provider.dart';
import '../providers/settings_provider.dart';
import '../models/expense.dart';

class InsightsScreen extends StatelessWidget {
  const InsightsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Smart Insights'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Consumer2<ExpenseProvider, SettingsProvider>(
        builder: (context, expenseProvider, settingsProvider, child) {
          final insights = _calculateInsights(expenseProvider);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context),
                const SizedBox(height: 20),
                _buildSpendingComparison(context, insights, settingsProvider),
                const SizedBox(height: 16),
                _buildTopCategory(context, insights, settingsProvider),
                const SizedBox(height: 16),
                _buildHighestSpendingDay(context, insights),
                const SizedBox(height: 16),
                _buildSpendingPatterns(context, insights, settingsProvider),
                const SizedBox(height: 16),
                _buildSmartMessages(context, insights, settingsProvider),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Card(
      elevation: 0,
      color: Theme.of(context).colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(
              Icons.lightbulb,
              size: 40,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Smart Analysis',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'AI-powered insights from your spending',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(
                        context,
                      ).colorScheme.onPrimaryContainer.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSpendingComparison(
    BuildContext context,
    Map<String, dynamic> insights,
    SettingsProvider settings,
  ) {
    final currencyFormat = NumberFormat.currency(
      symbol: settings.currencySymbol,
    );
    final percentageChange = insights['monthlyChange'] as double;
    final isIncrease = percentageChange > 0;
    final currentMonth = insights['currentMonthTotal'] as double;
    final lastMonth = insights['lastMonthTotal'] as double;

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  isIncrease ? Icons.trending_up : Icons.trending_down,
                  color: isIncrease ? Colors.red : Colors.green,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Monthly Comparison',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: (isIncrease ? Colors.red : Colors.green).withOpacity(
                  0.1,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    percentageChange == 0
                        ? 'Your spending is the same as last month'
                        : isIncrease
                        ? 'You spent ${percentageChange.abs().toStringAsFixed(0)}% more this month'
                        : 'You spent ${percentageChange.abs().toStringAsFixed(0)}% less this month',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isIncrease ? Colors.red[700] : Colors.green[700],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'This Month',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            currencyFormat.format(currentMonth),
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'Last Month',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            currencyFormat.format(lastMonth),
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopCategory(
    BuildContext context,
    Map<String, dynamic> insights,
    SettingsProvider settings,
  ) {
    final topCategory = insights['topCategory'] as ExpenseCategory?;
    final topCategoryAmount = insights['topCategoryAmount'] as double;
    final currencyFormat = NumberFormat.currency(
      symbol: settings.currencySymbol,
    );

    if (topCategory == null) {
      return const SizedBox.shrink();
    }

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.category,
                  color: Theme.of(context).colorScheme.primary,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Top Spending Category',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    _getCategoryIcon(topCategory),
                    size: 40,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          topCategory.displayName,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          currencyFormat.format(topCategoryAmount),
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[700],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHighestSpendingDay(
    BuildContext context,
    Map<String, dynamic> insights,
  ) {
    final highestDay = insights['highestSpendingDay'] as String?;

    if (highestDay == null) {
      return const SizedBox.shrink();
    }

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  color: Theme.of(context).colorScheme.primary,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Spending Pattern',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: Colors.blue, size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Your highest spending day is $highestDay',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSpendingPatterns(
    BuildContext context,
    Map<String, dynamic> insights,
    SettingsProvider settings,
  ) {
    final weekdaySpending = (insights['weekdaySpending'] as num).toDouble();
    final weekendSpending = (insights['weekendSpending'] as num).toDouble();
    final currencyFormat = NumberFormat.currency(
      symbol: settings.currencySymbol,
    );

    if (weekdaySpending == 0 && weekendSpending == 0) {
      return const SizedBox.shrink();
    }

    final total = weekdaySpending + weekendSpending;
    final weekdayPercentage = total > 0
        ? (weekdaySpending / total * 100).toDouble()
        : 0.0;
    final weekendPercentage = total > 0
        ? (weekendSpending / total * 100).toDouble()
        : 0.0;

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.insights,
                  color: Theme.of(context).colorScheme.primary,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Weekday vs Weekend',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildPatternCard(
                    context,
                    'Weekday',
                    currencyFormat.format(weekdaySpending),
                    weekdayPercentage,
                    Colors.blue,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildPatternCard(
                    context,
                    'Weekend',
                    currencyFormat.format(weekendSpending),
                    weekendPercentage,
                    Colors.purple,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPatternCard(
    BuildContext context,
    String label,
    String amount,
    double percentage,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[700],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            amount,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${percentage.toStringAsFixed(0)}%',
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildSmartMessages(
    BuildContext context,
    Map<String, dynamic> insights,
    SettingsProvider settings,
  ) {
    final messages = _generateSmartMessages(insights, settings);

    if (messages.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.psychology,
                  color: Theme.of(context).colorScheme.primary,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Smart Recommendations',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...messages.map((message) => _buildMessageItem(context, message)),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageItem(BuildContext context, Map<String, dynamic> message) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: (message['type'] == 'warning' ? Colors.orange : Colors.green)
            .withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: (message['type'] == 'warning' ? Colors.orange : Colors.green)
              .withOpacity(0.3),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            message['type'] == 'warning'
                ? Icons.warning_amber
                : Icons.check_circle,
            color: message['type'] == 'warning' ? Colors.orange : Colors.green,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(message['text'], style: const TextStyle(fontSize: 14)),
          ),
        ],
      ),
    );
  }

  Map<String, dynamic> _calculateInsights(ExpenseProvider provider) {
    final now = DateTime.now();
    final currentMonth = DateTime(now.year, now.month);
    final lastMonth = DateTime(now.year, now.month - 1);
    final nextMonth = DateTime(now.year, now.month + 1);

    final currentMonthExpenses = provider.expenses.where(
      (e) =>
          e.date.isAfter(currentMonth.subtract(const Duration(days: 1))) &&
          e.date.isBefore(nextMonth),
    );

    final lastMonthExpenses = provider.expenses.where(
      (e) =>
          e.date.isAfter(lastMonth.subtract(const Duration(days: 1))) &&
          e.date.isBefore(currentMonth),
    );

    final currentMonthTotal = currentMonthExpenses.fold(
      0.0,
      (sum, e) => sum + e.amount,
    );

    final lastMonthTotal = lastMonthExpenses.fold(
      0.0,
      (sum, e) => sum + e.amount,
    );

    double monthlyChange = 0;
    if (lastMonthTotal > 0) {
      monthlyChange =
          ((currentMonthTotal - lastMonthTotal) / lastMonthTotal) * 100;
    }

    final categoryTotals = <ExpenseCategory, double>{};
    for (var expense in currentMonthExpenses) {
      categoryTotals[expense.category] =
          (categoryTotals[expense.category] ?? 0) + expense.amount;
    }

    ExpenseCategory? topCategory;
    double topCategoryAmount = 0;
    categoryTotals.forEach((category, amount) {
      if (amount > topCategoryAmount) {
        topCategory = category;
        topCategoryAmount = amount;
      }
    });

    final daySpending = <String, double>{};
    for (var expense in currentMonthExpenses) {
      final dayName = DateFormat('EEEE').format(expense.date);
      daySpending[dayName] = (daySpending[dayName] ?? 0) + expense.amount;
    }

    String? highestSpendingDay;
    double highestAmount = 0;
    daySpending.forEach((day, amount) {
      if (amount > highestAmount) {
        highestSpendingDay = day;
        highestAmount = amount;
      }
    });

    double weekdaySpending = 0;
    double weekendSpending = 0;
    for (var expense in currentMonthExpenses) {
      final weekday = expense.date.weekday;
      if (weekday == DateTime.saturday || weekday == DateTime.sunday) {
        weekendSpending += expense.amount;
      } else {
        weekdaySpending += expense.amount;
      }
    }

    return {
      'currentMonthTotal': currentMonthTotal,
      'lastMonthTotal': lastMonthTotal,
      'monthlyChange': monthlyChange,
      'topCategory': topCategory,
      'topCategoryAmount': topCategoryAmount,
      'highestSpendingDay': highestSpendingDay,
      'weekdaySpending': weekdaySpending,
      'weekendSpending': weekendSpending,
    };
  }

  List<Map<String, dynamic>> _generateSmartMessages(
    Map<String, dynamic> insights,
    SettingsProvider settings,
  ) {
    final messages = <Map<String, dynamic>>[];
    final monthlyChange = insights['monthlyChange'] as double;
    final topCategory = insights['topCategory'] as ExpenseCategory?;

    if (monthlyChange > 20) {
      messages.add({
        'type': 'warning',
        'text':
            'Your spending increased significantly this month. Consider reviewing your expenses.',
      });
    } else if (monthlyChange < -10) {
      messages.add({
        'type': 'success',
        'text': 'Great job! You reduced your spending this month.',
      });
    }

    if (topCategory != null) {
      if (topCategory == ExpenseCategory.food) {
        messages.add({
          'type': 'warning',
          'text':
              'Food is your top expense. Try meal planning to reduce costs.',
        });
      } else if (topCategory == ExpenseCategory.entertainment) {
        messages.add({
          'type': 'warning',
          'text': 'Entertainment spending is high. Consider free alternatives.',
        });
      }
    }

    final weekendSpending = (insights['weekendSpending'] as num).toDouble();
    final weekdaySpending = (insights['weekdaySpending'] as num).toDouble();
    final total = weekendSpending + weekdaySpending;

    if (total > 0 && weekendSpending / total > 0.4) {
      messages.add({
        'type': 'warning',
        'text':
            'You spend more on weekends. Plan weekend activities within budget.',
      });
    }

    return messages;
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
}
