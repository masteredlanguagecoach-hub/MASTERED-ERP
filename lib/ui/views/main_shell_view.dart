import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/permissions/role_permissions.dart';
import '../../providers/auth_provider.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/responsive_builder.dart';
import '../widgets/sidebar_drawer.dart';

import 'dashboard_view.dart';
import 'leads_view.dart';
import 'daily_followups_view.dart';
import 'fee_due_reminders_view.dart';
import 'students_view.dart';
import 'batches_view.dart';
import 'sales_team_view.dart';
import 'fee_collection_view.dart';
import 'accounting_view.dart';
import 'reports_view.dart';
import 'user_management_view.dart';
import 'courses_master_view.dart';
import 'audit_log_view.dart';
import 'ai_analysis_view.dart';
import 'settings_view.dart';
import 'login_view.dart';

class MainShellView extends StatefulWidget {
  const MainShellView({super.key});

  @override
  State<MainShellView> createState() => _MainShellViewState();
}

class _MainShellViewState extends State<MainShellView> {
  String _currentRoute = 'dashboard';
  String _globalSearchQuery = '';

  Widget _getScreenView(String route) {
    switch (route) {
      case 'dashboard':
        return const DashboardView();
      case 'leads':
        return const LeadsView();
      case 'followups':
        return const DailyFollowupsView();
      case 'due_reminders':
        return const FeeDueRemindersView();
      case 'students':
        return const StudentsView();
      case 'batches':
        return const BatchesView();
      case 'sales_team':
        return const SalesTeamView();
      case 'fee_collection':
        return const FeeCollectionView();
      case 'accounting':
        return const AccountingView();
      case 'reports':
        return const ReportsView();
      case 'user_management':
        return const UserManagementView();
      case 'courses':
        return const CoursesMasterView();
      case 'audit_logs':
        return const AuditLogView();
      case 'ai_analysis':
        return const AiAnalysisView();
      case 'settings':
        return const SettingsView();
      default:
        return const DashboardView();
    }
  }

  String _getScreenTitle(String route) {
    switch (route) {
      case 'dashboard':
        return 'Dashboard Overview';
      case 'leads':
        return 'Lead Management System (CRM)';
      case 'followups':
        return 'Daily Follow-up Workspace';
      case 'due_reminders':
        return 'Operations 3-Day Fee Due Reminders';
      case 'students':
        return 'Student Directory & Course Ledgers';
      case 'batches':
        return 'Batch & Class Management';
      case 'sales_team':
        return 'Sales Team & Performance Analytics';
      case 'fee_collection':
        return 'Fee Collection System';
      case 'accounting':
        return 'Accounting & Expenses';
      case 'reports':
        return 'Executive Reports & Analytics';
      case 'user_management':
        return 'User & Access Permission Management';
      case 'courses':
        return 'Admin Course Master Configuration';
      case 'audit_logs':
        return 'System Audit Logs & Security Trail';
      case 'ai_analysis':
        return 'Admin AI Report Analysis';
      case 'settings':
        return 'System & Database Settings';
      default:
        return 'Dashboard';
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.currentUser;

    if (user == null) {
      return const LoginView();
    }

    final role = user.role;
    if (!RolePermissions.canAccessNavItem(role, _currentRoute)) {
      _currentRoute = 'dashboard';
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(
        title: _getScreenTitle(_currentRoute),
        onSearch: (q) => setState(() => _globalSearchQuery = q),
      ),
      drawer: ResponsiveBuilder.isMobile(context)
          ? Drawer(
              child: SidebarDrawer(
                currentRoute: _currentRoute,
                onSelectRoute: (route) {
                  Navigator.pop(context);
                  setState(() => _currentRoute = route);
                },
              ),
            )
          : null,
      body: Row(
        children: [
          if (!ResponsiveBuilder.isMobile(context))
            SidebarDrawer(
              currentRoute: _currentRoute,
              onSelectRoute: (route) {
                setState(() => _currentRoute = route);
              },
            ),
          Expanded(
            child: Column(
              children: [
                if (_globalSearchQuery.isNotEmpty)
                  Container(
                    width: double.infinity,
                    color: AppColors.primary.withOpacity(0.1),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      children: [
                        const Icon(Icons.search, size: 16, color: AppColors.primary),
                        const SizedBox(width: 8),
                        Text(
                          'Filtered by query: "$_globalSearchQuery"',
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.primary),
                        ),
                        const Spacer(),
                        InkWell(
                          onTap: () => setState(() => _globalSearchQuery = ''),
                          child: const Icon(Icons.close, size: 16, color: AppColors.primary),
                        ),
                      ],
                    ),
                  ),
                Expanded(child: _getScreenView(_currentRoute)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
