import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/currency_formatter.dart';
import '../../core/utils/date_formatter.dart';
import '../../data/models/payment_model.dart';
import '../../data/models/student_model.dart';
import '../../data/services/pdf_receipt_service.dart';
import '../../providers/auth_provider.dart';
import '../../providers/fee_provider.dart';
import '../widgets/summary_card.dart';

class FeeCollectionView extends StatefulWidget {
  const FeeCollectionView({super.key});

  @override
  State<FeeCollectionView> createState() => _FeeCollectionViewState();
}

class _FeeCollectionViewState extends State<FeeCollectionView> {
  StudentModel? _selectedStudent;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<FeeProvider>(context, listen: false).fetchStudentsAndPayments();
    });
  }

  void _showCollectPaymentDialog(StudentModel student) {
    final amountCtrl = TextEditingController(text: student.balanceFee > 0 ? student.balanceFee.toStringAsFixed(0) : '5000');
    final remarksCtrl = TextEditingController(text: 'Installment Fee Payment');
    String selectedMode = 'UPI';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Collect Fee (${student.name})'),
        content: SizedBox(
          width: 440,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            cross: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      cross: CrossAxisAlignment.start,
                      children: [
                        Text('Course: ${student.course}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                        Text('Admission: ${student.admissionNo}', style: const TextStyle(fontSize: 10, color: AppColors.textMuted)),
                      ],
                    ),
                    Column(
                      cross: CrossAxisAlignment.end,
                      children: [
                        const Text('Balance Due:', style: TextStyle(fontSize: 10, color: AppColors.textMuted)),
                        Text(CurrencyFormatter.format(student.balanceFee), style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.danger)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: amountCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Payment Amount (₹) *'),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: selectedMode,
                decoration: const InputDecoration(labelText: 'Payment Mode *'),
                items: AppConstants.paymentModes.map((m) => DropdownMenuItem(value: m, child: Text(m))).toList(),
                onChanged: (v) => selectedMode = v ?? selectedMode,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: remarksCtrl,
                decoration: const InputDecoration(labelText: 'Remarks / Receipt Description'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.success),
            onPressed: () async {
              final amount = double.tryParse(amountCtrl.text) ?? 0;
              if (amount <= 0) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Enter a valid amount')));
                return;
              }

              final currentUser = Provider.of<AuthProvider>(context, listen: false).currentUser!;
              final feeProvider = Provider.of<FeeProvider>(context, listen: false);

              final payment = await feeProvider.collectFee(
                student: student,
                amount: amount,
                paymentMode: selectedMode,
                remarks: remarksCtrl.text,
                currentUser: currentUser,
              );

              if (mounted) {
                Navigator.pop(context);
                if (payment != null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Payment recorded! Receipt No: ${payment.receiptNo}'), backgroundColor: AppColors.success),
                  );
                  // Prompt to print or download PDF receipt
                  _showPrintReceiptPrompt(payment, student);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(feeProvider.errorMessage ?? 'Payment collection failed'), backgroundColor: AppColors.danger),
                  );
                }
              }
            },
            child: const Text('Confirm Payment & Generate Receipt'),
          ),
        ],
      ),
    );
  }

  void _showPrintReceiptPrompt(PaymentModel payment, StudentModel student) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Receipt Generated Successfully!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle_outline, size: 60, color: AppColors.success),
            const SizedBox(height: 12),
            Text('Receipt Number: ${payment.receiptNo}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            Text('Amount Paid: ${CurrencyFormatter.format(payment.amount)} (${payment.paymentMode})', style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
            const SizedBox(height: 16),
            const Text('Would you like to print or download the PDF receipt right now?', style: TextStyle(fontSize: 12), textAlign: TextAlign.center),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Later')),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              PdfReceiptService.printOrDownloadReceipt(payment: payment, student: student);
            },
            icon: const Icon(Icons.print, size: 18),
            label: const Text('Print / Download Receipt PDF'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final feeProvider = Provider.of<FeeProvider>(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        cross: CrossAxisAlignment.start,
        children: [
          // KPI Metric Row
          Row(
            children: [
              Expanded(child: SummaryCard(title: "Today's Collection", value: CurrencyFormatter.format(feeProvider.todayCollection), icon: Icons.payments, iconColor: AppColors.success)),
              const SizedBox(width: 12),
              Expanded(child: SummaryCard(title: 'Monthly Collection', value: CurrencyFormatter.format(feeProvider.monthlyCollection), icon: Icons.account_balance, iconColor: AppColors.info)),
              const SizedBox(width: 12),
              Expanded(child: SummaryCard(title: 'Total Pending Fees', value: CurrencyFormatter.format(feeProvider.totalPendingFees), icon: Icons.pending_actions, iconColor: AppColors.warning)),
            ],
          ),
          const SizedBox(height: 24),

          // Fast Student Lookup & Collect Fee Section
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                cross: CrossAxisAlignment.start,
                children: [
                  const Text('Fast Student Fee Lookup', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  Autocomplete<StudentModel>(
                    displayStringForOption: (s) => '${s.name} (${s.admissionNo}) - Balance: ${CurrencyFormatter.format(s.balanceFee)}',
                    optionsBuilder: (textEditingValue) {
                      if (textEditingValue.text.isEmpty) return const Iterable<StudentModel>.empty();
                      final q = textEditingValue.text.toLowerCase();
                      return feeProvider.students.where((s) {
                        return s.name.toLowerCase().contains(q) || s.phone.contains(q) || s.admissionNo.toLowerCase().contains(q);
                      });
                    },
                    onSelected: (s) => setState(() => _selectedStudent = s),
                    fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
                      return TextField(
                        controller: controller,
                        focusNode: focusNode,
                        decoration: const InputDecoration(
                          hintText: 'Type Name, Phone, or Admission Number...',
                          prefixIcon: Icon(Icons.search, size: 20),
                        ),
                      );
                    },
                  ),
                  if (_selectedStudent != null) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            cross: CrossAxisAlignment.start,
                            children: [
                              Text(_selectedStudent!.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                              Text('${_selectedStudent!.admissionNo} • ${_selectedStudent!.course}', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                              const SizedBox(height: 4),
                              Text('Total: ${CurrencyFormatter.format(_selectedStudent!.totalFee)} | Paid: ${CurrencyFormatter.format(_selectedStudent!.paidFee)}', style: const TextStyle(fontSize: 11)),
                            ],
                          ),
                          Column(
                            cross: CrossAxisAlignment.end,
                            children: [
                              Text('Balance Due: ${CurrencyFormatter.format(_selectedStudent!.balanceFee)}', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.danger, fontSize: 14)),
                              const SizedBox(height: 8),
                              ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(backgroundColor: AppColors.success),
                                onPressed: () => _showCollectPaymentDialog(_selectedStudent!),
                                icon: const Icon(Icons.add_card, size: 16),
                                label: const Text('Collect Payment'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Payment History Table
          const Text('Payment History & Receipts Ledger', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          feeProvider.isLoading
              ? const Center(child: CircularProgressIndicator())
              : Card(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      headingRowHeight: 44,
                      dataRowHeight: 56,
                      columns: const [
                        DataColumn(label: Text('Receipt No', style: TextStyle(fontWeight: FontWeight.bold))),
                        DataColumn(label: Text('Date', style: TextStyle(fontWeight: FontWeight.bold))),
                        DataColumn(label: Text('Student Name', style: TextStyle(fontWeight: FontWeight.bold))),
                        DataColumn(label: Text('Amount', style: TextStyle(fontWeight: FontWeight.bold))),
                        DataColumn(label: Text('Payment Mode', style: TextStyle(fontWeight: FontWeight.bold))),
                        DataColumn(label: Text('Remarks', style: TextStyle(fontWeight: FontWeight.bold))),
                        DataColumn(label: Text('Receipt PDF', style: TextStyle(fontWeight: FontWeight.bold))),
                      ],
                      rows: feeProvider.payments.map((p) {
                        return DataRow(
                          cells: [
                            DataCell(Text(p.receiptNo, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary))),
                            DataCell(Text(DateFormatter.formatDisplay(p.date), style: const TextStyle(fontSize: 12))),
                            DataCell(Text(p.studentName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
                            DataCell(Text(CurrencyFormatter.format(p.amount), style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.success, fontSize: 13))),
                            DataCell(Text(p.paymentMode, style: const TextStyle(fontSize: 12))),
                            DataCell(Text(p.remarks, style: const TextStyle(fontSize: 12))),
                            DataCell(
                              IconButton(
                                icon: const Icon(Icons.picture_as_pdf, size: 20, color: AppColors.danger),
                                onPressed: () {
                                  final student = feeProvider.students.firstWhere(
                                    (s) => s.studentId == p.studentId || s.name == p.studentName,
                                    orElse: () => StudentModel(
                                      studentId: p.studentId,
                                      admissionNo: 'ADM-2026-REG',
                                      admissionDate: p.date,
                                      name: p.studentName,
                                      phone: '-',
                                      email: '',
                                      course: 'Academy Course',
                                      totalFee: p.amount,
                                      paidFee: p.amount,
                                      balanceFee: 0,
                                      status: 'ACTIVE',
                                      driveFolderId: '',
                                      leadId: '',
                                      createdAt: p.createdAt,
                                    ),
                                  );
                                  PdfReceiptService.printOrDownloadReceipt(payment: p, student: student);
                                },
                                tooltip: 'Print / Download PDF Receipt',
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                ),
        ],
      ),
    );
  }
}
