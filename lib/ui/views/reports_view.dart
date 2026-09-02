import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/currency_formatter.dart';
import '../../core/utils/date_formatter.dart';
import '../../data/services/export_service.dart';
import '../../providers/lead_provider.dart';
import '../../providers/fee_provider.dart';
import '../../providers/accounting_provider.dart';
import '../../providers/user_provider.dart';

class ReportsView extends StatefulWidget {
  const ReportsView({super.key});

  @override
  State<ReportsView> createState() => _ReportsViewState();
}

class _ReportsViewState extends State<ReportsView> {
  String _selectedReportType = 'Total Leads Report';

  final List<String> _reportTypes = [
    'Total Leads Report',
    'Sales Executive-wise Lead Report',
    'Student Status Report (Active, Pending & Dropped)',
    'Collection & Payment Report',
    'Pending Fee Ledger Report',
    'Expense & Accounting Report',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<UserProvider>(context, listen: false).fetchUsers();
    });
  }

  void _exportReportPdf() {
    final feeProvider = Provider.of<FeeProvider>(context, listen: false);
    final leadProvider = Provider.of<LeadProvider>(context, listen: false);
    final accProvider = Provider.of<AccountingProvider>(context, listen: false);
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    List<String> headers = [];
    List<List<dynamic>> rows = [];

    if (_selectedReportType == 'Total Leads Report') {
      headers = ['Lead ID', 'Date', 'Name', 'Phone', 'Course', 'Assigned Rep', 'Status'];
      rows = leadProvider.rawLeads.map((l) => [l.leadId, l.date, l.name, l.phone, l.courseInterested, l.assignedTo, l.status]).toList();
    } else if (_selectedReportType == 'Sales Executive-wise Lead Report') {
      headers = ['Sales Executive', 'Total Leads', 'Contacted', 'Interested', 'Converted', 'Closing Rate'];
      final execs = userProvider.users.where((u) => u.role == 'SALES_EXECUTIVE' || u.role == 'SALES_HEAD').toList();
      rows = execs.map((exec) {
        final execLeads = leadProvider.rawLeads.where((l) => l.assignedTo == exec.name || l.createdBy == exec.email).toList();
        final converted = execLeads.where((l) => l.status == 'Converted').length;
        final contacted = execLeads.where((l) => l.status == 'Contacted').length;
        final interested = execLeads.where((l) => l.status == 'Interested').length;
        final rate = execLeads.isNotEmpty ? '${((converted / execLeads.length) * 100).toStringAsFixed(1)}%' : '0%';
        return [exec.name, execLeads.length, contacted, interested, converted, rate];
      }).toList();
    } else if (_selectedReportType == 'Student Status Report (Active, Pending & Dropped)') {
      headers = ['Admission No', 'Student Name', 'Course', 'Status', 'Total Fee', 'Paid', 'Balance'];
      rows = feeProvider.students.map((s) => [s.admissionNo, s.name, s.course, s.status, CurrencyFormatter.format(s.totalFee), CurrencyFormatter.format(s.paidFee), CurrencyFormatter.format(s.balanceFee)]).toList();
    } else if (_selectedReportType == 'Collection & Payment Report') {
      headers = ['Receipt No', 'Date', 'Student Name', 'Payment Mode', 'Amount'];
      rows = feeProvider.payments.map((p) => [p.receiptNo, DateFormatter.formatDisplay(p.date), p.studentName, p.paymentMode, CurrencyFormatter.format(p.amount)]).toList();
    } else if (_selectedReportType == 'Pending Fee Ledger Report') {
      headers = ['Admission No', 'Student Name', 'Course', 'Pending Fee', 'Due Date'];
      rows = feeProvider.students.where((s) => s.balanceFee > 0).map((s) => [s.admissionNo, s.name, s.course, CurrencyFormatter.format(s.balanceFee), s.feeDueDate]).toList();
    } else {
      headers = ['Expense ID', 'Date', 'Category', 'Description', 'Amount'];
      rows = accProvider.expenses.map((e) => [e.expenseId, DateFormatter.formatDisplay(e.date), e.category, e.description, CurrencyFormatter.format(e.amount)]).toList();
    }

    ExportService.exportReportPdf(
      title: _selectedReportType,
      headers: headers,
      rows: rows,
    );
  }

  @override
  Widget build(BuildContext context) {
    final feeProvider = Provider.of<FeeProvider>(context);
    final leadProvider = Provider.of<LeadProvider>(context);
    final accProvider = Provider.of<AccountingProvider>(context);
    final userProvider = Provider.of<UserProvider>(context);

    final activeStudentsCount = feeProvider.students.where((s) => s.status == 'ACTIVE').length;
    final droppedStudentsCount = feeProvider.students.where((s) => s.status == 'DROPPED').length;
    final pendingFeeStudentsCount = feeProvider.students.where((s) => s.balanceFee > 0).length;

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        cross: CrossAxisAlignment.start,
        children: [
          // Student Counts Summary Card Header
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  _buildCountTile('Active Students', '$activeStudentsCount', AppColors.success, Icons.school),
                  const SizedBox(width: 16),
                  _buildCountTile('Pending Fee Students', '$pendingFeeStudentsCount', AppColors.warning, Icons.pending_actions),
                  const SizedBox(width: 16),
                  _buildCountTile('Dropped Students', '$droppedStudentsCount', AppColors.danger, Icons.person_off),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Report Controls Selector Bar
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Text('Select Executive Report:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButton<String>(
                      value: _selectedReportType,
                      isExpanded: true,
                      underline: const SizedBox(),
                      items: _reportTypes.map((t) => DropdownMenuItem(value: t, child: Text(t, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)))).toList(),
                      onChanged: (v) => setState(() => _selectedReportType = v ?? _selectedReportType),
                    ),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton.icon(
                    onPressed: _exportReportPdf,
                    icon: const Icon(Icons.print, size: 18),
                    label: const Text('Export PDF / Print'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Report Table Container
          Expanded(
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  cross: CrossAxisAlignment.start,
                  children: [
                    Text(_selectedReportType, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primary)),
                    const SizedBox(height: 4),
                    Text('Executive audit report as of ${DateTime.now().toString().substring(0, 10)}', style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
                    const Divider(height: 24),

                    Expanded(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: SingleChildScrollView(
                          child: _buildSelectedReportTable(feeProvider, leadProvider, accProvider, userProvider),
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

  Widget _buildCountTile(String label, String count, Color color, IconData icon) {
    return Expanded(
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(8)),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 10),
          Column(
            cross: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
              Text(count, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSelectedReportTable(FeeProvider fp, LeadProvider lp, AccountingProvider ap, UserProvider up) {
    if (_selectedReportType == 'Total Leads Report') {
      return DataTable(
        columns: const [
          DataColumn(label: Text('Lead ID', style: TextStyle(fontWeight: FontWeight.bold))),
          DataColumn(label: Text('Date', style: TextStyle(fontWeight: FontWeight.bold))),
          DataColumn(label: Text('Lead Name', style: TextStyle(fontWeight: FontWeight.bold))),
          DataColumn(label: Text('Phone', style: TextStyle(fontWeight: FontWeight.bold))),
          DataColumn(label: Text('Course Interested', style: TextStyle(fontWeight: FontWeight.bold))),
          DataColumn(label: Text('Assigned Executive', style: TextStyle(fontWeight: FontWeight.bold))),
          DataColumn(label: Text('Status', style: TextStyle(fontWeight: FontWeight.bold))),
        ],
        rows: lp.rawLeads.map((l) => DataRow(cells: [
          DataCell(Text(l.leadId, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary))),
          DataCell(Text(l.date)),
          DataCell(Text(l.name, style: const TextStyle(fontWeight: FontWeight.bold))),
          DataCell(Text(l.phone)),
          DataCell(Text(l.courseInterested)),
          DataCell(Text(l.assignedTo)),
          DataCell(Text(l.status, style: const TextStyle(fontWeight: FontWeight.bold))),
        ])).toList(),
      );
    } else if (_selectedReportType == 'Sales Executive-wise Lead Report') {
      final execs = up.users.where((u) => u.role == 'SALES_EXECUTIVE' || u.role == 'SALES_HEAD').toList();
      return DataTable(
        columns: const [
          DataColumn(label: Text('Executive Name', style: TextStyle(fontWeight: FontWeight.bold))),
          DataColumn(label: Text('Total Leads Assigned', style: TextStyle(fontWeight: FontWeight.bold))),
          DataColumn(label: Text('Contacted', style: TextStyle(fontWeight: FontWeight.bold))),
          DataColumn(label: Text('Interested', style: TextStyle(fontWeight: FontWeight.bold))),
          DataColumn(label: Text('Converted', style: TextStyle(fontWeight: FontWeight.bold))),
          DataColumn(label: Text('Conversion Ratio', style: TextStyle(fontWeight: FontWeight.bold))),
        ],
        rows: execs.map((exec) {
          final execLeads = lp.rawLeads.where((l) => l.assignedTo == exec.name || l.createdBy == exec.email).toList();
          final converted = execLeads.where((l) => l.status == 'Converted').length;
          final contacted = execLeads.where((l) => l.status == 'Contacted').length;
          final interested = execLeads.where((l) => l.status == 'Interested').length;
          final rate = execLeads.isNotEmpty ? '${((converted / execLeads.length) * 100).toStringAsFixed(1)}%' : '0%';
          return DataRow(cells: [
            DataCell(Text(exec.name, style: const TextStyle(fontWeight: FontWeight.bold))),
            DataCell(Text('${execLeads.length}')),
            DataCell(Text('$contacted')),
            DataCell(Text('$interested')),
            DataCell(Text('$converted', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.success))),
            DataCell(Text(rate, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary))),
          ]);
        }).toList(),
      );
    } else if (_selectedReportType == 'Student Status Report (Active, Pending & Dropped)') {
      return DataTable(
        columns: const [
          DataColumn(label: Text('Admission No', style: TextStyle(fontWeight: FontWeight.bold))),
          DataColumn(label: Text('Student Name', style: TextStyle(fontWeight: FontWeight.bold))),
          DataColumn(label: Text('Course', style: TextStyle(fontWeight: FontWeight.bold))),
          DataColumn(label: Text('Status', style: TextStyle(fontWeight: FontWeight.bold))),
          DataColumn(label: Text('Total Fee', style: TextStyle(fontWeight: FontWeight.bold))),
          DataColumn(label: Text('Paid Fee', style: TextStyle(fontWeight: FontWeight.bold))),
          DataColumn(label: Text('Balance Fee', style: TextStyle(fontWeight: FontWeight.bold))),
        ],
        rows: fp.students.map((s) => DataRow(cells: [
          DataCell(Text(s.admissionNo, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary))),
          DataCell(Text(s.name, style: const TextStyle(fontWeight: FontWeight.bold))),
          DataCell(Text(s.course)),
          DataCell(Text(s.status, style: TextStyle(fontWeight: FontWeight.bold, color: s.status == 'ACTIVE' ? AppColors.success : AppColors.danger))),
          DataCell(Text(CurrencyFormatter.format(s.totalFee))),
          DataCell(Text(CurrencyFormatter.format(s.paidFee), style: const TextStyle(color: AppColors.success, fontWeight: FontWeight.bold))),
          DataCell(Text(CurrencyFormatter.format(s.balanceFee), style: TextStyle(color: s.balanceFee > 0 ? AppColors.danger : AppColors.success, fontWeight: FontWeight.bold))),
        ])).toList(),
      );
    } else if (_selectedReportType == 'Collection & Payment Report') {
      return DataTable(
        columns: const [
          DataColumn(label: Text('Receipt No', style: TextStyle(fontWeight: FontWeight.bold))),
          DataColumn(label: Text('Date', style: TextStyle(fontWeight: FontWeight.bold))),
          DataColumn(label: Text('Student Name', style: TextStyle(fontWeight: FontWeight.bold))),
          DataColumn(label: Text('Payment Mode', style: TextStyle(fontWeight: FontWeight.bold))),
          DataColumn(label: Text('Amount Paid', style: TextStyle(fontWeight: FontWeight.bold))),
        ],
        rows: fp.payments.map((p) => DataRow(cells: [
          DataCell(Text(p.receiptNo, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary))),
          DataCell(Text(DateFormatter.formatDisplay(p.date))),
          DataCell(Text(p.studentName, style: const TextStyle(fontWeight: FontWeight.bold))),
          DataCell(Text(p.paymentMode)),
          DataCell(Text(CurrencyFormatter.format(p.amount), style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.success))),
        ])).toList(),
      );
    } else if (_selectedReportType == 'Pending Fee Ledger Report') {
      final pendingStudents = fp.students.where((s) => s.balanceFee > 0).toList();
      return DataTable(
        columns: const [
          DataColumn(label: Text('Admission No', style: TextStyle(fontWeight: FontWeight.bold))),
          DataColumn(label: Text('Student Name', style: TextStyle(fontWeight: FontWeight.bold))),
          DataColumn(label: Text('Course', style: TextStyle(fontWeight: FontWeight.bold))),
          DataColumn(label: Text('Pending Fee Balance', style: TextStyle(fontWeight: FontWeight.bold))),
          DataColumn(label: Text('Fee Due Date', style: TextStyle(fontWeight: FontWeight.bold))),
        ],
        rows: pendingStudents.map((s) => DataRow(cells: [
          DataCell(Text(s.admissionNo, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary))),
          DataCell(Text(s.name, style: const TextStyle(fontWeight: FontWeight.bold))),
          DataCell(Text(s.course)),
          DataCell(Text(CurrencyFormatter.format(s.balanceFee), style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.danger))),
          DataCell(Text(s.feeDueDate, style: const TextStyle(color: AppColors.danger, fontWeight: FontWeight.bold))),
        ])).toList(),
      );
    } else {
      return DataTable(
        columns: const [
          DataColumn(label: Text('Expense ID', style: TextStyle(fontWeight: FontWeight.bold))),
          DataColumn(label: Text('Date', style: TextStyle(fontWeight: FontWeight.bold))),
          DataColumn(label: Text('Category', style: TextStyle(fontWeight: FontWeight.bold))),
          DataColumn(label: Text('Description', style: TextStyle(fontWeight: FontWeight.bold))),
          DataColumn(label: Text('Amount', style: TextStyle(fontWeight: FontWeight.bold))),
        ],
        rows: ap.expenses.map((e) => DataRow(cells: [
          DataCell(Text(e.expenseId, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.danger))),
          DataCell(Text(DateFormatter.formatDisplay(e.date))),
          DataCell(Text(e.category, style: const TextStyle(fontWeight: FontWeight.bold))),
          DataCell(Text(e.description)),
          DataCell(Text(CurrencyFormatter.format(e.amount), style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.danger))),
        ])).toList(),
      );
    }
  }
}
