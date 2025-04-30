import 'package:flutter/material.dart';
import '../../register_widgets.dart';
import '../../database/models/note_model.dart';
import '../../database/operations/note_operations.dart';

class ArchivePage extends StatefulWidget {
  const ArchivePage({super.key});

  @override
  ArchivePageState createState() => ArchivePageState();
}

class ArchivePageState extends State<ArchivePage> {
  bool _isActionMode = false;
  List<Note> archivedNotes = [];
  Set<Note> selectedNotes = {};

  @override
  void initState() {
    super.initState();
    _loadArchivedNotes();
  }

  void _toggleAppBar() {
    setState(() {
      _isActionMode = !_isActionMode;
      if (!_isActionMode) selectedNotes.clear();
    });
  }

  Future<void> _loadArchivedNotes() async {
    final notes = await NoteOperations.getArchivedNotes();
    setState(() => archivedNotes = notes);
  }

  Future<void> _batchDearchive() async {
    await NoteOperations.restoreNotesBatch(selectedNotes.toList());
    setState(() {
      selectedNotes.clear();
      _isActionMode = false;
    });
    _loadArchivedNotes();
  }

  Future<void> _batchMoveToTrash() async {
    await NoteOperations.trashNotesBatch(selectedNotes.toList());
    setState(() {
      selectedNotes.clear();
      _isActionMode = false;
    });
    _loadArchivedNotes();
  }

  void _exportSelected() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Exporting selected notes... (mock)")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _isActionMode ? _buildActionAppBar() : HomeAppBar(title: 'Archive'),
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
          icon: const Icon(Icons.unarchive),
          onPressed: _batchDearchive,
          tooltip: "Dearchive",
        ),
        IconButton(
          icon: const Icon(Icons.delete),
          onPressed: _batchMoveToTrash,
          tooltip: "Move to Trash",
        ),
        IconButton(
          icon: const Icon(Icons.file_download),
          onPressed: _exportSelected,
          tooltip: "Export",
        ),
      ],
    );
  }

  Widget _buildList() {
    if (archivedNotes.isEmpty) {
      return const Center(
        child: Text(
          "Archived notes will appear here...",
          style: TextStyle(fontSize: 18, color: Colors.black54),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(12),
      itemCount: archivedNotes.length,
      separatorBuilder: (_, __) => const Divider(),
      itemBuilder: (context, index) {
        final note = archivedNotes[index];
        return ListTile(
          leading: const Icon(Icons.note, color: Colors.blue),
          title: Text(note.title ?? "(Untitled Note)"),
          subtitle: const Text("Note"),
          tileColor: selectedNotes.contains(note) ? Colors.blue[100] : Colors.grey[200],
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
