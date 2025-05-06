import 'package:flutter/material.dart';
import 'package:language_app/duy_anh/vocab_game/vocabulary_game_play_screen.dart';
import 'package:language_app/provider/vocab_topic_provider.dart';
import 'package:language_app/widget/top_bar.dart';
import 'package:provider/provider.dart';

class VocabularyTopicScreen extends StatefulWidget {
  final String topic;
  const VocabularyTopicScreen({super.key, required this.topic});

  @override
  State<VocabularyTopicScreen> createState() => _VocabularyTopicScreenState();
}

class _VocabularyTopicScreenState extends State<VocabularyTopicScreen> {
  @override
  void initState() {
    super.initState();

    // Load data from the provider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final topicProvider =
          Provider.of<VocabularyTopicProvider>(context, listen: false);
      // Use topic name as ID for simplicity
      topicProvider.fetchLeaderboard(widget.topic);
    });
  }

  @override
  Widget build(BuildContext context) {
    final pix = MediaQuery.of(context).size.width / 375;
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
              child: TopBar(title: 'Chủ Đề: ${widget.topic}'),
            ),
            Positioned(
              top: 110 * pix,
              left: 16 * pix,
              right: 16 * pix,
              bottom: 16 * pix,
              child: Consumer<VocabularyTopicProvider>(
                  builder: (context, topicProvider, child) {
                if (topicProvider.isLoading) {
                  return Center(child: CircularProgressIndicator());
                }

                if (topicProvider.errorMessage != null) {
                  return Center(
                    child: Text(
                      topicProvider.errorMessage!,
                      style: TextStyle(color: Colors.red),
                    ),
                  );
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Tiêu đề bảng xếp hạng
                    Row(
                      children: [
                        Text(
                          'Bảng Xếp Hạng Bạn Bè',
                          style: TextStyle(
                            fontSize: 20 * pix,
                            fontFamily: 'BeVietnamPro',
                            fontWeight: FontWeight.w600,
                            color: isDarkMode
                                ? Colors.white
                                : const Color(0xFF1C2526),
                          ),
                        ),
                        SizedBox(width: 8 * pix),
                        Container(
                          height: 2 * pix,
                          width: 40 * pix,
                          color: isDarkMode
                              ? Colors.grey[700]
                              : const Color(0xFFE5E7EB),
                        ),
                      ],
                    ),
                    SizedBox(height: 16 * pix),
                    // Danh sách bạn bè
                    ...topicProvider.leaderboard.asMap().entries.map((entry) {
                      final index = entry.key;
                      final data = entry.value;
                      return Padding(
                        padding: EdgeInsets.only(bottom: 8 * pix),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          curve: Curves.easeInOut,
                          padding: EdgeInsets.all(12 * pix),
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
                              CircleAvatar(
                                radius: 14 * pix,
                                backgroundColor:
                                    const Color(0xFF10B981).withOpacity(0.1),
                                child: Text(
                                  '${index + 1}',
                                  style: TextStyle(
                                    fontSize: 14 * pix,
                                    fontFamily: 'BeVietnamPro',
                                    color: const Color(0xFF10B981),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              SizedBox(width: 12 * pix),
                              Expanded(
                                child: Text(
                                  data.name,
                                  style: TextStyle(
                                    fontSize: 16 * pix,
                                    fontFamily: 'BeVietnamPro',
                                    color: isDarkMode
                                        ? Colors.white
                                        : const Color(0xFF1C2526),
                                  ),
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 8 * pix, vertical: 4 * pix),
                                decoration: BoxDecoration(
                                  color:
                                      const Color(0xFF3B82F6).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8 * pix),
                                ),
                                child: Text(
                                  '${data.time ~/ 60}:${(data.time % 60).toString().padLeft(2, '0')}',
                                  style: TextStyle(
                                    fontSize: 14 * pix,
                                    fontFamily: 'BeVietnamPro',
                                    color: const Color(0xFF3B82F6),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                    SizedBox(height: 24 * pix),
                    // Thành tích của bạn
                    Text(
                      'Thành Tích Của Bạn',
                      style: TextStyle(
                        fontSize: 20 * pix,
                        fontFamily: 'BeVietnamPro',
                        fontWeight: FontWeight.w600,
                        color:
                            isDarkMode ? Colors.white : const Color(0xFF1C2526),
                      ),
                    ),
                    SizedBox(height: 8 * pix),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: EdgeInsets.all(12 * pix),
                      decoration: BoxDecoration(
                        color:
                            isDarkMode ? const Color(0xFF1E1E2F) : Colors.white,
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
                          Icon(
                            topicProvider.hasPersonalBest
                                ? Icons.timer
                                : Icons.timer_off,
                            size: 24 * pix,
                            color: isDarkMode
                                ? Colors.grey[400]
                                : Colors.grey[600],
                          ),
                          SizedBox(width: 12 * pix),
                          Expanded(
                            child: Text(
                              topicProvider.hasPersonalBest
                                  ? 'Kỷ lục của bạn'
                                  : 'Chưa hoàn thành',
                              style: TextStyle(
                                fontSize: 16 * pix,
                                fontFamily: 'BeVietnamPro',
                                color: isDarkMode
                                    ? Colors.white
                                    : const Color(0xFF1C2526),
                              ),
                            ),
                          ),
                          Text(
                            topicProvider.hasPersonalBest
                                ? '${topicProvider.personalBestTime! ~/ 60}:${(topicProvider.personalBestTime! % 60).toString().padLeft(2, '0')}'
                                : '--:--',
                            style: TextStyle(
                              fontSize: 16 * pix,
                              fontFamily: 'BeVietnamPro',
                              color: isDarkMode
                                  ? Colors.grey[400]
                                  : Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 32 * pix),
                    // Nút bắt đầu
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => VocabularyGamePlayScreen(
                                      topicId: widget
                                          .topic, // Using topic as ID for simplicity
                                      topicName: widget.topic,
                                    )),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 16 * pix),
                          backgroundColor: const Color(0xFF10B981),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12 * pix)),
                          elevation: 0,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.play_arrow, size: 20 * pix),
                            SizedBox(width: 8 * pix),
                            Text(
                              'Bắt Đầu',
                              style: TextStyle(
                                fontSize: 18 * pix,
                                fontFamily: 'BeVietnamPro',
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
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
