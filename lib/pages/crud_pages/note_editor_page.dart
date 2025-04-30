import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:speech_to_text/speech_to_text.dart';
import '../../database/models/note_model.dart';
import '../../widgets/data/camera.dart';
import '../../widgets/data/recorder.dart';
import '../../widgets/data/text_input.dart';
import '../../database/operations/note_operations.dart';

class NoteEditorPage extends StatefulWidget {
  final Note? note;
  final String widgetType;

  const NoteEditorPage({super.key, this.note, this.widgetType = 'text'});

  @override
  State<NoteEditorPage> createState() => _NoteEditorPageState();
}

class _NoteEditorPageState extends State<NoteEditorPage> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();

  String? imagePath;
  String? audioPath;
  String _transcribedText = '';

  late final String _noteId = widget.note?.id ?? const Uuid().v4();
  late final PlayerController _playerController = PlayerController();
  final SpeechToText _speech = SpeechToText();

  bool get isEditing => widget.note != null;

  @override
  void initState() {
    super.initState();
    if (isEditing) {
      _titleController.text = widget.note?.title ?? '';
      _contentController.text = '';
      _transcribedText = widget.note?.content ?? '';
      _loadMedia(_noteId);
    }

    _playerController.onCompletion.listen((_) {
      if (mounted) setState(() {});
    });

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _speech.initialize();
      if (!isEditing) {
        switch (widget.widgetType) {
          case 'image':
            await _openCamera();
            break;
          case 'recording':
            await _startRecordingWithSTT();
            break;
          case 'text':
          default:
            break;
        }
      }
    });
  }

  Future<void> _startRecordingWithSTT() async {
    _speech.listen(
      onResult: (result) {
        setState(() => _transcribedText = result.recognizedWords);
      },
      listenMode: ListenMode.dictation,
      partialResults: true,
      localeId: 'en_US',
    );
    await _openRecorder();
    await _speech.stop();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _playerController.dispose();
    super.dispose();
  }

  Future<void> _saveNoteAndExit() async {
    final now = DateTime.now();

    final note = Note(
      id: _noteId,
      title: _titleController.text.trim().isEmpty ? null : _titleController.text.trim(),
      content: _transcribedText.trim().isEmpty ? null : _transcribedText.trim(),
      label: null,
      userId: null,
      firebaseId: null,
      createdAt: isEditing ? widget.note!.createdAt : now,
      updatedAt: now,
    );

    await NoteOperations.insertNotesBatch([note]);

    final media = <Media>[];
    if (imagePath != null) {
      media.add(Media(
        id: const Uuid().v4(),
        parentId: _noteId,
        parentType: 'note',
        filePath: imagePath!,
        mediaType: 'image',
      ));
    }
    if (audioPath != null) {
      media.add(Media(
        id: const Uuid().v4(),
        parentId: _noteId,
        parentType: 'note',
        filePath: audioPath!,
        mediaType: 'recording',
      ));
    }

    if (media.isNotEmpty) {
      await NoteOperations.insertMediaBatch(media);
    }

    if (!mounted) return;
    Navigator.pop(context);
  }

  void _discardNote() {
    Navigator.pop(context);
  }

  Future<void> _openCamera() async {
    final path = await Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (_) => CameraCaptureWidget(
          onImageCaptured: (path) => Navigator.pop(context, path),
          onCancel: () => Navigator.pop(context),
        ),
      ),
    );
    if (path != null && mounted) {
      setState(() => imagePath = path);
    }
  }

  Future<void> _openRecorder() async {
    final path = await Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (_) => AudioRecorderWidget(
          onRecordingComplete: (path) => Navigator.pop(context, path),
          onCancel: () => Navigator.pop(context),
        ),
      ),
    );
    if (path != null && mounted) {
      setState(() => audioPath = path);
    }
  }

  Future<void> _loadMedia(String noteId) async {
    final mediaList = await NoteOperations.getMediaForNote(noteId);
    for (Media media in mediaList) {
      if (media.mediaType == 'image' && imagePath == null) {
        imagePath = media.filePath;
      } else if (media.mediaType == 'recording' && audioPath == null) {
        audioPath = media.filePath;
      }
    }
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        await _saveNoteAndExit();
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(isEditing ? 'Edit Note' : 'New Note'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: _saveNoteAndExit,
          ),
          actions: [
            IconButton(icon: const Icon(Icons.delete), onPressed: _discardNote),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 80),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextInput(
                titleController: _titleController,
                contentController: _contentController,
                readOnly: false,
              ),
              if (_transcribedText.trim().isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                  child: Card(
                    color: Colors.grey.shade100,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Extracted Content (read-only)",
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                          const SizedBox(height: 8),
                          SelectableText(
                            _transcribedText,
                            style: const TextStyle(fontStyle: FontStyle.italic),
                          ),
                          const SizedBox(height: 8),
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () {
                                _contentController.text += '\n$_transcribedText';
                              },
                              child: const Text("Copy to Note"),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
