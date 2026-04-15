import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../providers/expense_provider.dart';
import '../models/expense.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  TimeFilter _selectedFilter = TimeFilter.month;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Statistics & Reports'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Consumer<ExpenseProvider>(
        builder: (context, expenseProvider, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildFilterSelector(),
                const SizedBox(height: 16),
                _buildSummaryCards(expenseProvider),
                const SizedBox(height: 24),
                _buildCategoryPieChart(expenseProvider),
                const SizedBox(height: 24),
                _buildMonthlyBarChart(expenseProvider),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildFilterSelector() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: TimeFilter.values.map((filter) {
            final isSelected = _selectedFilter == filter;
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: ChoiceChip(
                  label: SizedBox(
                    width: double.infinity,
                    child: Text(
                      filter.displayName,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      _selectedFilter = filter;
                    });
                  },
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildSummaryCards(ExpenseProvider provider) {
    final dateRange = _getDateRange();
    final expenses = provider.getExpensesByDateRange(dateRange.start, dateRange.end);
    final total = expenses.fold(0.0, (sum, expense) => sum + expense.amount);
    final count = expenses.length;
    final average = count > 0 ? total / count : 0.0;

    final currencyFormat = NumberFormat.currency(symbol: '\$');

    return Row(
      children: [
        Expanded(
          child: _buildSummaryCard(
            'Total Spent',
            currencyFormat.format(total),
            Icons.account_balance_wallet,
            Colors.blue,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildSummaryCard(
            'Transactions',
            count.toString(),
            Icons.receipt_long,
            Colors.green,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildSummaryCard(
            'Average',
            currencyFormat.format(average),
            Icons.trending_up,
            Colors.orange,
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryPieChart(ExpenseProvider provider) {
    final dateRange = _getDateRange();
    final expenses = provider.getExpensesByDateRange(dateRange.start, dateRange.end);
    
    final Map<ExpenseCategory, double> categoryTotals = {};
    for (var expense in expenses) {
      categoryTotals[expense.category] = 
          (categoryTotals[expense.category] ?? 0) + expense.amount;
    }

    if (categoryTotals.isEmpty) {
      return _buildEmptyChart('No expenses in this period', Icons.pie_chart_outline);
    }

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Category-wise Breakdown',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 250,
              child: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: PieChart(
                      PieChartData(
                        sections: _getPieChartSections(categoryTotals),
                        centerSpaceRadius: 50,
                        sectionsSpace: 3,
                        borderData: FlBorderData(show: false),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: _buildPieChartLegend(categoryTotals),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<PieChartSectionData> _getPieChartSections(Map<ExpenseCategory, double> data) {
    final total = data.values.fold(0.0, (sum, value) => sum + value);
    
    return data.entries.map((entry) {
      final percentage = (entry.value / total * 100);
      return PieChartSectionData(
        value: entry.value,
        title: '${percentage.toStringAsFixed(1)}%',
        color: _getCategoryColor(entry.key),
        radius: 70,
        titleStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();
  }

  Widget _buildPieChartLegend(Map<ExpenseCategory, double> data) {
    final currencyFormat = NumberFormat.currency(symbol: '\$');
    final sortedEntries = data.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: sortedEntries.map((entry) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: _getCategoryColor(entry.key),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        entry.key.displayName,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        currencyFormat.format(entry.value),
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildMonthlyBarChart(ExpenseProvider provider) {
    final barData = _getBarChartData(provider);

    if (barData.isEmpty) {
      return _buildEmptyChart('No data available', Icons.bar_chart);
    }

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _selectedFilter == TimeFilter.week
                  ? 'Daily Spending (This Week)'
                  : _selectedFilter == TimeFilter.month
                      ? 'Weekly Spending (This Month)'
                      : 'Monthly Spending (This Year)',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 250,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: barData.values.reduce((a, b) => a > b ? a : b) * 1.2,
                  barTouchData: BarTouchData(
                    enabled: true,
                    touchTooltipData: BarTouchTooltipData(
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        final currencyFormat = NumberFormat.currency(symbol: '\$');
                        return BarTooltipItem(
                          currencyFormat.format(rod.toY),
                          const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        );
                      },
                    ),
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              _getBarChartLabel(value.toInt()),
                              style: const TextStyle(fontSize: 10),
                            ),
                          );
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            '\$${value.toInt()}',
                            style: const TextStyle(fontSize: 10),
                          );
                        },
                      ),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: 100,
                  ),
                  borderData: FlBorderData(show: false),
                  barGroups: barData.entries.map((entry) {
                    return BarChartGroupData(
                      x: entry.key,
                      barRods: [
                        BarChartRodData(
                          toY: entry.value,
                          color: Theme.of(context).colorScheme.primary,
                          width: 16,
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(4),
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyChart(String message, IconData icon) {
    return Card(
      elevation: 2,
      child: Container(
        height: 250,
        padding: const EdgeInsets.all(16),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 64, color: Colors.grey[400]),
              const SizedBox(height: 16),
              Text(
                message,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Map<int, double> _getBarChartData(ExpenseProvider provider) {
    final Map<int, double> data = {};
    final dateRange = _getDateRange();
    final expenses = provider.getExpensesByDateRange(dateRange.start, dateRange.end);

    switch (_selectedFilter) {
      case TimeFilter.week:
        for (int i = 0; i < 7; i++) {
          data[i] = 0.0;
        }
        for (var expense in expenses) {
          final dayIndex = expense.date.weekday - 1;
          data[dayIndex] = (data[dayIndex] ?? 0) + expense.amount;
        }
        break;

      case TimeFilter.month:
        for (int i = 0; i < 4; i++) {
          data[i] = 0.0;
        }
        for (var expense in expenses) {
          final weekIndex = ((expense.date.day - 1) / 7).floor().clamp(0, 3);
          data[weekIndex] = (data[weekIndex] ?? 0) + expense.amount;
        }
        break;

      case TimeFilter.year:
        for (int i = 0; i < 12; i++) {
          data[i] = 0.0;
        }
        for (var expense in expenses) {
          final monthIndex = expense.date.month - 1;
          data[monthIndex] = (data[monthIndex] ?? 0) + expense.amount;
        }
        break;
    }

    return data;
  }

  String _getBarChartLabel(int index) {
    switch (_selectedFilter) {
      case TimeFilter.week:
        const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
        return days[index];

      case TimeFilter.month:
        return 'W${index + 1}';

      case TimeFilter.year:
        const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 
                       'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
        return months[index];
    }
  }

  DateRange _getDateRange() {
    final now = DateTime.now();
    
    switch (_selectedFilter) {
      case TimeFilter.week:
        final weekStart = now.subtract(Duration(days: now.weekday - 1));
        final weekStartDate = DateTime(weekStart.year, weekStart.month, weekStart.day);
        final weekEndDate = weekStartDate.add(const Duration(days: 7));
        return DateRange(weekStartDate, weekEndDate);

      case TimeFilter.month:
        final monthStart = DateTime(now.year, now.month);
        final monthEnd = DateTime(now.year, now.month + 1);
        return DateRange(monthStart, monthEnd);

      case TimeFilter.year:
        final yearStart = DateTime(now.year, 1, 1);
        final yearEnd = DateTime(now.year + 1, 1, 1);
        return DateRange(yearStart, yearEnd);
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

enum TimeFilter {
  week,
  month,
  year,
}

extension TimeFilterExtension on TimeFilter {
  String get displayName {
    switch (this) {
      case TimeFilter.week:
        return 'Week';
      case TimeFilter.month:
        return 'Month';
      case TimeFilter.year:
        return 'Year';
    }
  }
}

class DateRange {
  final DateTime start;
  final DateTime end;

  DateRange(this.start, this.end);
}
