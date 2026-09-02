import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../data/services/export_service.dart';

class ReportsView extends StatefulWidget {
  const ReportsView({super.key});

  @override
  State<ReportsView> createState() => _ReportsViewState();
}

class _ReportsViewState extends State<ReportsView> {
  String _selectedReportCategory = 'Executive Performance Summary';

  final List<String> _reportCategories = [
    'Lead Summary Report',
    'Stage Summary Report',
    'Follow-ups Activity Report',
    'Missed Follow-ups Audit',
    'Executive Performance Summary',
    'Monthly Conversion Analysis',
    'Source Performance Report',
    'Student Admissions Directory',
    'Students Placement Register',
    'Batch Performance Ledger',
    'Fee Collection Register',
    'Installments & Due Dates',
    'Pending & Overdue Fees',
    'Receipt Register',
    'Expenses & Petty Cash Log',
    'Cash Book Ledger',
    'Bank Book Ledger',
    'Profit & Loss Statement',
    'System Security Audit Log',
  ];

  void _exportReport(String format) {
    ExportService.exportReport(
      reportTitle: _selectedReportCategory,
      headers: ['Metric Category', 'Total Count / Value', 'Status', 'Generated Timestamp'],
      data: [
        ['Total Qualified Records', '45', 'ACTIVE', DateTime.now().toIso8601String().substring(0, 10)],
        ['Realized Revenue / Progress', '₹105,000', 'COMPLETED', DateTime.now().toIso8601String().substring(0, 10)],
        ['Pending Balances / Follow-ups', '₹15,000', 'PENDING', DateTime.now().toIso8601String().substring(0, 10)],
      ],
      format: format,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Exported $_selectedReportCategory as $format'), backgroundColor: AppColors.success),
    );
  }

  @override
  Widget build(BuildContext context) {
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
                  Text('Executive Reports & Analytics Center', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  Text('Generate 19 comprehensive report categories with multi-format PDF, Excel, CSV, and Drive export.', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                ],
              ),
              Row(
                children: [
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger),
                    onPressed: () => _exportReport('PDF'),
                    icon: const Icon(Icons.picture_as_pdf, size: 16),
                    label: const Text('Export PDF'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.success),
                    onPressed: () => _exportReport('CSV'),
                    icon: const Icon(Icons.table_chart, size: 16),
                    label: const Text('Export CSV'),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Report Category Selector
          Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  const Text('Select Report Category:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  const SizedBox(width: 14),
                  Expanded(
                    child: DropdownButton<String>(
                      value: _selectedReportCategory,
                      isExpanded: true,
                      underline: const SizedBox(),
                      items: _reportCategories.map((r) => DropdownMenuItem(value: r, child: Text(r, style: const TextStyle(fontWeight: FontWeight.bold)))).toList(),
                      onChanged: (v) => setState(() => _selectedReportCategory = v!),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Report Data Display Table
          Expanded(
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  cross: CrossAxisAlignment.start,
                  children: [
                    Text('Report Preview: $_selectedReportCategory', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                    const Divider(height: 24),
                    DataTable(
                      columns: const [
                        DataColumn(label: Text('Metric Category', style: TextStyle(fontWeight: FontWeight.bold))),
                        DataColumn(label: Text('Total Count / Value', style: TextStyle(fontWeight: FontWeight.bold))),
                        DataColumn(label: Text('Status', style: TextStyle(fontWeight: FontWeight.bold))),
                        DataColumn(label: Text('Generated Timestamp', style: TextStyle(fontWeight: FontWeight.bold))),
                      ],
                      rows: const [
                        DataRow(cells: [
                          DataCell(Text('Total Qualified Records', style: TextStyle(fontWeight: FontWeight.bold))),
                          DataCell(Text('45 Records')),
                          DataCell(Text('ACTIVE', style: TextStyle(color: AppColors.success, fontWeight: FontWeight.bold))),
                          DataCell(Text('2026-09-02')),
                        ]),
                        DataRow(cells: [
                          DataCell(Text('Realized Revenue / Progress', style: TextStyle(fontWeight: FontWeight.bold))),
                          DataCell(Text('₹105,000', style: TextStyle(color: AppColors.success, fontWeight: FontWeight.bold))),
                          DataCell(Text('COMPLETED', style: TextStyle(color: AppColors.success, fontWeight: FontWeight.bold))),
                          DataCell(Text('2026-09-02')),
                        ]),
                        DataRow(cells: [
                          DataCell(Text('Pending Balances / Follow-ups', style: TextStyle(fontWeight: FontWeight.bold))),
                          DataCell(Text('₹15,000', style: TextStyle(color: AppColors.danger, fontWeight: FontWeight.bold))),
                          DataCell(Text('PENDING', style: TextStyle(color: AppColors.warning, fontWeight: FontWeight.bold))),
                          DataCell(Text('2026-09-02')),
                        ]),
                      ],
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
