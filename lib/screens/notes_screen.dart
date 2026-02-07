import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:taskify/services/notes_service.dart';
import 'package:taskify/widgets/note_card.dart';
import '../widgets/note_dialog.dart';

class NotesScreen extends StatefulWidget {
  const NotesScreen({super.key});

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  final NotesRealtimeService _notesService = NotesRealtimeService();

  final List<Color> noteColors = [
    Colors.white,
    Colors.yellowAccent,
    Colors.greenAccent,
    Colors.blueAccent,
    Colors.pinkAccent,
    Colors.purpleAccent,
    Colors.redAccent,
    Colors.orangeAccent,
    Colors.cyanAccent,
    Colors.tealAccent,
    Colors.indigoAccent,
    Colors.brown,
    Colors.grey,
    Colors.limeAccent,
  ];

  String get uid => FirebaseAuth.instance.currentUser!.uid;

  void showNoteDialog({
    String? noteId,
    String? title,
    String? content,
    int colorIndex = 0,
  }) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return NoteDialog(
          noteColors: noteColors,
          firebaseNoteId: noteId,
          title: title,
          content: content,
          colorIndex: colorIndex,
          onNoteSaved:
              (
                newDescription,
                newTitle,
                selectedColorIndex,
                currentDate,
              ) async {
                if (noteId == null) {
                  await _notesService.addNote(
                    uid: uid,
                    title: newTitle,
                    description: newDescription,
                    color: selectedColorIndex,
                  );
                } else {
                  await _notesService.updateNote(
                    uid: uid,
                    noteId: noteId,
                    title: newTitle,
                    description: newDescription,
                    color: selectedColorIndex,
                  );
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
                  "Notes",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
              ),

              Expanded(
                child: StreamBuilder<List<Map<String, dynamic>>>(
                  stream: _notesService.getNotesStream(uid),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (snapshot.hasError) {
                      return Center(child: Text("Error: ${snapshot.error}"));
                    }

                    final notes = snapshot.data ?? [];

                    if (notes.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.note_outlined,
                              size: 80,
                              color: Colors.grey[600],
                            ),
                            const SizedBox(height: 20),
                            Text(
                              "No notes available",
                              style: TextStyle(
                                fontSize: 20,
                                color: Colors.grey[500],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    return Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: GridView.builder(
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                              childAspectRatio: 0.85,
                            ),
                        itemCount: notes.length,
                        itemBuilder: (context, index) {
                          final note = notes[index];

                          return NoteCard(
                            note: note,
                            noteColors: noteColors,
                            onDelete: () async {
                              await _notesService.deleteNote(
                                uid: uid,
                                noteId: note["id"],
                              );
                            },
                            onTap: () {
                              showNoteDialog(
                                noteId: note["id"],
                                title: note["title"],
                                content: note["description"],
                                colorIndex: note["color"] ?? 0,
                              );
                            },
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),

          Positioned(
            bottom: 20,
            right: 20,
            child: FloatingActionButton(
              onPressed: () => showNoteDialog(),
              backgroundColor: Colors.white,
              child: const Icon(Icons.add, color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }
}
