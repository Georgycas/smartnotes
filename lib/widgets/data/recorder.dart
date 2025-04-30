import 'dart:io';
import 'package:flutter/material.dart';
import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:uuid/uuid.dart';

class AudioRecorderWidget extends StatefulWidget {
  final Function(String path) onRecordingComplete;
  final VoidCallback? onCancel;

  const AudioRecorderWidget({
    super.key,
    required this.onRecordingComplete,
    this.onCancel,
  });

  @override
  State<AudioRecorderWidget> createState() => _AudioRecorderWidgetState();
}

class _AudioRecorderWidgetState extends State<AudioRecorderWidget> {
  late final RecorderController _recorderController;
  bool _isRecording = false;
  String? _outputPath;

  @override
  void initState() {
    super.initState();
    _initializeRecorder();
  }

  Future<void> _initializeRecorder() async {
    final micStatus = await Permission.microphone.request();
    if (!micStatus.isGranted) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Microphone permission denied")),
      );
      Navigator.pop(context);
      return;
    }

    final dir = await getApplicationDocumentsDirectory();
    final audioDir = Directory('${dir.path}/smartnotes/audio/raw');
    await audioDir.create(recursive: true);

    final filename = '${const Uuid().v4()}.m4a';
    _outputPath = '${audioDir.path}/$filename';

    _recorderController = RecorderController()
      ..androidEncoder = AndroidEncoder.aac
      ..androidOutputFormat = AndroidOutputFormat.mpeg4
      ..iosEncoder = IosEncoder.kAudioFormatMPEG4AAC
      ..sampleRate = 44100;
  }

  Future<void> _toggleRecording() async {
    if (_isRecording) {
      final recordedPath = await _recorderController.stop();
      setState(() => _isRecording = false);

      if (recordedPath != null && File(recordedPath).existsSync()) {
        widget.onRecordingComplete(recordedPath);
      }
    } else {
      await _recorderController.record(path: _outputPath!);
      setState(() => _isRecording = true);
    }
  }

  @override
  void dispose() {
    _recorderController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Record Audio"),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: widget.onCancel ?? () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_isRecording)
              AudioWaveforms(
                enableGesture: false,
                size: const Size(300, 50),
                recorderController: _recorderController,
                waveStyle: const WaveStyle(
                  waveColor: Colors.redAccent,
                  extendWaveform: true,
                  showMiddleLine: true,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.black12,
                ),
              )
            else
              const Icon(Icons.mic_none, size: 100, color: Colors.grey),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _toggleRecording,
              icon: Icon(_isRecording ? Icons.stop : Icons.mic),
              label: Text(_isRecording ? 'Stop Recording' : 'Start Recording'),
              style: ElevatedButton.styleFrom(
                backgroundColor: _isRecording ? Colors.red : Colors.green,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
