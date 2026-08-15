import 'package:shared_preferences/shared_preferences.dart';

/// Audio service placeholder.
/// In production, integrate with `audioplayers` package.
/// For MVP, this manages state only - actual audio files
/// can be added later without changing the API.
class AudioService {
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;
  AudioService._internal();

  bool _soundEnabled = true;
  bool _musicEnabled = true;

  bool get soundEnabled => _soundEnabled;
  bool get musicEnabled => _musicEnabled;

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _soundEnabled = prefs.getBool('sound_enabled') ?? true;
    _musicEnabled = prefs.getBool('music_enabled') ?? true;
  }

  void playKick() {
    if (!_soundEnabled) return;
    // TODO: Play kick sound with audioplayers
  }

  void playGoal() {
    if (!_soundEnabled) return;
    // TODO: Play goal celebration sound
  }

  void playWhistle() {
    if (!_soundEnabled) return;
    // TODO: Play whistle sound
  }

  void startMusic() {
    if (!_musicEnabled) return;
    // TODO: Start background music
  }

  void stopMusic() {
    // TODO: Stop background music
  }

  void setSoundEnabled(bool enabled) {
    _soundEnabled = enabled;
  }

  void setMusicEnabled(bool enabled) {
    _musicEnabled = enabled;
    if (!enabled) {
      stopMusic();
    }
  }

  void dispose() {
    stopMusic();
  }
}
