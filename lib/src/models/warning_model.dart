class WarningModel {
  final String? id;
  final String title;
  final String description;
  final String severity;
  final DateTime timestamp;
  final bool active;

  WarningModel({
    this.id,
    required this.title,
    required this.description,
    required this.severity,
    required this.timestamp,
    required this.active,
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'severity': severity,
      'timestamp': timestamp.toUtc(),
      'active': active,
    };
  }

  factory WarningModel.fromMap(String id, Map<String, dynamic> map) {
    return WarningModel(
      id: id,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      severity: map['severity'] ?? 'info',
      timestamp: (map['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now().toUtc(),
      active: map['active'] ?? true,
    );
  }
}
