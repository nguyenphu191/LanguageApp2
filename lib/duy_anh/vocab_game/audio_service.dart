import 'package:flutter/material.dart';
import 'dart:async';

import 'audio_player.dart' if (dart.library.html) 'web_audio_player.dart'
    as platform_player;

/// A centralized service for handling audio playback with enhanced error handling
class AudioPlaybackService extends ChangeNotifier {
  static final AudioPlaybackService _instance =
      AudioPlaybackService._internal();

  factory AudioPlaybackService() {
    return _instance;
  }

  AudioPlaybackService._internal();

  bool _isPlaying = false;
  bool get isPlaying => _isPlaying;

  String? _lastPlayedText;
  String? get lastPlayedText => _lastPlayedText;

  /// Play the given text using the appropriate platform implementation
  Future<bool> playText(String text) async {
    if (_isPlaying) {
      // Already playing, don't start a new playback
      return false;
    }

    try {
      _isPlaying = true;
      _lastPlayedText = text;
      notifyListeners();

      // Use platform-specific implementation
      platform_player.playAudio(text);

      // Set a timer to reset the playing state
      await Future.delayed(const Duration(seconds: 3));

      return true;
    } catch (e) {
      print('AudioService error: $e');
      return false;
    } finally {
      _isPlaying = false;
      notifyListeners();
    }
  }

  /// Try multiple pronunciations with fallbacks
  Future<bool> tryPlayWithFallbacks(String text) async {
    // Try primary approach
    bool success = await playText(text);

    // If failed, try simplified text (remove punctuation)
    if (!success) {
      final simplifiedText = text.replaceAll(RegExp(r'[^\w\s]'), '');
      if (simplifiedText != text) {
        print('Trying simplified text: $simplifiedText');
        success = await playText(simplifiedText);
      }
    }

    return success;
  }
}
