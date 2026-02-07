import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TaskDialog extends StatefulWidget {
  final String? firebaseTaskId;
  final String? title;
  final bool? isDone;

  final Function(String title, bool isDone, String date) onTaskSaved;

  const TaskDialog({
    super.key,
    this.firebaseTaskId,
    this.title,
    this.isDone,
    required this.onTaskSaved,
  });

  @override
  State<TaskDialog> createState() => _TaskDialogState();
}

class _TaskDialogState extends State<TaskDialog> {
  final titleController = TextEditingController();
  bool doneValue = false;

  @override
  void initState() {
    super.initState();
    titleController.text = widget.title ?? "";
    doneValue = widget.isDone ?? false;
  }

  @override
  void dispose() {
    titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentDate = DateFormat('E d MMM').format(DateTime.now());

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(widget.firebaseTaskId == null ? "Add Task" : "Edit Task"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(currentDate, style: const TextStyle(color: Colors.grey)),
          const SizedBox(height: 12),

          TextField(
            controller: titleController,
            decoration: const InputDecoration(
              labelText: "Task Title",
              border: OutlineInputBorder(),
            ),
          ),

          const SizedBox(height: 12),

          Row(
            children: [
              Checkbox(
                value: doneValue,
                onChanged: (val) {
                  setState(() => doneValue = val ?? false);
                },
              ),
              const Text("Mark as Done"),
            ],
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Cancel"),
        ),
        ElevatedButton(
          onPressed: () async {
            final newTitle = titleController.text.trim();
            if (newTitle.isEmpty) return;

            await widget.onTaskSaved(newTitle, doneValue, currentDate);
            Navigator.pop(context);
          },
          child: const Text("Save"),
        ),
      ],
    );
  }
}
