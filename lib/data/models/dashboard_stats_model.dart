import 'lead_model.dart';
import 'payment_model.dart';

class DashboardStatsModel {
  final int todayLeads;
  final int totalLeads;
  final double todayCollection;
  final double monthlyCollection;
  final double totalPendingFees;
  final double todayExpenses;
  final double monthlyExpenses;
  final int activeStudents;
  final int newAdmissions;
  final double conversionPercentage;
  final List<PaymentModel> recentPayments;
  final List<LeadModel> recentLeads;

  DashboardStatsModel({
    required this.todayLeads,
    required this.totalLeads,
    required this.todayCollection,
    required this.monthlyCollection,
    required this.totalPendingFees,
    required this.todayExpenses,
    required this.monthlyExpenses,
    required this.activeStudents,
    required this.newAdmissions,
    required this.conversionPercentage,
    required this.recentPayments,
    required this.recentLeads,
  });

  factory DashboardStatsModel.fromJson(Map<String, dynamic> json) {
    var rawPayments = json['recentPayments'] as List? ?? [];
    var rawLeads = json['recentLeads'] as List? ?? [];

    return DashboardStatsModel(
      todayLeads: json['todayLeads'] ?? 0,
      totalLeads: json['totalLeads'] ?? 0,
      todayCollection: (json['todayCollection'] ?? 0).toDouble(),
      monthlyCollection: (json['monthlyCollection'] ?? 0).toDouble(),
      totalPendingFees: (json['totalPendingFees'] ?? 0).toDouble(),
      todayExpenses: (json['todayExpenses'] ?? 0).toDouble(),
      monthlyExpenses: (json['monthlyExpenses'] ?? 0).toDouble(),
      activeStudents: json['activeStudents'] ?? 0,
      newAdmissions: json['newAdmissions'] ?? 0,
      conversionPercentage: (json['conversionPercentage'] ?? 0).toDouble(),
      recentPayments: rawPayments.map((p) => PaymentModel.fromJson(p)).toList(),
      recentLeads: rawLeads.map((l) => LeadModel.fromJson(l)).toList(),
    );
  }
}
