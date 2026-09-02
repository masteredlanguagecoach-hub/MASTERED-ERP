class CourseModel {
  final String courseId;
  final String courseName;
  final String duration;
  final double defaultTotalFee;
  final int defaultInstallmentCount;
  final String status;
  final String createdAt;

  CourseModel({
    required this.courseId,
    required this.courseName,
    required this.duration,
    required this.defaultTotalFee,
    required this.defaultInstallmentCount,
    required this.status,
    required this.createdAt,
  });

  factory CourseModel.fromJson(Map<String, dynamic> json) {
    return CourseModel(
      courseId: json['course_id']?.toString() ?? '',
      courseName: json['course_name']?.toString() ?? '',
      duration: json['duration']?.toString() ?? '',
      defaultTotalFee: double.tryParse(json['default_total_fee']?.toString() ?? '0') ?? 0.0,
      defaultInstallmentCount: int.tryParse(json['default_installment_count']?.toString() ?? '4') ?? 4,
      status: json['status']?.toString() ?? 'ACTIVE',
      createdAt: json['created_at']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'course_id': courseId,
      'course_name': courseName,
      'duration': duration,
      'default_total_fee': defaultTotalFee,
      'default_installment_count': defaultInstallmentCount,
      'status': status,
      'created_at': createdAt,
    };
  }
}
