import 'package:flutter/material.dart';
import '../services/task_service.dart';
import '../widgets/task_card.dart';
import '../widgets/task_dialog.dart';

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  final TasksService service = TasksService();

  void showTaskDialog({String? taskId, String? title, bool? isDone}) {
    showDialog(
      context: context,
      builder: (_) {
        return TaskDialog(
          firebaseTaskId: taskId,
          title: title,
          isDone: isDone,
          onTaskSaved: (newTitle, done, date) async {
            if (taskId == null) {
              await service.addTask(newTitle, done, date);
            } else {
              await service.updateTask(taskId, newTitle, done, date);
            }
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey[100],
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  "Tasks",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
              ),

              Expanded(
                child: StreamBuilder<List<Map<String, dynamic>>>(
                  stream: service.getTasksStream(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (snapshot.hasError) {
                      return Center(
                        child: Text(
                          "Error: ${snapshot.error}",
                          style: const TextStyle(color: Colors.red),
                        ),
                      );
                    }

                    final tasks = snapshot.data ?? [];

                    if (tasks.isEmpty) {
                      return const Center(child: Text("No tasks available"));
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.all(12),
                      itemCount: tasks.length,
                      itemBuilder: (context, index) {
                        final task = tasks[index];

                        return TaskCard(
                          task: task,
                          onDelete: () async {
                            await service.deleteTask(task["id"]);
                          },
                          onEdit: () {
                            showTaskDialog(
                              taskId: task["id"],
                              title: task["title"],
                              isDone: task["isDone"],
                            );
                          },
                          onToggle: (val) async {
                            await service.toggleDone(task["id"], val);
                          },
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),

          // Floating Button
          Positioned(
            bottom: 20,
            right: 20,
            child: FloatingActionButton(
              onPressed: () => showTaskDialog(),
              backgroundColor: Colors.white,
              child: const Icon(Icons.add, color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }
}
