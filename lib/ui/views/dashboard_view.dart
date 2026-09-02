import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/currency_formatter.dart';
import '../../providers/auth_provider.dart';
import '../../providers/lead_provider.dart';
import '../../providers/fee_provider.dart';
import '../../providers/accounting_provider.dart';
import '../widgets/summary_card.dart';
import 'daily_followups_view.dart';
import 'fee_due_reminders_view.dart';

class DashboardView extends StatefulWidget {
  const DashboardView({super.key});

  @override
  State<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<LeadProvider>(context, listen: false).fetchLeads();
      Provider.of<FeeProvider>(context, listen: false).fetchStudentsAndPayments();
      Provider.of<AccountingProvider>(context, listen: false).fetchExpenses();
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.currentUser;
    final role = user?.role ?? AppConstants.roleSalesExecutive;

    final leadProvider = Provider.of<LeadProvider>(context);
    final feeProvider = Provider.of<FeeProvider>(context);
    final accountingProvider = Provider.of<AccountingProvider>(context);

    if (role == AppConstants.roleSalesExecutive) {
      return _buildSalesExecutiveDashboard(context, user?.name ?? 'Executive', leadProvider);
    } else if (role == AppConstants.roleCeo) {
      return _buildCeoDashboard(context, feeProvider, accountingProvider);
    } else if (role == AppConstants.roleSalesHead) {
      return _buildSalesHeadDashboard(context, leadProvider);
    } else if (role == AppConstants.roleOperations) {
      return _buildOperationsDashboard(context, feeProvider);
    } else {
      return _buildAdminDashboard(context, leadProvider, feeProvider, accountingProvider);
    }
  }

  // 1. Admin Full System Overview Dashboard
  Widget _buildAdminDashboard(
    BuildContext context,
    LeadProvider leadProvider,
    FeeProvider feeProvider,
    AccountingProvider accountingProvider,
  ) {
    final activeStudents = feeProvider.students.length;
    final totalCollections = feeProvider.students.fold(0.0, (sum, s) => sum + s.paidFee);
    final pendingBalances = feeProvider.students.fold(0.0, (sum, s) => sum + s.balanceFee);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        cross: CrossAxisAlignment.start,
        children: [
          const Text('System Administrator Master Dashboard', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          const Text('Complete academy operational metrics, financial summary, and active lead pipeline.', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
          const SizedBox(height: 20),

          GridView.count(
            crossAxisCount: MediaQuery.of(context).size.width > 900 ? 4 : 2,
            crossAxisSpacing: 14,
            mainAxisSpacing: 14,
            childAspectRatio: 2.2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              SummaryCard(title: 'Active Enrolled Students', value: '$activeStudents Students', icon: Icons.school, iconColor: AppColors.success),
              SummaryCard(title: 'Realized Collections', value: CurrencyFormatter.format(totalCollections), icon: Icons.account_balance_wallet, iconColor: AppColors.primary),
              SummaryCard(title: 'Pending Balances', value: CurrencyFormatter.format(pendingBalances), icon: Icons.warning_amber, iconColor: AppColors.warning),
              SummaryCard(title: 'Total Active CRM Leads', value: '${leadProvider.rawLeads.length} Leads', icon: Icons.leaderboard, iconColor: AppColors.info),
            ],
          ),
          const SizedBox(height: 24),

          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                cross: CrossAxisAlignment.start,
                children: [
                  const Text('Master Administrative System Controls', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 14),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      ElevatedButton.icon(onPressed: () {}, icon: const Icon(Icons.menu_book, size: 16), label: const Text('Course Master')),
                      ElevatedButton.icon(onPressed: () {}, icon: const Icon(Icons.people, size: 16), label: const Text('User Management')),
                      ElevatedButton.icon(onPressed: () {}, icon: const Icon(Icons.security, size: 16), label: const Text('Audit Security Logs')),
                      ElevatedButton.icon(onPressed: () {}, icon: const Icon(Icons.auto_awesome, size: 16), label: const Text('AI Analysis Summarizer')),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 2. CEO Rasheed Financial Control Dashboard
  Widget _buildCeoDashboard(BuildContext context, FeeProvider feeProvider, AccountingProvider accountingProvider) {
    final realizedCollections = feeProvider.students.fold(0.0, (sum, s) => sum + s.paidFee);
    final totalExpenses = accountingProvider.expenses.fold(0.0, (sum, e) => sum + e.amount);
    final netSurplus = realizedCollections - totalExpenses;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        cross: CrossAxisAlignment.start,
        children: [
          const Text('Executive Financial Control Dashboard (Rasheed)', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          const Text('Real-time gross collections, course ledgers, net operating surplus, and expense entry.', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
          const SizedBox(height: 20),

          GridView.count(
            crossAxisCount: MediaQuery.of(context).size.width > 900 ? 3 : 1,
            crossAxisSpacing: 14,
            mainAxisSpacing: 14,
            childAspectRatio: 2.2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              SummaryCard(title: 'Realized Collections', value: CurrencyFormatter.format(realizedCollections), icon: Icons.account_balance_wallet, iconColor: AppColors.success),
              SummaryCard(title: 'Recorded Expenses', value: CurrencyFormatter.format(totalExpenses), icon: Icons.shopping_bag_outlined, iconColor: AppColors.danger),
              SummaryCard(title: 'Net Operating Surplus', value: CurrencyFormatter.format(netSurplus), icon: Icons.savings_outlined, iconColor: AppColors.primary),
            ],
          ),
        ],
      ),
    );
  }

  // 3. Sales Head Ashif Dashboard
  Widget _buildSalesHeadDashboard(BuildContext context, LeadProvider leadProvider) {
    final activeLeads = leadProvider.rawLeads.where((l) => l.status != 'Closed').length;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        cross: CrossAxisAlignment.start,
        children: [
          const Text('Sales Team & Performance Dashboard (Ashif)', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          const Text('Team lead pipeline, 25% monthly target progress, and executive lead reassignments.', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
          const SizedBox(height: 20),

          GridView.count(
            crossAxisCount: MediaQuery.of(context).size.width > 900 ? 3 : 1,
            crossAxisSpacing: 14,
            mainAxisSpacing: 14,
            childAspectRatio: 2.2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              SummaryCard(title: 'Active Pipeline', value: '$activeLeads Active Leads', icon: Icons.leaderboard, iconColor: AppColors.primary),
              SummaryCard(title: 'Monthly Team Conversions', value: '1 Conversion', icon: Icons.emoji_events, iconColor: AppColors.success),
              SummaryCard(title: 'Monthly Target Progress', value: '33.3% (Target: 25%)', icon: Icons.pie_chart_outline, iconColor: AppColors.warning),
            ],
          ),
        ],
      ),
    );
  }

  // 4. Sales Executive Personal Workspace Dashboard
  Widget _buildSalesExecutiveDashboard(BuildContext context, String execName, LeadProvider leadProvider) {
    final myLeads = leadProvider.rawLeads.where((l) => l.assignedTo == execName).toList();
    final activeFollowups = myLeads.where((l) => l.status != 'Not Interested' && l.status != 'Unqualified' && l.status != 'Closed').length;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        cross: CrossAxisAlignment.start,
        children: [
          Card(
            color: AppColors.secondary,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                cross: CrossAxisAlignment.start,
                children: [
                  const Text('DAILY FOLLOW-UP TARGET: 10 / WORKING DAY', style: TextStyle(color: AppColors.primaryLight, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1)),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Column(
                        cross: CrossAxisAlignment.start,
                        children: [
                          Text('25% Monthly Conversion Target', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                          SizedBox(height: 4),
                          Text('1 Closed Student Admission (Status: On Track)', style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
                        ],
                      ),
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(context, MaterialPageRoute(builder: (_) => const DailyFollowupsView()));
                        },
                        icon: const Icon(Icons.phone_in_talk, size: 18),
                        label: const Text('Open Daily Follow-ups Workspace'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          GridView.count(
            crossAxisCount: MediaQuery.of(context).size.width > 900 ? 2 : 1,
            crossAxisSpacing: 14,
            mainAxisSpacing: 14,
            childAspectRatio: 2.2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              SummaryCard(title: 'My Assigned Leads Queue', value: '${myLeads.length} Leads', icon: Icons.person_search, iconColor: AppColors.info),
              SummaryCard(title: 'Active Scheduled Follow-ups', value: '$activeFollowups Pending', icon: Icons.phone_callback, iconColor: AppColors.success),
            ],
          ),
        ],
      ),
    );
  }

  // 5. Operations Dashboard
  Widget _buildOperationsDashboard(BuildContext context, FeeProvider feeProvider) {
    final pendingStudents = feeProvider.students.where((s) => s.balanceFee > 0).length;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        cross: CrossAxisAlignment.start,
        children: [
          const Text('Operations Workspace Dashboard (Operations)', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          const Text('Fee installment reminders, batch transfers, and receipt collections.', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
          const SizedBox(height: 20),

          GridView.count(
            crossAxisCount: MediaQuery.of(context).size.width > 900 ? 3 : 1,
            crossAxisSpacing: 14,
            mainAxisSpacing: 14,
            childAspectRatio: 2.2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              SummaryCard(title: '3-Day Fee Reminders Due', value: '$pendingStudents Pending', icon: Icons.alarm_on, iconColor: AppColors.warning),
              SummaryCard(title: "Today's Collections", value: '₹30,000', icon: Icons.receipt_long, iconColor: AppColors.success),
              SummaryCard(title: 'Active Batches Managed', value: '2 Batches', icon: Icons.class_outlined, iconColor: AppColors.primary),
            ],
          ),
          const SizedBox(height: 20),

          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Operations Quick Reminders Portal', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const FeeDueRemindersView()));
                    },
                    icon: const Icon(Icons.alarm_warning, size: 16),
                    label: const Text('Open 3-Day Fee Reminders Portal'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
