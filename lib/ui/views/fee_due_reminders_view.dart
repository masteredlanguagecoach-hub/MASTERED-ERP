import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/currency_formatter.dart';
import '../../data/models/student_model.dart';
import '../../providers/fee_provider.dart';
import '../../providers/batch_provider.dart';
import '../widgets/status_badge.dart';

class FeeDueRemindersView extends StatefulWidget {
  const FeeDueRemindersView({super.key});

  @override
  State<FeeDueRemindersView> createState() => _FeeDueRemindersViewState();
}

class _FeeDueRemindersViewState extends State<FeeDueRemindersView> {
  String? _selectedBatch;
  final Set<String> _sentReminderStudentIds = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<FeeProvider>(context, listen: false).fetchStudentsAndPayments();
      Provider.of<BatchProvider>(context, listen: false).fetchBatches();
    });
  }

  void _launchOperationsWhatsApp(StudentModel student) async {
    final cleanPhone = student.phone.replaceAll(RegExp(r'\D'), '');
    final fullPhone = cleanPhone.startsWith('91') ? cleanPhone : '91$cleanPhone';
    final amountFormatted = CurrencyFormatter.format(student.balanceFee);
    final msg = Uri.encodeComponent(
      'Hello ${student.name}, this is a reminder from MASTERED. Your fee installment of $amountFormatted is due on ${student.feeDueDate}.'
    );
    final url = Uri.parse('https://wa.me/$fullPhone?text=$msg');

    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  void _markReminderSent(StudentModel student) {
    setState(() {
      _sentReminderStudentIds.add(student.studentId);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Marked fee reminder sent to ${student.name}'), backgroundColor: AppColors.success),
    );
  }

  @override
  Widget build(BuildContext context) {
    final feeProvider = Provider.of<FeeProvider>(context);
    final batchProvider = Provider.of<BatchProvider>(context);

    // Filter students with pending fees
    final pendingStudents = feeProvider.students.where((s) => s.balanceFee > 0).toList();

    // Filter by selected batch
    final displayStudents = _selectedBatch == null || _selectedBatch!.isEmpty
        ? pendingStudents
        : pendingStudents.where((s) => s.batchName == _selectedBatch || s.batchId == _selectedBatch).toList();

    final pendingRemindersCount = displayStudents.where((s) => !_sentReminderStudentIds.contains(s.studentId)).length;

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        cross: CrossAxisAlignment.start,
        children: [
          // Header Card
          Card(
            color: AppColors.secondary,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 22,
                    backgroundColor: AppColors.warning,
                    child: Icon(Icons.alarm_on, color: Colors.white, size: 22),
                  ),
                  const SizedBox(width: 14),
                  const Column(
                    cross: CrossAxisAlignment.start,
                    children: [
                      Text('Operations 3-Day Fee Due Reminder Portal', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                      Text('Batch-wise automated fee due reminders & tracking for upcoming installments.', style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
                    ],
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(color: AppColors.warning.withOpacity(0.2), borderRadius: BorderRadius.circular(20)),
                    child: Text('Pending Reminders: $pendingRemindersCount', style: const TextStyle(color: AppColors.warning, fontWeight: FontWeight.bold, fontSize: 12)),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Batch Filter Bar
          Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  const Text('Filter by Batch:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButton<String>(
                      value: _selectedBatch,
                      hint: const Text('All Academy Batches'),
                      isExpanded: true,
                      underline: const SizedBox(),
                      items: [
                        const DropdownMenuItem(value: null, child: Text('All Academy Batches')),
                        ...batchProvider.batches.map((b) => DropdownMenuItem(value: b.batchName, child: Text('${b.batchName} (${b.course})'))),
                      ],
                      onChanged: (val) => setState(() => _selectedBatch = val),
                    ),
                  ),
                  const SizedBox(width: 12),
                  StatusBadge(label: 'Total Sent: ${_sentReminderStudentIds.length}'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Students Table
          Expanded(
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  cross: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('3-Day Fee Due Students List', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                        StatusBadge(label: '${displayStudents.length} Students Pending'),
                      ],
                    ),
                    const Divider(height: 24),
                    Expanded(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: SingleChildScrollView(
                          child: DataTable(
                            columns: const [
                              DataColumn(label: Text('Admission No', style: TextStyle(fontWeight: FontWeight.bold))),
                              DataColumn(label: Text('Student Name', style: TextStyle(fontWeight: FontWeight.bold))),
                              DataColumn(label: Text('Batch Name', style: TextStyle(fontWeight: FontWeight.bold))),
                              DataColumn(label: Text('Pending Fee', style: TextStyle(fontWeight: FontWeight.bold))),
                              DataColumn(label: Text('Due Date', style: TextStyle(fontWeight: FontWeight.bold))),
                              DataColumn(label: Text('Reminder Status', style: TextStyle(fontWeight: FontWeight.bold))),
                              DataColumn(label: Text('WhatsApp Reminder', style: TextStyle(fontWeight: FontWeight.bold))),
                              DataColumn(label: Text('Action', style: TextStyle(fontWeight: FontWeight.bold))),
                            ],
                            rows: displayStudents.map((student) {
                              final isSent = _sentReminderStudentIds.contains(student.studentId);
                              return DataRow(cells: [
                                DataCell(Text(student.admissionNo, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary))),
                                DataCell(Text(student.name, style: const TextStyle(fontWeight: FontWeight.bold))),
                                DataCell(Text(student.batchName, style: const TextStyle(fontSize: 12))),
                                DataCell(Text(CurrencyFormatter.format(student.balanceFee), style: const TextStyle(color: AppColors.danger, fontWeight: FontWeight.bold))),
                                DataCell(Text(student.feeDueDate, style: const TextStyle(color: AppColors.danger, fontWeight: FontWeight.bold))),
                                DataCell(
                                  StatusBadge(
                                    label: isSent ? 'Reminder Sent' : 'Pending Reminder',
                                  ),
                                ),
                                DataCell(
                                  IconButton(
                                    icon: const Icon(Icons.chat, color: AppColors.success, size: 20),
                                    onPressed: () => _launchOperationsWhatsApp(student),
                                    tooltip: 'Send Fee Reminder via WhatsApp',
                                  ),
                                ),
                                DataCell(
                                  ElevatedButton.icon(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: isSent ? AppColors.textMuted : AppColors.primary,
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    ),
                                    onPressed: isSent ? null : () => _markReminderSent(student),
                                    icon: Icon(isSent ? Icons.check : Icons.send, size: 14),
                                    label: Text(isSent ? 'Sent' : 'Mark as Sent', style: const TextStyle(fontSize: 11)),
                                  ),
                                ),
                              ]);
                            }).toList(),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
