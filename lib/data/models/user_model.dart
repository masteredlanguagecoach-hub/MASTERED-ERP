class UserModel {
  final String userId;
  final String name;
  final String email;
  final String role;
  final String status;
  final String phone;
  final String createdAt;

  UserModel({
    required this.userId,
    required this.name,
    required this.email,
    required this.role,
    required this.status,
    required this.phone,
    required this.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      userId: json['user_id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      role: json['role']?.toString() ?? 'SALES_EXECUTIVE',
      status: json['status']?.toString() ?? 'ACTIVE',
      phone: json['phone']?.toString() ?? '',
      createdAt: json['created_at']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'name': name,
      'email': email,
      'role': role,
      'status': status,
      'phone': phone,
      'created_at': createdAt,
    };
  }
}
