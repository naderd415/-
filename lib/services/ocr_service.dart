import 'dart:io';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class OCRService {
  final TextRecognizer _textRecognizer =
      TextRecognizer(script: TextRecognitionScript.latin);

  // Scans image and returns a list of all parsed numeric values found in paper sheets
  Future<List<double>> extractNumbersFromImage(String imagePath) async {
    final file = File(imagePath);
    if (!await file.exists()) {
      return [];
    }

    final inputImage = InputImage.fromFilePath(imagePath);
    try {
      final RecognizedText recognizedText =
          await _textRecognizer.processImage(inputImage);
      final List<double> foundNumbers = [];

      final RegExp numberRegex = RegExp(r'\b\d+(?:\.\d+)?\b');

      for (TextBlock block in recognizedText.blocks) {
        for (TextLine line in block.lines) {
          final Iterable<RegExpMatch> matches =
              numberRegex.allMatches(line.text);
          for (final match in matches) {
            final doubleValue = double.tryParse(match.group(0) ?? '');
            if (doubleValue != null) {
              foundNumbers.add(doubleValue);
            }
          }
        }
      }

      return foundNumbers.toSet().toList();
    } catch (e) {
      print("Offline OCR Exception: $e");
      return [];
    }
  }

  void dispose() {
    _textRecognizer.close();
  }
}
