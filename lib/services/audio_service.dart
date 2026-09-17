import 'package:flutter_tts/flutter_tts.dart';
import 'package:just_audio/just_audio.dart';

class AudioService {
  static final AudioPlayer _sfxPlayer = AudioPlayer();
  static final FlutterTts _tts = FlutterTts();
  static bool _soundOn = true;
  static bool _effectsOn = true;

  static void configure({
    required bool soundOn,
    required bool musicOn,
    required bool effectsOn,
  }) {
    _soundOn = soundOn;
    _effectsOn = effectsOn;
  }

  static Future<void> speak(String text) async {
    if (!_soundOn) return;
    await _tts.setSpeechRate(0.4);
    await _tts.setVolume(1.0);
    await _tts.speak(text);
  }

  static Future<void> playCorrect() async {
    if (!_soundOn || !_effectsOn) return;
    try {
      await _sfxPlayer.setAsset('assets/sounds/correct.mp3');
      await _sfxPlayer.play();
    } catch (_) {}
  }

  static Future<void> playWrong() async {
    if (!_soundOn || !_effectsOn) return;
    try {
      await _sfxPlayer.setAsset('assets/sounds/wrong.mp3');
      await _sfxPlayer.play();
    } catch (_) {}
  }

  static Future<void> playClick() async {
    if (!_soundOn || !_effectsOn) return;
    try {
      await _sfxPlayer.setAsset('assets/sounds/click.mp3');
      await _sfxPlayer.play();
    } catch (_) {}
  }

  static Future<void> playCoin() async {
    if (!_soundOn || !_effectsOn) return;
    try {
      await _sfxPlayer.setAsset('assets/sounds/coin.mp3');
      await _sfxPlayer.play();
    } catch (_) {}
  }

  static void dispose() {
    _sfxPlayer.dispose();
  }
}
