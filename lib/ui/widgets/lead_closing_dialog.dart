import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/currency_formatter.dart';
import '../../data/models/lead_model.dart';
import '../../providers/fee_provider.dart';
import '../../providers/batch_provider.dart';
import '../../providers/lead_provider.dart';

class LeadClosingDialog extends StatefulWidget {
  final LeadModel lead;

  const LeadClosingDialog({super.key, required this.lead});

  @override
  State<LeadClosingDialog> createState() => _LeadClosingDialogState();
}

class _LeadClosingDialogState extends State<LeadClosingDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameCtrl;
  late TextEditingController _phoneCtrl;
  late TextEditingController _emailCtrl;
  late TextEditingController _cityCtrl;
  late TextEditingController _totalFeeCtrl;
  late TextEditingController _paidFeeCtrl;
  late TextEditingController _refNoCtrl;
  late TextEditingController _firstDueDateCtrl;

  String _selectedCourse = 'BCA-1Y';
  String _selectedBatch = 'Batch 2026-A';
  String _selectedPaymentMode = 'GPay';
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.lead.name);
    _phoneCtrl = TextEditingController(text: widget.lead.phone);
    _emailCtrl = TextEditingController(text: widget.lead.email);
    _cityCtrl = TextEditingController(text: widget.lead.city);
    _totalFeeCtrl = TextEditingController(text: '75000');
    _paidFeeCtrl = TextEditingController(text: '25000');
    _refNoCtrl = TextEditingController(text: 'TXN-${Math.floor(100000 + Math.random() * 900000)}');
    _firstDueDateCtrl = TextEditingController(text: DateTime.now().add(const Duration(days: 30)).toIso8601String().substring(0, 10));
    _selectedCourse = widget.lead.courseInterested.isNotEmpty ? widget.lead.courseInterested : 'BCA-1Y';
  }

  @override
  Widget build(BuildContext context) {
    final batchProvider = Provider.of<BatchProvider>(context);

    return AlertDialog(
      title: Row(
        children: [
          const Icon(Icons.school, color: AppColors.primary),
          const SizedBox(width: 10),
          Expanded(child: Text('Atomic Lead Closing & Student Admission (${widget.lead.leadId})', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold))),
        ],
      ),
      content: SizedBox(
        width: 540,
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              cross: CrossAxisAlignment.start,
              children: [
                const Text('Student Basic Profile', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.primary)),
                const SizedBox(height: 8),
                TextFormField(controller: _nameCtrl, decoration: const InputDecoration(labelText: 'Student Full Name *')),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(child: TextFormField(controller: _phoneCtrl, decoration: const InputDecoration(labelText: 'Phone Number *'))),
                    const SizedBox(width: 10),
                    Expanded(child: TextFormField(controller: _emailCtrl, decoration: const InputDecoration(labelText: 'Email Address'))),
                  ],
                ),
                const SizedBox(height: 16),

                const Text('Course & Compatible Batch Selection', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.primary)),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: _selectedCourse,
                  decoration: const InputDecoration(labelText: 'Enrolled Course *'),
                  items: ['BHA-6M', 'HRCA-6M', 'BCA-1Y', 'HRCA-1Y'].map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                  onChanged: (v) => setState(() => _selectedCourse = v!),
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  value: _selectedBatch,
                  decoration: const InputDecoration(labelText: 'Compatible Active Batch *'),
                  items: batchProvider.batches.map((b) => DropdownMenuItem(value: b.batchName, child: Text('${b.batchName} (${b.timeSlot})'))).toList(),
                  onChanged: (v) => setState(() => _selectedBatch = v!),
                ),
                const SizedBox(height: 16),

                const Text('Fee Agreement & Initial Payment', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.primary)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(child: TextFormField(controller: _totalFeeCtrl, decoration: const InputDecoration(labelText: 'Total Fee Agreed (₹) *'))),
                    const SizedBox(width: 10),
                    Expanded(child: TextFormField(controller: _paidFeeCtrl, decoration: const InputDecoration(labelText: 'Initial Paid Amount (₹) *'))),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _selectedPaymentMode,
                        decoration: const InputDecoration(labelText: 'Payment Mode *'),
                        items: ['GPay', 'Cash', 'UPI', 'Bank Transfer', 'Card'].map((m) => DropdownMenuItem(value: m, child: Text(m))).toList(),
                        onChanged: (v) => setState(() => _selectedPaymentMode = v!),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(child: TextFormField(controller: _refNoCtrl, decoration: const InputDecoration(labelText: 'Transaction Ref No *'))),
                  ],
                ),
                const SizedBox(height: 10),
                TextFormField(controller: _firstDueDateCtrl, decoration: const InputDecoration(labelText: 'First Installment Due Date (YYYY-MM-DD) *')),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        ElevatedButton.icon(
          onPressed: _isSubmitting ? null : _submitAtomicClosing,
          icon: _isSubmitting ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Icon(Icons.check_circle),
          label: Text(_isSubmitting ? 'Processing Admission...' : 'Confirm Atomic Closing'),
        ),
      ],
    );
  }

  void _submitAtomicClosing() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSubmitting = true);

    final feeProvider = Provider.of<FeeProvider>(context, listen: false);
    final leadProvider = Provider.of<LeadProvider>(context, listen: false);

    final success = await feeProvider.closeLeadToStudent(
      leadId: widget.lead.leadId,
      name: _nameCtrl.text.trim(),
      phone: _phoneCtrl.text.trim(),
      email: _emailCtrl.text.trim(),
      city: _cityCtrl.text.trim(),
      course: _selectedCourse,
      batchName: _selectedBatch,
      totalFee: double.tryParse(_totalFeeCtrl.text) ?? 75000,
      paidFee: double.tryParse(_paidFeeCtrl.text) ?? 25000,
      paymentMode: _selectedPaymentMode,
      referenceNo: _refNoCtrl.text.trim(),
      firstDueDate: _firstDueDateCtrl.text.trim(),
    );

    if (mounted) {
      setState(() => _isSubmitting = false);
      if (success) {
        await leadProvider.fetchLeads();
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Lead Closed & Student Admission created atomically!'), backgroundColor: AppColors.success),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to close lead. Check server connection.'), backgroundColor: AppColors.danger),
        );
      }
    }
  }
}

class Math {
  static double random() => DateTime.now().millisecondsSinceEpoch % 1000 / 1000;
  static int floor(double d) => d.floor();
}
