import 'package:flutter/material.dart';
import 'package:language_app/duy_anh/vocab_game/vocabulary_listening_game_screen.dart';
import 'package:language_app/duy_anh/vocab_game/vocabulary_scramble_game_screen.dart';
import 'package:language_app/duy_anh/vocab_game/vocabulary_summary_screen.dart';
import 'package:language_app/provider/transition_provider.dart';
import 'package:provider/provider.dart';

enum NextGameType { scramble, listening, finished }

class VocabularyTransitionScreen extends StatefulWidget {
  final String topicId;
  final String topicName;
  final NextGameType nextGameType;

  const VocabularyTransitionScreen({
    super.key,
    required this.topicId,
    required this.topicName,
    required this.nextGameType,
  });

  @override
  State<VocabularyTransitionScreen> createState() =>
      _VocabularyTransitionScreenState();
}

class _VocabularyTransitionScreenState extends State<VocabularyTransitionScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    // Set up animation
    _animController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _animController,
        curve: Curves.elasticOut,
      ),
    );

    _animController.forward();

    // Use the provider to start countdown
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final transitionProvider =
          Provider.of<TransitionProvider>(context, listen: false);
      transitionProvider.startCountdown();
    });
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _navigateToNextScreen() {
    switch (widget.nextGameType) {
      case NextGameType.scramble:
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => VocabularyScrambleGameScreen(
              topicId: widget.topicId,
              topicName: widget.topicName,
            ),
          ),
        );
        break;
      case NextGameType.listening:
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => VocabularyListeningGameScreen(
              topicId: widget.topicId,
              topicName: widget.topicName,
            ),
          ),
        );
        break;
      case NextGameType.finished:
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => VocabularySummaryScreen(
              topicId: widget.topicId,
              topicName: widget.topicName,
              correctAnswers: 8,
              totalQuestions: 10,
              earnedPoints: 80,
            ),
          ),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final pix = (size.width / 375).clamp(0.8, 1.2);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Consumer<TransitionProvider>(
        builder: (context, transitionProvider, child) {
      // Check if countdown reached 0, navigate to next screen
      if (transitionProvider.countdown == 0) {
        // Use Future.microtask to avoid calling setState during build
        Future.microtask(() => _navigateToNextScreen());
      }

      return Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: _getGradientColors(),
              stops: const [0.0, 0.7],
            ),
          ),
          child: Center(
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    _getIcon(),
                    size: 100 * pix,
                    color: Colors.white,
                  ),
                  SizedBox(height: 24 * pix),
                  Text(
                    _getTitle(),
                    style: TextStyle(
                      fontSize: 28 * pix,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontFamily: 'BeVietnamPro',
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 16 * pix),
                  if (widget.nextGameType == NextGameType.finished)
                    Text(
                      "Trở về màn hình chính trong ${transitionProvider.countdown}...",
                      style: TextStyle(
                        fontSize: 18 * pix,
                        color: Colors.white.withOpacity(0.8),
                        fontFamily: 'BeVietnamPro',
                      ),
                    )
                  else
                    Text(
                      "Bắt đầu trong ${transitionProvider.countdown}...",
                      style: TextStyle(
                        fontSize: 18 * pix,
                        color: Colors.white.withOpacity(0.8),
                        fontFamily: 'BeVietnamPro',
                      ),
                    ),
                  SizedBox(height: 32 * pix),
                  CircleAvatar(
                    radius: 30 * pix,
                    backgroundColor: Colors.white.withOpacity(0.3),
                    child: Text(
                      "${transitionProvider.countdown}",
                      style: TextStyle(
                        fontSize: 24 * pix,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }

  List<Color> _getGradientColors() {
    switch (widget.nextGameType) {
      case NextGameType.scramble:
        return [Colors.purple.shade400, Colors.purple.shade800];
      case NextGameType.listening:
        return [Colors.green.shade400, Colors.green.shade800];
      case NextGameType.finished:
        return [Colors.indigo.shade400, Colors.indigo.shade800];
    }
  }

  IconData _getIcon() {
    switch (widget.nextGameType) {
      case NextGameType.scramble:
        return Icons.shuffle;
      case NextGameType.listening:
        return Icons.volume_up;
      case NextGameType.finished:
        return Icons.emoji_events;
    }
  }

  String _getTitle() {
    switch (widget.nextGameType) {
      case NextGameType.scramble:
        return "Thử Thách Xếp Chữ";
      case NextGameType.listening:
        return "Thử Thách Nghe";
      case NextGameType.finished:
        return "Chúc mừng!\nBạn đã hoàn thành!";
    }
  }
}
