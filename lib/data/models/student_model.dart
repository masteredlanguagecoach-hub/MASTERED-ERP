class StudentModel {
  final String studentId;
  final String admissionNo;
  final String admissionDate;
  final String name;
  final String phone;
  final String email;
  final String course;
  final double totalFee;
  final double paidFee;
  final double balanceFee;
  final String status;
  final String driveFolderId;
  final String leadId;
  final String batchId;
  final String batchName;
  final String feeDueDate;
  final String convertedByExecutive;
  final String createdAt;

  StudentModel({
    required this.studentId,
    required this.admissionNo,
    required this.admissionDate,
    required this.name,
    required this.phone,
    required this.email,
    required this.course,
    required this.totalFee,
    required this.paidFee,
    required this.balanceFee,
    required this.status,
    required this.driveFolderId,
    required this.leadId,
    this.batchId = 'BTC-101',
    this.batchName = 'Batch 2026-A',
    this.feeDueDate = '2026-09-15',
    this.convertedByExecutive = 'salesexec@mastered.com',
    required this.createdAt,
  });

  factory StudentModel.fromJson(Map<String, dynamic> json) {
    return StudentModel(
      studentId: json['student_id']?.toString() ?? '',
      admissionNo: json['admission_no']?.toString() ?? '',
      admissionDate: json['admission_date']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      course: json['course']?.toString() ?? '',
      totalFee: double.tryParse(json['total_fee']?.toString() ?? '0') ?? 0.0,
      paidFee: double.tryParse(json['paid_fee']?.toString() ?? '0') ?? 0.0,
      balanceFee: double.tryParse(json['balance_fee']?.toString() ?? '0') ?? 0.0,
      status: json['status']?.toString() ?? 'ACTIVE',
      driveFolderId: json['drive_folder_id']?.toString() ?? '',
      leadId: json['lead_id']?.toString() ?? '',
      batchId: json['batch_id']?.toString() ?? 'BTC-101',
      batchName: json['batch_name']?.toString() ?? 'Batch 2026-A',
      feeDueDate: json['fee_due_date']?.toString() ?? '2026-09-15',
      convertedByExecutive: json['converted_by_executive']?.toString() ?? 'salesexec@mastered.com',
      createdAt: json['created_at']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'student_id': studentId,
      'admission_no': admissionNo,
      'admission_date': admissionDate,
      'name': name,
      'phone': phone,
      'email': email,
      'course': course,
      'total_fee': totalFee,
      'paid_fee': paidFee,
      'balance_fee': balanceFee,
      'status': status,
      'drive_folder_id': driveFolderId,
      'lead_id': leadId,
      'batch_id': batchId,
      'batch_name': batchName,
      'fee_due_date': feeDueDate,
      'converted_by_executive': convertedByExecutive,
      'created_at': createdAt,
    };
  }
}
