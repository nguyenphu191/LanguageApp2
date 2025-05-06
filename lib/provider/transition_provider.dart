import 'package:flutter/foundation.dart';
import 'dart:async';

enum NextGameType { scramble, listening, finished }

class TransitionProvider with ChangeNotifier {
  int _countdown = 3;
  bool _isAnimating = false;

  int get countdown => _countdown;
  bool get isAnimating => _isAnimating;

  Timer? _timer;

  void startCountdown() {
    _countdown = 3;
    _isAnimating = true;
    notifyListeners();

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_countdown > 1) {
        _countdown--;
        notifyListeners();
      } else {
        _timer?.cancel();
        _timer = null;
        _countdown = 0;
        notifyListeners();
      }
    });
  }

  void setAnimating(bool value) {
    _isAnimating = value;
    notifyListeners();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
