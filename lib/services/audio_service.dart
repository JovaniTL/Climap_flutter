import 'package:just_audio/just_audio.dart';

class AudioService {
  final AudioPlayer _player;
  final String assetPath;
  final double defaultVolume;
  bool _isInitialized = false;

  AudioService({
    AudioPlayer? player,
    this.assetPath = 'assets/audio/ambient_loop.mp3',
    this.defaultVolume = 0.35,
  }) : _player = player ?? AudioPlayer();

  Future<void> init() async {
    if (_isInitialized) return;
    try {
      await _player.setAsset(assetPath);
      await _player.setLoopMode(LoopMode.one);
      await _player.setVolume(defaultVolume);
      _isInitialized = true;
    } catch (_) {
      // Si el asset aún no existe en desarrollo, evitamos romper el arranque de la app.
      _isInitialized = false;
    }
  }

  Future<void> playLoop() async {
    if (!_isInitialized) {
      await init();
    }
    if (!_isInitialized) return;

    if (!_player.playing) {
      await _player.play();
    }
  }

  Future<void> pause() async {
    if (!_isInitialized) return;
    if (_player.playing) {
      await _player.pause();
    }
  }

  Future<void> setMuted(bool muted) async {
    if (!_isInitialized) {
      await init();
    }
    if (!_isInitialized) return;

    await _player.setVolume(muted ? 0.0 : defaultVolume);
  }

  Future<void> dispose() async {
    await _player.dispose();
  }
}
