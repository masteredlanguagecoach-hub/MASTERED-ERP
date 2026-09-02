class PlacementModel {
  final String studentId;
  final String studentName;
  final String status; // Not Yet Eligible, Eligible, Interviewing, Intern, Placed, Not Seeking Placement
  final String companyName;
  final String jobTitle;
  final String placementType; // Internship, Executive, Full-Time, Part-Time, Contract, Other
  final String joiningDate;
  final double stipendSalary;
  final String remarks;
  final String updatedAt;

  PlacementModel({
    required this.studentId,
    required this.studentName,
    this.status = 'Not Yet Eligible',
    this.companyName = '',
    this.jobTitle = '',
    this.placementType = 'Full-Time',
    this.joiningDate = '',
    this.stipendSalary = 0.0,
    this.remarks = '',
    required this.updatedAt,
  });

  factory PlacementModel.fromJson(Map<String, dynamic> json) {
    return PlacementModel(
      studentId: json['student_id']?.toString() ?? '',
      studentName: json['student_name']?.toString() ?? '',
      status: json['status']?.toString() ?? 'Not Yet Eligible',
      companyName: json['company_name']?.toString() ?? '',
      jobTitle: json['job_title']?.toString() ?? '',
      placementType: json['placement_type']?.toString() ?? 'Full-Time',
      joiningDate: json['joining_date']?.toString() ?? '',
      stipendSalary: double.tryParse(json['stipend_salary']?.toString() ?? '0') ?? 0.0,
      remarks: json['remarks']?.toString() ?? '',
      updatedAt: json['updated_at']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'student_id': studentId,
      'student_name': studentName,
      'status': status,
      'company_name': companyName,
      'job_title': jobTitle,
      'placement_type': placementType,
      'joining_date': joiningDate,
      'stipend_salary': stipendSalary,
      'remarks': remarks,
      'updated_at': updatedAt,
    };
  }
}
