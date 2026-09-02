class ExpenseModel {
  final String expenseId;
  final String date;
  final String category;
  final String description;
  final double amount;
  final String paymentMode;
  final String billDriveFileId;
  final String createdBy;
  final String createdAt;

  ExpenseModel({
    required this.expenseId,
    required this.date,
    required this.category,
    required this.description,
    required this.amount,
    required this.paymentMode,
    required this.billDriveFileId,
    required this.createdBy,
    required this.createdAt,
  });

  factory ExpenseModel.fromJson(Map<String, dynamic> json) {
    return ExpenseModel(
      expenseId: json['expense_id']?.toString() ?? '',
      date: json['date']?.toString() ?? '',
      category: json['category']?.toString() ?? 'Other',
      description: json['description']?.toString() ?? '',
      amount: double.tryParse(json['amount']?.toString() ?? '0') ?? 0.0,
      paymentMode: json['payment_mode']?.toString() ?? 'Cash',
      billDriveFileId: json['bill_drive_file_id']?.toString() ?? '',
      createdBy: json['created_by']?.toString() ?? '',
      createdAt: json['created_at']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'expense_id': expenseId,
      'date': date,
      'category': category,
      'description': description,
      'amount': amount,
      'payment_mode': paymentMode,
      'bill_drive_file_id': billDriveFileId,
      'created_by': createdBy,
      'created_at': createdAt,
    };
  }
}
