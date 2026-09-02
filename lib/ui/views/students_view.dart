import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/permissions/role_permissions.dart';
import '../../core/utils/currency_formatter.dart';
import '../../core/utils/date_formatter.dart';
import '../../data/models/student_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/fee_provider.dart';
import '../../providers/batch_provider.dart';
import '../widgets/status_badge.dart';

class StudentsView extends StatefulWidget {
  const StudentsView({super.key});

  @override
  State<StudentsView> createState() => _StudentsViewState();
}

class _StudentsViewState extends State<StudentsView> {
  bool _filterPendingOnly = false;
  String? _selectedBatch;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<FeeProvider>(context, listen: false).fetchStudentsAndPayments();
      Provider.of<BatchProvider>(context, listen: false).fetchBatches();
    });
  }

  void _openDriveFolder(String driveFolderId) async {
    if (driveFolderId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No Google Drive folder ID linked')));
      return;
    }
    final url = Uri.parse('https://drive.google.com/drive/folders/$driveFolderId');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  void _launchFeedbackWhatsApp(StudentModel student, String roleLabel) async {
    final cleanPhone = student.phone.replaceAll(RegExp(r'\D'), '');
    final fullPhone = cleanPhone.startsWith('91') ? cleanPhone : '91$cleanPhone';
    final msg = Uri.encodeComponent(
      'Hello ${student.name}, this is $roleLabel from MASTERED. We would love to get your valuable feedback regarding your course ${student.course} in ${student.batchName}. Please reply with your feedback!'
    );
    final url = Uri.parse('https://wa.me/$fullPhone?text=$msg');

    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  void _launchPlacementSurveyWhatsApp(StudentModel student) async {
    final cleanPhone = student.phone.replaceAll(RegExp(r'\D'), '');
    final fullPhone = cleanPhone.startsWith('91') ? cleanPhone : '91$cleanPhone';
    final msg = Uri.encodeComponent(
      'Hello ${student.name}, this is Ashif (Sales Head) from MASTERED regarding placement support. Please reply with:\n1. Do you want Placement? (Yes/No)\n2. Email ID\n3. Preferred Job Locations\n4. Role/Domain Interested in.'
    );
    final url = Uri.parse('https://wa.me/$fullPhone?text=$msg');

    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  void _showUpdateDueDateDialog(StudentModel student) {
    final dateCtrl = TextEditingController(text: student.feeDueDate.isNotEmpty ? student.feeDueDate : DateTime.now().add(const Duration(days: 15)).toIso8601String().substring(0, 10));

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Update Fee Due Date (${student.name})'),
        content: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            cross: CrossAxisAlignment.start,
            children: [
              Text('Current Pending Balance: ${CurrencyFormatter.format(student.balanceFee)}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.danger)),
              const SizedBox(height: 16),
              TextField(
                controller: dateCtrl,
                decoration: const InputDecoration(labelText: 'Next Fee Due Date (YYYY-MM-DD) *', hintText: '2026-09-25'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              if (dateCtrl.text.isEmpty) return;
              final feeProvider = Provider.of<FeeProvider>(context, listen: false);
              await feeProvider.fetchStudentsAndPayments();
              if (mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Fee due date updated successfully'), backgroundColor: AppColors.success),
                );
              }
            },
            child: const Text('Update Due Date'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final feeProvider = Provider.of<FeeProvider>(context);
    final batchProvider = Provider.of<BatchProvider>(context);
    final user = Provider.of<AuthProvider>(context).currentUser;
    final role = user?.role ?? '';

    List<StudentModel> displayStudents = feeProvider.students;

    // Filter by Batch if selected
    if (_selectedBatch != null && _selectedBatch!.isNotEmpty) {
      displayStudents = displayStudents.where((s) => s.batchName == _selectedBatch || s.batchId == _selectedBatch).toList();
    }

    if (role == AppConstants.roleSalesExecutive && user != null) {
      displayStudents = displayStudents.where((s) => s.convertedByExecutive == user.email || s.convertedByExecutive.contains(user.email.split('@')[0])).toList();
    }

    if (_filterPendingOnly) {
      displayStudents = displayStudents.where((s) => s.balanceFee > 0).toList();
    }

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        cross: CrossAxisAlignment.start,
        children: [
          // Filter Bar with Batch Selector
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      onChanged: (q) => feeProvider.setSearchQuery(q),
                      decoration: const InputDecoration(
                        hintText: 'Search Student (Name, Phone, Admission No)...',
                        prefixIcon: Icon(Icons.search, size: 20),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Batch Dropdown Filter for Admin, CEO, Sales Head & Ops
                  Container(
                    width: 220,
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(border: Border.all(color: AppColors.border), borderRadius: BorderRadius.circular(8)),
                    child: DropdownButton<String>(
                      value: _selectedBatch,
                      hint: const Text('Filter by Batch', style: TextStyle(fontSize: 12)),
                      isExpanded: true,
                      underline: const SizedBox(),
                      items: [
                        const DropdownMenuItem(value: null, child: Text('All Batches')),
                        ...batchProvider.batches.map((b) => DropdownMenuItem(value: b.batchName, child: Text(b.batchName, style: const TextStyle(fontSize: 12)))),
                      ],
                      onChanged: (v) => setState(() => _selectedBatch = v),
                    ),
                  ),
                  const SizedBox(width: 12),
                  FilterChip(
                    selected: _filterPendingOnly,
                    label: const Text('Pending Fees Only'),
                    onSelected: (val) => setState(() => _filterPendingOnly = val),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Student Directory Table
          Expanded(
            child: feeProvider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : displayStudents.isEmpty
                    ? const Center(child: Text('No students found.', style: TextStyle(color: AppColors.textMuted)))
                    : Card(
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: SingleChildScrollView(
                            child: DataTable(
                              headingRowHeight: 44,
                              dataRowHeight: 64,
                              columns: [
                                const DataColumn(label: Text('Admission No', style: TextStyle(fontWeight: FontWeight.bold))),
                                const DataColumn(label: Text('Student Name', style: TextStyle(fontWeight: FontWeight.bold))),
                                const DataColumn(label: Text('Course & Batch', style: TextStyle(fontWeight: FontWeight.bold))),
                                const DataColumn(label: Text('Total Fee', style: TextStyle(fontWeight: FontWeight.bold))),
                                const DataColumn(label: Text('Paid Fee', style: TextStyle(fontWeight: FontWeight.bold))),
                                const DataColumn(label: Text('Pending Balance', style: TextStyle(fontWeight: FontWeight.bold))),
                                const DataColumn(label: Text('Fee Due Date', style: TextStyle(fontWeight: FontWeight.bold))),
                                if (role == AppConstants.roleAdmin || role == AppConstants.roleCeo)
                                  const DataColumn(label: Text('Feedback WhatsApp', style: TextStyle(fontWeight: FontWeight.bold))),
                                if (role == AppConstants.roleSalesHead || role == AppConstants.roleAdmin)
                                  const DataColumn(label: Text('Placement WhatsApp', style: TextStyle(fontWeight: FontWeight.bold))),
                                const DataColumn(label: Text('Drive Folder', style: TextStyle(fontWeight: FontWeight.bold))),
                              ],
                              rows: displayStudents.map((student) {
                                final isFullyPaid = student.balanceFee <= 0;
                                return DataRow(
                                  cells: [
                                    DataCell(Text(student.admissionNo, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary))),
                                    DataCell(Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      cross: CrossAxisAlignment.start,
                                      children: [
                                        Text(student.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                        Text(student.phone, style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
                                      ],
                                    )),
                                    DataCell(Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      cross: CrossAxisAlignment.start,
                                      children: [
                                        Text(student.course, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                                        Text(student.batchName, style: const TextStyle(fontSize: 10, color: AppColors.info)),
                                      ],
                                    )),
                                    DataCell(Text(CurrencyFormatter.format(student.totalFee), style: const TextStyle(fontSize: 12))),
                                    DataCell(Text(CurrencyFormatter.format(student.paidFee), style: const TextStyle(fontSize: 12, color: AppColors.success, fontWeight: FontWeight.bold))),
                                    DataCell(Text(CurrencyFormatter.format(student.balanceFee), style: TextStyle(fontSize: 12, color: isFullyPaid ? AppColors.success : AppColors.danger, fontWeight: FontWeight.bold))),
                                    DataCell(Row(
                                      children: [
                                        Text(DateFormatter.formatDisplay(student.feeDueDate), style: TextStyle(fontSize: 11, color: !isFullyPaid ? AppColors.danger : AppColors.textPrimary)),
                                        if (!isFullyPaid && RolePermissions.canUpdateDueDate(role))
                                          IconButton(
                                            icon: const Icon(Icons.edit_calendar, size: 16, color: AppColors.warning),
                                            onPressed: () => _showUpdateDueDateDialog(student),
                                            tooltip: 'Update Due Date',
                                          ),
                                      ],
                                    )),
                                    if (role == AppConstants.roleAdmin || role == AppConstants.roleCeo)
                                      DataCell(
                                        IconButton(
                                          icon: const Icon(Icons.chat, color: AppColors.info, size: 20),
                                          onPressed: () => _launchFeedbackWhatsApp(student, role == AppConstants.roleCeo ? 'Rasheed (CEO)' : 'Admin'),
                                          tooltip: 'Send Feedback Collection WhatsApp',
                                        ),
                                      ),
                                    if (role == AppConstants.roleSalesHead || role == AppConstants.roleAdmin)
                                      DataCell(
                                        IconButton(
                                          icon: const Icon(Icons.work_history, color: AppColors.success, size: 20),
                                          onPressed: () => _launchPlacementSurveyWhatsApp(student),
                                          tooltip: 'Send Placement Survey WhatsApp',
                                        ),
                                      ),
                                    DataCell(
                                      IconButton(
                                        icon: const Icon(Icons.folder_shared, size: 18, color: AppColors.primary),
                                        onPressed: () => _openDriveFolder(student.driveFolderId),
                                        tooltip: 'Open Student Google Drive Folder',
                                      ),
                                    ),
                                  ],
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}
