import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class NoteDialog extends StatefulWidget {
  final String? firebaseNoteId;

  final String? title;
  final String? content;
  final int? colorIndex;
  final List<Color> noteColors;

  final Function(String title, String desc, int colorIndex, String date)
  onNoteSaved;

  const NoteDialog({
    super.key,
    this.firebaseNoteId,
    this.title,
    this.content,
    this.colorIndex,
    required this.noteColors,
    required this.onNoteSaved,
  });

  @override
  State<NoteDialog> createState() => _NoteDialogState();
}

class _NoteDialogState extends State<NoteDialog> {
  late int _selectedColorIndex;

  final titleController = TextEditingController();
  final descriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _selectedColorIndex = widget.colorIndex ?? 0;

    titleController.text = widget.title ?? "";
    descriptionController.text = widget.content ?? "";
  }

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentDate = DateFormat('E d MMM').format(DateTime.now());

    return AlertDialog(
      backgroundColor: widget.noteColors[_selectedColorIndex],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text(
        widget.firebaseNoteId == null ? "Add Note" : "Edit Note",
        style: const TextStyle(color: Colors.black87),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              currentDate,
              style: const TextStyle(color: Colors.black54, fontSize: 14),
            ),
            const SizedBox(height: 16),

            TextField(
              controller: titleController,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white.withOpacity(0.5),
                labelText: 'Title',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),

            const SizedBox(height: 16),

            TextField(
              controller: descriptionController,
              maxLines: 5,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white.withOpacity(0.5),
                labelText: 'Description',
                alignLabelWithHint: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),

            const SizedBox(height: 16),

            Wrap(
              spacing: 8,
              children: List.generate(widget.noteColors.length, (index) {
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedColorIndex = index;
                    });
                  },
                  child: CircleAvatar(
                    backgroundColor: widget.noteColors[index],
                    child: _selectedColorIndex == index
                        ? const Icon(Icons.check, color: Colors.white)
                        : null,
                  ),
                );
              }),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel', style: TextStyle(color: Colors.black54)),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.black87,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onPressed: () async {
            final newTitle = titleController.text.trim();
            final newDescription = descriptionController.text.trim();

            if (newTitle.isEmpty || newDescription.isEmpty) return;

            await widget.onNoteSaved(
              newTitle,
              newDescription,
              _selectedColorIndex,
              currentDate,
            );

            Navigator.pop(context);
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}
