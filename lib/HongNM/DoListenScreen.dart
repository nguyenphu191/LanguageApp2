import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:language_app/res/imagesLA/AppImages.dart';
import 'package:language_app/widget/TopBar.dart';

class DoListenscreen extends StatefulWidget {
  const DoListenscreen({super.key, required this.title, required this.index});
  final String title;
  final int index;

  @override
  _DoListenscreenState createState() => _DoListenscreenState();
}

class _DoListenscreenState extends State<DoListenscreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  final Map<String, dynamic> questions2 = {
    "audio": "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3",
    "question": [
      {
        "question": "She ______ to school on foot sometimes.",
        "options": ["goes", "went", "has gone", "will go"],
        "answer": "goes",
      },
      {
        "question": "He ______ football every weekend.",
        "options": ["plays", "played", "is playing", "will play"],
        "answer": "plays",
      },
      {
        "question": "She ______ to school on foot sometimes.",
        "options": ["goes", "went", "has gone", "will go"],
        "answer": "goes",
      },
      {
        "question": "He ______ football every weekend.",
        "options": ["plays", "played", "is playing", "will play"],
        "answer": "plays",
      },
    ]
  };

  final AudioPlayer _audioPlayer = AudioPlayer();
  double _speed = 1.0;
  bool _isPlaying = false;
  List<String?> _selectedAnswers = [];
  bool _submitted = false;
  Duration _currentPosition = Duration.zero;
  Duration _totalDuration = Duration.zero;

  @override
  void initState() {
    super.initState();
    _selectedAnswers = List.filled(questions2["question"].length, null);
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _audioPlayer.onDurationChanged.listen((duration) {
      setState(() {
        _totalDuration = duration;
      });
    });

    _audioPlayer.onPositionChanged.listen((position) {
      setState(() {
        _currentPosition = position;
      });
    });

    _audioPlayer.onPlayerComplete.listen((event) {
      setState(() {
        _isPlaying = false;
        _currentPosition = _totalDuration;
        _animationController.stop();
      });
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  void _toggleAudio() async {
    if (_isPlaying) {
      await _audioPlayer.pause();
      _animationController.stop();
    } else {
      await _audioPlayer.setPlaybackRate(_speed);
      await _audioPlayer.play(UrlSource(questions2["audio"]));
      _animationController.repeat(reverse: true);
    }
    setState(() {
      _isPlaying = !_isPlaying;
    });
  }

  void _seekAudio(double value) {
    final newPosition = Duration(seconds: value.toInt());
    _audioPlayer.seek(newPosition);
    setState(() {
      _currentPosition = newPosition;
    });
  }

  String _formatDuration(Duration duration) {
    return "${duration.inMinutes}:${(duration.inSeconds % 60).toString().padLeft(2, '0')}";
  }

  void _submitAnswers() {
    setState(() {
      _submitted = true;
    });

    int correctCount = 0;
    for (int i = 0; i < questions2["question"].length; i++) {
      if (_selectedAnswers[i] == questions2["question"][i]["answer"]) {
        correctCount++;
      }
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Colors.white,
        title: Column(
          children: [
            Icon(
              correctCount == questions2["question"].length
                  ? Icons.emoji_events
                  : correctCount >= questions2["question"].length / 2
                      ? Icons.thumb_up
                      : Icons.sentiment_dissatisfied,
              size: 50,
              color: correctCount == questions2["question"].length
                  ? Colors.amber
                  : correctCount >= questions2["question"].length / 2
                      ? Colors.green
                      : Colors.red,
            ),
            SizedBox(height: 10),
            Text(
              "Kết quả",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.blueGrey[800],
              ),
            ),
          ],
        ),
        content: Container(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Bạn trả lời đúng",
                style: TextStyle(fontSize: 16, color: Colors.grey[700]),
              ),
              SizedBox(height: 10),
              Text(
                "$correctCount/${questions2["question"].length} câu",
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: correctCount == questions2["question"].length
                      ? Colors.amber
                      : correctCount >= questions2["question"].length / 2
                          ? Colors.green
                          : Colors.red,
                ),
              ),
              SizedBox(height: 10),
              LinearProgressIndicator(
                value: correctCount / questions2["question"].length,
                backgroundColor: Colors.grey[200],
                valueColor: AlwaysStoppedAnimation<Color>(
                  correctCount == questions2["question"].length
                      ? Colors.amber
                      : correctCount >= questions2["question"].length / 2
                          ? Colors.green
                          : Colors.red,
                ),
                minHeight: 10,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text(
              "Xem lại",
              style: TextStyle(color: Colors.blueGrey, fontSize: 16),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _submitted = false;
                _selectedAnswers =
                    List.filled(questions2["question"].length, null);
              });
            },
            child: Text("Làm lại", style: TextStyle(fontSize: 16)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30)),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final pix = size.width / 375;
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue.shade200, Colors.indigo.shade50],
            stops: const [0.0, 0.7],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              TopBar(title: "Bài tập ${widget.index + 1}", isBack: true),

              // Main content
              Expanded(
                child: SingleChildScrollView(
                  physics: BouncingScrollPhysics(),
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16 * pix),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 16 * pix),

                        // Audio player card
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 10,
                                offset: Offset(0, 5),
                              ),
                            ],
                          ),
                          padding: EdgeInsets.all(16 * pix),
                          child: Column(
                            children: [
                              Text(
                                "Nghe đoạn hội thoại và trả lời câu hỏi",
                                style: TextStyle(
                                  fontSize: 16 * pix,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.blueGrey[800],
                                ),
                              ),
                              SizedBox(height: 16 * pix),

                              // Image
                              Container(
                                height: 150 * pix,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16),
                                  image: DecorationImage(
                                    image: AssetImage(AppImages.talk),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              SizedBox(height: 16 * pix),

                              // Audio controls
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  // Play/Pause button
                                  AnimatedBuilder(
                                      animation: _animationController,
                                      builder: (context, child) {
                                        return GestureDetector(
                                          onTap: _toggleAudio,
                                          child: Container(
                                            height: 60 * pix,
                                            width: 60 * pix,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              gradient: LinearGradient(
                                                colors: [
                                                  Colors.blue,
                                                  Colors.lightBlue
                                                ],
                                                begin: Alignment.topLeft,
                                                end: Alignment.bottomRight,
                                              ),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.blue
                                                      .withOpacity(0.3),
                                                  spreadRadius: _isPlaying
                                                      ? 4 +
                                                          (_animationController
                                                                  .value *
                                                              4)
                                                      : 0,
                                                  blurRadius: 10,
                                                  offset: Offset(0, 3),
                                                ),
                                              ],
                                            ),
                                            child: Icon(
                                              _isPlaying
                                                  ? Icons.pause
                                                  : Icons.play_arrow,
                                              color: Colors.white,
                                              size: 30 * pix,
                                            ),
                                          ),
                                        );
                                      }),

                                  SizedBox(width: 16 * pix),

                                  // Speed control
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: Colors.grey[200],
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: DropdownButton<double>(
                                      value: _speed,
                                      underline: SizedBox(),
                                      icon:
                                          Icon(Icons.speed, color: Colors.blue),
                                      style: TextStyle(
                                        color: Colors.blueGrey[800],
                                        fontWeight: FontWeight.bold,
                                      ),
                                      onChanged: (value) {
                                        setState(() {
                                          _speed = value!;
                                          if (_isPlaying) {
                                            _audioPlayer
                                                .setPlaybackRate(_speed);
                                          }
                                        });
                                      },
                                      items: [0.5, 0.75, 1.0, 1.25, 1.5, 2.0]
                                          .map((speed) => DropdownMenuItem(
                                                value: speed,
                                                child: Text("${speed}x"),
                                              ))
                                          .toList(),
                                    ),
                                  ),
                                ],
                              ),

                              SizedBox(height: 16 * pix),

                              // Progress bar
                              SliderTheme(
                                data: SliderThemeData(
                                  trackHeight: 6,
                                  thumbShape: RoundSliderThumbShape(
                                      enabledThumbRadius: 8),
                                  overlayShape: RoundSliderOverlayShape(
                                      overlayRadius: 20),
                                  thumbColor: Colors.blue,
                                  activeTrackColor: Colors.blue,
                                  inactiveTrackColor: Colors.grey[300],
                                ),
                                child: Slider(
                                  value: _currentPosition.inSeconds.toDouble(),
                                  max: _totalDuration.inSeconds.toDouble(),
                                  onChanged: _seekAudio,
                                ),
                              ),

                              // Time indicators
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 16),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      _formatDuration(_currentPosition),
                                      style: TextStyle(
                                        color: Colors.grey[700],
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    Text(
                                      _formatDuration(_totalDuration),
                                      style: TextStyle(
                                        color: Colors.grey[700],
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        SizedBox(height: 24 * pix),

                        // Questions
                        ...List.generate(questions2["question"].length,
                            (index) {
                          final question = questions2["question"][index];
                          final isCorrect = _submitted &&
                              _selectedAnswers[index] == question["answer"];
                          final isWrong = _submitted &&
                              _selectedAnswers[index] != null &&
                              _selectedAnswers[index] != question["answer"];

                          return Container(
                            margin: EdgeInsets.only(bottom: 24 * pix),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 10,
                                  offset: Offset(0, 5),
                                ),
                              ],
                            ),
                            padding: EdgeInsets.all(16 * pix),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Question header
                                Row(
                                  children: [
                                    Container(
                                      padding: EdgeInsets.all(10 * pix),
                                      decoration: BoxDecoration(
                                        color: Colors.blue[100],
                                        shape: BoxShape.circle,
                                      ),
                                      child: Text(
                                        "${index + 1}",
                                        style: TextStyle(
                                          fontSize: 18 * pix,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.blue[800],
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 12 * pix),
                                    Expanded(
                                      child: Text(
                                        question["question"],
                                        style: TextStyle(
                                          fontSize: 16 * pix,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.blueGrey[800],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),

                                SizedBox(height: 16 * pix),

                                // Answer options
                                Column(
                                  children:
                                      (question["options"] as List<String>)
                                          .map((option) {
                                    bool isSelected =
                                        _selectedAnswers[index] == option;
                                    bool isCorrectAnswer =
                                        option == question["answer"];

                                    Color backgroundColor = Colors.white;
                                    Color borderColor = Colors.grey[300]!;
                                    Color textColor = Colors.blueGrey[800]!;

                                    if (_submitted) {
                                      if (isCorrectAnswer) {
                                        backgroundColor = Colors.green[50]!;
                                        borderColor = Colors.green;
                                        textColor = Colors.green[800]!;
                                      } else if (isSelected) {
                                        backgroundColor = Colors.red[50]!;
                                        borderColor = Colors.red;
                                        textColor = Colors.red[800]!;
                                      }
                                    } else if (isSelected) {
                                      backgroundColor = Colors.blue[50]!;
                                      borderColor = Colors.blue;
                                      textColor = Colors.blue[800]!;
                                    }

                                    return GestureDetector(
                                      onTap: _submitted
                                          ? null
                                          : () {
                                              setState(() {
                                                _selectedAnswers[index] =
                                                    option;
                                              });
                                            },
                                      child: Container(
                                        margin:
                                            EdgeInsets.only(bottom: 12 * pix),
                                        padding: EdgeInsets.symmetric(
                                            vertical: 12 * pix,
                                            horizontal: 16 * pix),
                                        decoration: BoxDecoration(
                                          color: backgroundColor,
                                          border: Border.all(
                                              color: borderColor, width: 1.5),
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        child: Row(
                                          children: [
                                            Container(
                                              width: 22 * pix,
                                              height: 22 * pix,
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                border: Border.all(
                                                  color: isSelected
                                                      ? borderColor
                                                      : Colors.grey[400]!,
                                                  width: 2,
                                                ),
                                                color: isSelected
                                                    ? borderColor
                                                    : Colors.white,
                                              ),
                                              child: isSelected
                                                  ? Icon(
                                                      _submitted
                                                          ? (isCorrectAnswer
                                                              ? Icons.check
                                                              : Icons.close)
                                                          : Icons.check,
                                                      color: Colors.white,
                                                      size: 14 * pix,
                                                    )
                                                  : null,
                                            ),
                                            SizedBox(width: 12 * pix),
                                            Expanded(
                                              child: Text(
                                                option,
                                                style: TextStyle(
                                                  fontSize: 16 * pix,
                                                  fontWeight: isSelected
                                                      ? FontWeight.w600
                                                      : FontWeight.normal,
                                                  color: textColor,
                                                ),
                                              ),
                                            ),
                                            if (_submitted && isCorrectAnswer)
                                              Icon(Icons.check_circle_outline,
                                                  color: Colors.green),
                                          ],
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ),

                                // Feedback message
                                if (_submitted &&
                                    _selectedAnswers[index] != null)
                                  Container(
                                    margin: EdgeInsets.only(top: 8 * pix),
                                    padding: EdgeInsets.all(12 * pix),
                                    decoration: BoxDecoration(
                                      color: isCorrect
                                          ? Colors.green[50]
                                          : Colors.red[50],
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: isCorrect
                                            ? Colors.green[200]!
                                            : Colors.red[200]!,
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          isCorrect
                                              ? Icons.check_circle
                                              : Icons.cancel,
                                          color: isCorrect
                                              ? Colors.green
                                              : Colors.red,
                                          size: 20 * pix,
                                        ),
                                        SizedBox(width: 8 * pix),
                                        Expanded(
                                          child: Text(
                                            isCorrect
                                                ? "Chính xác! Đáp án của bạn đúng."
                                                : "Sai rồi! Đáp án đúng là: ${question["answer"]}",
                                            style: TextStyle(
                                              color: isCorrect
                                                  ? Colors.green[800]
                                                  : Colors.red[800],
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                              ],
                            ),
                          );
                        }),

                        // Submit button
                        if (!_submitted)
                          Container(
                            margin: EdgeInsets.only(bottom: 24 * pix),
                            child: ElevatedButton(
                              onPressed: () {
                                if (_selectedAnswers
                                    .every((answer) => answer != null)) {
                                  _submitAnswers();
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                          "Vui lòng trả lời tất cả các câu hỏi!"),
                                      backgroundColor: Colors.amber[700],
                                      behavior: SnackBarBehavior.floating,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                  );
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                foregroundColor: Colors.white,
                                padding: EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                minimumSize: Size(double.infinity, 56 * pix),
                                elevation: 4,
                              ),
                              child: Text(
                                "Kiểm tra đáp án",
                                style: TextStyle(
                                  fontSize: 18 * pix,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),

                        // Try again button
                        if (_submitted)
                          Container(
                            margin: EdgeInsets.only(bottom: 24 * pix),
                            child: ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  _submitted = false;
                                  _selectedAnswers = List.filled(
                                      questions2["question"].length, null);
                                });
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                foregroundColor: Colors.white,
                                padding: EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                minimumSize: Size(double.infinity, 56 * pix),
                                elevation: 4,
                              ),
                              child: Text(
                                "Làm lại bài tập",
                                style: TextStyle(
                                  fontSize: 18 * pix,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
