class Task {
  final String id;
  final String title;
  bool completed;
  final String user;
  final DateTime createdAt;

  Task({
    required this.id,
    required this.title,
    this.completed = false,
    required this.user,
    required this.createdAt,
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['_id'],
      title: json['title'],
      completed: json['completed'] ?? false,
      user: json['user'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
} 