import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/permissions/role_permissions.dart';
import '../../core/utils/currency_formatter.dart';
import '../../core/utils/date_formatter.dart';
import '../../providers/auth_provider.dart';
import '../../providers/lead_provider.dart';
import '../../providers/fee_provider.dart';
import '../../providers/accounting_provider.dart';
import '../widgets/summary_card.dart';
import '../widgets/responsive_builder.dart';
import '../widgets/charts/collection_chart.dart';
import '../widgets/charts/lead_trend_chart.dart';

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
      _loadData();
    });
  }

  void _loadData() {
    final authUser = Provider.of<AuthProvider>(context, listen: false).currentUser;
    if (authUser != null) {
      Provider.of<LeadProvider>(context, listen: false).fetchLeads(authUser);
      Provider.of<FeeProvider>(context, listen: false).fetchStudentsAndPayments();
      Provider.of<AccountingProvider>(context, listen: false).fetchAccountingData();
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthProvider>(context).currentUser;
    final role = user?.role ?? AppConstants.roleSalesExecutive;

    final leadProvider = Provider.of<LeadProvider>(context);
    final feeProvider = Provider.of<FeeProvider>(context);
    final accProvider = Provider.of<AccountingProvider>(context);

    return RefreshIndicator(
      onRefresh: () async => _loadData(),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          cross: CrossAxisAlignment.start,
          children: [
            // Welcome Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  cross: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome back, ${user?.name ?? 'User'}!',
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Role Dashboard: ${RolePermissions.getRoleLabel(role)}',
                      style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                    ),
                  ],
                ),
                ElevatedButton.icon(
                  onPressed: _loadData,
                  icon: const Icon(Icons.refresh, size: 16),
                  label: const Text('Refresh Data', style: TextStyle(fontSize: 12)),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Strictly Role-Tailored KPI Cards Grid
            _buildMetricsGrid(role, leadProvider, feeProvider, accProvider),
            const SizedBox(height: 24),

            // Strictly Role-Tailored Quick Actions Bar
            _buildQuickActionsBar(role),
            const SizedBox(height: 24),

            // Analytics & Performance Charts (Tailored per role)
            if (role != AppConstants.roleSalesExecutive && role != AppConstants.roleOperations) ...[
              const Text('Analytics & Performance Trends', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              LayoutBuilder(
                builder: (context, constraints) {
                  final isWide = constraints.maxWidth >= 900;
                  return isWide
                      ? const Row(
                          cross: CrossAxisAlignment.start,
                          children: [
                            Expanded(child: ChartCard(title: 'Revenue Collection Trend', child: CollectionChart())),
                            SizedBox(width: 16),
                            Expanded(child: ChartCard(title: 'Lead Conversion Pipeline', child: LeadTrendChart())),
                          ],
                        )
                      : const Column(
                          children: [
                            ChartCard(title: 'Revenue Collection Trend', child: CollectionChart()),
                            SizedBox(height: 16),
                            ChartCard(title: 'Lead Conversion Pipeline', child: LeadTrendChart()),
                          ],
                        );
                },
              ),
              const SizedBox(height: 24),
            ],

            // Role-Tailored Recent Activity Feed
            Row(
              cross: CrossAxisAlignment.start,
              children: [
                if (role == AppConstants.roleAdmin || role == AppConstants.roleCeo || role == AppConstants.roleOperations)
                  Expanded(
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(18),
                        child: Column(
                          cross: CrossAxisAlignment.start,
                          children: [
                            const Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Recent Collections & Payments', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                Icon(Icons.history, size: 18, color: AppColors.textMuted),
                              ],
                            ),
                            const Divider(height: 24),
                            if (feeProvider.payments.isEmpty)
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 20),
                                child: Center(child: Text('No payment activity recorded yet', style: TextStyle(color: AppColors.textMuted, fontSize: 12))),
                              )
                            else
                              ListView.separated(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: feeProvider.payments.take(5).length,
                                separatorBuilder: (_, __) => const Divider(),
                                itemBuilder: (context, idx) {
                                  final p = feeProvider.payments[idx];
                                  return ListTile(
                                    dense: true,
                                    contentPadding: EdgeInsets.zero,
                                    leading: const CircleAvatar(
                                      radius: 16,
                                      backgroundColor: Color(0xFFDCFCE7),
                                      child: Icon(Icons.arrow_downward, color: AppColors.success, size: 16),
                                    ),
                                    title: Text(p.studentName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                    subtitle: Text('${p.receiptNo} • ${p.paymentMode}', style: const TextStyle(fontSize: 11)),
                                    trailing: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      cross: CrossAxisAlignment.end,
                                      children: [
                                        Text(CurrencyFormatter.format(p.amount), style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.success, fontSize: 13)),
                                        Text(DateFormatter.formatDisplay(p.date), style: const TextStyle(fontSize: 10, color: AppColors.textMuted)),
                                      ],
                                    ),
                                  );
                                },
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                if (role != AppConstants.roleOperations && !ResponsiveBuilder.isMobile(context)) ...[
                  const SizedBox(width: 16),
                  Expanded(
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(18),
                        child: Column(
                          cross: CrossAxisAlignment.start,
                          children: [
                            const Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Recent Leads & Inquiries', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                Icon(Icons.person_search, size: 18, color: AppColors.textMuted),
                              ],
                            ),
                            const Divider(height: 24),
                            if (leadProvider.leads.isEmpty)
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 20),
                                child: Center(child: Text('No leads recorded yet', style: TextStyle(color: AppColors.textMuted, fontSize: 12))),
                              )
                            else
                              ListView.separated(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: leadProvider.leads.take(5).length,
                                separatorBuilder: (_, __) => const Divider(),
                                itemBuilder: (context, idx) {
                                  final l = leadProvider.leads[idx];
                                  return ListTile(
                                    dense: true,
                                    contentPadding: EdgeInsets.zero,
                                    leading: CircleAvatar(
                                      radius: 16,
                                      backgroundColor: AppColors.primary.withOpacity(0.1),
                                      child: Text(l.name.isNotEmpty ? l.name[0].toUpperCase() : 'L', style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 12)),
                                    ),
                                    title: Text(l.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                    subtitle: Text('${l.courseInterested} • ${l.status}', style: const TextStyle(fontSize: 11)),
                                    trailing: Text(l.date, style: const TextStyle(fontSize: 10, color: AppColors.textMuted)),
                                  );
                                },
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricsGrid(String role, LeadProvider lp, FeeProvider fp, AccountingProvider ap) {
    List<Widget> cards = [];

    if (role == AppConstants.roleSalesExecutive) {
      cards = [
        SummaryCard(title: "Today's Follow-ups", value: '${lp.leads.where((l) => l.nextFollowup.isNotEmpty).length}', icon: Icons.calendar_today, iconColor: AppColors.info),
        SummaryCard(title: 'My Leads', value: '${lp.leads.length}', icon: Icons.leaderboard, iconColor: AppColors.primary),
        SummaryCard(title: 'My Converted Leads', value: '${lp.leads.where((l) => l.status == 'Converted').length}', icon: Icons.verified_user, iconColor: AppColors.success),
        SummaryCard(title: 'Conversion Rate', value: lp.leads.isNotEmpty ? '${((lp.leads.where((l) => l.status == 'Converted').length / lp.leads.length) * 100).toStringAsFixed(1)}%' : '0%', icon: Icons.pie_chart, iconColor: AppColors.warning),
      ];
    } else if (role == AppConstants.roleOperations) {
      cards = [
        SummaryCard(title: "Today's Collection", value: CurrencyFormatter.format(fp.todayCollection), icon: Icons.payments, iconColor: AppColors.success),
        SummaryCard(title: 'Monthly Collection', value: CurrencyFormatter.format(fp.monthlyCollection), icon: Icons.account_balance, iconColor: AppColors.info),
        SummaryCard(title: 'Pending Student Fees', value: CurrencyFormatter.format(fp.totalPendingFees), icon: Icons.pending_actions, iconColor: AppColors.warning),
        SummaryCard(title: "Today's Expenses", value: CurrencyFormatter.format(ap.todayExpense), icon: Icons.receipt_long, iconColor: AppColors.danger),
      ];
    } else if (role == AppConstants.roleSalesHead) {
      cards = [
        SummaryCard(title: "Today's Leads", value: '${lp.leads.where((l) => l.date.contains(DateTime.now().toIso8601String().substring(0,10))).length}', icon: Icons.person_add, iconColor: AppColors.info),
        SummaryCard(title: 'Total Pipeline Leads', value: '${lp.rawLeads.length}', icon: Icons.people, iconColor: AppColors.primary),
        SummaryCard(title: 'Converted Admissions', value: '${lp.rawLeads.where((l) => l.status == 'Converted').length}', icon: Icons.school, iconColor: AppColors.success),
        SummaryCard(title: 'Overall Conversion %', value: lp.rawLeads.isNotEmpty ? '${((lp.rawLeads.where((l) => l.status == 'Converted').length / lp.rawLeads.length) * 100).toStringAsFixed(1)}%' : '0%', icon: Icons.trending_up, iconColor: AppColors.warning),
      ];
    } else {
      // ADMIN & CEO
      cards = [
        SummaryCard(title: "Today's Collection", value: CurrencyFormatter.format(fp.todayCollection), icon: Icons.payments, iconColor: AppColors.success),
        SummaryCard(title: 'Monthly Collection', value: CurrencyFormatter.format(fp.monthlyCollection), icon: Icons.account_balance, iconColor: AppColors.info),
        SummaryCard(title: 'Total Active Leads', value: '${lp.rawLeads.length}', icon: Icons.people, iconColor: AppColors.primary),
        SummaryCard(title: 'Active Students', value: '${fp.students.length}', icon: Icons.school, iconColor: const Color(0xFF8B5CF6)),
        SummaryCard(title: 'Pending Fees', value: CurrencyFormatter.format(fp.totalPendingFees), icon: Icons.pending_actions, iconColor: AppColors.warning),
        SummaryCard(title: 'Monthly Expenses', value: CurrencyFormatter.format(ap.monthlyExpense), icon: Icons.money_off, iconColor: AppColors.danger),
      ];
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        int crossAxisCount = 3;
        if (constraints.maxWidth < 600) {
          crossAxisCount = 1;
        } else if (constraints.maxWidth < 950) {
          crossAxisCount = 2;
        }
        return GridView.count(
          crossAxisCount: crossAxisCount,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: 2.3,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          children: cards,
        );
      },
    );
  }

  Widget _buildQuickActionsBar(String role) {
    final actions = <Widget>[];

    if (RolePermissions.canCreateLead(role)) {
      actions.add(ElevatedButton.icon(
        onPressed: () {},
        icon: const Icon(Icons.add, size: 16),
        label: const Text('Add New Lead'),
      ));
    }

    if (RolePermissions.canCollectFee(role)) {
      actions.add(ElevatedButton.icon(
        style: ElevatedButton.styleFrom(backgroundColor: AppColors.success),
        onPressed: () {},
        icon: const Icon(Icons.receipt, size: 16),
        label: const Text('Collect Fee Payment'),
      ));
    }

    if (RolePermissions.canEnterExpense(role)) {
      actions.add(ElevatedButton.icon(
        style: ElevatedButton.styleFrom(backgroundColor: AppColors.secondary),
        onPressed: () {},
        icon: const Icon(Icons.note_add, size: 16),
        label: const Text('Record Expense'),
      ));
    }

    if (role != AppConstants.roleSalesExecutive) {
      actions.add(ElevatedButton.icon(
        style: ElevatedButton.styleFrom(backgroundColor: AppColors.info),
        onPressed: () {},
        icon: const Icon(Icons.bar_chart, size: 16),
        label: const Text('View Reports'),
      ));
    }

    if (actions.isEmpty) return const SizedBox();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          cross: CrossAxisAlignment.start,
          children: [
            const Text('Quick Actions', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 10,
              children: actions,
            ),
          ],
        ),
      ),
    );
  }
}

class ChartCard extends StatelessWidget {
  final String title;
  final Widget child;

  const ChartCard({super.key, required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          cross: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            const SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }
}
