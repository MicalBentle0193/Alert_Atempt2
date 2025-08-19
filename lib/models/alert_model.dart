import 'dart:convert';

class WynfordAlert {
  final String id;
  final String type; // e.g., Tornado, Severe Thunderstorm
  final String level; // Warning / Watch
  final String severity; // High / Medium / Low
  final String confidence; // High / Medium / Low
  final List<String> zipCodes;
  final String message; // custom/preset safety message
  final DateTime issuedAt;
  final Duration leadTime; // optional lead time
  final bool active;

  WynfordAlert({
    required this.id,
    required this.type,
    required this.level,
    required this.severity,
    required this.confidence,
    required this.zipCodes,
    required this.message,
    required this.issuedAt,
    required this.leadTime,
    required this.active,
  });

  factory WynfordAlert.fromMap(Map<String, dynamic> m) {
    return WynfordAlert(
      id: m['id'] as String,
      type: m['type'] as String,
      level: m['level'] as String,
      severity: m['severity'] as String,
      confidence: m['confidence'] as String,
      zipCodes: List<String>.from(m['zipCodes'] ?? []),
      message: m['message'] as String,
      issuedAt: DateTime.parse(m['issuedAt'] as String),
      leadTime: Duration(seconds: (m['leadTimeSec'] ?? 0) as int),
      active: m['active'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type,
      'level': level,
      'severity': severity,
      'confidence': confidence,
      'zipCodes': zipCodes,
      'message': message,
      'issuedAt': issuedAt.toIso8601String(),
      'leadTimeSec': leadTime.inSeconds,
      'active': active,
    };
  }

  String toJson() => jsonEncode(toMap());
}
