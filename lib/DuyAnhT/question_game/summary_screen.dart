import 'package:flutter/material.dart';
import 'package:language_app/DuyAnhT/question_game/quiz_screen.dart';
import 'package:language_app/provider/exam_provider.dart';
import 'package:language_app/widget/top_bar.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';

class SummaryScreen extends StatelessWidget {
  final int examId;
  final String examTitle;
  final List<bool?> answers;
  final int score;
  final int totalQuestions;
  final bool submissionSuccess;
  final List<String> userSelectedAnswers;

  const SummaryScreen({
    super.key,
    required this.examId,
    required this.examTitle,
    required this.answers,
    required this.score,
    required this.totalQuestions,
    this.submissionSuccess = true,
    required this.userSelectedAnswers,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final pix = size.width / 375;
    final scorePercentage = (score / totalQuestions * 100).round();
    final examProvider = Provider.of<ExamProvider>(context, listen: false);

    // Make sure we have the exam data available
    final exam = examProvider.currentExam;

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
              child: TopBar(
                title: exam?.type == 'comprehensive'
                    ? 'Kết quả bài kiểm tra toàn diện'
                    : 'Kết quả bài kiểm tra',
              ),
            ),
            Positioned(
              top: 110 * pix,
              left: 16 * pix,
              right: 16 * pix,
              bottom: 16 * pix,
              child: Column(
                children: [
                  // Submission status (success/error)
                  if (!submissionSuccess) _buildSubmissionStatus(),

                  // Result summary card
                  Card(
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          Icon(
                            scorePercentage >= 70
                                ? Icons.celebration
                                : Icons.school,
                            size: 60,
                            color: scorePercentage >= 70
                                ? Colors.amber
                                : Colors.blue,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            scorePercentage >= 70
                                ? 'Bạn làm rất tốt!'
                                : 'Hãy tiếp tục luyện tập!',
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            examTitle,
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              _buildScoreCircle(
                                context,
                                'Điểm',
                                '$scorePercentage%',
                                _getScoreColor(scorePercentage),
                              ),
                              _buildScoreCircle(
                                context,
                                'Đúng',
                                '$score',
                                Colors.green,
                              ),
                              _buildScoreCircle(
                                context,
                                'Sai',
                                '${totalQuestions - score}',
                                Colors.red,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Detailed results
                  if (exam != null) ...[
                    Expanded(
                      child: ListView.separated(
                        itemCount: exam.examSingleQuestions.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          // Make sure we don't go out of bounds
                          if (index >= answers.length) return const SizedBox();

                          final questionItem = exam.examSingleQuestions[index];
                          final questionData = questionItem.question;
                          final isCorrect = answers[index] == true;
                          final userAnswer = answers[index];

                          return Card(
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: ExpansionTile(
                              leading: CircleAvatar(
                                backgroundColor: isCorrect
                                    ? Colors.green[50]
                                    : Colors.red[50],
                                foregroundColor:
                                    isCorrect ? Colors.green : Colors.red,
                                child:
                                    Icon(isCorrect ? Icons.check : Icons.close),
                              ),
                              title: Text(
                                'Câu hỏi ${index + 1}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              subtitle: Text(
                                userAnswer == null
                                    ? 'Chưa trả lời'
                                    : (isCorrect ? 'Đúng' : 'Sai'),
                                style: TextStyle(
                                  color: userAnswer == null
                                      ? Colors.grey
                                      : (isCorrect ? Colors.green : Colors.red),
                                ),
                              ),
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      if (questionData.mediaUrl != null) ...[
                                        Container(
                                          width: double.infinity,
                                          height: 150,
                                          margin:
                                              const EdgeInsets.only(bottom: 12),
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            border: Border.all(
                                                color: Colors.grey.shade300),
                                          ),
                                          child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            child: CachedNetworkImage(
                                              imageUrl: questionData.mediaUrl!,
                                              fit: BoxFit.contain,
                                              placeholder: (context, url) =>
                                                  Container(
                                                color: Colors.grey[200],
                                                child: const Center(
                                                  child:
                                                      CircularProgressIndicator(),
                                                ),
                                              ),
                                              errorWidget:
                                                  (context, url, error) =>
                                                      Container(
                                                color: Colors.grey[200],
                                                child: const Center(
                                                  child: Icon(Icons.error),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                      Text(
                                        questionData.question,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      const SizedBox(height: 12),

                                      // Show all options
                                      if (questionData.options != null) ...[
                                        ...processOptions(questionData.options!)
                                            .map((option) {
                                          final isCorrectOption =
                                              option == questionData.answer;
                                          final isSelectedOption =
                                              userSelectedAnswers[index] ==
                                                  option;
                                          final bool isWrongSelection =
                                              isSelectedOption &&
                                                  !isCorrectOption;

                                          return Padding(
                                            padding: const EdgeInsets.only(
                                                bottom: 8),
                                            child: Container(
                                              padding: const EdgeInsets.all(12),
                                              decoration: BoxDecoration(
                                                color: isCorrectOption
                                                    ? Colors.green[50]
                                                    : (isWrongSelection
                                                        ? Colors.red[50]
                                                        : Colors.grey[100]),
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                                border: Border.all(
                                                  color: isCorrectOption
                                                      ? Colors.green
                                                      : (isWrongSelection
                                                          ? Colors.red
                                                          : Colors.grey[300]!),
                                                ),
                                              ),
                                              child: Row(
                                                children: [
                                                  Icon(
                                                    isCorrectOption
                                                        ? Icons.check_circle
                                                        : (isWrongSelection
                                                            ? Icons.cancel
                                                            : Icons
                                                                .circle_outlined),
                                                    color: isCorrectOption
                                                        ? Colors.green
                                                        : (isWrongSelection
                                                            ? Colors.red
                                                            : Colors.grey),
                                                    size: 20,
                                                  ),
                                                  const SizedBox(width: 8),
                                                  Expanded(
                                                    child: Text(
                                                      option,
                                                      style: TextStyle(
                                                        color: isCorrectOption
                                                            ? Colors.green[800]
                                                            : (isWrongSelection
                                                                ? Colors
                                                                    .red[800]
                                                                : Colors
                                                                    .black87),
                                                      ),
                                                    ),
                                                  ),
                                                  if (isSelectedOption) ...[
                                                    Container(
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                        horizontal: 8,
                                                        vertical: 2,
                                                      ),
                                                      decoration: BoxDecoration(
                                                        color: Colors.blue[100],
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(12),
                                                      ),
                                                      child: Text(
                                                        'Đã chọn',
                                                        style: TextStyle(
                                                          fontSize: 12,
                                                          color:
                                                              Colors.blue[800],
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ],
                                              ),
                                            ),
                                          );
                                        }).toList(),
                                      ] else ...[
                                        // For fill-in-blank questions
                                        Container(
                                          padding: const EdgeInsets.all(12),
                                          decoration: BoxDecoration(
                                            color: Colors.blue[50],
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            border: Border.all(
                                                color: Colors.blue[300]!),
                                          ),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                "Câu trả lời của bạn:",
                                                style: TextStyle(
                                                  color: Colors.grey[700],
                                                  fontWeight: FontWeight.w500,
                                                  fontSize: 14,
                                                ),
                                              ),
                                              const SizedBox(height: 8),
                                              Container(
                                                width: double.infinity,
                                                padding:
                                                    const EdgeInsets.all(8),
                                                decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  borderRadius:
                                                      BorderRadius.circular(6),
                                                  border: Border.all(
                                                    color: isCorrect
                                                        ? Colors.green
                                                        : Colors.red,
                                                  ),
                                                ),
                                                child: Text(
                                                  userSelectedAnswers[index]
                                                          .isEmpty
                                                      ? "(Không có câu trả lời)"
                                                      : userSelectedAnswers[
                                                          index],
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

                                      const SizedBox(height: 12),
                                      Text(
                                        'Đáp án đúng:',
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 14,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Container(
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: Colors.green[50],
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          border: Border.all(
                                            color: Colors.green[100]!,
                                          ),
                                        ),
                                        child: Text(
                                          questionData.answer,
                                          style: const TextStyle(
                                            color: Colors.green,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),

                                      // Add explanation section if available
                                      if (questionData.explanation != null &&
                                          questionData
                                              .explanation!.isNotEmpty) ...[
                                        const SizedBox(height: 16),
                                        Text(
                                          'Giải thích:',
                                          style: TextStyle(
                                            color: Colors.grey[600],
                                            fontSize: 14,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Container(
                                          width: double.infinity,
                                          padding: const EdgeInsets.all(12),
                                          decoration: BoxDecoration(
                                            color: Colors.blue[50],
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            border: Border.all(
                                              color: Colors.blue[100]!,
                                            ),
                                          ),
                                          child: Text(
                                            questionData.explanation!,
                                            style: TextStyle(
                                              color: Colors.blue[800],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],

                  // Action buttons
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              // Refresh the appropriate exam list based on type
                              final examProvider = Provider.of<ExamProvider>(
                                  context,
                                  listen: false);

                              final examType =
                                  examProvider.currentExam?.type ?? 'weekly';
                              examProvider.refreshExams(examType).then((_) {
                                Navigator.pop(context, true);
                              });
                            },
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              side: BorderSide(color: Colors.blue[800]!),
                            ),
                            child: const Text(
                              'Quay lại',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              final examProvider = Provider.of<ExamProvider>(
                                  context,
                                  listen: false);

                              // Return true to original screen to indicate a refresh is needed
                              Navigator.pop(context, true);

                              // Then start the quiz again
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => QuizScreen(
                                    examId: examId,
                                    title: examTitle,
                                  ),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue[800],
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              'Làm lại',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubmissionStatus() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.red[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red[300]!),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: Colors.red),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Không thể gửi kết quả bài kiểm tra',
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Kết quả của bạn sẽ không được lưu. Vui lòng thử lại.',
                  style: TextStyle(color: Colors.red),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScoreCircle(
      BuildContext context, String title, String value, Color color) {
    return Column(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            shape: BoxShape.circle,
            border: Border.all(
              color: color,
              width: 2,
            ),
          ),
          child: Center(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Color _getScoreColor(int percentage) {
    if (percentage >= 80) return Colors.green;
    if (percentage >= 50) return Colors.amber;
    return Colors.red;
  }

  List<String> processOptions(List<String> options) {
    // Check if the options might be a JSON string in the first element
    if (options.length == 1 && options[0].startsWith('[')) {
      try {
        // Try to parse as JSON
        List<dynamic> parsed = json.decode(options[0]);
        return parsed.map((e) => e.toString()).toList();
      } catch (e) {
        print("Error parsing options: $e");
        return options;
      }
    }

    // Process individual options that might have JSON formatting
    return options.map((option) {
      if (option.startsWith('"') && option.endsWith('"')) {
        return option.substring(1, option.length - 1);
      }
      return option;
    }).toList();
  }
}
