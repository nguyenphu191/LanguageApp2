import 'dart:async';
import 'dart:math' show sin, pi;
import 'package:flutter/material.dart';
import 'package:language_app/duy_anh/vocab_game/audio_button.dart';
import 'package:language_app/duy_anh/vocab_game/audio_service.dart';
import 'package:language_app/duy_anh/vocab_game/vocabulary_transition_screen.dart';
import 'package:language_app/provider/vocabulary_game_provider.dart';
import 'package:language_app/widget/top_bar.dart';
import 'package:provider/provider.dart';

class VocabularyListeningGameScreen extends StatefulWidget {
  final String topicId;
  final String topicName;

  const VocabularyListeningGameScreen({
    super.key,
    required this.topicId,
    required this.topicName,
  });

  @override
  State<VocabularyListeningGameScreen> createState() =>
      _VocabularyListeningGameScreenState();
}

class _VocabularyListeningGameScreenState
    extends State<VocabularyListeningGameScreen>
    with SingleTickerProviderStateMixin {
  bool _isLoading = true;
  bool _hasError = false;
  String _errorMessage = "";

  // Game state
  int _currentWordIndex = 0;
  List<VocabularyWord> _gameWords = [];
  String _userInput = '';
  bool _isSolved = false;
  Timer? _timer;
  int _timeLeft = 30; // 30 seconds per word
  bool _isPaused = false;
  bool _gameCompleted = false;
  bool _isAudioPlaying = false;

  // Animation controller
  late AnimationController _animationController;
  late Animation<double> _shakeAnimation;

  final TextEditingController _textController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _shakeAnimation = Tween<double>(
      begin: 0,
      end: 10,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.elasticIn,
      ),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadGameData();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _animationController.dispose();
    _textController.dispose();
    _focusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_isPaused) return;

      setState(() {
        if (_timeLeft > 0) {
          _timeLeft--;
        } else {
          // Time's up for this word, move to next one
          _moveToNextWord();
        }
      });
    });
  }

  void _pauseGame() {
    setState(() {
      _isPaused = true;
    });
  }

  void _resumeGame() {
    setState(() {
      _isPaused = false;
    });
    _focusNode.requestFocus();
  }

  void _moveToNextWord() {
    _timer?.cancel();

    if (_currentWordIndex < _gameWords.length - 1) {
      setState(() {
        _currentWordIndex++;
        _isSolved = false;
        _timeLeft = 30; // Reset timer for next word
        _textController.clear();
        _userInput = '';
      });
      _startTimer();
      _focusNode.requestFocus();

      // Automatically play audio for the new word
      Future.delayed(Duration(milliseconds: 300), () {
        _playCurrentWord();
      });
    } else {
      // Game completed
      setState(() {
        _gameCompleted = true;
      });

      // Navigate to transition screen with congratulation message
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => VocabularyTransitionScreen(
            topicId: widget.topicId,
            topicName: widget.topicName,
            nextGameType: NextGameType.finished,
          ),
        ),
      );
    }
  }

  Future<void> _loadGameData() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
      _errorMessage = "";
    });

    final gameProvider =
        Provider.of<VocabularyGameProvider>(context, listen: false);

    try {
      // Fetch listening game data
      await gameProvider.fetchListeningGame(widget.topicId);

      if (gameProvider.errorMessage != null) {
        setState(() {
          _hasError = true;
          _errorMessage = gameProvider.errorMessage!;
          _isLoading = false;
        });
        return;
      }

      _gameWords = gameProvider.listeningWords;

      if (_gameWords.isEmpty) {
        setState(() {
          _hasError = true;
          _errorMessage = "Không có từ vựng cho trò chơi này.";
          _isLoading = false;
        });
        return;
      }

      setState(() {
        _isLoading = false;
      });

      _startTimer();
      _focusNode.requestFocus();
    } catch (e) {
      print('Error loading game data: $e');
      setState(() {
        _hasError = true;
        _errorMessage = "Không thể tải dữ liệu trò chơi. Vui lòng thử lại sau.";
        _isLoading = false;
      });
    }
  }

  void _playCurrentWord() {
    if (_gameWords.isEmpty || _currentWordIndex >= _gameWords.length) return;

    final word = _gameWords[_currentWordIndex].word;
    final audioService = AudioPlaybackService();
    audioService.tryPlayWithFallbacks(word);
  }

  void _checkAnswer() {
    if (_isSolved) return;

    final correctWord = _gameWords[_currentWordIndex].word.toLowerCase().trim();
    final userAnswer = _userInput.toLowerCase().trim();

    if (userAnswer == correctWord) {
      // Correct answer
      setState(() {
        _isSolved = true;
      });

      // Show success dialog with word details
      Future.delayed(Duration(milliseconds: 500), () {
        _showWordDetailsDialog();
      });
    } else {
      // Wrong answer - shake the input
      _animationController.forward().then((_) {
        _animationController.reset();
      });
    }
  }

  void _showWordDetailsDialog() {
    // Delay showing the dialog to prevent rendering issues
    Future.delayed(Duration(milliseconds: 300), () {
      if (!mounted) return;

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext dialogContext) {
          // Use dialogContext instead of context
          final word = _gameWords[_currentWordIndex];
          final pix =
              (MediaQuery.of(dialogContext).size.width / 375).clamp(0.8, 1.2);
          final isDarkMode =
              Theme.of(dialogContext).brightness == Brightness.dark;

          return Dialog(
            backgroundColor: isDarkMode ? Color(0xFF1E1E2F) : Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16 * pix),
            ),
            child: Container(
              width: MediaQuery.of(dialogContext).size.width * 0.85,
              padding: EdgeInsets.all(16 * pix),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Dialog title
                  Text(
                    'Chúc mừng!',
                    style: TextStyle(
                      fontSize: 22 * pix,
                      fontWeight: FontWeight.bold,
                      color: isDarkMode ? Colors.white : Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 16 * pix),

                  // Word image - with constrained height
                  if (word.imageUrl.isNotEmpty)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12 * pix),
                      child: Container(
                        height: 150 * pix,
                        width: double.infinity,
                        child: Image.network(
                          word.imageUrl,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Center(
                              child: CircularProgressIndicator(
                                value: loadingProgress.expectedTotalBytes !=
                                        null
                                    ? loadingProgress.cumulativeBytesLoaded /
                                        loadingProgress.expectedTotalBytes!
                                    : null,
                              ),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: Colors.grey[300],
                              child: Center(
                                child: Icon(
                                  Icons.image_not_supported,
                                  size: 40 * pix,
                                  color: Colors.grey[500],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  SizedBox(height: 16 * pix),

                  // Word and definition
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        word.word,
                        style: TextStyle(
                          fontSize: 20 * pix,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                      SizedBox(width: 8 * pix),
                      AudioButton(
                        text: word.word,
                        size: 28 * pix,
                      ),
                    ],
                  ),
                  Text(
                    word.transcription,
                    style: TextStyle(
                      fontSize: 16 * pix,
                      fontStyle: FontStyle.italic,
                      color: isDarkMode ? Colors.white70 : Colors.grey[700],
                    ),
                  ),
                  SizedBox(height: 8 * pix),
                  Text(
                    word.definition,
                    style: TextStyle(
                      fontSize: 16 * pix,
                      color: isDarkMode ? Colors.white70 : Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 16 * pix),

                  // Example
                  Container(
                    padding: EdgeInsets.all(12 * pix),
                    decoration: BoxDecoration(
                      color: isDarkMode
                          ? Colors.blue.withOpacity(0.1)
                          : Colors.blue.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(8 * pix),
                      border: Border.all(
                        color: Colors.blue.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(
                          word.example,
                          style: TextStyle(
                            fontSize: 14 * pix,
                            fontStyle: FontStyle.italic,
                            color: isDarkMode ? Colors.white : Colors.black87,
                          ),
                        ),
                        SizedBox(height: 4 * pix),
                        Text(
                          word.exampleTranslation,
                          style: TextStyle(
                            fontSize: 14 * pix,
                            color:
                                isDarkMode ? Colors.white70 : Colors.grey[700],
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 16 * pix),

                  // Next button
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      padding: EdgeInsets.symmetric(
                          horizontal: 24 * pix, vertical: 12 * pix),
                    ),
                    onPressed: () {
                      Navigator.of(dialogContext).pop();
                      _moveToNextWord();
                    },
                    child: Text(
                      'Từ Tiếp Theo',
                      style: TextStyle(
                        fontSize: 16 * pix,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    });
  }

  String _formatTime(int seconds) {
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    return '$minutes:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final pix = (size.width / 375).clamp(0.8, 1.2);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      resizeToAvoidBottomInset:
          true, // Quan trọng: cho phép resize khi bàn phím xuất hiện
      body: GestureDetector(
        onTap: () {
          // Ẩn bàn phím khi chạm vào màn hình bên ngoài TextField
          FocusScope.of(context).unfocus();
        },
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.green.shade200, Colors.indigo.shade50],
              stops: const [0.0, 0.7],
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                top: 0,
                right: 0,
                left: 0,
                child: TopBar(
                  title: 'Nghe & Viết: ${widget.topicName}',
                  isBack: true,
                ),
              ),
              Positioned(
                top: 100 * pix,
                left: 0,
                right: 0,
                bottom: 0,
                child: _buildBody(context, pix, isDarkMode),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, double pix, bool isDarkMode) {
    if (_isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    if (_hasError) {
      return SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                color: Colors.red,
                size: 50 * pix,
              ),
              SizedBox(height: 16 * pix),
              Text(
                _errorMessage,
                style: TextStyle(
                  fontSize: 16 * pix,
                  color: Colors.red,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 16 * pix),
              ElevatedButton(
                onPressed: _loadGameData,
                child: Text('Thử lại'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xff165598),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_isPaused) {
      return _buildPausedView(pix, isDarkMode);
    }

    // Tính toán chiều cao của bàn phím
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;

    return SafeArea(
      child: Column(
        children: [
          // Header (không cần cuộn)
          _buildGameHeader(pix, isDarkMode),

          // Phần còn lại có thể cuộn nếu cần
          Expanded(
            child: SingleChildScrollView(
              controller: _scrollController,
              // Tự động cuộn xuống để hiện ô nhập khi bàn phím xuất hiện
              physics: BouncingScrollPhysics(),
              child: Padding(
                padding: EdgeInsets.only(
                  bottom: keyboardHeight > 0 ? keyboardHeight : 20 * pix,
                ),
                child: _buildListeningGame(pix, isDarkMode),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGameHeader(double pix, bool isDarkMode) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 24 * pix, vertical: 16 * pix),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: EdgeInsets.symmetric(
                    horizontal: 12 * pix, vertical: 8 * pix),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(16 * pix),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.timer,
                      size: 24 * pix,
                      color: _timeLeft < 10 ? Colors.red : Colors.blue,
                    ),
                    SizedBox(width: 8 * pix),
                    Text(
                      _formatTime(_timeLeft),
                      style: TextStyle(
                        fontSize: 18 * pix,
                        fontWeight: FontWeight.bold,
                        color: _timeLeft < 10 ? Colors.red : Colors.blue,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(16 * pix),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: IconButton(
                  icon: Icon(
                    Icons.pause_circle_filled,
                    size: 28 * pix,
                    color: Colors.blue,
                  ),
                  onPressed: _pauseGame,
                ),
              ),
            ],
          ),
          SizedBox(height: 16 * pix),
          Container(
            padding:
                EdgeInsets.symmetric(horizontal: 16 * pix, vertical: 10 * pix),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12 * pix),
              border:
                  Border.all(color: Colors.green.withOpacity(0.3), width: 1),
            ),
            child: Column(
              children: [
                Text(
                  'Từ ${_currentWordIndex + 1}/${_gameWords.length}',
                  style: TextStyle(
                    fontSize: 18 * pix,
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? Colors.white : Colors.green.shade800,
                  ),
                ),
                SizedBox(height: 8 * pix),
                Text(
                  'Nghe và viết từ tiếng Anh mà bạn nghe được',
                  style: TextStyle(
                    fontSize: 14 * pix,
                    fontWeight: FontWeight.w500,
                    color: isDarkMode ? Colors.white70 : Colors.black54,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListeningGame(double pix, bool isDarkMode) {
    // Lắng nghe sự kiện khi TextField được focus để tự động cuộn
    _focusNode.addListener(() {
      if (_focusNode.hasFocus) {
        // Sử dụng một hàm tạm thời để delay việc cuộn để đảm bảo bàn phím đã hiển thị
        Future.delayed(Duration(milliseconds: 300), () {
          if (_scrollController.hasClients) {
            _scrollController.animateTo(
              _scrollController.position.maxScrollExtent,
              duration: Duration(milliseconds: 300),
              curve: Curves.easeOut,
            );
          }
        });
      }
    });

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16 * pix),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Play button
          Container(
            margin: EdgeInsets.symmetric(vertical: 20 * pix),
            child: Material(
              elevation: 4,
              color: Colors.green,
              borderRadius: BorderRadius.circular(16 * pix),
              child: InkWell(
                borderRadius: BorderRadius.circular(16 * pix),
                onTap: _playCurrentWord,
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 24 * pix,
                    vertical: 16 * pix,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AudioButton(
                        text: _gameWords[_currentWordIndex].word,
                        size: 30 * pix,
                        color: Colors.white,
                        showText: true,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          SizedBox(height: 30 * pix),

          // Input field - Quan trọng: đây là phần gây ra lỗi tràn màn hình
          AnimatedBuilder(
            animation: _shakeAnimation,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(
                  sin(_animationController.value * 3 * 3.14159) * 10,
                  0,
                ),
                child: child,
              );
            },
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 16 * pix),
              decoration: BoxDecoration(
                color: isDarkMode
                    ? Color(0xFF2A2A42).withOpacity(0.8)
                    : Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(16 * pix),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: Offset(0, 5),
                  ),
                ],
              ),
              child: TextField(
                controller: _textController,
                focusNode: _focusNode,
                onChanged: (value) {
                  setState(() {
                    _userInput = value;
                  });
                },
                onSubmitted: (_) => _checkAnswer(),
                style: TextStyle(
                  fontSize: 20 * pix,
                  color: isDarkMode ? Colors.white : Colors.black87,
                ),
                textAlign: TextAlign.center,
                decoration: InputDecoration(
                  hintText: 'Nhập từ bạn nghe được...',
                  hintStyle: TextStyle(
                    color: isDarkMode ? Colors.white60 : Colors.black45,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16 * pix),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16 * pix,
                    vertical: 20 * pix,
                  ),
                ),
              ),
            ),
          ),

          SizedBox(height: 24 * pix),

          // Submit button
          ElevatedButton(
            onPressed: _checkAnswer,
            child: Text(
              'Kiểm tra',
              style: TextStyle(
                fontSize: 16 * pix,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              padding: EdgeInsets.symmetric(
                horizontal: 32 * pix,
                vertical: 12 * pix,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12 * pix),
              ),
            ),
          ),

          // Thêm padding phía dưới để đảm bảo nút luôn hiển thị
          SizedBox(height: 120 * pix),
        ],
      ),
    );
  }

  Widget _buildPausedView(double pix, bool isDarkMode) {
    return Center(
      child: Container(
        margin: EdgeInsets.all(24 * pix),
        padding: EdgeInsets.all(24 * pix),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          borderRadius: BorderRadius.circular(24 * pix),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.pause_circle_filled,
              size: 80 * pix,
              color: Colors.blue,
            ),
            SizedBox(height: 24 * pix),
            Text(
              'Trò Chơi Tạm Dừng',
              style: TextStyle(
                fontSize: 24 * pix,
                fontWeight: FontWeight.bold,
                color: Colors.blue.shade800,
              ),
            ),
            SizedBox(height: 16 * pix),
            Container(
              padding:
                  EdgeInsets.symmetric(horizontal: 16 * pix, vertical: 8 * pix),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12 * pix),
              ),
              child: Text(
                'Thời gian còn lại: ${_formatTime(_timeLeft)}',
                style: TextStyle(
                  fontSize: 18 * pix,
                  fontWeight: FontWeight.w500,
                  color: Colors.blue.shade700,
                ),
              ),
            ),
            SizedBox(height: 32 * pix),
            ElevatedButton.icon(
              icon: Icon(Icons.play_arrow),
              label: Text('Tiếp Tục Chơi'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(
                    horizontal: 24 * pix, vertical: 12 * pix),
                textStyle:
                    TextStyle(fontSize: 16 * pix, fontWeight: FontWeight.bold),
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16 * pix),
                ),
              ),
              onPressed: _resumeGame,
            ),
          ],
        ),
      ),
    );
  }
}
