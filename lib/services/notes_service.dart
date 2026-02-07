import 'package:firebase_database/firebase_database.dart';
import 'package:uuid/uuid.dart';

class NotesRealtimeService {
  final DatabaseReference _db = FirebaseDatabase.instance.ref();

  // Add Note
  Future<void> addNote({
    required String uid,
    required String title,
    required String description,
    required int color,
  }) async {
    final noteId = const Uuid().v4();

    await _db.child("users").child(uid).child("notes").child(noteId).set({
      "id": noteId,
      "title": title,
      "description": description,
      "color": color,
      "date": DateTime.now().toIso8601String(),
    });
  }

  Stream<List<Map<String, dynamic>>> getNotesStream(String uid) {
    final ref = _db.child("users").child(uid).child("notes");

    return ref.onValue.map((event) {
      final data = event.snapshot.value;

      if (data == null) return [];

      final notesMap = Map<String, dynamic>.from(data as Map);

      final notesList = notesMap.values.map((note) {
        return Map<String, dynamic>.from(note);
      }).toList();

      notesList.sort((a, b) => (b["date"] ?? "").compareTo(a["date"] ?? ""));

      return notesList;
    });
  }

  //  Update Note
  Future<void> updateNote({
    required String uid,
    required String noteId,
    required String title,
    required String description,
    required int color,
  }) async {
    await _db.child("users").child(uid).child("notes").child(noteId).update({
      "title": title,
      "description": description,
      "color": color,
      "date": DateTime.now().toIso8601String(),
    });
  }

  // Delete Note
  Future<void> deleteNote({required String uid, required String noteId}) async {
    await _db.child("users").child(uid).child("notes").child(noteId).remove();
  }
}
