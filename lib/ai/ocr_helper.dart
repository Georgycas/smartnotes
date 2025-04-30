import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class OCRService {
  static Future<String?> extractTextFromImage({
    required BuildContext context,
    required File imageFile,
  }) async {
    final messenger = ScaffoldMessenger.maybeOf(context);
    final inputImage = InputImage.fromFile(imageFile);
    final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);

    final recognizedText = await textRecognizer.processImage(inputImage);
    await textRecognizer.close();

    final text = recognizedText.text.trim();
    if (text.isEmpty && messenger != null) {
      messenger.showSnackBar(
        const SnackBar(
          content: Text("No text found in image."),
          duration: Duration(seconds: 2),
        ),
      );
      return null;
    }

    return text;
  }
}
