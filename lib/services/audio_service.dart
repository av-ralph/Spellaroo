import 'dart:async';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:just_audio/just_audio.dart';

class AudioService {
  static final AudioPlayer _sfxPlayer = AudioPlayer();
  static final AudioPlayer _bgmPlayer = AudioPlayer();
  static final FlutterTts _tts = FlutterTts();
  static bool _soundOn = true;
  static bool _effectsOn = true;
  static bool _musicOn = true;
  static String? _currentBgmPath;

  static void configure({
    required bool soundOn,
    required bool musicOn,
    required bool effectsOn,
  }) {
    _soundOn = soundOn;
    _musicOn = musicOn;
    _effectsOn = effectsOn;
    if (!_soundOn || !_musicOn) {
      _bgmPlayer.pause();
    } else if (_currentBgmPath != null) {
      _bgmPlayer.play();
    }
  }

  static Future<void> speak(String text) async {
    if (!_soundOn) return;
    final wasPlaying = _bgmPlayer.playing;
    if (wasPlaying) await _bgmPlayer.pause();
    await _tts.setSpeechRate(0.4);
    await _tts.setVolume(1.0);
    final completer = Completer<void>();
    _tts.setCompletionHandler(() {
      if (!completer.isCompleted) completer.complete();
    });
    await _tts.speak(text);
    await completer.future;
    if (wasPlaying && _soundOn && _musicOn) await _bgmPlayer.play();
  }

  static Future<void> playCorrect() async {
    if (!_soundOn || !_effectsOn) return;
    try {
      await _sfxPlayer.setAsset('assets/sounds/sfx/correct.wav');
      await _sfxPlayer.play();
    } catch (_) {}
  }

  static Future<void> playWrong() async {
    if (!_soundOn || !_effectsOn) return;
    try {
      await _sfxPlayer.setAsset('assets/sounds/sfx/wrong.wav');
      await _sfxPlayer.play();
    } catch (_) {}
  }

  static Future<void> playClick() async {
    if (!_soundOn || !_effectsOn) return;
    try {
      await _sfxPlayer.setAsset('assets/sounds/sfx/btn_click.mp3');
      await _sfxPlayer.play();
    } catch (_) {}
  }

  static Future<void> playButton() async {
    if (!_soundOn || !_effectsOn) return;
    try {
      await _sfxPlayer.setAsset('assets/sounds/sfx/button_click.wav');
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

  static Future<void> playBgm(String assetPath) async {
    if (!_soundOn || !_musicOn) return;
    if (_currentBgmPath == assetPath && _bgmPlayer.playing) return;
    try {
      _currentBgmPath = assetPath;
      await _bgmPlayer.setAsset(assetPath);
      await _bgmPlayer.setLoopMode(LoopMode.all);
      await _bgmPlayer.setVolume(0.4);
      await _bgmPlayer.play();
    } catch (_) {}
  }

  static Future<void> stopBgm() async {
    try {
      _currentBgmPath = null;
      await _bgmPlayer.stop();
    } catch (_) {}
  }

  static Future<void> pauseBgm() async {
    try {
      await _bgmPlayer.pause();
    } catch (_) {}
  }

  static Future<void> resumeBgm() async {
    if (!_soundOn || !_musicOn) return;
    try {
      await _bgmPlayer.play();
    } catch (_) {}
  }

  static void dispose() {
    _sfxPlayer.dispose();
    _bgmPlayer.dispose();
  }
}
