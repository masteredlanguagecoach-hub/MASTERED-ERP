import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/permissions/role_permissions.dart';
import '../../core/utils/date_formatter.dart';
import '../../data/models/lead_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/lead_provider.dart';
import '../../providers/user_provider.dart';
import '../widgets/status_badge.dart';

class LeadsView extends StatefulWidget {
  const LeadsView({super.key});

  @override
  State<LeadsView> createState() => _LeadsViewState();
}

class _LeadsViewState extends State<LeadsView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = Provider.of<AuthProvider>(context, listen: false).currentUser;
      if (user != null) {
        Provider.of<LeadProvider>(context, listen: false).fetchLeads(user);
        Provider.of<UserProvider>(context, listen: false).fetchUsers();
      }
    });
  }

  void _openWhatsApp(String phone) async {
    final cleanPhone = phone.replaceAll(RegExp(r'\D'), '');
    final url = Uri.parse('https://wa.me/$cleanPhone');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not open WhatsApp for $phone')),
        );
      }
    }
  }

  void _makeCall(String phone) async {
    final url = Uri.parse('tel:$phone');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
  }

  void _showAddEditLeadDialog([LeadModel? lead]) {
    final isEdit = lead != null;
    final nameCtrl = TextEditingController(text: lead?.name ?? '');
    final phoneCtrl = TextEditingController(text: lead?.phone ?? '');
    final whatsappCtrl = TextEditingController(text: lead?.whatsapp ?? '');
    final emailCtrl = TextEditingController(text: lead?.email ?? '');
    final cityCtrl = TextEditingController(text: lead?.city ?? '');
    final courseCtrl = TextEditingController(text: lead?.courseInterested ?? 'Full Stack Development');
    final remarksCtrl = TextEditingController(text: lead?.remarks ?? '');
    final followupCtrl = TextEditingController(text: lead?.nextFollowup ?? '');

    String selectedSource = lead?.source ?? 'Website';
    String selectedStatus = lead?.status ?? 'New';
    String selectedAssigned = lead?.assignedTo ?? 'Unassigned';

    showDialog(
      context: context,
      builder: (context) {
        final users = Provider.of<UserProvider>(context).users;
        return AlertDialog(
          title: Text(isEdit ? 'Edit Lead (${lead.leadId})' : 'Quick Lead Entry'),
          content: SingleChildScrollView(
            child: SizedBox(
              width: 500,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Full Name *')),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(child: TextField(controller: phoneCtrl, decoration: const InputDecoration(labelText: 'Phone *'))),
                      const SizedBox(width: 12),
                      Expanded(child: TextField(controller: whatsappCtrl, decoration: const InputDecoration(labelText: 'WhatsApp Number'))),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(child: TextField(controller: emailCtrl, decoration: const InputDecoration(labelText: 'Email Address'))),
                      const SizedBox(width: 12),
                      Expanded(child: TextField(controller: cityCtrl, decoration: const InputDecoration(labelText: 'City'))),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextField(controller: courseCtrl, decoration: const InputDecoration(labelText: 'Course Interested *')),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: AppConstants.leadSources.contains(selectedSource) ? selectedSource : AppConstants.leadSources.first,
                          decoration: const InputDecoration(labelText: 'Source'),
                          items: AppConstants.leadSources.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                          onChanged: (v) => selectedSource = v ?? selectedSource,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: AppConstants.leadStatuses.contains(selectedStatus) ? selectedStatus : AppConstants.leadStatuses.first,
                          decoration: const InputDecoration(labelText: 'Lead Status'),
                          items: AppConstants.leadStatuses.map((st) => DropdownMenuItem(value: st, child: Text(st))).toList(),
                          onChanged: (v) => selectedStatus = v ?? selectedStatus,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: users.any((u) => u.name == selectedAssigned) ? selectedAssigned : 'Unassigned',
                    decoration: const InputDecoration(labelText: 'Assigned Sales Executive'),
                    items: [
                      const DropdownMenuItem(value: 'Unassigned', child: Text('Unassigned')),
                      ...users.map((u) => DropdownMenuItem(value: u.name, child: Text(u.name))),
                    ],
                    onChanged: (v) => selectedAssigned = v ?? 'Unassigned',
                  ),
                  const SizedBox(height: 12),
                  TextField(controller: followupCtrl, decoration: const InputDecoration(labelText: 'Next Follow-up Date (YYYY-MM-DD)', hintText: '2026-09-10')),
                  const SizedBox(height: 12),
                  TextField(controller: remarksCtrl, maxLines: 2, decoration: const InputDecoration(labelText: 'Remarks / Notes')),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () async {
                if (nameCtrl.text.isEmpty || phoneCtrl.text.isEmpty || courseCtrl.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please fill required fields (Name, Phone, Course)')));
                  return;
                }

                final leadProvider = Provider.of<LeadProvider>(context, listen: false);
                final currentUser = Provider.of<AuthProvider>(context, listen: false).currentUser!;

                final payload = {
                  if (isEdit) 'lead_id': lead.leadId,
                  'name': nameCtrl.text.trim(),
                  'phone': phoneCtrl.text.trim(),
                  'whatsapp': whatsappCtrl.text.trim().isNotEmpty ? whatsappCtrl.text.trim() : phoneCtrl.text.trim(),
                  'email': emailCtrl.text.trim(),
                  'city': cityCtrl.text.trim(),
                  'course_interested': courseCtrl.text.trim(),
                  'source': selectedSource,
                  'status': selectedStatus,
                  'assigned_to': selectedAssigned,
                  'next_followup': followupCtrl.text.trim(),
                  'remarks': remarksCtrl.text.trim(),
                };

                final success = isEdit
                    ? await leadProvider.updateLead(payload, currentUser)
                    : await leadProvider.createLead(payload, currentUser);

                if (mounted) {
                  if (success) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(isEdit ? 'Lead updated successfully' : 'Lead created successfully'), backgroundColor: AppColors.success),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(leadProvider.errorMessage ?? 'Operation failed'), backgroundColor: AppColors.danger),
                    );
                  }
                }
              },
              child: Text(isEdit ? 'Update Lead' : 'Save Lead'),
            ),
          ],
        );
      },
    );
  }

  void _showConvertLeadDialog(LeadModel lead) {
    final courseCtrl = TextEditingController(text: lead.courseInterested);
    final totalFeeCtrl = TextEditingController(text: '50000');
    final paidFeeCtrl = TextEditingController(text: '15000');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Convert Lead to Student (${lead.name})'),
        content: SizedBox(
          width: 420,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Converting this lead will automatically:\n• Generate a Student ID (STU-100X) & Admission No (ADM-2026-00X).\n• Create a Google Drive folder under MASTERED/Students/.\n• Record initial admission fee payment in Fee Ledger.',
                style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 16),
              TextField(controller: courseCtrl, decoration: const InputDecoration(labelText: 'Final Enrolled Course')),
              const SizedBox(height: 12),
              TextField(controller: totalFeeCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Total Agreed Fee (₹)')),
              const SizedBox(height: 12),
              TextField(controller: paidFeeCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Initial Down Payment Paid (₹)')),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.success),
            onPressed: () async {
              final totalFee = double.tryParse(totalFeeCtrl.text) ?? 50000;
              final paidFee = double.tryParse(paidFeeCtrl.text) ?? 0;
              final currentUser = Provider.of<AuthProvider>(context, listen: false).currentUser!;

              final leadProvider = Provider.of<LeadProvider>(context, listen: false);
              final success = await leadProvider.convertLeadToStudent(
                lead: lead,
                totalFee: totalFee,
                paidFee: paidFee,
                course: courseCtrl.text,
                currentUser: currentUser,
              );

              if (mounted) {
                if (success) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Lead converted to Student successfully! Drive folder created.'), backgroundColor: AppColors.success),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(leadProvider.errorMessage ?? 'Conversion failed'), backgroundColor: AppColors.danger),
                  );
                }
              }
            },
            child: const Text('Confirm Conversion'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final leadProvider = Provider.of<LeadProvider>(context);
    final authUser = Provider.of<AuthProvider>(context).currentUser;
    final role = authUser?.role ?? AppConstants.roleSalesExecutive;

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        cross: CrossAxisAlignment.start,
        children: [
          // Filter & Search Controls Bar
          Row(
            children: [
              Expanded(
                child: TextField(
                  onChanged: (q) => leadProvider.setSearchQuery(q),
                  decoration: const InputDecoration(
                    hintText: 'Search leads by name, phone, email, course...',
                    prefixIcon: Icon(Icons.search, size: 20),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              DropdownButton<String>(
                value: leadProvider.selectedStatusFilter,
                underline: const SizedBox(),
                items: ['All', ...AppConstants.leadStatuses]
                    .map((st) => DropdownMenuItem(value: st, child: Text('Status: $st', style: const TextStyle(fontSize: 13))))
                    .toList(),
                onChanged: (v) => leadProvider.setStatusFilter(v ?? 'All'),
              ),
              const SizedBox(width: 12),
              if (RolePermissions.canCreateLead(role))
                ElevatedButton.icon(
                  onPressed: () => _showAddEditLeadDialog(),
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Add Lead'),
                ),
            ],
          ),
          const SizedBox(height: 16),

          // Lead Cards / Table
          Expanded(
            child: leadProvider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : leadProvider.leads.isEmpty
                    ? const Center(child: Text('No leads found.', style: TextStyle(color: AppColors.textMuted)))
                    : Card(
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: SingleChildScrollView(
                            child: DataTable(
                              headingRowHeight: 44,
                              dataRowHeight: 64,
                              columns: const [
                                DataColumn(label: Text('Lead ID', style: TextStyle(fontWeight: FontWeight.bold))),
                                DataColumn(label: Text('Name & City', style: TextStyle(fontWeight: FontWeight.bold))),
                                DataColumn(label: Text('Contact', style: TextStyle(fontWeight: FontWeight.bold))),
                                DataColumn(label: Text('Course Interested', style: TextStyle(fontWeight: FontWeight.bold))),
                                DataColumn(label: Text('Assigned To', style: TextStyle(fontWeight: FontWeight.bold))),
                                DataColumn(label: Text('Status', style: TextStyle(fontWeight: FontWeight.bold))),
                                DataColumn(label: Text('Next Followup', style: TextStyle(fontWeight: FontWeight.bold))),
                                DataColumn(label: Text('Actions', style: TextStyle(fontWeight: FontWeight.bold))),
                              ],
                              rows: leadProvider.leads.map((lead) {
                                return DataRow(
                                  cells: [
                                    DataCell(Text(lead.leadId, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary))),
                                    DataCell(Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      cross: CrossAxisAlignment.start,
                                      children: [
                                        Text(lead.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                        if (lead.city.isNotEmpty) Text(lead.city, style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
                                      ],
                                    )),
                                    DataCell(Row(
                                      children: [
                                        Text(lead.phone, style: const TextStyle(fontSize: 12)),
                                        const SizedBox(width: 6),
                                        IconButton(
                                          icon: const Icon(Icons.phone, size: 16, color: AppColors.info),
                                          onPressed: () => _makeCall(lead.phone),
                                          tooltip: 'Call',
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.chat_bubble_outline, size: 16, color: AppColors.success),
                                          onPressed: () => _openWhatsApp(lead.whatsapp),
                                          tooltip: 'WhatsApp',
                                        ),
                                      ],
                                    )),
                                    DataCell(Text(lead.courseInterested, style: const TextStyle(fontSize: 12))),
                                    DataCell(Text(lead.assignedTo, style: const TextStyle(fontSize: 12))),
                                    DataCell(StatusBadge(label: lead.status)),
                                    DataCell(Text(DateFormatter.formatDisplay(lead.nextFollowup), style: const TextStyle(fontSize: 11))),
                                    DataCell(Row(
                                      children: [
                                        IconButton(
                                          icon: const Icon(Icons.edit, size: 18, color: AppColors.textSecondary),
                                          onPressed: () => _showAddEditLeadDialog(lead),
                                          tooltip: 'Edit Lead',
                                        ),
                                        if (lead.status != 'Converted')
                                          ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: AppColors.success,
                                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                            ),
                                            onPressed: () => _showConvertLeadDialog(lead),
                                            child: const Text('Convert', style: TextStyle(fontSize: 11)),
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
          ),
        ],
      ),
    );
  }
}
