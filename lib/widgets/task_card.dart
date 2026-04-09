import 'package:flutter/material.dart';

import '../models/task.dart';

class TaskCard extends StatefulWidget {
  const TaskCard({
    super.key,
    required this.task,
    required this.onToggleTask,
    required this.onDeleteTask,
    required this.onAddSubtask,
    required this.onToggleSubtask,
    required this.onRemoveSubtask,
  });

  final Task task;
  final VoidCallback onToggleTask;
  final VoidCallback onDeleteTask;
  final Future<void> Function(String title) onAddSubtask;
  final Future<void> Function(int index) onToggleSubtask;
  final Future<void> Function(int index) onRemoveSubtask;

  @override
  State<TaskCard> createState() => _TaskCardState();
}

class _TaskCardState extends State<TaskCard> {
  final TextEditingController _subtaskController = TextEditingController();
  bool _expanded = false;

  @override
  void dispose() {
    _subtaskController.dispose();
    super.dispose();
  }

  Future<void> _handleAddSubtask() async {
    final title = _subtaskController.text.trim();
    if (title.isEmpty) {
      return;
    }
    await widget.onAddSubtask(title);
    _subtaskController.clear();
    if (!mounted) return;
    setState(() {
      _expanded = true;
    });
  }

  Color _priorityColor(BuildContext context) {
    switch (widget.task.priority) {
      case 'High':
        return Colors.red;
      case 'Low':
        return Colors.green;
      default:
        return Theme.of(context).colorScheme.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final task = widget.task;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
        child: Column(
          children: [
            Row(
              children: [
                Checkbox(
                  value: task.isCompleted,
                  onChanged: (_) => widget.onToggleTask(),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        task.title,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              decoration: task.isCompleted
                                  ? TextDecoration.lineThrough
                                  : null,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Chip(
                            visualDensity: VisualDensity.compact,
                            label: Text(task.priority),
                            avatar: Icon(
                              Icons.flag,
                              size: 18,
                              color: _priorityColor(context),
                            ),
                          ),
                          Text(
                            '${task.completedSubtaskCount}/${task.totalSubtaskCount} subtasks',
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      LinearProgressIndicator(value: task.progress),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: _expanded ? 'Collapse' : 'Expand',
                  onPressed: () {
                    setState(() {
                      _expanded = !_expanded;
                    });
                  },
                  icon: Icon(
                    _expanded
                        ? Icons.expand_less
                        : Icons.expand_more,
                  ),
                ),
                IconButton(
                  tooltip: 'Delete task',
                  onPressed: widget.onDeleteTask,
                  icon: const Icon(Icons.delete_outline),
                ),
              ],
            ),
            if (_expanded) ...[
              const Divider(),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _subtaskController,
                      textInputAction: TextInputAction.done,
                      onSubmitted: (_) => _handleAddSubtask(),
                      decoration: const InputDecoration(
                        hintText: 'Add subtask',
                        prefixIcon: Icon(Icons.subdirectory_arrow_right),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  FilledButton(
                    onPressed: _handleAddSubtask,
                    child: const Text('Add'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (task.subtasks.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text('No subtasks yet.'),
                  ),
                )
              else
                Column(
                  children: List.generate(task.subtasks.length, (index) {
                    final subtask = task.subtasks[index];
                    final done = (subtask['done'] ?? false) == true;
                    final title = (subtask['title'] ?? '').toString();

                    return ListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      leading: Checkbox(
                        value: done,
                        onChanged: (_) => widget.onToggleSubtask(index),
                      ),
                      title: Text(
                        title,
                        style: TextStyle(
                          decoration:
                              done ? TextDecoration.lineThrough : null,
                        ),
                      ),
                      trailing: IconButton(
                        onPressed: () => widget.onRemoveSubtask(index),
                        icon: const Icon(Icons.close),
                      ),
                    );
                  }),
                ),
            ],
          ],
        ),
      ),
    );
  }
}