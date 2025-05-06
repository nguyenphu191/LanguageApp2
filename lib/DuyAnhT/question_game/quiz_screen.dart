import 'package:flutter/material.dart';
import 'package:language_app/DuyAnhT/question_game/summary_screen.dart';
import 'package:language_app/provider/exam_provider.dart';
import 'package:language_app/widget/top_bar.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';

class QuizScreen extends StatefulWidget {
  final int examId;
  final String title;

  const QuizScreen({
    super.key,
    required this.examId,
    required this.title,
  });

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int currentQuestion = 0;
  int timeLeft = 300; // 5 minutes
  List<bool?> answers = [];
  List<String> selectedAnswers = [];
  bool isLoading = true;
  List<TextEditingController> _textControllers = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadExamData();
    });
  }

  Future<void> _loadExamData() async {
    setState(() {
      isLoading = true; // Ensure loading state is set before fetch
    });

    try {
      print("QuizScreen: Starting to load exam data for ID: ${widget.examId}");
      final examProvider = Provider.of<ExamProvider>(context, listen: false);

      // Reset current exam to ensure we're not using cached data
      if (examProvider.currentExam != null) {
        print("QuizScreen: Resetting previous exam data");
      }

      // Force fetch exam by ID
      await examProvider.fetchExamById(widget.examId);
      print("QuizScreen: Exam data fetched, examining results");

      if (mounted) {
        if (examProvider.examDetailError != null) {
          print(
              "QuizScreen: Error from provider: ${examProvider.examDetailError}");

          // Show error to user
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content:
                  Text('Error loading exam: ${examProvider.examDetailError}'),
              backgroundColor: Colors.red,
            ),
          );
        }

        setState(() {
          if (examProvider.currentExam != null &&
              examProvider.currentExam!.examSingleQuestions.isNotEmpty) {
            print(
                "QuizScreen: Setting up answers for ${examProvider.currentExam!.examSingleQuestions.length} questions");
            final questionCount =
                examProvider.currentExam!.examSingleQuestions.length;
            answers = List<bool?>.filled(questionCount, null);
            selectedAnswers = List<String>.filled(questionCount, '');

            // Initialize text controllers for each question
            _textControllers = List.generate(
              questionCount,
              (index) => TextEditingController(),
            );
          } else {
            // Handle case where there are no questions
            print("QuizScreen: No questions found in exam data");
            answers = [];
            selectedAnswers = [];
            _textControllers = [];

            // Show message to user if no questions available
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('No questions available for this exam'),
                backgroundColor: Colors.orange,
              ),
            );
          }
          isLoading = false;
        });

        // Only start timer if we have questions
        if (answers.isNotEmpty) {
          print("QuizScreen: Starting timer for ${answers.length} questions");
          _startTimer();
        }
      }
    } catch (e) {
      print("QuizScreen: Exception during load: $e");
      if (mounted) {
        setState(() {
          isLoading = false;
        });

        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading exam: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _startTimer() {
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        if (timeLeft > 0) {
          setState(() => timeLeft--);
          _startTimer();
        } else {
          _submitQuiz();
        }
      }
    });
  }

  void _showQuestionList() {
    final examProvider = Provider.of<ExamProvider>(context, listen: false);
    if (examProvider.currentExam == null) return;

    final questionCount = examProvider.currentExam!.examSingleQuestions.length;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16),
          height: MediaQuery.of(context).size.height * 0.4,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 10,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Column(
            children: [
              Text(
                'Danh sách câu hỏi',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[800],
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 5,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
                  itemCount: questionCount,
                  itemBuilder: (context, index) {
                    // Check if this question has been answered
                    bool isAnswered = false;

                    final questionData = examProvider
                        .currentExam!.examSingleQuestions[index].question;
                    if (questionData.type == 'multiple_choice') {
                      // For multiple choice, check if an option has been selected
                      isAnswered = selectedAnswers[index].isNotEmpty;
                    } else if (questionData.type == 'fill_in_blank') {
                      // For fill-in-blank, check if text has been entered
                      isAnswered = _textControllers[index].text.isNotEmpty;
                    }

                    return GestureDetector(
                      onTap: () {
                        _navigateToQuestion(index);
                        Navigator.pop(context);
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: currentQuestion == index
                              ? Colors.blue[100]
                              : (isAnswered
                                  ? Colors.green[100]
                                  : Colors.grey[200]),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: currentQuestion == index
                                ? Colors.blue
                                : (isAnswered
                                    ? Colors.green
                                    : Colors.transparent),
                            width: 2,
                          ),
                        ),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Text(
                              '${index + 1}',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: currentQuestion == index
                                    ? Colors.blue[800]
                                    : (isAnswered
                                        ? Colors.green[800]
                                        : Colors.black),
                              ),
                            ),
                            if (isAnswered)
                              Positioned(
                                top: 4,
                                right: 4,
                                child: Container(
                                  width: 8,
                                  height: 8,
                                  decoration: const BoxDecoration(
                                    color: Colors.green,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[800],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                ),
                child: const Text(
                  'Đóng',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _submitQuiz() async {
    final examProvider = Provider.of<ExamProvider>(context, listen: false);
    if (examProvider.currentExam == null) return;

    // Save the current fill-in-blank answer if there is one
    if (currentQuestion <
        examProvider.currentExam!.examSingleQuestions.length) {
      final currentQuestionData = examProvider
          .currentExam!.examSingleQuestions[currentQuestion].question;
      if (currentQuestionData.type == 'fill_in_blank' &&
          _textControllers.isNotEmpty &&
          currentQuestion < _textControllers.length) {
        selectedAnswers[currentQuestion] =
            _textControllers[currentQuestion].text;
      }
    }

    // Check for unanswered questions
    int unansweredCount = 0;
    for (int i = 0; i < selectedAnswers.length; i++) {
      final questionData =
          examProvider.currentExam!.examSingleQuestions[i].question;
      bool isAnswered = false;

      if (questionData.type == 'multiple_choice') {
        isAnswered = selectedAnswers[i].isNotEmpty;
      } else if (questionData.type == 'fill_in_blank') {
        isAnswered = selectedAnswers[i].isNotEmpty;
      }

      if (!isAnswered) {
        unansweredCount++;
      }
    }

    // If there are unanswered questions, show confirmation dialog
    if (unansweredCount > 0) {
      bool shouldContinue =
          await _showSubmitConfirmationDialog(unansweredCount);
      if (!shouldContinue) {
        return; // User chose to go back and finish answering
      }
    }

    // Now evaluate all answers
    for (int i = 0;
        i < examProvider.currentExam!.examSingleQuestions.length;
        i++) {
      final questionData =
          examProvider.currentExam!.examSingleQuestions[i].question;

      if (questionData.type == 'multiple_choice') {
        // For multiple choice, check if selected answer matches correct answer
        answers[i] = selectedAnswers[i] == questionData.answer;
      } else if (questionData.type == 'fill_in_blank') {
        // For fill-in-blank, compare answers ignoring case
        answers[i] = selectedAnswers[i].toLowerCase().trim() ==
            questionData.answer.toLowerCase().trim();
      } else {
        // Default case if there are other question types
        answers[i] = false;
      }
    }

    // Calculate the score
    int score = 0;
    for (int i = 0; i < answers.length; i++) {
      if (answers[i] == true) {
        score++;
      }
    }

    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text("Submitting your results..."),
          ],
        ),
      ),
    );

    // Submit the score to API
    bool success = await examProvider.submitExamResult(widget.examId, score);

    // Dismiss the loading dialog
    if (mounted) Navigator.pop(context);

    // Show success/error message and navigate
    if (mounted) {
      if (!success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Error submitting results: ${examProvider.resultSubmissionError}'),
            backgroundColor: Colors.red,
          ),
        );
      }

      // Navigate to summary screen for all exam types
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => SummaryScreen(
            examId: widget.examId,
            examTitle: widget.title,
            answers: answers,
            score: score,
            totalQuestions: answers.length,
            submissionSuccess: success,
            userSelectedAnswers: selectedAnswers,
          ),
        ),
      );
    }
  }

  void _navigateToQuestion(int index) {
    // Save current answer if it's a fill-in-blank question
    final examProvider = Provider.of<ExamProvider>(context, listen: false);
    if (examProvider.currentExam != null &&
        currentQuestion <
            examProvider.currentExam!.examSingleQuestions.length) {
      final currentQuestionData = examProvider
          .currentExam!.examSingleQuestions[currentQuestion].question;
      if (currentQuestionData.type == 'fill_in_blank' &&
          _textControllers.isNotEmpty &&
          currentQuestion < _textControllers.length) {
        selectedAnswers[currentQuestion] =
            _textControllers[currentQuestion].text;
      }
    }

    setState(() => currentQuestion = index);
  }

  // Check if all questions are answered
  bool _allQuestionsAnswered() {
    for (int i = 0; i < selectedAnswers.length; i++) {
      final examProvider = Provider.of<ExamProvider>(context, listen: false);
      if (examProvider.currentExam == null) return false;

      final questionData =
          examProvider.currentExam!.examSingleQuestions[i].question;
      bool isAnswered = false;

      if (questionData.type == 'multiple_choice') {
        isAnswered = selectedAnswers[i].isNotEmpty;
      } else if (questionData.type == 'fill_in_blank') {
        isAnswered = selectedAnswers[i].isNotEmpty;
      }

      if (!isAnswered) {
        return false;
      }
    }
    return true;
  }

  // Show confirmation dialog for exit
  Future<bool> _showExitConfirmationDialog() async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Xác nhận thoát'),
            content: const Text(
              'Bạn có chắc chắn muốn thoát? Tiến trình làm bài của bạn sẽ bị mất.',
              style: TextStyle(fontSize: 16),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text(
                  'Hủy',
                  style: TextStyle(color: Colors.grey[700]),
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red[800],
                  foregroundColor: Colors.white,
                ),
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Thoát'),
              ),
            ],
          ),
        ) ??
        false;
  }

  // Show confirmation dialog for submission with incomplete answers
  Future<bool> _showSubmitConfirmationDialog(int unansweredCount) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Xác nhận nộp bài'),
            content: Text(
              'Bạn còn $unansweredCount câu hỏi chưa trả lời. Bạn có chắc chắn muốn nộp bài không?',
              style: const TextStyle(fontSize: 16),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text(
                  'Quay lại làm bài',
                  style: TextStyle(color: Colors.grey[700]),
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[800],
                  foregroundColor: Colors.white,
                ),
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Nộp bài'),
              ),
            ],
          ),
        ) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final pix = size.width / 375;
    final examProvider = Provider.of<ExamProvider>(context);

    // Show loading indicator while fetching data
    if (isLoading ||
        examProvider.isLoadingExamDetail ||
        examProvider.currentExam == null) {
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
                  title: widget.title,
                ),
              ),
              const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 20),
                    Text("Đang tải câu hỏi...", style: TextStyle(fontSize: 16)),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    // If there's an error
    if (examProvider.examDetailError != null) {
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
                  title: widget.title,
                ),
              ),
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Lỗi tải câu hỏi',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.red[800],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      examProvider.examDetailError!,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[700],
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _loadExamData,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue[800],
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Thử lại'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Handle case with no questions
    if (examProvider.currentExam!.examSingleQuestions.isEmpty) {
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
                  title: widget.title,
                ),
              ),
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.quiz_outlined,
                      size: 64,
                      color: Colors.orange,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Không có câu hỏi',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Bài kiểm tra này hiện không có câu hỏi nào',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[700],
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue[800],
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Quay lại'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    final exam = examProvider.currentExam!;
    final currentExamQuestion = exam.examSingleQuestions[currentQuestion];
    final currentQuestionData = currentExamQuestion.question;

    // Get correct answer index for multiple choice questions
    final correctOptionIndex = currentQuestionData.type == 'multiple_choice' &&
            currentQuestionData.options != null
        ? currentQuestionData.options!.indexOf(currentQuestionData.answer)
        : -1;

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (didPop) return;

        final shouldPop = await _showExitConfirmationDialog();
        if (shouldPop && context.mounted) {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
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
                  title: 'Quiz - ${widget.title}',
                ),
              ),
              Positioned(
                top: 120 * pix,
                left: 16 * pix,
                right: 16 * pix,
                bottom: 0,
                child: Column(
                  children: [
                    // Timer - Moved from row to a dedicated position above
                    Container(
                      width: double.infinity,
                      margin: EdgeInsets.only(bottom: 10 * pix),
                      child: Center(
                        child: Container(
                          padding:
                              EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.red[50],
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.red[300]!),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.red.withOpacity(0.2),
                                spreadRadius: 1,
                                blurRadius: 4,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.timer,
                                  size: 20, color: Colors.red),
                              const SizedBox(width: 8),
                              Text(
                                '${timeLeft ~/ 60}:${(timeLeft % 60).toString().padLeft(2, '0')}',
                                style: TextStyle(
                                  color: Colors.red[800],
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16 * pix,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // Top section with progress
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Question counter
                        Text(
                          'Câu ${currentQuestion + 1}/${exam.examSingleQuestions.length}',
                          style: TextStyle(
                            color: Colors.grey[700],
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),

                        // Question list button
                        TextButton(
                          onPressed: _showQuestionList,
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.symmetric(horizontal: 8),
                          ),
                          child: const Text(
                            'Danh sách',
                            style: TextStyle(
                              color: Colors.blue,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ],
                    ),

                    // Progress indicator
                    LinearProgressIndicator(
                      value: (currentQuestion + 1) /
                          exam.examSingleQuestions.length,
                      backgroundColor: Colors.grey[200],
                      color: Colors.blue[800],
                      minHeight: 6,
                    ),

                    SizedBox(height: 16 * pix),

                    // Question card
                    Expanded(
                      child: SingleChildScrollView(
                        child: Card(
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Display reading section if available
                                if (exam.examSections.isNotEmpty &&
                                    exam.examSections[0].description !=
                                        null) ...[
                                  Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: Colors.blue[50],
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        if (exam.examSections[0].title != null)
                                          Text(
                                            exam.examSections[0].title!,
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.blue[800],
                                            ),
                                          ),
                                        const SizedBox(height: 8),
                                        Text(
                                          exam.examSections[0].description!,
                                          style: const TextStyle(fontSize: 15),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 24),
                                ],

                                // Question text
                                if (currentQuestionData.mediaUrl != null) ...[
                                  Container(
                                    width: double.infinity,
                                    height: 180,
                                    margin: const EdgeInsets.only(bottom: 16),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                          color: Colors.grey.shade300),
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: CachedNetworkImage(
                                        imageUrl: currentQuestionData.mediaUrl!,
                                        fit: BoxFit.contain,
                                        placeholder: (context, url) =>
                                            Container(
                                          color: Colors.grey[200],
                                          child: const Center(
                                            child: CircularProgressIndicator(),
                                          ),
                                        ),
                                        errorWidget: (context, url, error) =>
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
                                  currentQuestionData.question,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 24),

                                // Options or input field based on question type
                                if (currentQuestionData.type ==
                                        'multiple_choice' &&
                                    currentQuestionData.options != null) ...[
                                  ...processOptions(
                                          currentQuestionData.options!)
                                      .asMap()
                                      .entries
                                      .map((entry) {
                                    int idx = entry.key;
                                    String option = entry.value;
                                    bool isSelected =
                                        selectedAnswers[currentQuestion] ==
                                            option;

                                    return Padding(
                                      padding:
                                          const EdgeInsets.only(bottom: 12),
                                      child: InkWell(
                                        borderRadius: BorderRadius.circular(12),
                                        onTap: () {
                                          setState(() {
                                            selectedAnswers[currentQuestion] =
                                                option;
                                          });
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.all(16),
                                          decoration: BoxDecoration(
                                            color: isSelected
                                                ? Colors.blue[50]
                                                : Colors.grey[50],
                                            borderRadius:
                                                BorderRadius.circular(12),
                                            border: Border.all(
                                              color: isSelected
                                                  ? Colors.blue
                                                  : Colors.grey[300]!,
                                              width: 1.5,
                                            ),
                                          ),
                                          child: Row(
                                            children: [
                                              Icon(
                                                isSelected
                                                    ? Icons.radio_button_checked
                                                    : Icons
                                                        .radio_button_unchecked,
                                                color: isSelected
                                                    ? Colors.blue
                                                    : Colors.grey,
                                              ),
                                              const SizedBox(width: 12),
                                              Expanded(
                                                child: Text(
                                                  option,
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                    color: isSelected
                                                        ? Colors.blue[800]
                                                        : Colors.black87,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ] else if (currentQuestionData.type ==
                                    'fill_in_blank') ...[
                                  TextField(
                                    controller:
                                        _textControllers[currentQuestion],
                                    decoration: InputDecoration(
                                      hintText: 'Nhập câu trả lời của bạn',
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      filled: true,
                                      fillColor: Colors.grey[50],
                                    ),
                                    onChanged: (value) {
                                      // Just update the controller, we'll save on navigation
                                      selectedAnswers[currentQuestion] = value;
                                    },
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),

                    // Navigation buttons
                    Padding(
                      padding: EdgeInsets.only(top: 20 * pix, bottom: 20 * pix),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          ElevatedButton(
                            onPressed: currentQuestion > 0
                                ? () => _navigateToQuestion(currentQuestion - 1)
                                : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: Colors.blue[800],
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                                side: BorderSide(color: Colors.blue[800]!),
                              ),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 24, vertical: 12),
                            ),
                            child: const Row(
                              children: [
                                Icon(Icons.arrow_back, size: 18),
                                SizedBox(width: 8),
                                Text('Quay lại'),
                              ],
                            ),
                          ),
                          ElevatedButton(
                            onPressed: currentQuestion <
                                    exam.examSingleQuestions.length - 1
                                ? () => _navigateToQuestion(currentQuestion + 1)
                                : () => _submitQuiz(),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue[800],
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 24, vertical: 12),
                            ),
                            child: Row(
                              children: [
                                Text(
                                  currentQuestion <
                                          exam.examSingleQuestions.length - 1
                                      ? 'Tiếp theo'
                                      : 'Nộp bài',
                                ),
                                if (currentQuestion <
                                    exam.examSingleQuestions.length - 1) ...[
                                  const SizedBox(width: 8),
                                  const Icon(Icons.arrow_forward, size: 18),
                                ],
                              ],
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
      ),
    );
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

  @override
  void dispose() {
    // Dispose all text controllers to avoid memory leaks
    for (var controller in _textControllers) {
      controller.dispose();
    }
    super.dispose();
  }
}
