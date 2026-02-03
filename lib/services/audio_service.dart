import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

class AudioService {
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;
  AudioService._internal();


  final AudioPlayer _bgPlayer = AudioPlayer();      // Nhạc nền
  final AudioPlayer _enginePlayer = AudioPlayer();  // Tiếng động cơ
  bool _isMuted = false;                            // Trạng thái tắt tiếng

  bool get isMuted => _isMuted;

  // Nhạc nền (Background)
  Future<void> playBackgroundMusic() async {
    if (_isMuted) return;
    try {
      await _bgPlayer.setReleaseMode(ReleaseMode.loop); // Lặp lại liên tục
      await _bgPlayer.setVolume(0.3);                   // Âm lượng 30%
      await _bgPlayer.play(AssetSource('audio/background_music.mp3'));
    } catch (e) {
      debugPrint('Error playing background music: $e');
    }
  }

  Future<void> stopBackgroundMusic() async {
    await _bgPlayer.stop();
  }

  // Tiếng của động cơ xe
  Future<void> playEngineSound() async {
    if (_isMuted) return;
    try {
      await _enginePlayer.setReleaseMode(ReleaseMode.loop); // Lặp lại
      await _enginePlayer.setVolume(0.5);                   // Âm lượng 50%
      await _enginePlayer.play(AssetSource('audio/engine.mp3'));
    } catch (e) {
      debugPrint('Error playing engine sound: $e');
    }
  }

  Future<void> stopEngineSound() async {
    await _enginePlayer.stop();
  }

  // Âm thanh nếu người chơi đặt cược có xe chiến thắng
  Future<void> playWinSound() async {
    if (_isMuted) return;
    try {
      final player = AudioPlayer();
      await player.play(AssetSource('audio/win.mp3'));
    } catch (e) {
      debugPrint('Error playing win sound: $e');
    }
  }

  // Âm thanh nếu xe người chơi cược thua cuộc
  Future<void> playLoseSound() async {
    if (_isMuted) return;
    try {
      final player = AudioPlayer();
      await player.play(AssetSource('audio/lose.mp3'));
    } catch (e) {
      debugPrint('Error playing lose sound: $e');
    }
  }


  // Tiếng Click
  Future<void> playClickSound() async {
    if (_isMuted) return;
    try {
      final player = AudioPlayer();
      await player.setVolume(0.5);
      await player.play(AssetSource('audio/click.mp3'));
    } catch (e) {
      debugPrint('Error playing click sound: $e');
    }
  }

  // Bật/ Tắt âm thanh
  void toggleMute() {
    _isMuted = !_isMuted;
    if (_isMuted) {
      _bgPlayer.setVolume(0);
      _enginePlayer.setVolume(0);
    } else {
      _bgPlayer.setVolume(0.3);
      _enginePlayer.setVolume(0.5);
    }
  }

  void dispose() {
    _bgPlayer.dispose();
    _enginePlayer.dispose();
  }
}