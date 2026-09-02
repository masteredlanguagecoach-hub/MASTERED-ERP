class FollowupModel {
  final String followupId;
  final String leadId;
  final String executiveId;
  final String executiveName;
  final String activityType;
  final String dateTime;
  final String outcomeNote;
  final String updatedStage;
  final String nextFollowupDate;
  final String createdAt;

  FollowupModel({
    required this.followupId,
    required this.leadId,
    required this.executiveId,
    required this.executiveName,
    required this.activityType,
    required this.dateTime,
    required this.outcomeNote,
    required this.updatedStage,
    required this.nextFollowupDate,
    required this.createdAt,
  });

  factory FollowupModel.fromJson(Map<String, dynamic> json) {
    return FollowupModel(
      followupId: json['followup_id']?.toString() ?? '',
      leadId: json['lead_id']?.toString() ?? '',
      executiveId: json['executive_id']?.toString() ?? '',
      executiveName: json['executive_name']?.toString() ?? '',
      activityType: json['activity_type']?.toString() ?? 'Phone Call',
      dateTime: json['date_time']?.toString() ?? '',
      outcomeNote: json['outcome_note']?.toString() ?? '',
      updatedStage: json['updated_stage']?.toString() ?? 'Follow-up',
      nextFollowupDate: json['next_followup_date']?.toString() ?? '',
      createdAt: json['created_at']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'followup_id': followupId,
      'lead_id': leadId,
      'executive_id': executiveId,
      'executive_name': executiveName,
      'activity_type': activityType,
      'date_time': dateTime,
      'outcome_note': outcomeNote,
      'updated_stage': updatedStage,
      'next_followup_date': nextFollowupDate,
      'created_at': createdAt,
    };
  }
}
