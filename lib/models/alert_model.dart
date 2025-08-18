class WeatherAlert {
  final String id;
  final String title;
  final String message;
  final String author;
  final DateTime createdAt;

  WeatherAlert({
    required this.id,
    required this.title,
    required this.message,
    required this.author,
    required this.createdAt,
  });

  factory WeatherAlert.fromJson(Map<String, dynamic> json) {
    return WeatherAlert(
      id: json['id'] as String,
      title: json['title'] as String,
      message: json['message'] as String,
      author: json['author'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'message': message,
        'author': author,
        'createdAt': createdAt.toIso8601String(),
      };
}
