import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/permissions/role_permissions.dart';
import '../../data/models/user_model.dart';
import '../../providers/user_provider.dart';
import '../widgets/status_badge.dart';

class UserManagementView extends StatefulWidget {
  const UserManagementView({super.key});

  @override
  State<UserManagementView> createState() => _UserManagementViewState();
}

class _UserManagementViewState extends State<UserManagementView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<UserProvider>(context, listen: false).fetchUsers();
    });
  }

  void _showAddUserDialog() {
    final nameCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    final passwordCtrl = TextEditingController(text: 'user123');
    String selectedRole = AppConstants.roleSalesExecutive;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create New User'),
        content: SizedBox(
          width: 440,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Full Name *')),
              const SizedBox(height: 12),
              TextField(controller: emailCtrl, keyboardType: TextInputType.emailAddress, decoration: const InputDecoration(labelText: 'Email Address *')),
              const SizedBox(height: 12),
              TextField(controller: phoneCtrl, decoration: const InputDecoration(labelText: 'Phone Number')),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: selectedRole,
                decoration: const InputDecoration(labelText: 'Role & Permissions *'),
                items: [
                  DropdownMenuItem(value: AppConstants.roleAdmin, child: Text(RolePermissions.getRoleLabel(AppConstants.roleAdmin))),
                  DropdownMenuItem(value: AppConstants.roleCeo, child: Text(RolePermissions.getRoleLabel(AppConstants.roleCeo))),
                  DropdownMenuItem(value: AppConstants.roleSalesHead, child: Text(RolePermissions.getRoleLabel(AppConstants.roleSalesHead))),
                  DropdownMenuItem(value: AppConstants.roleSalesExecutive, child: Text(RolePermissions.getRoleLabel(AppConstants.roleSalesExecutive))),
                  DropdownMenuItem(value: AppConstants.roleOperations, child: Text(RolePermissions.getRoleLabel(AppConstants.roleOperations))),
                ],
                onChanged: (v) => selectedRole = v ?? selectedRole,
              ),
              const SizedBox(height: 12),
              TextField(controller: passwordCtrl, decoration: const InputDecoration(labelText: 'Initial Password *')),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              if (nameCtrl.text.isEmpty || emailCtrl.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Fill name and email')));
                return;
              }

              final userProvider = Provider.of<UserProvider>(context, listen: false);
              final success = await userProvider.createUser(
                name: nameCtrl.text.trim(),
                email: emailCtrl.text.trim(),
                password: passwordCtrl.text,
                role: selectedRole,
                phone: phoneCtrl.text.trim(),
              );

              if (mounted) {
                if (success) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('User created successfully'), backgroundColor: AppColors.success),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(userProvider.errorMessage ?? 'User creation failed'), backgroundColor: AppColors.danger),
                  );
                }
              }
            },
            child: const Text('Create User'),
          ),
        ],
      ),
    );
  }

  void _showResetPasswordDialog(UserModel user) {
    final passCtrl = TextEditingController(text: 'newpass123');
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Reset Password (${user.name})'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: passCtrl, decoration: const InputDecoration(labelText: 'New Password')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              final userProvider = Provider.of<UserProvider>(context, listen: false);
              await userProvider.resetPassword(user.userId, passCtrl.text);
              if (mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Password updated successfully'), backgroundColor: AppColors.success),
                );
              }
            },
            child: const Text('Reset Password'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        cross: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('System Users & Access Control', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ElevatedButton.icon(
                onPressed: _showAddUserDialog,
                icon: const Icon(Icons.person_add, size: 18),
                label: const Text('Create New User'),
              ),
            ],
          ),
          const SizedBox(height: 16),

          Expanded(
            child: userProvider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : Card(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        headingRowHeight: 44,
                        dataRowHeight: 60,
                        columns: const [
                          DataColumn(label: Text('User ID', style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text('Name', style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text('Email', style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text('Role', style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text('Phone', style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text('Status', style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text('Actions', style: TextStyle(fontWeight: FontWeight.bold))),
                        ],
                        rows: userProvider.users.map((u) {
                          return DataRow(
                            cells: [
                              DataCell(Text(u.userId, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary))),
                              DataCell(Text(u.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
                              DataCell(Text(u.email, style: const TextStyle(fontSize: 12))),
                              DataCell(Text(RolePermissions.getRoleLabel(u.role), style: const TextStyle(fontSize: 12))),
                              DataCell(Text(u.phone.isNotEmpty ? u.phone : '-', style: const TextStyle(fontSize: 12))),
                              DataCell(StatusBadge(label: u.status)),
                              DataCell(Row(
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.key, size: 18, color: AppColors.warning),
                                    onPressed: () => _showResetPasswordDialog(u),
                                    tooltip: 'Reset Password',
                                  ),
                                  IconButton(
                                    icon: Icon(u.status == 'ACTIVE' ? Icons.block : Icons.check_circle, size: 18, color: u.status == 'ACTIVE' ? AppColors.danger : AppColors.success),
                                    onPressed: () => userProvider.toggleUserStatus(u),
                                    tooltip: u.status == 'ACTIVE' ? 'Disable User' : 'Activate User',
                                  ),
                                ],
                              )),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
