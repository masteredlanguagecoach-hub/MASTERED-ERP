import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/currency_formatter.dart';
import '../../core/utils/date_formatter.dart';
import '../../providers/auth_provider.dart';
import '../../providers/accounting_provider.dart';
import '../widgets/summary_card.dart';
import '../widgets/charts/expense_chart.dart';

class AccountingView extends StatefulWidget {
  const AccountingView({super.key});

  @override
  State<AccountingView> createState() => _AccountingViewState();
}

class _AccountingViewState extends State<AccountingView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AccountingProvider>(context, listen: false).fetchAccountingData();
    });
  }

  void _showAddExpenseDialog() {
    final amountCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    String selectedCategory = AppConstants.expenseCategories.first;
    String selectedMode = 'Bank Transfer';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Record Academy Expense'),
        content: SizedBox(
          width: 440,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                value: selectedCategory,
                decoration: const InputDecoration(labelText: 'Expense Category *'),
                items: AppConstants.expenseCategories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                onChanged: (v) => selectedCategory = v ?? selectedCategory,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: amountCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Amount (₹) *'),
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
                controller: descCtrl,
                maxLines: 2,
                decoration: const InputDecoration(labelText: 'Description / Purpose *'),
              ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Bill uploaded to MASTERED/Expenses/ Google Drive folder')),
                  );
                },
                icon: const Icon(Icons.cloud_upload_outlined, size: 18),
                label: const Text('Upload Bill / Invoice (Google Drive)'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger),
            onPressed: () async {
              final amount = double.tryParse(amountCtrl.text) ?? 0;
              if (amount <= 0 || descCtrl.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter valid amount and description')));
                return;
              }

              final currentUser = Provider.of<AuthProvider>(context, listen: false).currentUser!;
              final accProvider = Provider.of<AccountingProvider>(context, listen: false);

              final success = await accProvider.addExpense(
                category: selectedCategory,
                description: descCtrl.text,
                amount: amount,
                paymentMode: selectedMode,
                currentUser: currentUser,
              );

              if (mounted) {
                if (success) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Expense recorded successfully'), backgroundColor: AppColors.success),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(accProvider.errorMessage ?? 'Failed to record expense'), backgroundColor: AppColors.danger),
                  );
                }
              }
            },
            child: const Text('Save Expense'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final accProvider = Provider.of<AccountingProvider>(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        cross: CrossAxisAlignment.start,
        children: [
          // Profit & Loss Overview Row
          Row(
            children: [
              Expanded(child: SummaryCard(title: 'Monthly Income', value: CurrencyFormatter.format(accProvider.monthlyIncome), icon: Icons.trending_up, iconColor: AppColors.success)),
              const SizedBox(width: 12),
              Expanded(child: SummaryCard(title: 'Monthly Expenses', value: CurrencyFormatter.format(accProvider.monthlyExpense), icon: Icons.trending_down, iconColor: AppColors.danger)),
              const SizedBox(width: 12),
              Expanded(child: SummaryCard(title: 'Net Collection Profit', value: CurrencyFormatter.format(accProvider.netProfit), icon: Icons.account_balance_wallet, iconColor: accProvider.netProfit >= 0 ? AppColors.success : AppColors.danger)),
            ],
          ),
          const SizedBox(height: 24),

          // Action & Breakdown Section
          Row(
            cross: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 2,
                child: Column(
                  cross: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Expense Ledger', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger),
                          onPressed: _showAddExpenseDialog,
                          icon: const Icon(Icons.add, size: 18),
                          label: const Text('Record Expense'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    accProvider.isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : Card(
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: DataTable(
                                headingRowHeight: 44,
                                dataRowHeight: 56,
                                columns: const [
                                  DataColumn(label: Text('Expense ID', style: TextStyle(fontWeight: FontWeight.bold))),
                                  DataColumn(label: Text('Date', style: TextStyle(fontWeight: FontWeight.bold))),
                                  DataColumn(label: Text('Category', style: TextStyle(fontWeight: FontWeight.bold))),
                                  DataColumn(label: Text('Description', style: TextStyle(fontWeight: FontWeight.bold))),
                                  DataColumn(label: Text('Amount', style: TextStyle(fontWeight: FontWeight.bold))),
                                  DataColumn(label: Text('Mode', style: TextStyle(fontWeight: FontWeight.bold))),
                                ],
                                rows: accProvider.expenses.map((e) {
                                  return DataRow(
                                    cells: [
                                      DataCell(Text(e.expenseId, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.danger))),
                                      DataCell(Text(DateFormatter.formatDisplay(e.date), style: const TextStyle(fontSize: 12))),
                                      DataCell(Text(e.category, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
                                      DataCell(Text(e.description, style: const TextStyle(fontSize: 12))),
                                      DataCell(Text(CurrencyFormatter.format(e.amount), style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.danger, fontSize: 13))),
                                      DataCell(Text(e.paymentMode, style: const TextStyle(fontSize: 12))),
                                    ],
                                  );
                                }).toList(),
                              ),
                            ),
                          ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              const Expanded(
                flex: 1,
                child: Card(
                  child: Padding(
                    padding: EdgeInsets.all(18),
                    child: Column(
                      cross: CrossAxisAlignment.start,
                      children: [
                        Text('Expense Category Breakdown', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                        SizedBox(height: 16),
                        ExpenseChart(),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
