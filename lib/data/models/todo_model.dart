class TodoModel {
  final String id;
  final String title;
  final String description;
  final bool isCompleted;

  TodoModel({
    required this.id,
    required this.title,
    required this.description,
    this.isCompleted = false,
  });

  factory TodoModel.fromMap(Map<String, dynamic> map) {
    return TodoModel(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      isCompleted: map['is_completed'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'is_completed': isCompleted,
    };
  }
}