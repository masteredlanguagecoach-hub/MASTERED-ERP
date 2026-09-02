import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/currency_formatter.dart';
import '../../data/models/course_model.dart';

class CoursesMasterView extends StatefulWidget {
  const CoursesMasterView({super.key});

  @override
  State<CoursesMasterView> createState() => _CoursesMasterViewState();
}

class _CoursesMasterViewState extends State<CoursesMasterView> {
  final List<CourseModel> _courses = [
    CourseModel(courseId: 'BHA-6M', courseName: 'Bachelor in Hospitality Administration', duration: '6 months', defaultTotalFee: 45000, defaultInstallmentCount: 4, status: 'ACTIVE', createdAt: '2026-08-01'),
    CourseModel(courseId: 'HRCA-6M', courseName: 'Hospitality & Retail Culinary Arts (6 Months)', duration: '6 months', defaultTotalFee: 50000, defaultInstallmentCount: 4, status: 'ACTIVE', createdAt: '2026-08-01'),
    CourseModel(courseId: 'BCA-1Y', courseName: 'Bachelor in Computer Applications', duration: '1 year', defaultTotalFee: 75000, defaultInstallmentCount: 4, status: 'ACTIVE', createdAt: '2026-08-01'),
    CourseModel(courseId: 'HRCA-1Y', courseName: 'Hospitality & Retail Culinary Arts (1 Year)', duration: '1 year', defaultTotalFee: 90000, defaultInstallmentCount: 4, status: 'ACTIVE', createdAt: '2026-08-01'),
  ];

  void _showAddCourseDialog() {
    final idCtrl = TextEditingController();
    final nameCtrl = TextEditingController();
    final durationCtrl = TextEditingController(text: '6 months');
    final feeCtrl = TextEditingController(text: '50000');
    final instCtrl = TextEditingController(text: '4');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Course to Course Master'),
        content: SizedBox(
          width: 420,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: idCtrl, decoration: const InputDecoration(labelText: 'Course ID *', hintText: 'BBA-3Y')),
              const SizedBox(height: 12),
              TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Course Full Name *')),
              const SizedBox(height: 12),
              TextField(controller: durationCtrl, decoration: const InputDecoration(labelText: 'Duration *', hintText: '6 months / 1 year')),
              const SizedBox(height: 12),
              TextField(controller: feeCtrl, decoration: const InputDecoration(labelText: 'Default Fee Amount (₹) *')),
              const SizedBox(height: 12),
              TextField(controller: instCtrl, decoration: const InputDecoration(labelText: 'Default Installments Count *')),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (idCtrl.text.isEmpty || nameCtrl.text.isEmpty) return;
              setState(() {
                _courses.add(CourseModel(
                  courseId: idCtrl.text.trim(),
                  courseName: nameCtrl.text.trim(),
                  duration: durationCtrl.text.trim(),
                  defaultTotalFee: double.tryParse(feeCtrl.text) ?? 50000,
                  defaultInstallmentCount: int.tryParse(instCtrl.text) ?? 4,
                  status: 'ACTIVE',
                  createdAt: DateTime.now().toIso8601String(),
                ));
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Course added to Master'), backgroundColor: AppColors.success));
            },
            child: const Text('Save Course'),
          ),
        ],
      ),
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
                  Text('Admin Course Master Configuration', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  Text('Configure academy courses, durations, default fee amounts, and installment rules.', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                ],
              ),
              ElevatedButton.icon(
                onPressed: _showAddCourseDialog,
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Add Course'),
              ),
            ],
          ),
          const SizedBox(height: 20),

          Expanded(
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: DataTable(
                  columns: const [
                    DataColumn(label: Text('Course ID', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('Course Name', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('Duration', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('Default Fee', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('Installments', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('Status', style: TextStyle(fontWeight: FontWeight.bold))),
                  ],
                  rows: _courses.map((c) => DataRow(cells: [
                    DataCell(Text(c.courseId, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary))),
                    DataCell(Text(c.courseName, style: const TextStyle(fontWeight: FontWeight.bold))),
                    DataCell(Text(c.duration)),
                    DataCell(Text(CurrencyFormatter.format(c.defaultTotalFee), style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.success))),
                    DataCell(Text('${c.defaultInstallmentCount} Installments')),
                    DataCell(Text(c.status, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.success))),
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
