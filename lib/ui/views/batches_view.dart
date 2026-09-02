import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/permissions/role_permissions.dart';
import '../../data/models/batch_model.dart';
import '../../data/models/student_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/batch_provider.dart';
import '../../providers/fee_provider.dart';
import '../widgets/status_badge.dart';

class BatchesView extends StatefulWidget {
  const BatchesView({super.key});

  @override
  State<BatchesView> createState() => _BatchesViewState();
}

class _BatchesViewState extends State<BatchesView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<BatchProvider>(context, listen: false).fetchBatches();
      Provider.of<FeeProvider>(context, listen: false).fetchStudentsAndPayments();
    });
  }

  void _showCreateBatchDialog() {
    final nameCtrl = TextEditingController();
    final courseCtrl = TextEditingController(text: 'Full Stack Development');
    final scheduleCtrl = TextEditingController(text: 'Mon-Fri 10:00 AM - 12:00 PM');
    final trainerCtrl = TextEditingController(text: 'Senior Faculty');
    final startDateCtrl = TextEditingController(text: DateTime.now().toIso8601String().substring(0, 10));

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create New Training Batch'),
        content: SizedBox(
          width: 440,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Batch Name *', hintText: 'Batch 2026-B')),
              const SizedBox(height: 12),
              TextField(controller: courseCtrl, decoration: const InputDecoration(labelText: 'Course *')),
              const SizedBox(height: 12),
              TextField(controller: scheduleCtrl, decoration: const InputDecoration(labelText: 'Schedule (Days & Time)')),
              const SizedBox(height: 12),
              TextField(controller: trainerCtrl, decoration: const InputDecoration(labelText: 'Assigned Trainer / Faculty')),
              const SizedBox(height: 12),
              TextField(controller: startDateCtrl, decoration: const InputDecoration(labelText: 'Start Date (YYYY-MM-DD)')),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              if (nameCtrl.text.isEmpty || courseCtrl.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Fill batch name and course')));
                return;
              }

              final batchProvider = Provider.of<BatchProvider>(context, listen: false);
              final success = await batchProvider.createBatch(
                batchName: nameCtrl.text.trim(),
                course: courseCtrl.text.trim(),
                startDate: startDateCtrl.text.trim(),
                schedule: scheduleCtrl.text.trim(),
                trainer: trainerCtrl.text.trim(),
              );

              if (mounted) {
                if (success) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Batch created successfully'), backgroundColor: AppColors.success),
                  );
                }
              }
            },
            child: const Text('Create Batch'),
          ),
        ],
      ),
    );
  }

  void _showTransferBatchDialog(StudentModel student) {
    final batchProvider = Provider.of<BatchProvider>(context, listen: false);
    BatchModel? selectedTargetBatch = batchProvider.batches.isNotEmpty ? batchProvider.batches.first : null;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Change Batch for ${student.name}'),
        content: SizedBox(
          width: 420,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            cross: CrossAxisAlignment.start,
            children: [
              Text('Current Batch: ${student.batchName}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              DropdownButtonFormField<BatchModel>(
                value: selectedTargetBatch,
                decoration: const InputDecoration(labelText: 'Select New Target Batch *'),
                items: batchProvider.batches.map((b) => DropdownMenuItem(value: b, child: Text('${b.batchName} (${b.course})'))).toList(),
                onChanged: (v) => selectedTargetBatch = v,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.success),
            onPressed: () async {
              if (selectedTargetBatch == null) return;
              await batchProvider.reassignStudentBatch(student.studentId, selectedTargetBatch!);
              if (mounted) {
                Navigator.pop(context);
                Provider.of<FeeProvider>(context, listen: false).fetchStudentsAndPayments();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Moved ${student.name} to ${selectedTargetBatch!.batchName}'), backgroundColor: AppColors.success),
                );
              }
            },
            child: const Text('Transfer Student'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final batchProvider = Provider.of<BatchProvider>(context);
    final feeProvider = Provider.of<FeeProvider>(context);
    final user = Provider.of<AuthProvider>(context).currentUser;
    final role = user?.role ?? '';

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        cross: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                cross: CrossAxisAlignment.start,
                children: [
                  Text('Batch & Academy Class Management', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  Text('Create batches, assign new admissions, and move students between batches.', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                ],
              ),
              if (RolePermissions.canCreateBatch(role))
                ElevatedButton.icon(
                  onPressed: _showCreateBatchDialog,
                  icon: const Icon(Icons.group_add, size: 18),
                  label: const Text('Create New Batch'),
                ),
            ],
          ),
          const SizedBox(height: 20),

          // Batches Grid
          Expanded(
            child: ListView.builder(
              itemCount: batchProvider.batches.length,
              itemBuilder: (context, idx) {
                final batch = batchProvider.batches[idx];
                final batchStudents = feeProvider.students.where((s) => s.batchId == batch.batchId || s.batchName == batch.batchName).toList();

                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      cross: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                const CircleAvatar(
                                  backgroundColor: AppColors.primary,
                                  radius: 18,
                                  child: Icon(Icons.class_, color: Colors.white, size: 18),
                                ),
                                const SizedBox(width: 12),
                                Column(
                                  cross: CrossAxisAlignment.start,
                                  children: [
                                    Text(batch.batchName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                    Text('${batch.course} • Trainer: ${batch.trainer}', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                                  ],
                                ),
                              ],
                            ),
                            StatusBadge(label: '${batchStudents.length} Enrolled Students'),
                          ],
                        ),
                        const Divider(height: 24),
                        Row(
                          children: [
                            const Icon(Icons.schedule, size: 16, color: AppColors.textMuted),
                            const SizedBox(width: 6),
                            Text('Schedule: ${batch.schedule}', style: const TextStyle(fontSize: 12)),
                            const SizedBox(width: 24),
                            const Icon(Icons.calendar_today, size: 16, color: AppColors.textMuted),
                            const SizedBox(width: 6),
                            Text('Start Date: ${batch.startDate}', style: const TextStyle(fontSize: 12)),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Enrolled Students List
                        if (batchStudents.isEmpty)
                          const Text('No students currently assigned to this batch.', style: TextStyle(fontSize: 12, color: AppColors.textMuted, fontStyle: FontStyle.italic))
                        else
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: DataTable(
                              headingRowHeight: 36,
                              dataRowHeight: 44,
                              columns: const [
                                DataColumn(label: Text('Admission No')),
                                DataColumn(label: Text('Student Name')),
                                DataColumn(label: Text('Phone')),
                                DataColumn(label: Text('Fee Balance')),
                                DataColumn(label: Text('Batch Transfer')),
                              ],
                              rows: batchStudents.map((s) {
                                return DataRow(
                                  cells: [
                                    DataCell(Text(s.admissionNo, style: const TextStyle(fontWeight: FontWeight.bold))),
                                    DataCell(Text(s.name)),
                                    DataCell(Text(s.phone)),
                                    DataCell(Text('₹${s.balanceFee.toStringAsFixed(0)}', style: TextStyle(color: s.balanceFee > 0 ? AppColors.danger : AppColors.success, fontWeight: FontWeight.bold))),
                                    DataCell(
                                      OutlinedButton.icon(
                                        style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4)),
                                        onPressed: () => _showTransferBatchDialog(s),
                                        icon: const Icon(Icons.swap_horiz, size: 14),
                                        label: const Text('Move Batch', style: TextStyle(fontSize: 11)),
                                      ),
                                    ),
                                  ],
                                );
                              }).toList(),
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
