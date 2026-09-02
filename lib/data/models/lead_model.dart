class LeadModel {
  final String leadId;
  final String date;
  final String name;
  final String phone;
  final String whatsapp;
  final String email;
  final String city;
  final String courseInterested;
  final String source;
  final String assignedTo;
  final String status;
  final String nextFollowup;
  final String remarks;
  final String createdBy;
  final String updatedAt;

  LeadModel({
    required this.leadId,
    required this.date,
    required this.name,
    required this.phone,
    required this.whatsapp,
    required this.email,
    required this.city,
    required this.courseInterested,
    required this.source,
    required this.assignedTo,
    required this.status,
    required this.nextFollowup,
    required this.remarks,
    required this.createdBy,
    required this.updatedAt,
  });

  factory LeadModel.fromJson(Map<String, dynamic> json) {
    return LeadModel(
      leadId: json['lead_id']?.toString() ?? '',
      date: json['date']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      whatsapp: json['whatsapp']?.toString() ?? json['phone']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      city: json['city']?.toString() ?? '',
      courseInterested: json['course_interested']?.toString() ?? '',
      source: json['source']?.toString() ?? 'Direct',
      assignedTo: json['assigned_to']?.toString() ?? 'Unassigned',
      status: json['status']?.toString() ?? 'New',
      nextFollowup: json['next_followup']?.toString() ?? '',
      remarks: json['remarks']?.toString() ?? '',
      createdBy: json['created_by']?.toString() ?? '',
      updatedAt: json['updated_at']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'lead_id': leadId,
      'date': date,
      'name': name,
      'phone': phone,
      'whatsapp': whatsapp,
      'email': email,
      'city': city,
      'course_interested': courseInterested,
      'source': source,
      'assigned_to': assignedTo,
      'status': status,
      'next_followup': nextFollowup,
      'remarks': remarks,
      'created_by': createdBy,
      'updated_at': updatedAt,
    };
  }
}
