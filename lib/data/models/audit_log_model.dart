class AuditLogModel {
  final String logId;
  final String timestamp;
  final String userId;
  final String userName;
  final String action;
  final String module;
  final String details;

  AuditLogModel({
    required this.logId,
    required this.timestamp,
    required this.userId,
    required this.userName,
    required this.action,
    required this.module,
    required this.details,
  });

  factory AuditLogModel.fromJson(Map<String, dynamic> json) {
    return AuditLogModel(
      logId: json['log_id']?.toString() ?? '',
      timestamp: json['timestamp']?.toString() ?? '',
      userId: json['user_id']?.toString() ?? '',
      userName: json['user_name']?.toString() ?? '',
      action: json['action']?.toString() ?? '',
      module: json['module']?.toString() ?? '',
      details: json['details']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'log_id': logId,
      'timestamp': timestamp,
      'user_id': userId,
      'user_name': userName,
      'action': action,
      'module': module,
      'details': details,
    };
  }
}
