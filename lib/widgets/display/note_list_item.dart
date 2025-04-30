import 'package:flutter/material.dart';
import '../../database/models/note_model.dart';

class NoteListItem extends StatelessWidget {
  final Note note;
  final Function(Note) onArchive;
  final Function(Note) onDelete;
  final Function(Note)? onTap; // 👈 Tap support

  const NoteListItem({
    super.key,
    required this.note,
    required this.onArchive,
    required this.onDelete,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final title = (note.title == null || note.title!.isEmpty)
        ? 'Untitled Note'
        : note.title!;
    final content = note.content ?? '';
    final hasImage = note.mediaTypes.contains('image');
    final hasAudio = note.mediaTypes.contains('recording');

    return Dismissible(
      key: Key(note.id),
      background: _swipeLeft(Colors.blue, Icons.archive, "Archive"),
      secondaryBackground: _swipeRight(Colors.red, Icons.delete, "Delete"),
      onDismissed: (dir) =>
          dir == DismissDirection.startToEnd ? onArchive(note) : onDelete(note),
      child: ListTile(
        leading: const Icon(Icons.note),
        title: Text(title),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(content, maxLines: 2, overflow: TextOverflow.ellipsis),
            if (hasImage || hasAudio)
              Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: Row(
                  children: [
                    if (hasImage)
                      const Icon(Icons.image, size: 18, color: Colors.grey),
                    if (hasAudio)
                      const Icon(Icons.mic, size: 18, color: Colors.grey),
                  ],
                ),
              ),
          ],
        ),
        onTap: onTap != null ? () => onTap!(note) : null,
      ),
    );
  }

  Widget _swipeLeft(Color color, IconData icon, String label) {
    return Container(
      color: color,
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Icon(icon, color: Colors.white),
          const SizedBox(width: 8),
          Text(label, style: const TextStyle(color: Colors.white)),
        ],
      ),
    );
  }

  Widget _swipeRight(Color color, IconData icon, String label) {
    return Container(
      color: color,
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(label, style: const TextStyle(color: Colors.white)),
          const SizedBox(width: 8),
          Icon(icon, color: Colors.white),
        ],
      ),
    );
  }
}
