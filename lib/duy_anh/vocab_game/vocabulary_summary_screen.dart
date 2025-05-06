import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import 'dart:async';

import 'package:language_app/duy_anh/vocab_game/vocabulary_game_topics_screen.dart';

class VocabularySummaryScreen extends StatefulWidget {
  final String topicId;
  final String topicName;

  const VocabularySummaryScreen({
    Key? key,
    required this.topicId,
    required this.topicName,
    // Keep these parameters so we don't need to change the calling code
    required int correctAnswers,
    required int totalQuestions,
    required int earnedPoints,
  }) : super(key: key);

  @override
  State<VocabularySummaryScreen> createState() =>
      _VocabularySummaryScreenState();
}

class _VocabularySummaryScreenState extends State<VocabularySummaryScreen> {
  late ConfettiController _confettiController;
  late Timer _navigationTimer;

  @override
  void initState() {
    super.initState();

    // Initialize the confetti controller
    _confettiController =
        ConfettiController(duration: const Duration(seconds: 3));

    // Start the confetti animation when the screen loads
    _confettiController.play();

    // Set up timer to navigate to the topics screen after 3 seconds
    _navigationTimer = Timer(const Duration(seconds: 3), () {
      // Check if the widget is still mounted before navigating
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => VocabularyGameTopicsScreen(),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _navigationTimer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final pix = (size.width / 375).clamp(0.8, 1.2);

    return Scaffold(
      body: Stack(
        children: [
          // Background
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.indigo.shade400, Colors.indigo.shade50],
                stops: const [0.0, 0.7],
              ),
            ),
          ),

          // Confetti effect
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              emissionFrequency: 0.05,
              numberOfParticles: 20,
              gravity: 0.1,
              shouldLoop: false,
              colors: const [
                Colors.red,
                Colors.blue,
                Colors.yellow,
                Colors.green,
                Colors.purple,
                Colors.orange,
              ],
            ),
          ),

          // Content - Just a simple congratulations message
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Trophy icon
                Icon(
                  Icons.emoji_events,
                  size: 100 * pix,
                  color: Colors.amber,
                ),

                SizedBox(height: 24 * pix),

                // Congratulations text
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24 * pix),
                  child: Text(
                    "Chúc mừng!\nBạn đã hoàn thành thử thách từ vựng",
                    style: TextStyle(
                      fontSize: 24 * pix,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontFamily: 'BeVietnamPro',
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
