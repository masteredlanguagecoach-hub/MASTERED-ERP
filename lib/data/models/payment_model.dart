class PaymentModel {
  final String paymentId;
  final String receiptNo;
  final String date;
  final String studentId;
  final String studentName;
  final double amount;
  final String paymentMode;
  final String remarks;
  final String driveFileId;
  final String createdBy;
  final String createdAt;

  PaymentModel({
    required this.paymentId,
    required this.receiptNo,
    required this.date,
    required this.studentId,
    required this.studentName,
    required this.amount,
    required this.paymentMode,
    required this.remarks,
    required this.driveFileId,
    required this.createdBy,
    required this.createdAt,
  });

  factory PaymentModel.fromJson(Map<String, dynamic> json) {
    return PaymentModel(
      paymentId: json['payment_id']?.toString() ?? '',
      receiptNo: json['receipt_no']?.toString() ?? '',
      date: json['date']?.toString() ?? '',
      studentId: json['student_id']?.toString() ?? '',
      studentName: json['student_name']?.toString() ?? '',
      amount: double.tryParse(json['amount']?.toString() ?? '0') ?? 0.0,
      paymentMode: json['payment_mode']?.toString() ?? 'Cash',
      remarks: json['remarks']?.toString() ?? '',
      driveFileId: json['drive_file_id']?.toString() ?? '',
      createdBy: json['created_by']?.toString() ?? '',
      createdAt: json['created_at']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'payment_id': paymentId,
      'receipt_no': receiptNo,
      'date': date,
      'student_id': studentId,
      'student_name': studentName,
      'amount': amount,
      'payment_mode': paymentMode,
      'remarks': remarks,
      'drive_file_id': driveFileId,
      'created_by': createdBy,
      'created_at': createdAt,
    };
  }
}
