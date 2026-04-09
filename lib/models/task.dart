import 'package:cloud_firestore/cloud_firestore.dart';

class Task {
  final String id;
  final String title;
  final bool isCompleted;
  final String priority;
  final List<Map<String, dynamic>> subtasks;
  final DateTime createdAt;

  const Task({
    required this.id,
    required this.title,
    required this.isCompleted,
    required this.priority,
    required this.subtasks,
    required this.createdAt,
  });

  factory Task.create({
    required String title,
    required String priority,
  }) {
    return Task(
      id: '',
      title: title,
      isCompleted: false,
      priority: priority,
      subtasks: const [],
      createdAt: DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'isCompleted': isCompleted,
      'priority': priority,
      'subtasks': subtasks,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory Task.fromMap(String id, Map<String, dynamic> data) {
    final rawCreatedAt = data['createdAt'];
    DateTime parsedCreatedAt = DateTime.now();

    if (rawCreatedAt is Timestamp) {
      parsedCreatedAt = rawCreatedAt.toDate();
    } else if (rawCreatedAt is String) {
      parsedCreatedAt = DateTime.tryParse(rawCreatedAt) ?? DateTime.now();
    }

    final rawSubtasks = data['subtasks'];
    final subtasks = rawSubtasks is List
        ? rawSubtasks
            .map(
              (item) => Map<String, dynamic>.from(item as Map),
            )
            .toList()
        : <Map<String, dynamic>>[];

    return Task(
      id: id,
      title: (data['title'] ?? '') as String,
      isCompleted: (data['isCompleted'] ?? false) as bool,
      priority: (data['priority'] ?? 'Medium') as String,
      subtasks: subtasks,
      createdAt: parsedCreatedAt,
    );
  }

  Task copyWith({
    String? id,
    String? title,
    bool? isCompleted,
    String? priority,
    List<Map<String, dynamic>>? subtasks,
    DateTime? createdAt,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      isCompleted: isCompleted ?? this.isCompleted,
      priority: priority ?? this.priority,
      subtasks: subtasks ?? this.subtasks,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  int get completedSubtaskCount {
    return subtasks.where((subtask) => (subtask['done'] ?? false) == true).length;
  }

  int get totalSubtaskCount => subtasks.length;

  double get progress {
    if (isCompleted) {
      return 1.0;
    }
    if (subtasks.isEmpty) {
      return isCompleted ? 1.0 : 0.0;
    }
    return completedSubtaskCount / subtasks.length;
  }
}