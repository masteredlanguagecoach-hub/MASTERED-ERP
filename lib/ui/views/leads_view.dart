import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/permissions/role_permissions.dart';
import '../../data/models/lead_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/lead_provider.dart';
import '../widgets/lead_closing_dialog.dart';
import '../widgets/status_badge.dart';

class LeadsView extends StatefulWidget {
  const LeadsView({super.key});

  @override
  State<LeadsView> createState() => _LeadsViewState();
}

class _LeadsViewState extends State<LeadsView> {
  String _selectedStageFilter = 'All';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<LeadProvider>(context, listen: false).fetchLeads();
    });
  }

  void _showAddLeadDialog() {
    final nameCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    final cityCtrl = TextEditingController();
    final remarksCtrl = TextEditingController();
    final refStudentIdCtrl = TextEditingController();

    String selectedCourse = 'BCA-1Y';
    String selectedSource = 'Meta Ad';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => AlertDialog(
          title: const Text('Add New Lead to CRM'),
          content: SizedBox(
            width: 440,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Lead Full Name *')),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(child: TextField(controller: phoneCtrl, decoration: const InputDecoration(labelText: 'Phone Number *'))),
                      const SizedBox(width: 10),
                      Expanded(child: TextField(controller: emailCtrl, decoration: const InputDecoration(labelText: 'Email Address'))),
                    ],
                  ),
                  const SizedBox(height: 10),
                  TextField(controller: cityCtrl, decoration: const InputDecoration(labelText: 'City / Location *')),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    value: selectedCourse,
                    decoration: const InputDecoration(labelText: 'Course Interested *'),
                    items: ['BHA-6M', 'HRCA-6M', 'BCA-1Y', 'HRCA-1Y'].map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                    onChanged: (v) => setModalState(() => selectedCourse = v!),
                  ),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    value: selectedSource,
                    decoration: const InputDecoration(labelText: 'Lead Source *'),
                    items: ['Meta Ad', 'Organic Lead', 'Random Visit', 'Referral'].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                    onChanged: (v) => setModalState(() => selectedSource = v!),
                  ),
                  if (selectedSource == 'Referral') ...[
                    const SizedBox(height: 10),
                    TextField(controller: refStudentIdCtrl, decoration: const InputDecoration(labelText: 'Search Referral Student ID (Optional)', hintText: 'STU-2026-101')),
                  ],
                  const SizedBox(height: 10),
                  TextField(controller: remarksCtrl, decoration: const InputDecoration(labelText: 'Initial Remarks / Enquiry Note')),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () async {
                if (nameCtrl.text.isEmpty || phoneCtrl.text.isEmpty) return;
                final leadProvider = Provider.of<LeadProvider>(context, listen: false);
                await leadProvider.addLead(
                  LeadModel(
                    leadId: '',
                    date: DateTime.now().toIso8601String().substring(0, 10),
                    name: nameCtrl.text.trim(),
                    phone: phoneCtrl.text.trim(),
                    whatsapp: phoneCtrl.text.trim(),
                    email: emailCtrl.text.trim(),
                    city: cityCtrl.text.trim(),
                    courseInterested: selectedCourse,
                    source: selectedSource,
                    createdBy: '',
                    assignedTo: '',
                    status: 'New',
                    nextFollowup: DateTime.now().add(const Duration(days: 1)).toIso8601String().substring(0, 10),
                    remarks: remarksCtrl.text.trim(),
                    updatedAt: DateTime.now().toIso8601String(),
                  ),
                );

                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Lead registered and auto-assigned successfully'), backgroundColor: AppColors.success),
                  );
                }
              },
              child: const Text('Save Lead'),
            ),
          ],
        ),
      ),
    );
  }

  void _handleStageTransition(LeadModel lead, String newStage) {
    if (newStage == 'Closed') {
      showDialog(
        context: context,
        builder: (context) => LeadClosingDialog(lead: lead),
      );
      return;
    }

    final reasonCtrl = TextEditingController();
    final dateCtrl = TextEditingController(text: DateTime.now().add(const Duration(days: 2)).toIso8601String().substring(0, 10));

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Transition Lead to $newStage (${lead.name})'),
        content: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (newStage == 'Not Interested' || newStage == 'Unqualified')
                TextField(
                  controller: reasonCtrl,
                  decoration: InputDecoration(labelText: 'Reason for $newStage *', hintText: 'Not interested in course fee structure...'),
                ),
              if (newStage == 'Follow-up' || newStage == 'Interested') ...[
                TextField(
                  controller: dateCtrl,
                  decoration: const InputDecoration(labelText: 'Next Follow-up Date (YYYY-MM-DD) *'),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: reasonCtrl,
                  decoration: const InputDecoration(labelText: 'Follow-up Discussion Notes *'),
                ),
              ],
              if (newStage == 'Visited') ...[
                TextField(
                  controller: reasonCtrl,
                  maxLines: 2,
                  decoration: const InputDecoration(labelText: 'Campus Visit Summary & Notes *'),
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              final leadProvider = Provider.of<LeadProvider>(context, listen: false);
              await leadProvider.updateLead(
                LeadModel(
                  leadId: lead.leadId,
                  date: lead.date,
                  name: lead.name,
                  phone: lead.phone,
                  whatsapp: lead.whatsapp,
                  email: lead.email,
                  city: lead.city,
                  courseInterested: lead.courseInterested,
                  source: lead.source,
                  assignedTo: lead.assignedTo,
                  status: newStage,
                  nextFollowup: dateCtrl.text.trim(),
                  remarks: reasonCtrl.text.trim(),
                  createdBy: lead.createdBy,
                  updatedAt: DateTime.now().toIso8601String(),
                ),
              );

              if (mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Lead updated to $newStage'), backgroundColor: AppColors.success),
                );
              }
            },
            child: const Text('Save Stage'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final leadProvider = Provider.of<LeadProvider>(context);
    final user = Provider.of<AuthProvider>(context).currentUser;
    final role = user?.role ?? '';

    List<LeadModel> displayLeads = leadProvider.leads;
    if (_selectedStageFilter != 'All') {
      displayLeads = displayLeads.where((l) => l.status == _selectedStageFilter).toList();
    }

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        cross: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                cross: CrossAxisAlignment.start,
                children: [
                  const Text('Lead Management System (CRM)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  Text(role == 'SALES_EXECUTIVE' ? 'Showing leads assigned to ${user?.name}' : 'Showing team active CRM pipeline', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                ],
              ),
              ElevatedButton.icon(
                onPressed: _showAddLeadDialog,
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Add Lead'),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Stage Filter Bar
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: ['All', 'New', 'Interested', 'Follow-up', 'Visited', 'Closed', 'Not Interested', 'Unqualified'].map((s) {
                final isSelected = _selectedStageFilter == s;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(s, style: TextStyle(color: isSelected ? Colors.white : AppColors.textPrimary, fontSize: 12)),
                    selected: isSelected,
                    selectedColor: AppColors.primary,
                    onSelected: (val) => setState(() => _selectedStageFilter = s),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 16),

          Expanded(
            child: leadProvider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : displayLeads.isEmpty
                    ? const Center(child: Text('No leads found in selected stage.', style: TextStyle(color: AppColors.textMuted)))
                    : Card(
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: SingleChildScrollView(
                            child: DataTable(
                              columns: const [
                                DataColumn(label: Text('Lead ID', style: TextStyle(fontWeight: FontWeight.bold))),
                                DataColumn(label: Text('Lead Name', style: TextStyle(fontWeight: FontWeight.bold))),
                                DataColumn(label: Text('Phone', style: TextStyle(fontWeight: FontWeight.bold))),
                                DataColumn(label: Text('Course Interested', style: TextStyle(fontWeight: FontWeight.bold))),
                                DataColumn(label: Text('Source', style: TextStyle(fontWeight: FontWeight.bold))),
                                DataColumn(label: Text('Assigned Exec', style: TextStyle(fontWeight: FontWeight.bold))),
                                DataColumn(label: Text('Status Stage', style: TextStyle(fontWeight: FontWeight.bold))),
                                DataColumn(label: Text('Next Due', style: TextStyle(fontWeight: FontWeight.bold))),
                                DataColumn(label: Text('Stage Transition Action', style: TextStyle(fontWeight: FontWeight.bold))),
                              ],
                              rows: displayLeads.map((lead) {
                                return DataRow(cells: [
                                  DataCell(Text(lead.leadId, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary))),
                                  DataCell(Text(lead.name, style: const TextStyle(fontWeight: FontWeight.bold))),
                                  DataCell(Text(lead.phone)),
                                  DataCell(Text(lead.courseInterested)),
                                  DataCell(StatusBadge(label: lead.source)),
                                  DataCell(Text(lead.assignedTo, style: const TextStyle(fontSize: 12))),
                                  DataCell(StatusBadge(label: lead.status)),
                                  DataCell(Text(lead.nextFollowup, style: const TextStyle(color: AppColors.danger, fontWeight: FontWeight.bold))),
                                  DataCell(
                                    PopupMenuButton<String>(
                                      onSelected: (newStage) => _handleStageTransition(lead, newStage),
                                      itemBuilder: (context) => ['Interested', 'Follow-up', 'Visited', 'Closed', 'Not Interested', 'Unqualified']
                                          .map((stg) => PopupMenuItem(value: stg, child: Text('Mark $stg')))
                                          .toList(),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                        decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
                                        child: const Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text('Change Stage', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 11)),
                                            Icon(Icons.arrow_drop_down, color: AppColors.primary, size: 16),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ]);
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
