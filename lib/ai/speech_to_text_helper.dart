import 'package:speech_to_text/speech_to_text.dart';

class SpeechToTextHelper {
  static final SpeechToText _speech = SpeechToText();
  static bool _isInitialized = false;
  static String _bufferedText = '';

  /// Initialize speech recognizer
  static Future<bool> initialize({
    Function(String)? onStatus,
    Function(String)? onError,
  }) async {
    try {
      _isInitialized = await _speech.initialize(
        onStatus: (status) => onStatus?.call(status),
        onError: (error) => onError?.call(error.errorMsg),
      );
      return _isInitialized;
    } catch (e) {
      onError?.call(e.toString());
      return false;
    }
  }

  /// Start live transcription (in parallel with recording)
  static Future<void> startTranscription({
    required Function(String) onUpdate,
    Duration listenFor = const Duration(seconds: 60),
    Duration pauseFor = const Duration(seconds: 3),
    bool onDevice = false,
  }) async {
    if (!_isInitialized) return;

    _bufferedText = '';

    await _speech.listen(
      listenFor: listenFor,
      pauseFor: pauseFor,
      partialResults: true,
      onDevice: onDevice,
      localeId: 'en_US',
      listenMode: ListenMode.dictation,
      onResult: (result) {
        if (result.recognizedWords.isNotEmpty) {
          _bufferedText = result.recognizedWords;
          onUpdate(_bufferedText);
        }
      },
    );
  }

  static Future<void> stopTranscription() async {
    if (_speech.isListening) await _speech.stop();
  }

  static String getTranscriptionResult() => _bufferedText;

  static bool get isListening => _speech.isListening;
  static bool get isAvailable => _speech.isAvailable;
}
