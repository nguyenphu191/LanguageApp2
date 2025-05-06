import 'dart:async';
import 'package:flutter/material.dart';
import 'package:language_app/provider/vocabulary_game_provider.dart';
import 'package:language_app/widget/top_bar.dart';
import 'package:provider/provider.dart';
import 'package:language_app/duy_anh/vocab_game/vocabulary_transition_screen.dart';

class VocabularyGamePlayScreen extends StatefulWidget {
  final String topicId;
  final String topicName;

  const VocabularyGamePlayScreen({
    super.key,
    required this.topicId,
    required this.topicName,
  });

  @override
  State<VocabularyGamePlayScreen> createState() =>
      _VocabularyGamePlayScreenState();
}

class _VocabularyGamePlayScreenState extends State<VocabularyGamePlayScreen>
    with SingleTickerProviderStateMixin {
  bool _isLoading = true;
  bool _hasError = false;
  String _errorMessage = "";

  // Game cards for matrix layout
  List<GameCard> _allCards = [];
  GameCard? _selectedCard;
  bool _canSelect = true;

  // Game state
  int _score = 0;
  bool _gameCompleted = false;
  Timer? _timer;
  int _timeLeft = 120; // 2 minutes in seconds
  bool _isPaused = false;

  // Animation controller for wrong matches
  late AnimationController _animationController;
  List<String> _animatingCardIds = [];

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _animationController.reverse();
        } else if (status == AnimationStatus.dismissed &&
            _animatingCardIds.isNotEmpty) {
          setState(() {
            _animatingCardIds = [];
            _canSelect = true;
          });
        }
      });

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
          _endGame();
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

  void _endGame() {
    _timer?.cancel();
    setState(() {
      _gameCompleted = true;
    });

    // Navigate to transition screen instead of summary screen
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => VocabularyTransitionScreen(
          topicId: widget.topicId,
          topicName: widget.topicName,
          nextGameType: NextGameType.scramble,
        ),
      ),
    );
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
      // Fetch word link game data
      await gameProvider.fetchWordLinkGame(widget.topicId);

      if (gameProvider.errorMessage != null) {
        setState(() {
          _hasError = true;
          _errorMessage = gameProvider.errorMessage!;
          _isLoading = false;
        });
        return;
      }

      final wordPairs = gameProvider.wordPairs;

      if (wordPairs.isEmpty) {
        setState(() {
          _hasError = true;
          _errorMessage = "Không có từ vựng cho trò chơi này.";
          _isLoading = false;
        });
        return;
      }

      // Setup the game with the fetched word pairs
      _setupWordLinkGame(wordPairs);

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

  void _setupWordLinkGame(List<WordPair> wordPairs) {
    _allCards = [];

    // Limit to 8 word pairs for better gameplay
    final gameWordPairs =
        wordPairs.length > 8 ? wordPairs.sublist(0, 8) : wordPairs;

    // Create cards for words and translations
    for (var i = 0; i < gameWordPairs.length; i++) {
      _allCards.add(
        GameCard(
          id: i.toString(),
          content: gameWordPairs[i].word,
          isMatched: false,
          isWord: true,
        ),
      );
      final List<String> parts = gameWordPairs[i].translation.split(".");
      _allCards.add(
        GameCard(
          id: i.toString(),
          content: parts[0],
          isMatched: false,
          isWord: false,
        ),
      );
    }

    // Shuffle all cards
    _allCards.shuffle();
  }

  void _onCardTap(GameCard card) {
    if (!_canSelect || card.isMatched || _animatingCardIds.contains(card.id))
      return;

    setState(() {
      if (_selectedCard == null) {
        // First card selection
        _selectedCard = card;
      } else {
        // Second card selection - check for match
        _checkMatch(card);
      }
    });
  }

  void _checkMatch(GameCard secondCard) {
    // Can't match the same card
    if (_selectedCard!.content == secondCard.content &&
        _selectedCard!.isWord == secondCard.isWord) {
      return;
    }

    _canSelect = false;

    final isMatched = _selectedCard!.id == secondCard.id &&
        _selectedCard!.isWord != secondCard.isWord;

    if (isMatched) {
      // If matched, mark both cards as matched
      setState(() {
        // Find all cards with the matching ID
        for (var card in _allCards) {
          if (card.id == _selectedCard!.id) {
            card.isMatched = true;
          }
        }
        _selectedCard = null;
        _score++;
        _canSelect = true;
      });

      // Check if game is completed
      if (_allCards.every((card) => card.isMatched)) {
        _endGame();
      }
    } else {
      // If not matched, animate wrong match
      // Store the exact cards that didn't match
      final firstCardIndex = _allCards.indexWhere((card) =>
          card.content == _selectedCard!.content &&
          card.isWord == _selectedCard!.isWord);
      final secondCardIndex = _allCards.indexOf(secondCard);

      setState(() {
        _animatingCardIds = [
          firstCardIndex.toString(),
          secondCardIndex.toString()
        ];
      });

      _animationController.forward();

      // Clear selected card after animation
      Future.delayed(Duration(milliseconds: 600), () {
        if (mounted) {
          setState(() {
            _selectedCard = null;
          });
        }
      });
    }
  }

  void _resetGame() {
    _timer?.cancel();

    final gameProvider =
        Provider.of<VocabularyGameProvider>(context, listen: false);

    setState(() {
      _score = 0;
      _gameCompleted = false;
      _selectedCard = null;
      _canSelect = true;
      _timeLeft = 120;
      _isPaused = false;
      _animatingCardIds = [];

      // Re-setup game with the same word pairs
      if (gameProvider.wordPairs.isNotEmpty) {
        _setupWordLinkGame(gameProvider.wordPairs);
      }
    });

    _startTimer();
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
            colors: [Colors.blue.shade200, Colors.indigo.shade50],
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
                title: 'Nối từ: ${widget.topicName}',
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
          child: _buildGameMatrix(pix, isDarkMode),
        ),
      ],
    );
  }

  Widget _buildGameHeader(double pix, bool isDarkMode) {
    return Padding(
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
                  color: Colors.white.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(16 * pix),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 5,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.timer,
                      size: 24 * pix,
                      color: _timeLeft < 30 ? Colors.red : Colors.blue,
                    ),
                    SizedBox(width: 8 * pix),
                    Text(
                      _formatTime(_timeLeft),
                      style: TextStyle(
                        fontSize: 18 * pix,
                        fontWeight: FontWeight.bold,
                        color: _timeLeft < 30 ? Colors.red : Colors.blue,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(16 * pix),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 5,
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
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12 * pix),
              border: Border.all(color: Colors.blue.withOpacity(0.3), width: 1),
            ),
            child: Text(
              'Chọn các ô từ vựng và nghĩa tiếng Việt tương ứng',
              style: TextStyle(
                fontSize: 16 * pix,
                fontWeight: FontWeight.w500,
                color: Colors.blue.shade800,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGameMatrix(double pix, bool isDarkMode) {
    // Giảm số cột để ô to hơn
    final int crossAxisCount = _getCrossAxisCount(_allCards.length);

    // Tính toán kích thước tối ưu cho grid
    final width = MediaQuery.of(context).size.width;
    final itemWidth = (width - 40 * pix) / crossAxisCount; // Trừ đi padding

    // Tính toán chiều cao dựa trên độ dài nội dung trung bình
    final avgContentLength = _calculateAvgContentLength();
    final aspectRatio = _getAspectRatioBasedOnContent(avgContentLength);

    return Padding(
      padding: EdgeInsets.all(16 * pix),
      child: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          childAspectRatio: aspectRatio, // Sử dụng tỷ lệ động
          crossAxisSpacing: 12 * pix, // Tăng khoảng cách giữa các ô
          mainAxisSpacing: 12 * pix, // Tăng khoảng cách giữa các ô
        ),
        itemCount: _allCards.length,
        itemBuilder: (context, index) {
          final card = _allCards[index];
          final bool isSelected = _selectedCard != null &&
              _selectedCard!.content == card.content &&
              _selectedCard!.isWord == card.isWord;
          final bool isAnimating = _animatingCardIds.contains(index.toString());

          // Tính kích thước font dựa trên độ dài nội dung
          final fontSize = _calculateFontSize(card.content.length) * pix;

          return GestureDetector(
            onTap: () => _onCardTap(card),
            child: AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return Container(
                  decoration: BoxDecoration(
                    color: card.isMatched
                        ? Colors.transparent
                        : card.isWord
                            ? Colors.cyanAccent.withOpacity(0.2)
                            : Colors.amberAccent.withOpacity(0.2),
                    borderRadius:
                        BorderRadius.circular(12 * pix), // Bo góc nhiều hơn
                    border: Border.all(
                      color: _getCardBorderColor(card, isSelected, isAnimating),
                      width: 2 * pix,
                    ),
                  ),
                  child: card.isMatched
                      ? Container() // Empty container for matched cards
                      : Center(
                          child: Container(
                            padding: EdgeInsets.all(10 * pix),
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                card.content,
                                style: TextStyle(
                                  fontSize: fontSize, // Kích thước font động
                                  fontWeight: card.isWord
                                      ? FontWeight.bold
                                      : FontWeight.w500,
                                  color: _getCardTextColor(card, isSelected,
                                      isAnimating, isDarkMode),
                                ),
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                        ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  // Tính toán số cột dựa trên số ô và kích thước màn hình
  int _getCrossAxisCount(int totalCards) {
    // Giảm số cột xuống để ô to hơn
    if (totalCards <= 4) return 2;
    if (totalCards <= 9) return 2; // Giảm từ 3 xuống 2
    if (totalCards <= 16) return 3; // Giảm từ 4 xuống 3
    return 3; // Mặc định là 3 thay vì 4
  }

  // Tính toán kích thước font dựa trên độ dài nội dung
  double _calculateFontSize(int contentLength) {
    if (contentLength <= 5) return 18.0;
    if (contentLength <= 10) return 16.0;
    if (contentLength <= 15) return 14.0;
    if (contentLength <= 20) return 12.0;
    return 11.0;
  }

  // Tính độ dài nội dung trung bình
  double _calculateAvgContentLength() {
    if (_allCards.isEmpty) return 10.0;
    int totalLength = 0;
    for (var card in _allCards) {
      totalLength += card.content.length;
    }
    return totalLength / _allCards.length;
  }

  // Lấy tỷ lệ khung hình dựa trên độ dài nội dung
  double _getAspectRatioBasedOnContent(double avgLength) {
    if (avgLength <= 5) return 1.0; // Gần như vuông
    if (avgLength <= 10) return 0.85;
    if (avgLength <= 15) return 0.8;
    return 0.75; // Cho phép chiều cao lớn hơn chiều rộng
  }

  Color _getCardColor(
      GameCard card, bool isSelected, bool isAnimating, bool isDarkMode) {
    if (card.isMatched) {
      return Colors.transparent;
    }

    if (isAnimating) {
      return Colors.red.withOpacity(_animationController.value * 0.5);
    }

    if (isSelected) {
      return isDarkMode
          ? Colors.blue.withOpacity(0.3)
          : Colors.blue.withOpacity(0.1);
    }

    return isDarkMode ? Color(0xFF2A2A42) : Colors.white;
  }

  Color _getCardBorderColor(GameCard card, bool isSelected, bool isAnimating) {
    if (card.isMatched) {
      return Colors.transparent;
    }

    if (isAnimating) {
      return Colors.red;
    }

    if (isSelected) {
      return Colors.blue;
    }

    return Colors.grey.withOpacity(0.3);
  }

  Color _getCardTextColor(
      GameCard card, bool isSelected, bool isAnimating, bool isDarkMode) {
    if (card.isMatched) {
      return Colors.transparent;
    }

    if (isAnimating) {
      return Colors.white;
    }

    if (isSelected) {
      return Colors.blue.shade700;
    }

    return isDarkMode ? Colors.white : Colors.blueGrey.shade800;
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
                color: Colors.blueGrey.shade800,
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
            SizedBox(height: 16 * pix),
            TextButton.icon(
              icon: Icon(Icons.restart_alt),
              label: Text('Chơi Lại'),
              style: TextButton.styleFrom(
                foregroundColor: Colors.blueGrey.shade700,
                padding: EdgeInsets.symmetric(
                    horizontal: 24 * pix, vertical: 12 * pix),
                textStyle: TextStyle(fontSize: 16 * pix),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16 * pix),
                  side: BorderSide(color: Colors.blue.withOpacity(0.3)),
                ),
              ),
              onPressed: _resetGame,
            ),
          ],
        ),
      ),
    );
  }
}

class GameCard {
  final String id;
  final String content;
  bool isMatched;
  final bool isWord;

  GameCard({
    required this.id,
    required this.content,
    required this.isMatched,
    required this.isWord,
  });
}
