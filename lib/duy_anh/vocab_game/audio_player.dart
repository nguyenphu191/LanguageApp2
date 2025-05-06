import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';

// This is the implementation used for non-web platforms
void playAudio(String text) async {
  // Create a simple audio player
  final player = AudioPlayer();

  try {
    final googleTtsUrl = Uri(
      scheme: 'https',
      host: 'translate.google.com',
      path: '/translate_tts',
      queryParameters: {
        'ie': 'UTF-8',
        'q': text,
        'tl': 'en', // Language: English
        'client': 'tw-ob',
        'ttsspeed': '1.0', // Normal speed
        'textlen': text.length.toString(),
      },
    ).toString();

    print('Playing audio from URL: $googleTtsUrl');

    // Stop any currently playing audio first
    await player.stop();

    // Play the audio at full volume
    await player.setVolume(1.0);

    // Play the audio URL
    await player.play(UrlSource(googleTtsUrl));
  } catch (e) {
    print("Error playing audio: $e");
    // Try fallback approach with just basic URL if the complex one fails
    try {
      final fallbackUrl =
          'https://translate.google.com/translate_tts?ie=UTF-8&q=${Uri.encodeComponent(text)}&tl=en&client=tw-ob';
      await player.play(UrlSource(fallbackUrl));
    } catch (fallbackError) {
      print("Fallback audio also failed: $fallbackError");
      rethrow; // Rethrow to allow UI to handle the error
    }
  }
}
