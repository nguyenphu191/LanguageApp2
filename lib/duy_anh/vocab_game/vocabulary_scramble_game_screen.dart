import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:language_app/duy_anh/vocab_game/vocabulary_transition_screen.dart';
import 'package:language_app/provider/vocabulary_game_provider.dart';
import 'package:language_app/widget/top_bar.dart';
import 'package:provider/provider.dart';

class VocabularyScrambleGameScreen extends StatefulWidget {
  final String topicId;
  final String topicName;

  const VocabularyScrambleGameScreen({
    super.key,
    required this.topicId,
    required this.topicName,
  });

  @override
  State<VocabularyScrambleGameScreen> createState() =>
      _VocabularyScrambleGameScreenState();
}

class _VocabularyScrambleGameScreenState
    extends State<VocabularyScrambleGameScreen>
    with SingleTickerProviderStateMixin {
  bool _isLoading = true;
  bool _hasError = false;
  String _errorMessage = "";

  // Game state
  int _currentWordIndex = 0;
  List<ScrambleWordItem> _gameWords = [];
  List<String> _shuffledLetters = [];
  List<String> _originalShuffledArrangement = []; // Store original arrangement
  List<String?> _userSolution = [];
  bool _isSolved = false;
  Timer? _timer;
  int _timeLeft = 60; // 1 minute per word
  bool _isPaused = false;
  bool _gameCompleted = false;

  // Animation controller
  late AnimationController _animationController;
  late Animation<double> _shakeAnimation;

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
  }

  void _moveToNextWord() {
    _timer?.cancel();

    if (_currentWordIndex < _gameWords.length - 1) {
      setState(() {
        _currentWordIndex++;
        _isSolved = false;
        _timeLeft = 60; // Reset timer for next word
        _setupCurrentWord();
      });
      _startTimer();
    } else {
      // Game completed
      setState(() {
        _gameCompleted = true;
      });

      // Navigate to transition screen instead of summary screen
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => VocabularyTransitionScreen(
            topicId: widget.topicId,
            topicName: widget.topicName,
            nextGameType: NextGameType.listening,
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
      // Fetch scramble game data
      await gameProvider.fetchScrambleGame(widget.topicId);

      if (gameProvider.errorMessage != null) {
        setState(() {
          _hasError = true;
          _errorMessage = gameProvider.errorMessage!;
          _isLoading = false;
        });
        return;
      }

      _gameWords = gameProvider.scrambleWords;

      if (_gameWords.isEmpty) {
        setState(() {
          _hasError = true;
          _errorMessage = "Không có từ vựng cho trò chơi này.";
          _isLoading = false;
        });
        return;
      }

      // Setup the first word
      _setupCurrentWord();
      setState(() {
        _isLoading = false;
      });

      _startTimer();
    } catch (e) {
      print('Error loading game data: $e');
      setState(() {
        _hasError = true;
        _errorMessage = "Không thể tải dữ liệu trò chơi. Vui lòng thử lại sau.";
        _isLoading = false;
      });
    }
  }

  void _setupCurrentWord() {
    final currentWord = _gameWords[_currentWordIndex];

    // Create list of letters from scrambled word
    _shuffledLetters = currentWord.scrambled.split('');

    // Store the original scrambled arrangement for reset purposes
    _originalShuffledArrangement = List.from(_shuffledLetters);

    // Initialize empty solution slots
    _userSolution = List.filled(currentWord.word.length, null);

    // Reset solved state
    _isSolved = false;
  }

  void _onShuffledLetterTap(int index) {
    if (_isSolved) return;

    final letter = _shuffledLetters[index];
    if (letter.isEmpty) return; // Already used

    setState(() {
      // Find the first empty slot in user solution
      final emptySlotIndex = _userSolution.indexWhere((slot) => slot == null);
      if (emptySlotIndex != -1) {
        _userSolution[emptySlotIndex] = letter;
        // Mark this letter as used (empty)
        _shuffledLetters[index] = '';

        // Check if word is complete
        _checkSolution();
      }
    });
  }

  void _onSolutionLetterTap(int index) {
    if (_isSolved) return;

    final letter = _userSolution[index];
    if (letter == null) return; // Empty slot

    setState(() {
      // Find the first empty slot in shuffled letters array
      final emptySlotIndex = _shuffledLetters.indexOf('');
      if (emptySlotIndex != -1) {
        _shuffledLetters[emptySlotIndex] = letter;
      } else {
        _shuffledLetters.add(letter);
      }

      // Empty this solution slot
      _userSolution[index] = null;
    });
  }

  void _checkSolution() {
    // If there are still empty slots, solution is not complete
    if (_userSolution.contains(null)) return;

    final userWord = _userSolution.join('');
    final correctWord = _gameWords[_currentWordIndex].word;

    if (userWord.toLowerCase() == correctWord.toLowerCase()) {
      // Correct solution
      setState(() {
        _isSolved = true;
      });

      // Show success dialog with word details
      Future.delayed(Duration(milliseconds: 500), () {
        _showWordDetailsDialog();
      });
    } else {
      // Wrong solution - shake the word and reset
      _animationController.forward().then((_) {
        _animationController.reset();

        // Return letters to original arrangement
        setState(() {
          // Restore the original arrangement
          _shuffledLetters = List.from(_originalShuffledArrangement);

          // Clear user solution
          for (int i = 0; i < _userSolution.length; i++) {
            _userSolution[i] = null;
          }

          // Mark letters as used that are in the solution
          for (int i = 0; i < _shuffledLetters.length; i++) {
            for (int j = 0; j < _userSolution.length; j++) {
              if (_userSolution[j] == _shuffledLetters[i]) {
                _shuffledLetters[i] = '';
                break;
              }
            }
          }
        });
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
                  Text(
                    word.word,
                    style: TextStyle(
                      fontSize: 20 * pix,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
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
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.purple.shade200, Colors.indigo.shade50],
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
                title: 'Xếp chữ: ${widget.topicName}',
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
    );
  }

  Widget _buildBody(BuildContext context, double pix, bool isDarkMode) {
    if (_isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    if (_hasError) {
      return Center(
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
      );
    }

    if (_isPaused) {
      return _buildPausedView(pix, isDarkMode);
    }

    return Column(
      children: [
        _buildGameHeader(pix, isDarkMode),
        Expanded(
          child: _buildScrambleGame(pix, isDarkMode),
        ),
      ],
    );
  }

  Widget _buildGameHeader(double pix, bool isDarkMode) {
    final currentWord = _gameWords[_currentWordIndex];

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24 * pix, vertical: 16 * pix),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.timer,
                    size: 24 * pix,
                    color: _timeLeft < 20 ? Colors.red : Colors.blue,
                  ),
                  SizedBox(width: 8 * pix),
                  Text(
                    _formatTime(_timeLeft),
                    style: TextStyle(
                      fontSize: 18 * pix,
                      fontWeight: FontWeight.bold,
                      color: _timeLeft < 20 ? Colors.red : Colors.blue,
                    ),
                  ),
                ],
              ),
              IconButton(
                icon: Icon(
                  Icons.pause_circle_filled,
                  size: 28 * pix,
                  color: Colors.blue,
                ),
                onPressed: _pauseGame,
              ),
            ],
          ),
          SizedBox(height: 16 * pix),
          Text(
            'Từ ${_currentWordIndex + 1}/${_gameWords.length}',
            style: TextStyle(
              fontSize: 18 * pix,
              fontWeight: FontWeight.bold,
              color: isDarkMode ? Colors.white : Colors.black87,
            ),
          ),
          SizedBox(height: 8 * pix),
          Text(
            'Sắp xếp các chữ cái để tạo thành từ tiếng Anh',
            style: TextStyle(
              fontSize: 14 * pix,
              fontWeight: FontWeight.w500,
              color: isDarkMode ? Colors.white70 : Colors.black54,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildScrambleGame(double pix, bool isDarkMode) {
    return Padding(
      padding: EdgeInsets.all(16 * pix),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Solution area
          AnimatedBuilder(
            animation: _shakeAnimation,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(
                  sin(_animationController.value * 3 * pi) * 10,
                  0,
                ),
                child: child,
              );
            },
            child: Container(
              margin: EdgeInsets.symmetric(vertical: 20 * pix),
              padding: EdgeInsets.all(16 * pix),
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
              child: Wrap(
                alignment: WrapAlignment.center,
                spacing: 8 * pix,
                runSpacing: 8 * pix,
                children: List.generate(
                  _userSolution.length,
                  (index) => _buildLetterTile(
                    _userSolution[index] ?? '',
                    isDarkMode,
                    pix,
                    () => _onSolutionLetterTap(index),
                    isEmpty: _userSolution[index] == null,
                    isPlaceholder: true,
                  ),
                ),
              ),
            ),
          ),

          SizedBox(height: 30 * pix),

          // Shuffled letters area
          Container(
            margin: EdgeInsets.symmetric(vertical: 10 * pix),
            padding: EdgeInsets.all(16 * pix),
            decoration: BoxDecoration(
              color: isDarkMode
                  ? Color(0xFF2A2A42).withOpacity(0.5)
                  : Colors.white.withOpacity(0.7),
              borderRadius: BorderRadius.circular(16 * pix),
            ),
            child: Wrap(
              alignment: WrapAlignment.center,
              spacing: 8 * pix,
              runSpacing: 8 * pix,
              children: List.generate(
                _shuffledLetters.length,
                (index) => _buildLetterTile(
                  _shuffledLetters[index],
                  isDarkMode,
                  pix,
                  () => _onShuffledLetterTap(index),
                  isEmpty: _shuffledLetters[index].isEmpty,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLetterTile(
      String letter, bool isDarkMode, double pix, VoidCallback onTap,
      {bool isEmpty = false, bool isPlaceholder = false}) {
    return GestureDetector(
      onTap: isEmpty ? null : onTap,
      child: Container(
        width: 45 * pix,
        height: 45 * pix,
        decoration: BoxDecoration(
          color: isEmpty
              ? Colors.transparent
              : (isPlaceholder
                  ? (isDarkMode
                      ? Colors.purple.withOpacity(0.3)
                      : Colors.purple.withOpacity(0.1))
                  : (isDarkMode
                      ? Colors.blue.withOpacity(0.3)
                      : Colors.blue.withOpacity(0.1))),
          borderRadius: BorderRadius.circular(8 * pix),
          border: Border.all(
            color: isEmpty
                ? (isPlaceholder
                    ? Colors.purple.withOpacity(0.5)
                    : Colors.transparent)
                : (isPlaceholder ? Colors.purple : Colors.blue),
            width: 2,
          ),
        ),
        child: Center(
          child: Text(
            letter.toUpperCase(),
            style: TextStyle(
              fontSize: 22 * pix,
              fontWeight: FontWeight.bold,
              color: isPlaceholder
                  ? (isDarkMode ? Colors.purple[200] : Colors.purple[700])
                  : (isDarkMode ? Colors.blue[200] : Colors.blue[700]),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPausedView(double pix, bool isDarkMode) {
    return Center(
      child: Column(
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
              color: isDarkMode ? Colors.white : Colors.black87,
            ),
          ),
          SizedBox(height: 16 * pix),
          Text(
            'Thời gian còn lại: ${_formatTime(_timeLeft)}',
            style: TextStyle(
              fontSize: 18 * pix,
              color: isDarkMode ? Colors.white70 : Colors.black54,
            ),
          ),
          SizedBox(height: 32 * pix),
          ElevatedButton.icon(
            icon: Icon(Icons.play_arrow),
            label: Text('Tiếp Tục Chơi'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              padding: EdgeInsets.symmetric(
                  horizontal: 24 * pix, vertical: 12 * pix),
              textStyle: TextStyle(fontSize: 16 * pix),
            ),
            onPressed: _resumeGame,
          ),
        ],
      ),
    );
  }
}
