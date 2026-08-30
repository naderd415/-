import 'package:speech_to_text/speech_to_text.dart' as stt;

class SpeechService {
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isAvailable = false;

  bool get isAvailable => _isAvailable;

  // Initialize Speech recognition offline engine
  Future<bool> initialize() async {
    try {
      _isAvailable = await _speech.initialize(
        onError: (val) => print('Speech Init Error: $val'),
        onStatus: (val) => print('Speech Status: $val'),
      );
      return _isAvailable;
    } catch (e) {
      print('Speech Engine Exception: $e');
      _isAvailable = false;
      return false;
    }
  }

  // Start listening and stream results
  Future<void> startListening({
    required Function(String text) onResult,
    required String languageCode, // 'ar' or 'en'
  }) async {
    if (!_isAvailable) {
      final success = await initialize();
      if (!success) return;
    }

    await _speech.listen(
      localeId: languageCode == 'ar' ? 'ar-EG' : 'en-US',
      onResult: (result) {
        if (result.recognizedWords.isNotEmpty) {
          onResult(result.recognizedWords);
        }
      },
    );
  }

  // Stop listening
  Future<void> stopListening() async {
    await _speech.stop();
  }

  // NLP parser that scans Arabic or English strings and extracts values
  // e.g., "أمس 100 والتشغيل 30 والاستوك 70"
  // e.g., "yesterday 150 operating 45 stock 105"
  Map<String, double> parseVoiceCommand(String text) {
    final Map<String, double> parsedValues = {};
    final String cleanText = text.toLowerCase();

    // Arabic and English keywords
    final List<String> yesterdayKeys = ['أمس', 'البارحه', 'البارحة', 'مخزون أمس', 'yesterday', 'yesterdays'];
    final List<String> operatingKeys = ['التشغيل', 'تشغيل', 'تشغل', 'عمليات', 'operating', 'operation', 'sales'];
    final List<String> currentKeys = ['الاستوك', 'استوك', 'الحالي', 'اليوم', 'current', 'stock', 'today'];

    // Regex to match a keyword followed by optional spaces, colons, or words like "هو", "كان", followed by a number
    // Example: "أمس 100" or "أمس هو 100" or "yesterday 100" or "yesterday is 100"
    double? extractValueForKeys(List<String> keys) {
      for (final key in keys) {
        // Match: key + optional non-digits (like "هو", "كان", ":", "is", "was") + decimal or integer number
        final regExp = RegExp(
          '${RegExp.escape(key)}[^\\d]*([\\d]+(?:\\.[\\d]+)?)',
          caseSensitive: false,
        );
        final match = regExp.firstMatch(cleanText);
        if (match != null && match.groupCount >= 1) {
          return double.tryParse(match.group(1) ?? '');
        }
      }
      return null;
    }

    final double? yesterday = extractValueForKeys(yesterdayKeys);
    final double? operating = extractValueForKeys(operatingKeys);
    final double? current = extractValueForKeys(currentKeys);

    if (yesterday != null) parsedValues['yesterdayStock'] = yesterday;
    if (operating != null) parsedValues['operatingUnits'] = operating;
    if (current != null) parsedValues['currentStock'] = current;

    return parsedValues;
  }
}
