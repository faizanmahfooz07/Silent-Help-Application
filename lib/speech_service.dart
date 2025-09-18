import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SpeechService {
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;
  Function(String)? onTriggerWordDetected;
  String _triggerWord = "Help";

  Future<void> initialize({Function(String)? onTrigger}) async {
    onTriggerWordDetected = onTrigger;
    await _loadTriggerWord();

    bool available = await _speech.initialize(
      onStatus: (status) {
        debugPrint("Speech status: $status");
        if (status == 'done' || status == 'notListening') {
          _restartListening();
        }
      },
      onError: (error) {
        debugPrint("Speech error: $error");
        _restartListening();
      },
    );

    if (available) {
      _startListening();
    } else {
      debugPrint("❌ Speech recognition not available");
    }
  }

  Future<void> _loadTriggerWord() async {
    final prefs = await SharedPreferences.getInstance();
    _triggerWord = prefs.getString('trigger_word')?.toLowerCase().trim() ?? "help";
    debugPrint("Loaded trigger word: $_triggerWord");
  }

  void _startListening() {
    if (!_isListening) {
      _speech.listen(
        onResult: (result) {
          String text = result.recognizedWords.toLowerCase().trim();
          debugPrint("🎙️ Heard: $text");

          if (text.contains(_triggerWord)) {
            onTriggerWordDetected?.call(_triggerWord);
          }
        },
        listenMode: stt.ListenMode.dictation,
        partialResults: true,
        cancelOnError: false,
      );
      _isListening = true;
    }
  }

  void _restartListening() {
    _speech.stop().then((_) {
      _isListening = false;
      _startListening();
    });
  }

  void stopListening() {
    _speech.stop();
    _isListening = false;
  }
}
