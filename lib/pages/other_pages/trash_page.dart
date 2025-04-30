import 'package:flutter/material.dart';
import '../../register_widgets.dart';
import '../../database/models/note_model.dart';
import '../../database/operations/note_operations.dart';

class TrashPage extends StatefulWidget {
  const TrashPage({super.key});

  @override
  State<TrashPage> createState() => _TrashPageState();
}

class _TrashPageState extends State<TrashPage> {
  bool _isActionMode = false;
  List<Note> trashedNotes = [];
  Set<Note> selectedNotes = {};

  @override
  void initState() {
    super.initState();
    _loadTrashedNotes();
  }

  void _toggleAppBar() {
    setState(() {
      _isActionMode = !_isActionMode;
      if (!_isActionMode) selectedNotes.clear();
    });
  }

  Future<void> _loadTrashedNotes() async {
    final notes = await NoteOperations.getTrashedNotes();
    setState(() => trashedNotes = notes);
  }

  Future<void> _batchRecover() async {
    await NoteOperations.restoreNotesBatch(selectedNotes.toList());
    setState(() {
      selectedNotes.clear();
      _isActionMode = false;
    });
    _loadTrashedNotes();
  }

  Future<void> _batchDeleteForever() async {
    await NoteOperations.permanentlyDeleteNotesBatch(selectedNotes.toList());
    setState(() {
      selectedNotes.clear();
      _isActionMode = false;
    });
    _loadTrashedNotes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _isActionMode ? _buildActionAppBar() : HomeAppBar(title: 'Trash'),
      drawer: _isActionMode ? null : HomeDrawer(labels: []),
      body: _buildList(),
      floatingActionButton: FloatingActionButton(
        onPressed: _toggleAppBar,
        tooltip: "Switch AppBar",
        child: const Icon(Icons.swap_horiz),
      ),
    );
  }

  AppBar _buildActionAppBar() {
    return AppBar(
      title: Text('${selectedNotes.length} selected'),
      leading: IconButton(
        icon: const Icon(Icons.close),
        onPressed: _toggleAppBar,
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.restore),
          onPressed: _batchRecover,
          tooltip: "Recover",
        ),
        IconButton(
          icon: const Icon(Icons.delete_forever),
          onPressed: _batchDeleteForever,
          tooltip: "Delete Permanently",
        ),
      ],
    );
  }

  Widget _buildList() {
    if (trashedNotes.isEmpty) {
      return const Center(
        child: Text(
          "Deleted notes will appear here...",
          style: TextStyle(fontSize: 18, color: Colors.black54),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(12),
      itemCount: trashedNotes.length,
      separatorBuilder: (_, __) => const Divider(),
      itemBuilder: (context, index) {
        final note = trashedNotes[index];
        return ListTile(
          leading: const Icon(Icons.note, color: Colors.red),
          title: Text(note.title ?? "(Untitled Note)"),
          subtitle: const Text("Note"),
          tileColor: selectedNotes.contains(note) ? Colors.red[100] : Colors.grey[200],
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          onTap: () {
            if (_isActionMode) {
              setState(() {
                selectedNotes.contains(note)
                    ? selectedNotes.remove(note)
                    : selectedNotes.add(note);
              });
            }
          },
          onLongPress: () {
            setState(() {
              _isActionMode = true;
              selectedNotes.add(note);
            });
          },
        );
      },
    );
  }
}
