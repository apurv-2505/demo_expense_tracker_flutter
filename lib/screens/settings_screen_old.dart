import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../providers/settings_provider.dart';
import '../providers/expense_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildSectionHeader('Appearance'),
          _buildThemeSelector(context),
          const SizedBox(height: 24),
          _buildSectionHeader('Currency'),
          _buildCurrencySelector(context),
          const SizedBox(height: 24),
          _buildSectionHeader('Data Management'),
          _buildDataManagementOptions(context),
          const SizedBox(height: 24),
          _buildAboutSection(context),
        ],
      ),
    );
  }

  Widget _buildUserProfile(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, auth, child) {
        final user = auth.user;
        if (user == null) return const SizedBox.shrink();

        return Card(
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  child: Text(
                    user.name[0].toUpperCase(),
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        user.email,
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.deepPurple,
        ),
      ),
    );
  }

  Widget _buildThemeSelector(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (context, settings, child) {
        return Card(
          elevation: 2,
          child: Column(
            children: [
              RadioListTile<ThemeMode>(
                title: const Text('Light Theme'),
                subtitle: const Text('Always use light theme'),
                value: ThemeMode.light,
                groupValue: settings.themeMode,
                onChanged: (ThemeMode? value) {
                  if (value != null) {
                    settings.setThemeMode(value);
                  }
                },
                secondary: const Icon(Icons.light_mode),
              ),
              const Divider(height: 1),
              RadioListTile<ThemeMode>(
                title: const Text('Dark Theme'),
                subtitle: const Text('Always use dark theme'),
                value: ThemeMode.dark,
                groupValue: settings.themeMode,
                onChanged: (ThemeMode? value) {
                  if (value != null) {
                    settings.setThemeMode(value);
                  }
                },
                secondary: const Icon(Icons.dark_mode),
              ),
              const Divider(height: 1),
              RadioListTile<ThemeMode>(
                title: const Text('System Default'),
                subtitle: const Text('Follow system theme'),
                value: ThemeMode.system,
                groupValue: settings.themeMode,
                onChanged: (ThemeMode? value) {
                  if (value != null) {
                    settings.setThemeMode(value);
                  }
                },
                secondary: const Icon(Icons.brightness_auto),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCurrencySelector(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (context, settings, child) {
        return Card(
          elevation: 2,
          child: ListTile(
            leading: const Icon(Icons.attach_money),
            title: const Text('Select Currency'),
            subtitle: Text(
              'Current: ${settings.currency} (${settings.currencySymbol})',
            ),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () => _showCurrencyPicker(context, settings),
          ),
        );
      },
    );
  }

  void _showCurrencyPicker(BuildContext context, SettingsProvider settings) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'Select Currency',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              Expanded(
                child: ListView(
                  children: settings.availableCurrencies.entries.map((entry) {
                    final isSelected = settings.currency == entry.key;
                    return ListTile(
                      leading: Icon(
                        Icons.check,
                        color: isSelected
                            ? Colors.deepPurple
                            : Colors.transparent,
                      ),
                      title: Text(entry.key),
                      trailing: Text(
                        entry.value,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      selected: isSelected,
                      onTap: () {
                        settings.setCurrency(entry.key, entry.value);
                        Navigator.pop(context);
                      },
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDataManagementOptions(BuildContext context) {
    return Card(
      elevation: 2,
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.upload_file, color: Colors.blue),
            title: const Text('Export Data'),
            subtitle: const Text('Export all expenses and budget data'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () => _exportData(context),
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.delete_forever, color: Colors.red),
            title: const Text('Reset All Data'),
            subtitle: const Text('Delete all expenses and reset budget'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () => _showResetConfirmation(context),
          ),
        ],
      ),
    );
  }

  Widget _buildAboutSection(BuildContext context) {
    return Card(
      elevation: 2,
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('About'),
            subtitle: const Text('Expense Tracker v1.0.0'),
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.code),
            title: const Text('Developer'),
            subtitle: const Text('Built with Flutter'),
          ),
        ],
      ),
    );
  }

  Future<void> _exportData(BuildContext context) async {
    try {
      final expenseProvider = Provider.of<ExpenseProvider>(
        context,
        listen: false,
      );
      final exportedData = await expenseProvider.exportData();

      await Share.share(exportedData, subject: 'Expense Tracker Data Export');

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Data exported successfully!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Export failed: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  void _showResetConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Reset All Data?'),
          content: const Text(
            'This will permanently delete all your expenses and reset your budget to default. This action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                await _resetData(context);
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Reset'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _resetData(BuildContext context) async {
    try {
      final expenseProvider = Provider.of<ExpenseProvider>(
        context,
        listen: false,
      );
      await expenseProvider.resetAllData();

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('All data has been reset successfully'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Reset failed: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }
}
