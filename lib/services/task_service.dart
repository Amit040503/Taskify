import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class TasksService {
  final _db = FirebaseDatabase.instance.ref();
  final _auth = FirebaseAuth.instance;

  String get _uid => _auth.currentUser!.uid;

  DatabaseReference get _tasksRef =>
      _db.child("users").child(_uid).child("tasks");

  Future<void> addTask(String title, bool isDone, String date) async {
    final newRef = _tasksRef.push();

    await newRef.set({
      "title": title,
      "isDone": isDone,
      "date": date,
      "createdAt": ServerValue.timestamp,
    });
  }

  Future<void> updateTask(
    String taskId,
    String title,
    bool isDone,
    String date,
  ) async {
    await _tasksRef.child(taskId).update({
      "title": title,
      "isDone": isDone,
      "date": date,
    });
  }

  Future<void> toggleDone(String taskId, bool isDone) async {
    await _tasksRef.child(taskId).update({"isDone": isDone});
  }

  Future<void> deleteTask(String taskId) async {
    await _tasksRef.child(taskId).remove();
  }

  Stream<List<Map<String, dynamic>>> getTasksStream() {
    return _tasksRef.onValue.map((event) {
      final snapshot = event.snapshot;

      if (!snapshot.exists || snapshot.value == null) return [];

      final raw = snapshot.value;

      final data = Map<String, dynamic>.from(raw as Map);

      final tasks = data.entries.map((e) {
        final taskMap = Map<String, dynamic>.from(e.value);
        taskMap["id"] = e.key;
        return taskMap;
      }).toList();

      tasks.sort(
        (a, b) => (b["createdAt"] ?? 0).compareTo(a["createdAt"] ?? 0),
      );

      return tasks;
    });
  }
}
