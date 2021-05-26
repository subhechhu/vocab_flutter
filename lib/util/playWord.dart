import 'package:flutter_tts/flutter_tts.dart';

enum TtsState { playing, stopped }

class PlayWord {
  FlutterTts _flutterTts;
  String _language = 'en-US';
  double _volume = 0.8;
  double _pitch = 1.0;
  double _rate = 0.2;

  TtsState ttsState = TtsState.stopped;

  initTTS() {
    _flutterTts = FlutterTts();
    _flutterTts.setLanguage(_language);
    _flutterTts.setVolume(_volume);
    _flutterTts.setPitch(_pitch);
    _flutterTts.setSpeechRate(_rate);

    _flutterTts.setStartHandler(() {
      print("playing");
      ttsState = TtsState.playing;
    });

    _flutterTts.setCompletionHandler(() {
      print("Complete");
      ttsState = TtsState.stopped;
    });

    _flutterTts.setErrorHandler((msg) {
      print("error: $msg");
      ttsState = TtsState.stopped;
    });
  }

  Future speak(_newVoiceText) async {
    print('word: $_newVoiceText');
    await _flutterTts.setVolume(_volume);
    await _flutterTts.setSpeechRate(_rate);
    await _flutterTts.setPitch(_pitch);

    if (_newVoiceText != null) {
      if (_newVoiceText.isNotEmpty) {
        var result = await _flutterTts.speak(_newVoiceText);
        if (result == 1) ttsState = TtsState.playing;
      }
    }
  }

  Future stop() async {
    var result = await _flutterTts.stop();
    if (result == 1) ttsState = TtsState.stopped;
  }

  stopTTS() {
    _flutterTts.stop();
  }
}
