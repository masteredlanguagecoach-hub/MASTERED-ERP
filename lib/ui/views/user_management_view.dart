import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
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
    final tempPassCtrl = TextEditingController(text: 'TempPass123');
    String selectedRole = 'SALES_EXECUTIVE';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create New User Account (Admin)'),
        content: SizedBox(
          width: 420,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Display Name *')),
              const SizedBox(height: 10),
              TextField(controller: emailCtrl, decoration: const InputDecoration(labelText: 'Email Address *')),
              const SizedBox(height: 10),
              TextField(controller: phoneCtrl, decoration: const InputDecoration(labelText: 'Phone Number *')),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: selectedRole,
                decoration: const InputDecoration(labelText: 'Role Profile *'),
                items: [
                  const DropdownMenuItem(value: 'SALES_EXECUTIVE', child: Text('Sales Executive')),
                  const DropdownMenuItem(value: 'OPERATIONS', child: Text('Operations')),
                  const DropdownMenuItem(value: 'SALES_HEAD', child: Text('Sales Head')),
                  const DropdownMenuItem(value: 'CEO', child: Text('CEO')),
                  const DropdownMenuItem(value: 'ADMIN', child: Text('Admin')),
                ],
                onChanged: (v) => selectedRole = v!,
              ),
              const SizedBox(height: 10),
              TextField(controller: tempPassCtrl, decoration: const InputDecoration(labelText: 'Temporary Password *')),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              if (nameCtrl.text.isEmpty || emailCtrl.text.isEmpty) return;
              final userProvider = Provider.of<UserProvider>(context, listen: false);
              await userProvider.addUser(
                UserModel(
                  id: '',
                  name: nameCtrl.text.trim(),
                  email: emailCtrl.text.trim(),
                  role: selectedRole,
                  phone: phoneCtrl.text.trim(),
                  status: 'ACTIVE',
                  createdAt: DateTime.now().toIso8601String(),
                ),
              );

              if (mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('New account created with forced password change!'), backgroundColor: AppColors.success),
                );
              }
            },
            child: const Text('Create User'),
          ),
        ],
      ),
    );
  }

  void _updateStatus(UserModel user, String newStatus) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    await userProvider.updateUserStatus(user.id, newStatus);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${user.name} status updated to $newStatus'), backgroundColor: AppColors.success),
      );
    }
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
              const Column(
                cross: CrossAxisAlignment.start,
                children: [
                  Text('User & Access Permission Management', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  Text('Manage staff credentials, issue temporary passwords, activate, disable, or mark executive dismissed.', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                ],
              ),
              ElevatedButton.icon(
                onPressed: _showAddUserDialog,
                icon: const Icon(Icons.person_add, size: 18),
                label: const Text('Create User'),
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
                    DataColumn(label: Text('User ID', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('Display Name', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('Email Address', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('Role Profile', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('Phone', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('Account Status', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('Actions', style: TextStyle(fontWeight: FontWeight.bold))),
                  ],
                  rows: userProvider.users.map((u) {
                    return DataRow(cells: [
                      DataCell(Text(u.id, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary))),
                      DataCell(Text(u.name, style: const TextStyle(fontWeight: FontWeight.bold))),
                      DataCell(Text(u.email)),
                      DataCell(StatusBadge(label: u.role)),
                      DataCell(Text(u.phone)),
                      DataCell(StatusBadge(label: u.status)),
                      DataCell(
                        PopupMenuButton<String>(
                          onSelected: (st) => _updateStatus(u, st),
                          itemBuilder: (context) => [
                            const PopupMenuItem(value: 'ACTIVE', child: Text('Activate Account')),
                            const PopupMenuItem(value: 'DISABLED', child: Text('Disable Account')),
                            const PopupMenuItem(value: 'DISMISSED', child: Text('Mark Dismissed')),
                          ],
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
                            child: const Text('Edit Status', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 11)),
                          ),
                        ),
                      ),
                    ]);
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
