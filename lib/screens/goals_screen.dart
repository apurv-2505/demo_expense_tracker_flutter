import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/goals_provider.dart';
import '../providers/expense_provider.dart';
import '../providers/settings_provider.dart';
import '../models/financial_goal.dart';
import '../models/expense.dart';

class GoalsScreen extends StatelessWidget {
  const GoalsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Financial Goals'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Consumer3<GoalsProvider, ExpenseProvider, SettingsProvider>(
        builder:
            (context, goalsProvider, expenseProvider, settingsProvider, child) {
              return SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSavingsInsight(
                      context,
                      expenseProvider,
                      settingsProvider,
                    ),
                    const SizedBox(height: 20),
                    _buildYearlySavingsProjection(
                      context,
                      expenseProvider,
                      settingsProvider,
                    ),
                    const SizedBox(height: 20),
                    _buildGoalsHeader(context, goalsProvider),
                    const SizedBox(height: 16),
                    if (goalsProvider.activeGoals.isEmpty)
                      _buildEmptyState(context)
                    else
                      ...goalsProvider.activeGoals.map(
                        (goal) => _buildGoalCard(
                          context,
                          goal,
                          settingsProvider,
                          goalsProvider,
                        ),
                      ),
                    if (goalsProvider.completedGoals.isNotEmpty) ...[
                      const SizedBox(height: 24),
                      Text(
                        'Completed Goals 🎉',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ...goalsProvider.completedGoals.map(
                        (goal) => _buildGoalCard(
                          context,
                          goal,
                          settingsProvider,
                          goalsProvider,
                        ),
                      ),
                    ],
                  ],
                ),
              );
            },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddGoalDialog(context),
        icon: const Icon(Icons.add),
        label: const Text('Add Goal'),
      ),
    );
  }

  Widget _buildSavingsInsight(
    BuildContext context,
    ExpenseProvider expenseProvider,
    SettingsProvider settings,
  ) {
    final currencyFormat = NumberFormat.currency(
      symbol: settings.currencySymbol,
    );
    final currentMonthExpenses = expenseProvider.currentMonthExpenses;
    final budget = expenseProvider.monthlyBudget;
    final potentialSavings = budget - currentMonthExpenses;

    final categoryExpenses = expenseProvider.categoryWiseExpenses;
    final topCategory = categoryExpenses.entries.isNotEmpty
        ? categoryExpenses.entries.reduce((a, b) => a.value > b.value ? a : b)
        : null;

    String savingsMessage;
    if (potentialSavings > 0) {
      if (topCategory != null && topCategory.value > budget * 0.3) {
        final reduction = topCategory.value * 0.2;
        savingsMessage =
            'You can save ${currencyFormat.format(potentialSavings + reduction)} this month if you reduce ${topCategory.key.displayName} by 20%';
      } else {
        savingsMessage =
            'You\'re on track to save ${currencyFormat.format(potentialSavings)} this month!';
      }
    } else {
      savingsMessage =
          'You\'re over budget by ${currencyFormat.format(potentialSavings.abs())}. Try reducing expenses to start saving.';
    }

    return Card(
      elevation: 3,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            colors: [Colors.green.shade400, Colors.teal.shade400],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: const [
                Icon(Icons.savings, color: Colors.white, size: 28),
                SizedBox(width: 12),
                Text(
                  'Savings Insight',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.lightbulb, color: Colors.white, size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      savingsMessage,
                      style: const TextStyle(
                        color: Colors.white,
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

  Widget _buildYearlySavingsProjection(
    BuildContext context,
    ExpenseProvider expenseProvider,
    SettingsProvider settings,
  ) {
    final currencyFormat = NumberFormat.currency(
      symbol: settings.currencySymbol,
    );
    final monthlyBudget = expenseProvider.monthlyBudget;
    final currentMonthExpenses = expenseProvider.currentMonthExpenses;
    final monthlySavings = monthlyBudget - currentMonthExpenses;
    final yearlySavings = monthlySavings * 12;

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
                  Icons.trending_up,
                  color: Theme.of(context).colorScheme.primary,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Yearly Projection',
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
                color: yearlySavings > 0
                    ? Colors.green.withOpacity(0.1)
                    : Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    yearlySavings > 0
                        ? 'At your current rate, you\'ll save:'
                        : 'At your current rate, you\'ll overspend:',
                    style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    currencyFormat.format(yearlySavings.abs()),
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: yearlySavings > 0
                          ? Colors.green[700]
                          : Colors.orange[700],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'this year',
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGoalsHeader(BuildContext context, GoalsProvider provider) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Your Goals',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        if (provider.activeGoals.isNotEmpty)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '${provider.activeGoals.length} active',
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Card(
      elevation: 2,
      child: Container(
        padding: const EdgeInsets.all(40),
        child: Column(
          children: [
            Icon(Icons.flag, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No goals yet',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Create your first financial goal to start saving!',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey[500]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGoalCard(
    BuildContext context,
    FinancialGoal goal,
    SettingsProvider settings,
    GoalsProvider provider,
  ) {
    final currencyFormat = NumberFormat.currency(
      symbol: settings.currencySymbol,
    );
    final dateFormat = DateFormat('MMM dd, yyyy');
    final progress = goal.progress;
    final isCompleted = goal.isCompleted;

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _showGoalDetails(context, goal, provider, settings),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(goal.emoji, style: const TextStyle(fontSize: 32)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          goal.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Target: ${dateFormat.format(goal.deadline)}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (isCompleted)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'Completed',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 12,
                  backgroundColor: Colors.grey[200],
                  valueColor: AlwaysStoppedAnimation<Color>(
                    isCompleted
                        ? Colors.green
                        : Theme.of(context).colorScheme.primary,
                  ),
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
                        'Progress',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${(progress * 100).toStringAsFixed(0)}%',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Saved',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${currencyFormat.format(goal.currentAmount)} / ${currencyFormat.format(goal.targetAmount)}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              if (!isCompleted && goal.daysRemaining >= 0) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.access_time,
                        size: 16,
                        color: Colors.blue,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${goal.daysRemaining} days remaining',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.blue,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _showGoalDetails(
    BuildContext context,
    FinancialGoal goal,
    GoalsProvider provider,
    SettingsProvider settings,
  ) {
    final currencyFormat = NumberFormat.currency(
      symbol: settings.currencySymbol,
    );
    final amountController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 16,
          right: 16,
          top: 16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(goal.emoji, style: const TextStyle(fontSize: 40)),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    goal.name,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () {
                    provider.deleteGoal(goal.id);
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
            const SizedBox(height: 24),
            if (!goal.isCompleted) ...[
              TextField(
                controller: amountController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Add to savings',
                  prefixText: settings.currencySymbol,
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.add_circle),
                    onPressed: () {
                      final amount = double.tryParse(amountController.text);
                      if (amount != null && amount > 0) {
                        provider.addToGoal(goal.id, amount);
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Added ${currencyFormat.format(amount)} to ${goal.name}',
                            ),
                          ),
                        );
                      }
                    },
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
            Text(
              'Remaining: ${currencyFormat.format(goal.remainingAmount)}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  void _showAddGoalDialog(BuildContext context) {
    final nameController = TextEditingController();
    final amountController = TextEditingController();
    DateTime selectedDate = DateTime.now().add(const Duration(days: 30));
    String selectedEmoji = '🎯';

    final emojis = [
      '🎯',
      '📱',
      '✈️',
      '🏠',
      '🚗',
      '💍',
      '🎓',
      '💰',
      '🎁',
      '🏖️',
    ];

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Create New Goal'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Wrap(
                  spacing: 8,
                  children: emojis.map((emoji) {
                    return ChoiceChip(
                      label: Text(emoji, style: const TextStyle(fontSize: 24)),
                      selected: selectedEmoji == emoji,
                      onSelected: (selected) {
                        if (selected) {
                          setState(() => selectedEmoji = emoji);
                        }
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Goal Name',
                    hintText: 'e.g., New Phone',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: amountController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Target Amount',
                    prefixText: Provider.of<SettingsProvider>(
                      context,
                      listen: false,
                    ).currencySymbol,
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                ListTile(
                  title: const Text('Target Date'),
                  subtitle: Text(
                    DateFormat('MMM dd, yyyy').format(selectedDate),
                  ),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: selectedDate,
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 3650)),
                    );
                    if (date != null) {
                      setState(() => selectedDate = date);
                    }
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final name = nameController.text.trim();
                final amount = double.tryParse(amountController.text);

                if (name.isNotEmpty && amount != null && amount > 0) {
                  final goal = FinancialGoal(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    name: name,
                    targetAmount: amount,
                    currentAmount: 0,
                    deadline: selectedDate,
                    emoji: selectedEmoji,
                  );

                  Provider.of<GoalsProvider>(
                    context,
                    listen: false,
                  ).addGoal(goal);
                  Navigator.pop(context);
                }
              },
              child: const Text('Create'),
            ),
          ],
        ),
      ),
    );
  }
}
