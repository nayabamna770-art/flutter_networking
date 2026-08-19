class TodoModel {
  final String id;
  final String userId;
  final String title;
  final bool isCompleted;
  final DateTime createdAt;

  TodoModel({
    required this.id,
    required this.userId,
    required this.title,
    this.isCompleted = false,
    required this.createdAt,
  });

  /// Creates a [TodoModel] from a Supabase row (JSON map).
  factory TodoModel.fromJson(Map<String, dynamic> json) {
    return TodoModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      title: json['title'] as String,
      isCompleted: json['is_completed'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  /// Converts this model to a map suitable for Supabase insert / update.
  /// Omit [id] and [createdAt] on insert — Supabase generates them automatically.
  Map<String, dynamic> toJson({bool includeId = false}) {
    return {
      if (includeId) 'id': id,
      'user_id': userId,
      'title': title,
      'is_completed': isCompleted,
    };
  }

  /// Returns a copy with updated fields.
  TodoModel copyWith({
    String? id,
    String? userId,
    String? title,
    bool? isCompleted,
    DateTime? createdAt,
  }) {
    return TodoModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}