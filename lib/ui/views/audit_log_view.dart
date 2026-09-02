import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../data/models/audit_log_model.dart';

class AuditLogView extends StatefulWidget {
  const AuditLogView({super.key});

  @override
  State<AuditLogView> createState() => _AuditLogViewState();
}

class _AuditLogViewState extends State<AuditLogView> {
  final List<AuditLogModel> _logs = [
    AuditLogModel(logId: 'LOG-1001', timestamp: DateTime.now().subtract(const Duration(minutes: 5)).toIso8601String(), userId: 'USR-1001', userName: 'System Administrator', action: 'LOGIN', module: 'AUTH', details: 'Admin logged into portal'),
    AuditLogModel(logId: 'LOG-1002', timestamp: DateTime.now().subtract(const Duration(minutes: 15)).toIso8601String(), userId: 'USR-1004', userName: 'Demo Sales Executive', action: 'CREATE_LEAD', module: 'CRM', details: 'Created lead LD-1004 for Aarav Patel'),
    AuditLogModel(logId: 'LOG-1003', timestamp: DateTime.now().subtract(const Duration(minutes: 30)).toIso8601String(), userId: 'USR-1003', userName: 'Ashif', action: 'REASSIGN_LEADS', module: 'CRM', details: 'Reassigned 2 leads to Priya Verma'),
    AuditLogModel(logId: 'LOG-1004', timestamp: DateTime.now().subtract(const Duration(hours: 1)).toIso8601String(), userId: 'USR-1005', userName: 'Operations', action: 'UPDATE_FEE_DUE_DATE', module: 'FINANCE', details: 'Extended due date for Rohan Mehta by 7 days'),
    AuditLogModel(logId: 'LOG-1005', timestamp: DateTime.now().subtract(const Duration(hours: 2)).toIso8601String(), userId: 'USR-1002', userName: 'Rasheed', action: 'RECORD_EXPENSE', module: 'FINANCE', details: 'Recorded Google Ads expense EXP-1001'),
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        cross: CrossAxisAlignment.start,
        children: [
          const Text('System Audit Logs & Security Trail', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          const Text('Immutable read-only record of system events, lead reassignments, due-date extensions, and financial transactions.', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
          const SizedBox(height: 20),

          Expanded(
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: DataTable(
                  columns: const [
                    DataColumn(label: Text('Log ID', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('Timestamp', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('User', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('Action', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('Module', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('Details', style: TextStyle(fontWeight: FontWeight.bold))),
                  ],
                  rows: _logs.map((log) => DataRow(cells: [
                    DataCell(Text(log.logId, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary))),
                    DataCell(Text(log.timestamp.substring(0, 16).replaceAll('T', ' '))),
                    DataCell(Text(log.userName, style: const TextStyle(fontWeight: FontWeight.bold))),
                    DataCell(Text(log.action, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.info))),
                    DataCell(Text(log.module)),
                    DataCell(Text(log.details, style: const TextStyle(fontSize: 11))),
                  ])).toList(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
