import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/constants/app_colors.dart';
import '../../data/models/lead_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/lead_provider.dart';
import '../widgets/status_badge.dart';

class DailyFollowupsView extends StatefulWidget {
  const DailyFollowupsView({super.key});

  @override
  State<DailyFollowupsView> createState() => _DailyFollowupsViewState();
}

class _DailyFollowupsViewState extends State<DailyFollowupsView> {
  final int _dailyTarget = 10;

  void _launchWhatsApp(LeadModel lead) async {
    final cleanPhone = lead.phone.replaceAll(RegExp(r'\D'), '');
    final fullPhone = cleanPhone.startsWith('91') ? cleanPhone : '91$cleanPhone';
    // Updated dedicated sales message template: "Hello {name}"
    final msg = Uri.encodeComponent('Hello ${lead.name}');
    final url = Uri.parse('https://wa.me/$fullPhone?text=$msg');

    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  void _showRecordFollowupDialog(LeadModel lead) {
    final noteCtrl = TextEditingController();
    final nextDateCtrl = TextEditingController(text: DateTime.now().add(const Duration(days: 2)).toIso8601String().substring(0, 10));
    String selectedActivity = 'Phone Call';
    String selectedStage = lead.status == 'New' ? 'Interested' : lead.status;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => AlertDialog(
          title: Text('Log Follow-up Activity (${lead.name})'),
          content: SizedBox(
            width: 440,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  value: selectedActivity,
                  decoration: const InputDecoration(labelText: 'Activity Type *'),
                  items: ['Phone Call', 'WhatsApp', 'Direct Visit', 'Office Visit', 'Other']
                      .map((a) => DropdownMenuItem(value: a, child: Text(a)))
                      .toList(),
                  onChanged: (v) => setModalState(() => selectedActivity = v!),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: selectedStage,
                  decoration: const InputDecoration(labelText: 'Updated Lead Stage *'),
                  items: ['New', 'Interested', 'Not Interested', 'Follow-up', 'Unqualified', 'Visited']
                      .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                      .toList(),
                  onChanged: (v) => setModalState(() => selectedStage = v!),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: noteCtrl,
                  maxLines: 2,
                  decoration: const InputDecoration(labelText: 'Follow-up Note / Outcome *', hintText: 'Follow-up discussion notes...'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: nextDateCtrl,
                  decoration: const InputDecoration(labelText: 'Next Follow-up Date (YYYY-MM-DD)'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () async {
                if (noteCtrl.text.isEmpty) return;
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
                    status: selectedStage,
                    nextFollowup: nextDateCtrl.text.trim(),
                    remarks: noteCtrl.text.trim(),
                    createdBy: lead.createdBy,
                    updatedAt: DateTime.now().toIso8601String(),
                  ),
                );

                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Follow-up logged successfully'), backgroundColor: AppColors.success),
                  );
                }
              },
              child: const Text('Save Activity'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final leadProvider = Provider.of<LeadProvider>(context);
    final user = Provider.of<AuthProvider>(context).currentUser;

    final myLeads = leadProvider.rawLeads.where((l) => l.assignedTo == user?.name || l.createdBy == user?.email).toList();
    final activeFollowups = myLeads.where((l) => l.status != 'Not Interested' && l.status != 'Unqualified' && l.status != 'Closed').toList();

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        cross: CrossAxisAlignment.start,
        children: [
          Card(
            color: AppColors.secondary,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 22,
                    backgroundColor: AppColors.primary,
                    child: Icon(Icons.phone_in_talk, color: Colors.white, size: 22),
                  ),
                  const SizedBox(width: 14),
                  Column(
                    cross: CrossAxisAlignment.start,
                    children: [
                      const Text('Sales Daily Follow-up Workspace', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                      Text('Target: $_dailyTarget Completed Follow-ups / Working Day', style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
                    ],
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(color: AppColors.success.withOpacity(0.2), borderRadius: BorderRadius.circular(20)),
                    child: const Text('On Track', style: TextStyle(color: AppColors.success, fontWeight: FontWeight.bold, fontSize: 12)),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          Expanded(
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  cross: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Pending & Scheduled Follow-ups (${activeFollowups.length})', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                        StatusBadge(label: 'Min Target: $_dailyTarget/day'),
                      ],
                    ),
                    const Divider(height: 24),
                    Expanded(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: SingleChildScrollView(
                          child: DataTable(
                            columns: const [
                              DataColumn(label: Text('Lead ID', style: TextStyle(fontWeight: FontWeight.bold))),
                              DataColumn(label: Text('Lead Name', style: TextStyle(fontWeight: FontWeight.bold))),
                              DataColumn(label: Text('Phone', style: TextStyle(fontWeight: FontWeight.bold))),
                              DataColumn(label: Text('Course Interested', style: TextStyle(fontWeight: FontWeight.bold))),
                              DataColumn(label: Text('Next Due Date', style: TextStyle(fontWeight: FontWeight.bold))),
                              DataColumn(label: Text('Current Stage', style: TextStyle(fontWeight: FontWeight.bold))),
                              DataColumn(label: Text('WhatsApp Action', style: TextStyle(fontWeight: FontWeight.bold))),
                              DataColumn(label: Text('Log Follow-up', style: TextStyle(fontWeight: FontWeight.bold))),
                            ],
                            rows: activeFollowups.map((l) {
                              return DataRow(cells: [
                                DataCell(Text(l.leadId, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary))),
                                DataCell(Text(l.name, style: const TextStyle(fontWeight: FontWeight.bold))),
                                DataCell(Text(l.phone)),
                                DataCell(Text(l.courseInterested)),
                                DataCell(Text(l.nextFollowup, style: const TextStyle(color: AppColors.danger, fontWeight: FontWeight.bold))),
                                DataCell(StatusBadge(label: l.status)),
                                DataCell(
                                  IconButton(
                                    icon: const Icon(Icons.chat, color: AppColors.success, size: 20),
                                    onPressed: () => _launchWhatsApp(l),
                                    tooltip: 'Send "Hello ${l.name}" via WhatsApp',
                                  ),
                                ),
                                DataCell(
                                  ElevatedButton.icon(
                                    style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6)),
                                    onPressed: () => _showRecordFollowupDialog(l),
                                    icon: const Icon(Icons.edit_note, size: 16),
                                    label: const Text('Log Activity', style: TextStyle(fontSize: 11)),
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
              ),
            ),
          ),
        ],
      ),
    );
  }
}
