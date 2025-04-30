import 'package:flutter/material.dart';
import '../../register_widgets.dart';
import '../../database/models/note_model.dart';
import '../../database/operations/note_operations.dart';
import '../../register_routes.dart';

class NotePage extends StatefulWidget {
  const NotePage({super.key});

  @override
  State<NotePage> createState() => _NotePageState();
}

class _NotePageState extends State<NotePage> with WidgetsBindingObserver {
  List<Note> notes = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _fetchNotes();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused && mounted) {
      // Optional: save or sync here
    }
  }

  Future<void> _fetchNotes() async {
    final fetchedNotes = await NoteOperations.getActiveNotes();
    if (!mounted) return;
    setState(() => notes = fetchedNotes);
  }

  Future<void> _openNewNote(String widgetType) async {
    await Navigator.pushNamed(
      context,
      AppRoutes.noteEditor,
      arguments: {'widgetType': widgetType},
    );
    _fetchNotes();
  }

  Future<void> _openEditNote(Note note) async {
    await Navigator.pushNamed(
      context,
      AppRoutes.noteEditor,
      arguments: note,
    );
    _fetchNotes();
  }

  Future<void> _archiveNote(Note note) async {
    await NoteOperations.archiveNote(note);
    if (!mounted) return;
    _fetchNotes();
  }

  Future<void> _deleteNote(Note note) async {
    await NoteOperations.trashNote(note);
    if (!mounted) return;
    _fetchNotes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: HomeAppBar(
        title: 'Notes',
        actions: [
          PopupMenuButton<String>(
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'multi_select', child: Text('Multi-select')),
              const PopupMenuItem(value: 'sort_filter', child: Text('Filter/Sort (placeholder)')),
            ],
          ),
        ],
      ),
      drawer: HomeDrawer(labels: []),
      body: ContentContainer(
        items: notes,
        onArchive: _archiveNote,
        onDelete: _deleteNote,
        onTap: _openEditNote,
      ),
      floatingActionButton: ActionButtons(
        onAdd: _openNewNote,
      ),
    );
  }
}
