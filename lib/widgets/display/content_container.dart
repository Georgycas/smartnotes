import 'package:flutter/material.dart';
import '../../database/models/note_model.dart';
import 'note_list_item.dart';

class ContentContainer extends StatelessWidget {
  final List<Note> items;
  final Function(Note) onArchive;
  final Function(Note) onDelete;
  final Function(Note)? onTap; // 👈 NEW: for opening editor

  const ContentContainer({
    super.key,
    required this.items,
    required this.onArchive,
    required this.onDelete,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.sticky_note_2_outlined, size: 64, color: Colors.grey),
            SizedBox(height: 12),
            Text("No notes yet!", style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(8.0),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final note = items[index];
        return NoteListItem(
          note: note,
          onArchive: onArchive,
          onDelete: onDelete,
          onTap: onTap, // 👈 Pass tap action to each item
        );
      },
    );
  }
}
