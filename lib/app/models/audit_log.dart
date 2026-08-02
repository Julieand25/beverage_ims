class AuditLog {
  final String id;
  final String userId;
  final String userName;
  final String action;
  final String targetType;
  final String? targetId;
  final Map<String, dynamic> details;
  final DateTime timestamp;

  const AuditLog({
    this.id = '',
    required this.userId,
    required this.userName,
    required this.action,
    required this.targetType,
    this.targetId,
    this.details = const {},
    required this.timestamp,
  });

  factory AuditLog.fromJson(Map<String, dynamic> json) => AuditLog(
        id: json['id'] as String,
        userId: json['user_id'] as String,
        userName: json['user_name'] as String,
        action: json['action'] as String,
        targetType: json['target_type'] as String,
        targetId: json['target_id'] as String?,
        details: json['details'] is Map
            ? Map<String, dynamic>.from(json['details'] as Map)
            : {},
        timestamp: DateTime.parse(json['timestamp'] as String),
      );

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{
      'user_id': userId,
      'user_name': userName,
      'action': action,
      'target_type': targetType,
      'details': details,
      'timestamp': timestamp.toIso8601String(),
    };
    if (targetId != null) json['target_id'] = targetId;
    return json;
  }
}
