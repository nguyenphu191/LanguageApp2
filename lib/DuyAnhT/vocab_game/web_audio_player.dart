import 'dart:js' as js;

// This implementation is used only on web platforms
void playAudio(String text) {
  try {
    // First check if Web Speech API is available
    if (_isSpeechSynthesisSupported()) {
      print('Using Web Speech API for TTS');
      _playWithWebSpeechAPI(text);
      return;
    }

    // Fallback to Audio API
    final encodedText = Uri.encodeComponent(text);
    final ttsUrl =
        'https://translate.google.com/translate_tts?ie=UTF-8&q=$encodedText&tl=en&client=tw-ob';

    print('Web: Attempting to play audio');

    // Use raw JavaScript to create and play audio
    js.context.callMethod('eval', [
      '''
      (function() {
        var audio = new Audio('$ttsUrl');
        audio.play().catch(function(error) {
          console.error('Audio play failed:', error);
          alert('Cannot play audio. This feature may require enabling autoplay in your browser settings.');
        });
      })()
    '''
    ]);
  } catch (e) {
    print('Web audio player error: $e');
  }
}

// Check if Web Speech API is supported
bool _isSpeechSynthesisSupported() {
  return js.context.hasProperty('speechSynthesis');
}

// Play audio using Web Speech API
void _playWithWebSpeechAPI(String text) {
  try {
    // Use JavaScript to access the Web Speech API
    js.context.callMethod('eval', [
      '''
      (function() {
        if (window.speechSynthesis) {
          var utterance = new SpeechSynthesisUtterance('$text');
          utterance.lang = 'en-US';
          utterance.volume = 1.0;
          utterance.rate = 1.0;
          utterance.pitch = 1.0;
          
          utterance.onerror = function(event) {
            console.error('Speech synthesis error:', event);
          };
          
          window.speechSynthesis.speak(utterance);
        }
      })()
    '''
    ]);
  } catch (e) {
    print('Web Speech API error: $e');
  }
}
