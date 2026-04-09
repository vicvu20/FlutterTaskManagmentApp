import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/task.dart';

class TaskService {
  TaskService();

  final CollectionReference<Map<String, dynamic>> _tasksRef =
      FirebaseFirestore.instance.collection('tasks');

  Stream<List<Task>> streamTasks() {
    return _tasksRef.orderBy('createdAt', descending: false).snapshots().map(
      (snapshot) {
        return snapshot.docs
            .map((doc) => Task.fromMap(doc.id, doc.data()))
            .toList();
      },
    );
  }

  Future<void> addTask({
    required String title,
    required String priority,
  }) async {
    final trimmed = title.trim();
    if (trimmed.isEmpty) {
      return;
    }

    final task = Task.create(
      title: trimmed,
      priority: priority,
    );

    await _tasksRef.add(task.toMap());
  }

  Future<void> toggleTask(Task task) async {
    await _tasksRef.doc(task.id).update({
      'isCompleted': !task.isCompleted,
    });
  }

  Future<void> deleteTask(String taskId) async {
    await _tasksRef.doc(taskId).delete();
  }

  Future<void> addSubtask({
    required Task task,
    required String subtaskTitle,
  }) async {
    final trimmed = subtaskTitle.trim();
    if (trimmed.isEmpty) {
      return;
    }

    final updatedSubtasks = List<Map<String, dynamic>>.from(task.subtasks)
      ..add({
        'title': trimmed,
        'done': false,
      });

    await _tasksRef.doc(task.id).update({
      'subtasks': updatedSubtasks,
    });
  }

  Future<void> removeSubtask({
    required Task task,
    required int index,
  }) async {
    final updatedSubtasks = List<Map<String, dynamic>>.from(task.subtasks);
    if (index < 0 || index >= updatedSubtasks.length) {
      return;
    }

    updatedSubtasks.removeAt(index);

    await _tasksRef.doc(task.id).update({
      'subtasks': updatedSubtasks,
    });
  }

  Future<void> toggleSubtask({
    required Task task,
    required int index,
  }) async {
    final updatedSubtasks = List<Map<String, dynamic>>.from(task.subtasks);
    if (index < 0 || index >= updatedSubtasks.length) {
      return;
    }

    final current = Map<String, dynamic>.from(updatedSubtasks[index]);
    current['done'] = !(current['done'] ?? false);

    updatedSubtasks[index] = current;

    await _tasksRef.doc(task.id).update({
      'subtasks': updatedSubtasks,
    });
  }
}