import 'dart:io';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import '../../database/models/note_model.dart';
import '../../widgets/data/camera.dart';
import '../../widgets/data/recorder.dart';
import '../../widgets/data/text_input.dart';
import '../../database/operations/note_operations.dart'; 
import '../../ai/speech_to_text_helper.dart';

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

  late final String _noteId = widget.note?.id ?? const Uuid().v4();
  late final PlayerController _playerController = PlayerController();

  bool _isPlaying = false;

  bool get isEditing => widget.note != null;

  @override
  void initState() {
    super.initState();
    if (isEditing) {
      _titleController.text = widget.note?.title ?? '';
      _contentController.text = widget.note?.content ?? '';
      _loadMedia(_noteId);
    }

    _playerController.onCompletion.listen((_) {
      if (mounted) setState(() => _isPlaying = false);
    });

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!isEditing) {
        switch (widget.widgetType) {
          case 'image':
            await _openCamera();
            break;
          case 'recording':
            await _openRecorder();
            break;
          case 'text':
          default:
            break;
        }
      }
    });
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
      title:
          _titleController.text.trim().isEmpty
              ? null
              : _titleController.text.trim(),
      content:
          _contentController.text.trim().isEmpty
              ? null
              : _contentController.text.trim(),
      label: null,
      userId: null,
      firebaseId: null,
      createdAt: isEditing ? widget.note!.createdAt : now,
      updatedAt: now,
    );

    await NoteOperations.insertNotesBatch([note]);

    final media = <Media>[];
    if (imagePath != null) {
      media.add(
        Media(
          id: const Uuid().v4(),
          parentId: _noteId,
          parentType: 'note',
          filePath: imagePath!,
          mediaType: 'image',
        ),
      );
    }
    if (audioPath != null) {
      media.add(
        Media(
          id: const Uuid().v4(),
          parentId: _noteId,
          parentType: 'note',
          filePath: audioPath!,
          mediaType: 'recording',
        ),
      );
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
        builder:
            (_) => CameraCaptureWidget(
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
        builder:
            (_) => AudioRecorderWidget(
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

  Future<bool> _confirmDelete(String mediaType) async {
    return await showDialog<bool>(
          context: context,
          builder:
              (_) => AlertDialog(
                title: Text("Delete $mediaType?"),
                content: Text(
                  "This will remove the $mediaType from this note.",
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text("Cancel"),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context, true),
                    child: const Text("Delete"),
                  ),
                ],
              ),
        ) ??
        false;
  }

  Future<String?> _runOCR(File imageFile) async {
    final messenger = ScaffoldMessenger.maybeOf(context);
    final inputImage = InputImage.fromFile(imageFile);
    final recognizer = TextRecognizer(script: TextRecognitionScript.latin);

    final result = await recognizer.processImage(inputImage);
    await recognizer.close();

    final text = result.text.trim();
    if (text.isEmpty) {
      if (mounted && messenger != null) {
        messenger.showSnackBar(
          const SnackBar(content: Text('No text found in image')),
        );
      }
      return null;
    }

    return text;
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
              if (widget.note?.content?.trim().isNotEmpty == true)
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 12.0,
                  ),
                  child: Card(
                    color: Colors.grey.shade100,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Extracted Content (read-only)",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 8),
                          SelectableText(
                            widget.note!.content!,
                            style: const TextStyle(fontStyle: FontStyle.italic),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

              if (imagePath != null)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: GestureDetector(
                    onLongPress: () async {
                      final choice = await showModalBottomSheet<String>(
                        context: context,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        builder:
                            (_) => Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                ListTile(
                                  leading: const Icon(Icons.text_snippet),
                                  title: const Text('Extract text (OCR)'),
                                  onTap: () => Navigator.pop(context, 'ocr'),
                                ),
                                ListTile(
                                  leading: const Icon(Icons.delete),
                                  title: const Text('Delete image'),
                                  onTap: () => Navigator.pop(context, 'delete'),
                                ),
                              ],
                            ),
                      );

                      if (choice == 'ocr') {
                        final text = await _runOCR(File(imagePath!));
                        if (text != null && mounted) {
                          _contentController.text += "\n$text";
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                "Extracted text: ${text.length > 40 ? '${text.substring(0, 40)}...' : text}",
                              ),
                            ),
                          );
                        }
                      } else if (choice == 'delete') {
                        final confirm = await _confirmDelete('image');
                        if (confirm && mounted) {
                          final file = File(imagePath!);
                          if (await file.exists()) await file.delete();
                          setState(() => imagePath = null);
                        }
                      }
                    },
                    child: SizedBox(
                      width: double.infinity,
                      height: 160,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(File(imagePath!), fit: BoxFit.cover),
                      ),
                    ),
                  ),
                ),
              if (audioPath != null)
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 8,
                  ),
                  child: GestureDetector(
                    onLongPress: () async {
                      final choice = await showModalBottomSheet<String>(
                        context: context,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        builder:
                            (_) => Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                ListTile(
                                  leading: const Icon(Icons.surround_sound),
                                  title: const Text(
                                    'Transcribe audio (coming soon)',
                                  ),
                                  onTap:
                                      () =>
                                          Navigator.pop(context, 'transcribe'),
                                ),
                                ListTile(
                                  leading: const Icon(Icons.delete),
                                  title: const Text('Delete recording'),
                                  onTap: () => Navigator.pop(context, 'delete'),
                                ),
                              ],
                            ),
                      );

                      if (choice == 'transcribe') {
                        final messenger = ScaffoldMessenger.of(context);
                        messenger.showSnackBar(
                          const SnackBar(
                            content: Text("Initializing speech recognizer..."),
                          ),
                        );

                        final initialized = await SpeechToTextHelper.initialize(
                          onError: (err) {
                            messenger.showSnackBar(
                              SnackBar(content: Text("Error: $err")),
                            );
                          },
                        );

                        if (!initialized) return;

                        messenger.showSnackBar(
                          const SnackBar(
                            content: Text("Transcribing... Please wait."),
                          ),
                        );

                        await SpeechToTextHelper.startTranscription(
                          onUpdate: (text) {
                            if (mounted) {
                              setState(() {
                                _contentController.text += "\n🎤 $text";
                              });
                            }
                          },
                          listenFor: const Duration(seconds: 12),
                          pauseFor: const Duration(seconds: 3),
                        );

                        await Future.delayed(const Duration(seconds: 13));
                        await SpeechToTextHelper.stopTranscription();

                        final result =
                            SpeechToTextHelper.getTranscriptionResult();

                        if (result.isNotEmpty && mounted) {
                          setState(() {
                            _contentController.text += "\n🎤 $result";
                          });
                          messenger.showSnackBar(
                            SnackBar(
                              content: Text(
                                "Transcribed: ${result.length > 40 ? '${result.substring(0, 40)}...' : result}",
                              ),
                            ),
                          );
                        } else {
                          messenger.showSnackBar(
                            const SnackBar(
                              content: Text("No speech recognized."),
                            ),
                          );
                        }
                      } else if (choice == 'delete') {
                        final shouldDelete = await _confirmDelete('recording');
                        if (shouldDelete && mounted) {
                          final file = File(audioPath!);
                          if (await file.exists()) await file.delete();
                          await _playerController.stopPlayer();
                          setState(() {
                            audioPath = null;
                            _isPlaying = false;
                          });
                        }
                      }
                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            IconButton(
                              icon: Icon(
                                _isPlaying ? Icons.stop : Icons.play_arrow,
                              ),
                              onPressed: () async {
                                if (_isPlaying) {
                                  await _playerController.stopPlayer();
                                } else {
                                  await _playerController.preparePlayer(
                                    path: audioPath!,
                                  );
                                  await _playerController.startPlayer();
                                }
                                if (mounted) {
                                  setState(() => _isPlaying = !_isPlaying);
                                }
                              },
                            ),
                            const Text("Tap to play audio"),
                          ],
                        ),
                        AudioFileWaveforms(
                          size: const Size(double.infinity, 50),
                          playerController: _playerController,
                          enableSeekGesture: true,
                          waveformType: WaveformType.long,
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
        bottomNavigationBar: BottomAppBar(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.camera_alt),
                  onPressed: _openCamera,
                ),
                IconButton(
                  icon: const Icon(Icons.mic),
                  onPressed: _openRecorder,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
