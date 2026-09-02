import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/permissions/role_permissions.dart';
import '../../providers/auth_provider.dart';

class SidebarDrawer extends StatelessWidget {
  final String currentRoute;
  final Function(String route) onSelectRoute;

  const SidebarDrawer({
    super.key,
    required this.currentRoute,
    required this.onSelectRoute,
  });

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.currentUser;
    final role = user?.role ?? AppConstants.roleSalesExecutive;

    final navItems = [
      {'id': 'dashboard', 'title': 'Dashboard', 'icon': Icons.dashboard_outlined},
      {'id': 'leads', 'title': 'Lead CRM', 'icon': Icons.leaderboard_outlined},
      {'id': 'followups', 'title': 'Daily Follow-ups', 'icon': Icons.phone_in_talk_outlined},
      {'id': 'due_reminders', 'title': '3-Day Fee Reminders', 'icon': Icons.alarm_on_outlined},
      {'id': 'students', 'title': 'Students Directory', 'icon': Icons.school_outlined},
      {'id': 'batches', 'title': 'Batch Management', 'icon': Icons.class_outlined},
      {'id': 'sales_team', 'title': 'Sales Team Overview', 'icon': Icons.groups_outlined},
      {'id': 'fee_collection', 'title': 'Fee Collection', 'icon': Icons.receipt_long_outlined},
      {'id': 'accounting', 'title': 'Accounting', 'icon': Icons.account_balance_wallet_outlined},
      {'id': 'reports', 'title': 'Reports & Analytics', 'icon': Icons.bar_chart_outlined},
      {'id': 'user_management', 'title': 'User Management', 'icon': Icons.people_alt_outlined},
      {'id': 'courses', 'title': 'Course Master', 'icon': Icons.menu_book_outlined},
      {'id': 'audit_logs', 'title': 'Audit Logs', 'icon': Icons.security_outlined},
      {'id': 'ai_analysis', 'title': 'AI Analysis', 'icon': Icons.auto_awesome_outlined},
      {'id': 'settings', 'title': 'Settings', 'icon': Icons.settings_outlined},
    ];

    final allowedNavItems = navItems.where((item) {
      return RolePermissions.canAccessNavItem(role, item['id'] as String);
    }).toList();

    return Container(
      width: 250,
      color: AppColors.secondary,
      child: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: AppColors.secondaryLight)),
              ),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: Image.asset(
                      AppConstants.logoPath,
                      width: 36,
                      height: 36,
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => Container(
                        width: 36,
                        height: 36,
                        color: AppColors.primary,
                        child: const Center(
                          child: Text('M', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      cross: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          AppConstants.academyName,
                          style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold, letterSpacing: 1),
                        ),
                        Text(
                          'ERP SYSTEM',
                          style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 9, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            if (user != null)
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.secondaryLight.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 15,
                      backgroundColor: AppColors.primary,
                      child: Text(
                        user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
                        style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        cross: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user.name,
                            style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            RolePermissions.getRoleLabel(user.role),
                            style: const TextStyle(color: AppColors.primaryLight, fontSize: 10),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

            Expanded(
              child: Scrollbar(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                  itemCount: allowedNavItems.length,
                  itemBuilder: (context, index) {
                    final item = allowedNavItems[index];
                    final id = item['id'] as String;
                    final isSelected = currentRoute == id;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 2),
                      child: ListTile(
                        dense: true,
                        selected: isSelected,
                        selectedTileColor: AppColors.primary,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        leading: Icon(
                          item['icon'] as IconData,
                          color: isSelected ? Colors.white : Colors.white.withOpacity(0.7),
                          size: 18,
                        ),
                        title: Text(
                          item['title'] as String,
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.white.withOpacity(0.85),
                            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                            fontSize: 12.5,
                          ),
                        ),
                        onTap: () => onSelectRoute(id),
                      ),
                    );
                  },
                ),
              ),
            ),

            Container(
              padding: const EdgeInsets.only(left: 12, right: 12, top: 8, bottom: 20),
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: AppColors.secondaryLight)),
              ),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white.withOpacity(0.9),
                    side: BorderSide(color: Colors.white.withOpacity(0.25)),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                  onPressed: () {
                    authProvider.logout();
                  },
                  icon: const Icon(Icons.logout, size: 16),
                  label: const Text('Logout', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
