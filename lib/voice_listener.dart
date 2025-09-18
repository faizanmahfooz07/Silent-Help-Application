import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class VoiceTriggerListener extends StatefulWidget {
  final String triggerWord;
  final VoidCallback onTrigger;

  const VoiceTriggerListener({
    super.key,
    required this.triggerWord,
    required this.onTrigger,
  });

  @override
  _VoiceTriggerListenerState createState() => _VoiceTriggerListenerState();
}

class _VoiceTriggerListenerState extends State<VoiceTriggerListener> {
  late stt.SpeechToText _speech;
  bool _isListening = false;

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _initializeSpeech();
  }

  Future<void> _initializeSpeech() async {
    bool available = await _speech.initialize(
      onStatus: (status) {
        if (status == 'done' || status == 'notListening') {
          _startListening();
        }
      },
      onError: (error) {
        print("Speech error: $error");
        setState(() => _isListening = false);
      },
    );

    if (available) _startListening();
  }

  void _startListening() {
    _speech.listen(
      onResult: (result) {
        String words = result.recognizedWords.toLowerCase();
        print("Heard: $words");

        if (words.contains(widget.triggerWord.toLowerCase())) {
          widget.onTrigger();
        }
      },
      listenMode: stt.ListenMode.dictation,
      partialResults: true,
      cancelOnError: false,
    );

    setState(() => _isListening = true);
  }

  @override
  void dispose() {
    _speech.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 20,
      right: 20,
      child: AnimatedOpacity(
        opacity: _isListening ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 500),
        child: const CircleAvatar(
          backgroundColor: Colors.redAccent,
          radius: 30,
          child: Icon(Icons.mic, color: Colors.white),
        ),
      ),
    );
  }
}
