class SessionModel {
  final String sessionToken;
  final String userId;
  final String name;
  final String email;
  final String role;
  final bool mustChangePassword;

  SessionModel({
    required this.sessionToken,
    required this.userId,
    required this.name,
    required this.email,
    required this.role,
    this.mustChangePassword = false,
  });

  factory SessionModel.fromJson(Map<String, dynamic> json) {
    return SessionModel(
      sessionToken: json['sessionToken'] ?? '',
      userId: json['userId'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? '',
      mustChangePassword: json['mustChangePassword'] == true || json['mustChangePassword'] == 'TRUE',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sessionToken': sessionToken,
      'userId': userId,
      'name': name,
      'email': email,
      'role': role,
      'mustChangePassword': mustChangePassword,
    };
  }
}
