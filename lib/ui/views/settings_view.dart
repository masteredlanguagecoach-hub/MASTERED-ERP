import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../providers/settings_provider.dart';

class SettingsView extends StatefulWidget {
  const SettingsView({super.key});

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  late TextEditingController _urlCtrl;

  @override
  void initState() {
    super.initState();
    final settingsProvider = Provider.of<SettingsProvider>(context, listen: false);
    _urlCtrl = TextEditingController(text: settingsProvider.gasUrl);
  }

  @override
  Widget build(BuildContext context) {
    final settingsProvider = Provider.of<SettingsProvider>(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        cross: CrossAxisAlignment.start,
        children: [
          const Text('System & Database Configuration', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),

          // Google Apps Script Connection Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                cross: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.cloud_sync, color: AppColors.primary, size: 24),
                      SizedBox(width: 10),
                      Text('Google Apps Script Web API Endpoint', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Paste your deployed Google Apps Script Web App URL below to sync directly with Google Sheets (MASTERED_DATABASE) and Google Drive (MASTERED/).',
                    style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _urlCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Web App URL',
                      hintText: 'https://script.google.com/macros/s/.../exec',
                      prefixIcon: Icon(Icons.link, size: 20),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      ElevatedButton.icon(
                        onPressed: () async {
                          await settingsProvider.saveGasUrl(_urlCtrl.text);
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('API URL saved'), backgroundColor: AppColors.success),
                            );
                          }
                        },
                        icon: const Icon(Icons.save, size: 18),
                        label: const Text('Save URL'),
                      ),
                      const SizedBox(width: 12),
                      OutlinedButton.icon(
                        onPressed: settingsProvider.isTestingConnection
                            ? null
                            : () async {
                                await settingsProvider.saveGasUrl(_urlCtrl.text);
                                await settingsProvider.testConnection();
                              },
                        icon: settingsProvider.isTestingConnection
                            ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                            : const Icon(Icons.network_check, size: 18),
                        label: const Text('Test Connection'),
                      ),
                    ],
                  ),
                  if (settingsProvider.connectionStatus != null) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: settingsProvider.connectionStatus!.contains('Successfully') ? AppColors.success.withOpacity(0.1) : AppColors.danger.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        settingsProvider.connectionStatus!,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: settingsProvider.connectionStatus!.contains('Successfully') ? AppColors.success : AppColors.danger,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Google Sheets & Drive Schema Information Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                cross: CrossAxisAlignment.start,
                children: [
                  const Text('Database & Drive Architecture', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  const Text('MASTERED_DATABASE (Google Sheets):', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.primary)),
                  const SizedBox(height: 4),
                  const Text('• SETTINGS: Key-value system config & Drive Folder IDs\n• USERS: System users, roles, password hashes\n• LEADS: Lead CRM pipeline, next follow-ups, conversion status\n• STUDENTS: Enrolled students, course fees, drive folder links\n• PAYMENTS: Payment receipts ledger & mode breakdowns\n• EXPENSES: Academy expenses & bill attachments', style: TextStyle(fontSize: 12, height: 1.5)),
                  const SizedBox(height: 16),
                  const Text('MASTERED (Google Drive Root Folder):', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.primary)),
                  const SizedBox(height: 4),
                  const Text('• Students/ (Individual folder automatically created per student)\n• Receipts/ (PDF Fee receipts)\n• Expenses/ (Uploaded bills & invoices)\n• Reports/ (Exported executive CSV/PDF reports)\n• Backups/ (Automated system backups)', style: TextStyle(fontSize: 12, height: 1.5)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
