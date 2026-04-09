import 'package:flutter/material.dart';

import '../models/task.dart';
import '../services/task_service.dart';
import '../widgets/task_card.dart';

class TaskListScreen extends StatefulWidget {
  const TaskListScreen({
    super.key,
    required this.onToggleTheme,
  });

  final VoidCallback onToggleTheme;

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  final TaskService _taskService = TaskService();
  final TextEditingController _taskController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();

  String _priority = 'Medium';
  String _searchQuery = '';

  @override
  void dispose() {
    _taskController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _addTask() async {
    final title = _taskController.text.trim();

    if (title.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Task title cannot be empty.'),
        ),
      );
      return;
    }

    await _taskService.addTask(
      title: title,
      priority: _priority,
    );

    _taskController.clear();

    if (!mounted) return;
    FocusScope.of(context).unfocus();
  }

  List<Task> _filterTasks(List<Task> tasks) {
    if (_searchQuery.trim().isEmpty) {
      return tasks;
    }

    final query = _searchQuery.toLowerCase();
    return tasks.where((task) {
      final titleMatch = task.title.toLowerCase().contains(query);
      final subtaskMatch = task.subtasks.any(
        (subtask) =>
            (subtask['title'] ?? '').toString().toLowerCase().contains(query),
      );
      return titleMatch || subtaskMatch;
    }).toList();
  }

  int _calculateXP(List<Task> tasks) {
    int xp = 0;
    for (final task in tasks) {
      if (task.isCompleted) {
        xp += 20;
      }
      xp += task.completedSubtaskCount * 5;
    }
    return xp;
  }

  String _levelLabel(int xp) {
    final level = (xp ~/ 50) + 1;
    return 'Level $level';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Level Up Life'),
        actions: [
          IconButton(
            tooltip: 'Toggle theme',
            onPressed: widget.onToggleTheme,
            icon: const Icon(Icons.dark_mode_outlined),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            _buildTopPanel(),
            Expanded(
              child: StreamBuilder<List<Task>>(
                stream: _taskService.streamTasks(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Text(
                          'Something went wrong:\n${snapshot.error}',
                          textAlign: TextAlign.center,
                        ),
                      ),
                    );
                  }

                  final tasks = snapshot.data ?? [];
                  final filteredTasks = _filterTasks(tasks);
                  final completedTasks =
                      tasks.where((task) => task.isCompleted).length;
                  final xp = _calculateXP(tasks);

                  if (tasks.isEmpty) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(24),
                        child: Text(
                          'No tasks yet — add one above!',
                          textAlign: TextAlign.center,
                        ),
                      ),
                    );
                  }

                  return Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                        child: Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _levelLabel(xp),
                                  style: Theme.of(context).textTheme.titleLarge,
                                ),
                                const SizedBox(height: 8),
                                Text('XP: $xp'),
                                const SizedBox(height: 8),
                                LinearProgressIndicator(
                                  value: tasks.isEmpty
                                      ? 0
                                      : completedTasks / tasks.length,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Completed $completedTasks of ${tasks.length} main tasks',
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      if (filteredTasks.isEmpty)
                        const Expanded(
                          child: Center(
                            child: Padding(
                              padding: EdgeInsets.all(24),
                              child: Text(
                                'No tasks match your search.',
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        )
                      else
                        Expanded(
                          child: ListView.builder(
                            padding: const EdgeInsets.fromLTRB(12, 0, 12, 16),
                            itemCount: filteredTasks.length,
                            itemBuilder: (context, index) {
                              final task = filteredTasks[index];
                              return TaskCard(
                                task: task,
                                onToggleTask: () => _taskService.toggleTask(task),
                                onDeleteTask: () => _showDeleteDialog(task),
                                onAddSubtask: (title) => _taskService.addSubtask(
                                  task: task,
                                  subtaskTitle: title,
                                ),
                                onToggleSubtask: (subtaskIndex) =>
                                    _taskService.toggleSubtask(
                                  task: task,
                                  index: subtaskIndex,
                                ),
                                onRemoveSubtask: (subtaskIndex) =>
                                    _taskService.removeSubtask(
                                  task: task,
                                  index: subtaskIndex,
                                ),
                              );
                            },
                          ),
                        ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addTask,
        icon: const Icon(Icons.add),
        label: const Text('Add Task'),
      ),
    );
  }

  Widget _buildTopPanel() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Column(
        children: [
          TextField(
            controller: _taskController,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _addTask(),
            decoration: const InputDecoration(
              labelText: 'New quest',
              hintText: 'Enter a task title',
              prefixIcon: Icon(Icons.task_alt),
            ),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: _priority,
            decoration: const InputDecoration(
              labelText: 'Priority',
              prefixIcon: Icon(Icons.flag_outlined),
            ),
            items: const [
              DropdownMenuItem(value: 'Low', child: Text('Low')),
              DropdownMenuItem(value: 'Medium', child: Text('Medium')),
              DropdownMenuItem(value: 'High', child: Text('High')),
            ],
            onChanged: (value) {
              if (value == null) return;
              setState(() {
                _priority = value;
              });
            },
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _searchController,
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
            decoration: InputDecoration(
              labelText: 'Search tasks or subtasks',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchController.text.isEmpty
                  ? null
                  : IconButton(
                      onPressed: () {
                        _searchController.clear();
                        setState(() {
                          _searchQuery = '';
                        });
                      },
                      icon: const Icon(Icons.clear),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showDeleteDialog(Task task) async {
    final shouldDelete = await showDialog<bool>(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('Delete task?'),
              content: Text('Delete "${task.title}" permanently?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text('Delete'),
                ),
              ],
            );
          },
        ) ??
        false;

    if (shouldDelete) {
      await _taskService.deleteTask(task.id);
    }
  }
}