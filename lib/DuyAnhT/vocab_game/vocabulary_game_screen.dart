import 'package:flutter/material.dart';
import 'package:language_app/DuyAnhT/vocab_game/vocabulary_topic_screen.dart';
import 'package:language_app/widget/top_bar.dart';
import 'package:language_app/provider/vocab_game_screen_provider.dart';
import 'package:provider/provider.dart';

class VocabularyGameScreen extends StatefulWidget {
  const VocabularyGameScreen({super.key});

  @override
  State<VocabularyGameScreen> createState() => _VocabularyGameScreenState();
}

class _VocabularyGameScreenState extends State<VocabularyGameScreen> {
  @override
  void initState() {
    super.initState();
    // The provider auto-fetches topics in constructor
  }

  @override
  Widget build(BuildContext context) {
    final pix = (MediaQuery.of(context).size.width / 375).clamp(0.8, 1.2);
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
              left: 0,
              right: 0,
              child: TopBar(title: 'Luyện Từ Vựng'),
            ),
            Positioned(
              top: 100 * pix,
              left: 16 * pix,
              right: 16 * pix,
              bottom: 0,
              child: Consumer<VocabularyGameScreenProvider>(
                  builder: (context, gameProvider, child) {
                if (gameProvider.isLoading) {
                  return Center(child: CircularProgressIndicator());
                }

                if (gameProvider.errorMessage != null) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          gameProvider.errorMessage!,
                          style: TextStyle(color: Colors.red),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => gameProvider.fetchTopics(),
                          child: Text('Thử lại'),
                        ),
                      ],
                    ),
                  );
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: EdgeInsets.all(16 * pix),
                      child: Text(
                        'Chọn Chủ Đề',
                        style: TextStyle(
                          fontSize: 24 * pix,
                          fontFamily: 'BeVietnamPro',
                          fontWeight: FontWeight.w700,
                          color: isDarkMode
                              ? Colors.white
                              : const Color(0xFF1C2526),
                        ),
                      ),
                    ),
                    SizedBox(height: 8 * pix),
                    Text(
                      'Khám phá các trò chơi từ vựng theo chủ đề',
                      style: TextStyle(
                        fontSize: 14 * pix,
                        fontFamily: 'BeVietnamPro',
                        color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                      ),
                    ),
                    SizedBox(height: 24 * pix),
                    // Danh sách chủ đề
                    ...gameProvider.topics.map((topic) {
                      return Padding(
                        padding: EdgeInsets.only(bottom: 8 * pix),
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    VocabularyTopicScreen(topic: topic.name),
                              ),
                            );
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            curve: Curves.easeInOut,
                            padding: EdgeInsets.all(16 * pix),
                            decoration: BoxDecoration(
                              color: isDarkMode
                                  ? const Color(0xFF1E1E2F)
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(12 * pix),
                              border: Border.all(
                                color: isDarkMode
                                    ? Colors.grey[800]!
                                    : const Color(0xFFE5E7EB),
                                width: 1,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black
                                      .withOpacity(isDarkMode ? 0.3 : 0.05),
                                  spreadRadius: 1,
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.all(10 * pix),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF10B981)
                                        .withOpacity(0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    gameProvider.getIconForTopic(topic.name),
                                    size: 24 * pix,
                                    color: const Color(0xFF10B981),
                                  ),
                                ),
                                SizedBox(width: 16 * pix),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        topic.name,
                                        style: TextStyle(
                                          fontSize: 18 * pix,
                                          fontFamily: 'BeVietnamPro',
                                          fontWeight: FontWeight.w600,
                                          color: isDarkMode
                                              ? Colors.white
                                              : const Color(0xFF1C2526),
                                        ),
                                      ),
                                      SizedBox(height: 4 * pix),
                                      Text(
                                        topic.description,
                                        style: TextStyle(
                                          fontSize: 14 * pix,
                                          fontFamily: 'BeVietnamPro',
                                          color: isDarkMode
                                              ? Colors.grey[400]
                                              : Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Icon(
                                  Icons.arrow_forward_ios,
                                  size: 18 * pix,
                                  color: const Color(0xFF10B981),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ],
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
