import 'package:flutter/material.dart';
import 'package:language_app/models/topic_model.dart';
import 'package:language_app/duy_anh/vocab_game/vocabulary_game_play_screen.dart';
import 'package:language_app/duy_anh/vocab_game/vocabulary_listening_game_screen.dart';
import 'package:language_app/duy_anh/vocab_game/vocabulary_scramble_game_screen.dart';
import 'package:language_app/provider/topic_provider.dart';
import 'package:language_app/widget/top_bar.dart';
import 'package:provider/provider.dart';

class VocabularyGameTopicsScreen extends StatefulWidget {
  const VocabularyGameTopicsScreen({super.key});

  @override
  State<VocabularyGameTopicsScreen> createState() =>
      _VocabularyGameTopicsScreenState();
}

class _VocabularyGameTopicsScreenState
    extends State<VocabularyGameTopicsScreen> {
  bool _isLoading = true;
  bool _hasError = false;
  String _errorMessage = "";

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadTopics();
    });
  }

  Future<void> _loadTopics() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
      _errorMessage = "";
    });

    final topicProvider = Provider.of<TopicProvider>(context, listen: false);

    try {
      await topicProvider.fetchTopics();
    } catch (e) {
      print('Error loading topics: $e');
      setState(() {
        _hasError = true;
        _errorMessage = "Không thể tải danh sách chủ đề. Vui lòng thử lại sau.";
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
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
                title: 'Trò Chơi Từ Vựng',
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
              onPressed: _loadTopics,
              child: Text('Thử lại'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xff165598),
              ),
            ),
          ],
        ),
      );
    }

    return Consumer<TopicProvider>(
      builder: (context, topicProvider, child) {
        final topics = topicProvider.topics;

        if (topics.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.category_outlined,
                  size: 50 * pix,
                  color: isDarkMode ? Colors.white70 : Colors.grey[700],
                ),
                SizedBox(height: 16 * pix),
                Text(
                  'Không có chủ đề nào',
                  style: TextStyle(
                    fontSize: 18 * pix,
                    fontFamily: 'BeVietnamPro',
                    color: isDarkMode ? Colors.white70 : Colors.grey[700],
                  ),
                ),
              ],
            ),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.only(
                  left: 24 * pix,
                  right: 24 * pix,
                  bottom: 12 * pix,
                  top: 10 * pix),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 10 * pix),
                  Text(
                    'Thử thách kiến thức với trò chơi từ vựng',
                    style: TextStyle(
                      fontSize: 14 * pix,
                      fontFamily: 'BeVietnamPro',
                      fontWeight: FontWeight.w500,
                      color:
                          isDarkMode ? Colors.white : const Color(0xFF1C2526),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: _loadTopics,
                child: ListView.builder(
                  padding: EdgeInsets.symmetric(
                      horizontal: 24 * pix, vertical: 8 * pix),
                  itemCount: topics.length,
                  itemBuilder: (context, index) {
                    final topic = topics[index];
                    return _buildGameTopicCard(context, topic, pix, isDarkMode);
                  },
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildGameTopicCard(
      BuildContext context, TopicModel topic, double pix, bool isDarkMode) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16 * pix),
      child: InkWell(
        onTap: () {
          _showGameOptionsDialog(context, topic, pix, isDarkMode);
        },
        borderRadius: BorderRadius.circular(16 * pix),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16 * pix),
            color: isDarkMode ? Color(0xFF1E1E2F) : Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                spreadRadius: 0,
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image section
              ClipRRect(
                borderRadius:
                    BorderRadius.vertical(top: Radius.circular(16 * pix)),
                child: Stack(
                  children: [
                    AspectRatio(
                      aspectRatio: 16 / 9,
                      child: topic.imageUrl.isNotEmpty
                          ? Image.network(
                              topic.imageUrl,
                              fit: BoxFit.cover,
                              loadingBuilder:
                                  (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return Center(
                                  child: CircularProgressIndicator(
                                    value: loadingProgress.expectedTotalBytes !=
                                            null
                                        ? loadingProgress
                                                .cumulativeBytesLoaded /
                                            loadingProgress.expectedTotalBytes!
                                        : null,
                                  ),
                                );
                              },
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: Colors.grey[200],
                                  child: Center(
                                    child: Icon(
                                      Icons.image_not_supported,
                                      color: Colors.grey[400],
                                      size: 40 * pix,
                                    ),
                                  ),
                                );
                              },
                            )
                          : Container(
                              color: Colors.grey[200],
                              child: Center(
                                child: Icon(
                                  Icons.image,
                                  color: Colors.grey[400],
                                  size: 40 * pix,
                                ),
                              ),
                            ),
                    ),
                    // Game type badge
                    Positioned(
                      top: 12 * pix,
                      left: 12 * pix,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 12 * pix,
                          vertical: 6 * pix,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.8),
                          borderRadius: BorderRadius.circular(20 * pix),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.videogame_asset,
                              color: Colors.white,
                              size: 14 * pix,
                            ),
                            SizedBox(width: 4 * pix),
                            Text(
                              'Trò Chơi',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 12 * pix,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Content section
              Padding(
                padding: EdgeInsets.all(16 * pix),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      topic.topic,
                      style: TextStyle(
                        fontSize: 18 * pix,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'BeVietnamPro',
                        color: isDarkMode ? Colors.white : Colors.black87,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 8 * pix),
                    Row(
                      children: [
                        // Level indicator
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 10 * pix,
                            vertical: 4 * pix,
                          ),
                          decoration: BoxDecoration(
                            color: _getLevelColor(topic.level).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8 * pix),
                          ),
                          child: Text(
                            topic.translevel(),
                            style: TextStyle(
                              fontSize: 12 * pix,
                              fontWeight: FontWeight.w600,
                              color: _getLevelColor(topic.level),
                            ),
                          ),
                        ),
                        Spacer(),
                        ElevatedButton.icon(
                          icon: Icon(Icons.play_arrow, size: 16 * pix),
                          label: Text('Chơi ngay'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(
                                horizontal: 12 * pix, vertical: 6 * pix),
                            textStyle: TextStyle(
                              fontSize: 12 * pix,
                              fontWeight: FontWeight.bold,
                            ),
                            elevation: 0,
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => VocabularyGamePlayScreen(
                                    topicId: topic.id, topicName: topic.topic),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showGameOptionsDialog(
      BuildContext context, TopicModel topic, double pix, bool isDarkMode) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: isDarkMode ? Color(0xFF1E1E2F) : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16 * pix),
          ),
          child: Padding(
            padding: EdgeInsets.all(20 * pix),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Chọn thử thách',
                  style: TextStyle(
                    fontSize: 20 * pix,
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? Colors.white : Colors.black87,
                  ),
                ),
                SizedBox(height: 16 * pix),

                // Word Link Game
                _buildGameOptionButton(
                  context: context,
                  icon: Icons.link,
                  title: 'Nối Từ',
                  description: 'Nối từ tiếng Anh với nghĩa tiếng Việt',
                  color: Colors.blue,
                  onTap: () {
                    Navigator.pop(context); // Close dialog
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => VocabularyGamePlayScreen(
                          topicId: topic.id,
                          topicName: topic.topic,
                        ),
                      ),
                    );
                  },
                  pix: pix,
                  isDarkMode: isDarkMode,
                ),

                SizedBox(height: 12 * pix),

                // Scramble Game
                _buildGameOptionButton(
                  context: context,
                  icon: Icons.shuffle,
                  title: 'Xếp Chữ',
                  description: 'Sắp xếp các chữ cái để tạo thành từ tiếng Anh',
                  color: Colors.purple,
                  onTap: () {
                    Navigator.pop(context); // Close dialog
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => VocabularyScrambleGameScreen(
                          topicId: topic.id,
                          topicName: topic.topic,
                        ),
                      ),
                    );
                  },
                  pix: pix,
                  isDarkMode: isDarkMode,
                ),

                SizedBox(height: 12 * pix),

                // Listening Game
                _buildGameOptionButton(
                  context: context,
                  icon: Icons.volume_up,
                  title: 'Luyện Nghe',
                  description: 'Nghe và viết từ tiếng Anh bạn nghe được',
                  color: Colors.green,
                  onTap: () {
                    Navigator.pop(context); // Close dialog
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => VocabularyListeningGameScreen(
                          topicId: topic.id,
                          topicName: topic.topic,
                        ),
                      ),
                    );
                  },
                  pix: pix,
                  isDarkMode: isDarkMode,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildGameOptionButton({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String description,
    required Color color,
    required VoidCallback onTap,
    required double pix,
    required bool isDarkMode,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12 * pix),
        child: Container(
          padding: EdgeInsets.all(16 * pix),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12 * pix),
            color: isDarkMode ? Color(0xFF2A2A42) : color.withOpacity(0.1),
          ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(10 * pix),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 24 * pix,
                ),
              ),
              SizedBox(width: 16 * pix),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16 * pix,
                        fontWeight: FontWeight.bold,
                        color: isDarkMode ? Colors.white : Colors.black87,
                      ),
                    ),
                    SizedBox(height: 4 * pix),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 12 * pix,
                        color: isDarkMode ? Colors.white70 : Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: color,
                size: 16 * pix,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getLevelColor(String level) {
    switch (level) {
      case "1":
        return Colors.green;
      case "2":
        return Colors.orange;
      case "3":
        return Colors.red;
      default:
        return Colors.blue;
    }
  }
}
