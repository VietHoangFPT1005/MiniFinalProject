import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

class AudioService {
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;
  AudioService._internal();

  final AudioPlayer _bgPlayer = AudioPlayer();
  final AudioPlayer _enginePlayer = AudioPlayer();
  final AudioPlayer _sfxPlayer = AudioPlayer(); // dùng chung cho click/win/lose

  bool _isMuted = false;
  bool get isMuted => _isMuted;

  /* ================= BACKGROUND MUSIC ================= */

  Future<void> playBackgroundMusic() async {
    if (_isMuted) return;
    if (_bgPlayer.state == PlayerState.playing) return;

    try {
      await _bgPlayer.setReleaseMode(ReleaseMode.loop);
      await _bgPlayer.setVolume(0.3);
      await _bgPlayer.play(
        AssetSource('audio/background_music.mp3'),
      );
    } catch (e) {
      debugPrint('BG Music error: $e');
    }
  }

  Future<void> stopBackgroundMusic() async {
    await _bgPlayer.stop();
  }

  /* ================= ENGINE SOUND ================= */

  Future<void> playEngineSound() async {
    if (_isMuted) return;
    if (_enginePlayer.state == PlayerState.playing) return;

    try {
      await _enginePlayer.setReleaseMode(ReleaseMode.loop);
      await _enginePlayer.setVolume(0.5);
      await _enginePlayer.play(
        AssetSource('audio/engine.mp3'),
      );
    } catch (e) {
      debugPrint('Engine sound error: $e');
    }
  }

  Future<void> stopEngineSound() async {
    await _enginePlayer.stop();
  }

  /* ================= SFX ================= */

  Future<void> _playSfx(String path, {double volume = 0.7}) async {
    if (_isMuted) return;

    try {
      await _sfxPlayer.stop(); // tránh chồng âm
      await _sfxPlayer.setVolume(volume);
      await _sfxPlayer.play(AssetSource(path));
    } catch (e) {
      debugPrint('SFX error ($path): $e');
    }
  }

  Future<void> playWinSound() => _playSfx('audio/win.mp3');
  Future<void> playLoseSound() => _playSfx('audio/lose.mp3');
  Future<void> playClickSound() => _playSfx('audio/click.mp3', volume: 0.5);

  /* ================= MUTE ================= */

  Future<void> toggleMute() async {
    _isMuted = !_isMuted;

    if (_isMuted) {
      await _bgPlayer.pause();
      await _enginePlayer.pause();
    } else {
      if (_bgPlayer.state != PlayerState.playing) {
        await playBackgroundMusic();
      }
      if (_enginePlayer.state != PlayerState.playing) {
        await playEngineSound();
      }
    }
  }

  /* ================= DISPOSE ================= */

  void dispose() {
    _bgPlayer.dispose();
    _enginePlayer.dispose();
    _sfxPlayer.dispose();
  }
}
