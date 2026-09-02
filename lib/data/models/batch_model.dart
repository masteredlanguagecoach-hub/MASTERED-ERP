class BatchModel {
  final String batchId;
  final String batchName;
  final String course;
  final String startDate;
  final String schedule;
  final String trainer;
  final String status;
  final String createdAt;

  BatchModel({
    required this.batchId,
    required this.batchName,
    required this.course,
    required this.startDate,
    required this.schedule,
    required this.trainer,
    required this.status,
    required this.createdAt,
  });

  factory BatchModel.fromJson(Map<String, dynamic> json) {
    return BatchModel(
      batchId: json['batch_id']?.toString() ?? '',
      batchName: json['batch_name']?.toString() ?? '',
      course: json['course']?.toString() ?? '',
      startDate: json['start_date']?.toString() ?? '',
      schedule: json['schedule']?.toString() ?? '',
      trainer: json['trainer']?.toString() ?? '',
      status: json['status']?.toString() ?? 'ACTIVE',
      createdAt: json['created_at']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'batch_id': batchId,
      'batch_name': batchName,
      'course': course,
      'start_date': startDate,
      'schedule': schedule,
      'trainer': trainer,
      'status': status,
      'created_at': createdAt,
    };
  }
}
