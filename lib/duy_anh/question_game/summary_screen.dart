import 'package:flutter/material.dart';
import 'package:language_app/duy_anh/question_game/quiz_screen.dart';
import 'package:language_app/provider/exam_provider.dart';
import 'package:language_app/widget/top_bar.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';

class SummaryScreen extends StatefulWidget {
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
  State<SummaryScreen> createState() => _SummaryScreenState();
}

class _SummaryScreenState extends State<SummaryScreen> {
  // Store all questions from both single questions and sections
  List<Map<String, dynamic>> allQuestions = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    // Process all questions from exam when the screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _processExamQuestions();
    });
  }

  void _processExamQuestions() {
    final examProvider = Provider.of<ExamProvider>(context, listen: false);
    final exam = examProvider.currentExam;

    if (exam == null) {
      setState(() {
        allQuestions = [];
        isLoading = false;
      });
      return;
    }

    // Use the provider's combined question list instead of rebuilding it
    final providerQuestions = examProvider.allQuestions;
    print(
        "SummaryScreen: Retrieved ${providerQuestions.length} questions from provider");

    setState(() {
      // Create a copy of the provider's question list
      allQuestions = List<Map<String, dynamic>>.from(providerQuestions);
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final pix = size.width / 375;
    final scorePercentage =
        (widget.score / widget.totalQuestions * 100).round();
    final examProvider = Provider.of<ExamProvider>(context, listen: false);
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
                  if (!widget.submissionSuccess) _buildSubmissionStatus(),

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
                            widget.examTitle,
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
                                '${widget.score}',
                                Colors.green,
                              ),
                              _buildScoreCircle(
                                context,
                                'Sai',
                                '${widget.totalQuestions - widget.score}',
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
                  if (isLoading) ...[
                    const Expanded(
                      child: Center(
                        child: CircularProgressIndicator(),
                      ),
                    ),
                  ] else if (allQuestions.isEmpty) ...[
                    Expanded(
                      child: Center(
                        child: Text(
                          'Không có kết quả chi tiết',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                      ),
                    ),
                  ] else ...[
                    Expanded(
                      child: ListView.separated(
                        itemCount: allQuestions.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          // Make sure we don't go out of bounds
                          if (index >= widget.answers.length ||
                              index >= allQuestions.length) {
                            return const SizedBox();
                          }

                          final questionData = allQuestions[index];
                          final question = questionData['question'];
                          final sectionTitle = questionData['sectionTitle'];
                          final isCorrect = widget.answers[index] == true;
                          final userAnswer = widget.answers[index];

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
                                sectionTitle != null
                                    ? 'Câu hỏi ${index + 1} (${sectionTitle})'
                                    : 'Câu hỏi ${index + 1}',
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
                                      if (question.mediaUrl != null) ...[
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
                                              imageUrl: question.mediaUrl!,
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
                                        question.question,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      const SizedBox(height: 12),

                                      // Show all options
                                      if (question.options != null) ...[
                                        ...processOptions(question.options!)
                                            .map((option) {
                                          final isCorrectOption =
                                              option == question.answer;
                                          final isSelectedOption = index <
                                                  widget.userSelectedAnswers
                                                      .length &&
                                              widget.userSelectedAnswers[
                                                      index] ==
                                                  option;
                                          final bool isWrongSelection =
                                              isSelectedOption &&
                                                  !isCorrectOption;

                                          return Container(
                                            margin: const EdgeInsets.only(
                                                bottom: 8),
                                            decoration: BoxDecoration(
                                              color: isCorrectOption
                                                  ? Colors.green
                                                      .withOpacity(0.1)
                                                  : (isWrongSelection
                                                      ? Colors.red
                                                          .withOpacity(0.1)
                                                      : Colors.grey
                                                          .withOpacity(0.05)),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              border: Border.all(
                                                color: isCorrectOption
                                                    ? Colors.green
                                                    : (isWrongSelection
                                                        ? Colors.red
                                                        : Colors.grey.shade300),
                                                width: 1.5,
                                              ),
                                            ),
                                            padding: const EdgeInsets.all(12),
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
                                                          ? Colors
                                                              .green.shade800
                                                          : (isWrongSelection
                                                              ? Colors
                                                                  .red.shade800
                                                              : Colors.black87),
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(width: 8),
                                                if (isSelectedOption &&
                                                    !isCorrectOption)
                                                  const Icon(
                                                    Icons.info,
                                                    color: Colors.red,
                                                    size: 18,
                                                  ),
                                              ],
                                            ),
                                          );
                                        }).toList(),
                                      ] else if (question.type ==
                                          "fill_in_blank") ...[
                                        Row(
                                          children: [
                                            const Text(
                                              'Đáp án đúng: ',
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            Text(
                                              question.answer,
                                              style: const TextStyle(
                                                color: Colors.green,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        Row(
                                          children: [
                                            const Text(
                                              'Bạn đã trả lời: ',
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            Text(
                                              index <
                                                      widget.userSelectedAnswers
                                                          .length
                                                  ? widget.userSelectedAnswers[
                                                      index]
                                                  : 'Không có đáp án',
                                              style: TextStyle(
                                                color: isCorrect
                                                    ? Colors.green
                                                    : Colors.red,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],

                                      // Explanation if available
                                      if (question.explanation != null) ...[
                                        const SizedBox(height: 16),
                                        Container(
                                          width: double.infinity,
                                          padding: const EdgeInsets.all(12),
                                          decoration: BoxDecoration(
                                            color:
                                                Colors.amber.withOpacity(0.1),
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            border: Border.all(
                                                color: Colors.amber.shade300),
                                          ),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              const Text(
                                                'Giải thích:',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.amber,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(question.explanation!),
                                            ],
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
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton.icon(
                          onPressed: () => Navigator.of(context).pop(),
                          icon: const Icon(Icons.arrow_back),
                          label: const Text('Quay lại'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.blue[800],
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                              side: BorderSide(color: Colors.blue[800]!),
                            ),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 12),
                          ),
                        ),
                        ElevatedButton.icon(
                          onPressed: () {
                            Navigator.of(context).pushReplacement(
                              MaterialPageRoute(
                                builder: (context) => QuizScreen(
                                  examId: widget.examId,
                                  title: widget.examTitle,
                                ),
                              ),
                            );
                          },
                          icon: const Icon(Icons.replay),
                          label: const Text('Làm lại'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue[800],
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 12),
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
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.orange),
      ),
      child: Row(
        children: [
          const Icon(Icons.warning, color: Colors.orange),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Cảnh báo',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.orange,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Đã xảy ra lỗi khi gửi kết quả của bạn. Kết quả có thể không được lưu.',
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () {
                    // Attempt to resubmit the result
                    Provider.of<ExamProvider>(context, listen: false)
                        .submitExamResult(widget.examId, widget.score);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: const Text('Thử lại'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScoreCircle(
      BuildContext context, String label, String value, Color color) {
    return Column(
      children: [
        Container(
          width: 70,
          height: 70,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color.withOpacity(0.1),
            border: Border.all(color: color, width: 2),
          ),
          child: Center(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[700],
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Color _getScoreColor(int scorePercentage) {
    if (scorePercentage >= 80) return Colors.green;
    if (scorePercentage >= 60) return Colors.amber;
    if (scorePercentage >= 40) return Colors.orange;
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
