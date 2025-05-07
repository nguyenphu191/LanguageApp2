import 'package:flutter/material.dart';
import 'package:language_app/duy_anh/question_game/summary_screen.dart';
import 'package:language_app/provider/exam_provider.dart';
import 'package:language_app/widget/top_bar.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import 'dart:math';
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:async';

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

class _QuizScreenState extends State<QuizScreen> with TickerProviderStateMixin {
  int currentQuestion = 0;
  int timeLeft = 300; // 5 minutes
  List<bool?> answers = [];
  List<String> selectedAnswers = [];
  bool isLoading = true;
  List<TextEditingController> _textControllers = [];

  // New for section handling
  late TabController _tabController;
  bool hasLoadedExamData = false;

  // Timer
  late Timer _timer;

  // For tracking all questions including section questions
  List<Map<String, dynamic>> allQuestions = [];
  int totalQuestions = 0;

  // Track which audio files have been played
  Set<String> playedAudioFiles = {};

  // Map to keep track of sections
  Map<int, List<int>> sectionQuestionIndices =
      {}; // sectionIndex -> list of question indices
  List<Map<String, dynamic>> sectionInfoList =
      []; // List of section info for navigation

  // Get the current section index (if any)
  int? getCurrentSectionIndex() {
    if (currentQuestion >= allQuestions.length) return null;

    final questionData = allQuestions[currentQuestion];
    final sectionIndex = questionData['sectionIndex'] as int?;
    return sectionIndex;
  }

  // Get all questions for the current section
  List<Map<String, dynamic>> getCurrentSectionQuestions() {
    final currentSectionIndex = getCurrentSectionIndex();
    if (currentSectionIndex == null) return [];

    final questionIndices = sectionQuestionIndices[currentSectionIndex] ?? [];
    return questionIndices.map((index) => allQuestions[index]).toList();
  }

  // Check if current question is part of a section
  bool isCurrentQuestionInSection() {
    if (currentQuestion >= allQuestions.length) return false;

    final questionData = allQuestions[currentQuestion];
    return questionData['type'] == 'section';
  }

  // Navigate to a specific section
  void navigateToSection(int sectionIndex) {
    final questionIndices = sectionQuestionIndices[sectionIndex] ?? [];
    if (questionIndices.isNotEmpty) {
      _navigateToQuestion(questionIndices.first);
    }
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    // Start timer to count down from 5 minutes
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          if (timeLeft > 0) {
            timeLeft--;
          } else {
            // Time's up, submit the quiz without confirmation (isTimeout=true)
            _timer.cancel();
            _submitQuiz(isTimeout: true);
          }
        });
      }
    });

    // Load the exam data
    _loadExamData().then((_) {
      // After loading exam data, ensure arrays are in sync
      _ensureArrayConsistency();
    });
  }

  Future<void> _loadExamData() async {
    setState(() {
      isLoading = true;
      allQuestions = []; // Clear existing questions
      sectionQuestionIndices = {}; // Clear section indices
      sectionInfoList = []; // Clear section info
    });

    try {
      print("QuizScreen: Starting to load exam data for ID: ${widget.examId}");
      final examProvider = Provider.of<ExamProvider>(context, listen: false);

      // Fetch exam by ID
      await examProvider.fetchExamById(widget.examId);
      print("QuizScreen: Exam data fetched");

      if (!mounted) return;

      if (examProvider.examDetailError != null) {
        print(
            "QuizScreen: Error from provider: ${examProvider.examDetailError}");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text('Error loading exam: ${examProvider.examDetailError}'),
            backgroundColor: Colors.red,
          ),
        );
        setState(() => isLoading = false);
        return;
      }

      final exam = examProvider.currentExam;
      if (exam == null) {
        print("QuizScreen: No exam data received");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No exam data available'),
            backgroundColor: Colors.orange,
          ),
        );
        setState(() => isLoading = false);
        return;
      }

      // Debug info
      print("QuizScreen: Exam ID: ${exam.id}, Title: ${exam.title}");
      print("QuizScreen: Single Questions: ${exam.examSingleQuestions.length}");
      print("QuizScreen: Sections: ${exam.examSections.length}");

      // Get combined questions directly from the provider
      // rather than rebuilding the list ourselves
      final questions = examProvider.allQuestions;
      final questionCount = questions.length;

      print("QuizScreen: Retrieved ${questionCount} questions from provider");

      // No questions available
      if (questionCount == 0) {
        print("QuizScreen: No questions found in exam data");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No questions available for this exam'),
            backgroundColor: Colors.orange,
          ),
        );
        setState(() {
          allQuestions = [];
          answers = [];
          selectedAnswers = [];
          _textControllers = [];
          totalQuestions = 0;
          isLoading = false;
        });
        return;
      }

      // Create a list of section info for navigation
      List<Map<String, dynamic>> sections = [];

      // Process all questions to organize them by section
      List<Map<String, dynamic>> processedQuestions = [];
      Map<int, List<int>> sectionIndices = {};
      Map<int, Map<String, dynamic>> sectionMap = {};

      int questionIndex = 0;

      // First, process single questions
      for (int i = 0; i < questions.length; i++) {
        final question = questions[i];
        if (question['type'] == 'single') {
          processedQuestions.add(question);
          questionIndex++;
        }
      }

      // Then, process section questions
      for (int i = 0; i < questions.length; i++) {
        final question = questions[i];
        if (question['type'] != 'section') continue;

        final sectionIndex = question['sectionIndex'] as int?;
        if (sectionIndex == null) continue;

        // If this is the first question of the section, add section info
        if (!sectionMap.containsKey(sectionIndex)) {
          final sectionInfo = {
            'sectionIndex': sectionIndex,
            'title': question['sectionTitle'] ?? 'Section ${sectionIndex + 1}',
            'description': question['sectionDescription'],
            'type': question['sectionType'],
            'audioUrl': question['sectionAudioUrl'],
            'startQuestionIndex': questionIndex // Track starting question index
          };
          sectionMap[sectionIndex] = sectionInfo;
          sections.add(sectionInfo);
          sectionIndices[sectionIndex] = [];
        }

        // Add question to the list and track its index
        processedQuestions.add(question);
        sectionIndices[sectionIndex]!.add(questionIndex);
        questionIndex++;
      }

      // Update state with processed questions and section data
      setState(() {
        allQuestions = processedQuestions;
        totalQuestions = processedQuestions.length;
        sectionQuestionIndices = sectionIndices;
        sectionInfoList = sections;

        // Initialize tracking arrays
        answers = List<bool?>.filled(totalQuestions, null);
        selectedAnswers = List<String>.filled(totalQuestions, '');

        // Create text controllers
        _textControllers = [];
        for (int i = 0; i < totalQuestions; i++) {
          _textControllers.add(TextEditingController());
        }

        currentQuestion = 0;
        hasLoadedExamData = true;
        isLoading = false;
      });

      // Output the state for debugging
      _debugState();
      _debugSectionInfo();

      // Start timer
      _startTimer();
    } catch (e) {
      print("QuizScreen: Exception during load: $e");
      if (mounted) {
        setState(() {
          isLoading = false;
          allQuestions = [];
          totalQuestions = 0;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading exam: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Helper method to restart the timer if needed
  void _startTimer() {
    // Reset to 5 minutes if needed
    timeLeft = 300;
  }

  void _showQuestionList() {
    // Create a list of displayable question items
    List<Map<String, dynamic>> displayItems = [];

    // Keep track of sections we've already added
    Set<int> addedSections = {};

    // Process all questions
    for (int i = 0; i < allQuestions.length; i++) {
      final questionData = allQuestions[i];
      final questionType = questionData['type'];

      if (questionType == 'single') {
        // For single questions, add them individually
        displayItems.add({
          'index': i,
          'type': 'single',
          'title': 'Question ${displayItems.length + 1}',
          'isSection': false,
        });
      } else if (questionType == 'section') {
        // For section questions, add the section once
        final sectionIndex = questionData['sectionIndex'] as int?;
        if (sectionIndex != null && !addedSections.contains(sectionIndex)) {
          addedSections.add(sectionIndex);

          // Find section info
          final sectionTitle = questionData['sectionTitle'];

          displayItems.add({
            'index': i,
            'type': 'section',
            'title': sectionTitle ?? 'Section ${addedSections.length}',
            'isSection': true,
            'sectionIndex': sectionIndex,
          });
        }
      }
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16),
          height: MediaQuery.of(context).size.height * 0.6,
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
                child: ListView.builder(
                  itemCount: displayItems.length,
                  itemBuilder: (context, index) {
                    final item = displayItems[index];
                    final isCurrentQuestion = _isCurrentQuestionInItem(item);
                    final isSection = item['isSection'] as bool;

                    return Card(
                      elevation: 1,
                      margin: EdgeInsets.symmetric(vertical: 4),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: BorderSide(
                          color: isCurrentQuestion
                              ? Colors.blue
                              : Colors.transparent,
                          width: 2,
                        ),
                      ),
                      child: ListTile(
                        onTap: () {
                          // Close the modal
                          Navigator.pop(context);

                          // Navigate to the question or section
                          if (isSection) {
                            final sectionIndex = item['sectionIndex'] as int;
                            navigateToSection(sectionIndex);
                          } else {
                            _navigateToQuestion(item['index'] as int);
                          }
                        },
                        tileColor: isCurrentQuestion ? Colors.blue[50] : null,
                        leading: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isSection
                                ? Colors.purple[100]
                                : Colors.blue[100],
                          ),
                          child: Center(
                            child: Icon(
                              isSection ? Icons.article : Icons.question_answer,
                              size: 20,
                              color: isSection
                                  ? Colors.purple[800]
                                  : Colors.blue[800],
                            ),
                          ),
                        ),
                        title: Text(
                          item['title'] as String,
                          style: TextStyle(
                            fontWeight: isCurrentQuestion
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                        subtitle: Text(
                          isSection
                              ? 'Click to view all questions in this section'
                              : 'Single question',
                        ),
                        trailing: Icon(
                          Icons.arrow_forward_ios,
                          size: 16,
                          color: Colors.grey[600],
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

  // Check if the current question is inside a displayed item
  bool _isCurrentQuestionInItem(Map<String, dynamic> item) {
    if (item['isSection'] as bool) {
      // For section items, check if current question is in this section
      final sectionIndex = item['sectionIndex'] as int;

      // Get all questions for this section
      final sectionQuestions = sectionQuestionIndices[sectionIndex] ?? [];

      // Check if current question is in this section
      return sectionQuestions.contains(currentQuestion);
    } else {
      // For single question items, just check if the index matches
      return item['index'] == currentQuestion;
    }
  }

  Future<void> _submitQuiz({bool isTimeout = false}) async {
    final examProvider = Provider.of<ExamProvider>(context, listen: false);
    if (examProvider.currentExam == null) return;

    // Save the current fill-in-blank answer if there is one
    if (currentQuestion < allQuestions.length) {
      final questionData = allQuestions[currentQuestion];
      final question = questionData['question'];

      if (question.type == 'fill_in_blank' &&
          _textControllers.isNotEmpty &&
          currentQuestion < _textControllers.length) {
        selectedAnswers[currentQuestion] =
            _textControllers[currentQuestion].text;
        print(
            "Saved answer for question $currentQuestion: '${selectedAnswers[currentQuestion]}'");
      }
    }

    // Check for unanswered questions
    int unansweredCount = 0;
    for (int i = 0; i < allQuestions.length; i++) {
      if (i >= allQuestions.length) {
        print(
            "ERROR: Question index $i is out of bounds (allQuestions.length=${allQuestions.length})");
        continue;
      }

      final questionData = allQuestions[i];
      final question = questionData['question'];

      bool isAnswered = false;

      if (question.type == 'multiple_choice') {
        isAnswered = selectedAnswers[i].isNotEmpty;
      } else if (question.type == 'fill_in_blank') {
        isAnswered = selectedAnswers[i].isNotEmpty;
      }

      if (!isAnswered) {
        unansweredCount++;
      }
    }

    // If there are unanswered questions, show confirmation dialog (but skip if timeout)
    if (unansweredCount > 0 && !isTimeout) {
      bool shouldContinue =
          await _showSubmitConfirmationDialog(unansweredCount);
      if (!shouldContinue) {
        return; // User chose to go back and finish answering
      }
    }

    // Show a notification if it's a timeout
    if (isTimeout && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Hết thời gian! Bài làm đang được nộp tự động.'),
          backgroundColor: Colors.orange,
        ),
      );
    }

    // Now evaluate all answers
    await _evaluateAnswers();
  }

  Future<void> _evaluateAnswers() async {
    print("Starting answer evaluation");
    print("allQuestions.length: ${allQuestions.length}");
    print("selectedAnswers.length: ${selectedAnswers.length}");
    print("answers.length: ${answers.length}");

    final examProvider = Provider.of<ExamProvider>(context, listen: false);

    // Safety check - make sure we have questions and answers
    if (allQuestions.isEmpty) {
      print("ERROR: No questions to evaluate");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No questions to evaluate'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Ensure arrays are of correct size
    if (answers.length != allQuestions.length) {
      print(
          "WARNING: Resizing answers array from ${answers.length} to ${allQuestions.length}");
      answers = List<bool?>.filled(allQuestions.length, null);
    }

    if (selectedAnswers.length != allQuestions.length) {
      print(
          "WARNING: Resizing selectedAnswers array from ${selectedAnswers.length} to ${allQuestions.length}");
      // Create a new array with correct size, copying existing values
      List<String> newSelectedAnswers =
          List<String>.filled(allQuestions.length, '');
      for (int i = 0;
          i < selectedAnswers.length && i < allQuestions.length;
          i++) {
        newSelectedAnswers[i] = selectedAnswers[i];
      }
      selectedAnswers = newSelectedAnswers;
    }

    // Evaluate each answer
    for (int i = 0; i < allQuestions.length; i++) {
      try {
        final questionData = allQuestions[i];
        final question = questionData['question'];
        final sectionTitle = questionData['sectionTitle'];

        // Safety check for question data
        if (question == null) {
          print("ERROR: Question $i is null");
          answers[i] = false;
          continue;
        }

        // Make sure we have a selected answer for this question
        if (i >= selectedAnswers.length) {
          print("ERROR: No selected answer for question $i");
          answers[i] = false;
          continue;
        }

        try {
          if (question.type == 'multiple_choice') {
            // For multiple choice, check if selected answer matches correct answer
            answers[i] = selectedAnswers[i] == question.answer;
          } else if (question.type == 'fill_in_blank') {
            // For fill-in-blank, compare answers ignoring case
            answers[i] = selectedAnswers[i].toLowerCase().trim() ==
                question.answer.toLowerCase().trim();
          } else {
            // Default case if there are other question types
            answers[i] = false;
          }

          print(
              "Question $i${sectionTitle != null ? ' (Section: $sectionTitle)' : ''}: ${answers[i] == true ? 'CORRECT' : 'INCORRECT'}");
        } catch (e) {
          print("ERROR evaluating question $i: $e");
          answers[i] = false;
        }
      } catch (e) {
        print("ERROR processing question $i: $e");
        // If we're within bounds of the answers array, set it to false
        if (i < answers.length) {
          answers[i] = false;
        }
      }
    }

    // Calculate the score
    int score = 0;
    for (int i = 0; i < answers.length; i++) {
      if (answers[i] == true) {
        score++;
      }
    }

    print("Final score: $score / ${answers.length}");

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
            Text("Đang chấm điểm..."),
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
    try {
      // Check if there are questions loaded
      if (allQuestions.isEmpty) {
        print("ERROR: Cannot navigate, no questions available");
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("No questions available")),
          );
        }
        return;
      }

      // Check if the index is valid
      if (index < 0 || index >= allQuestions.length) {
        print(
            "ERROR: Invalid question index in _navigateToQuestion: $index (allQuestions.length: ${allQuestions.length})");

        // Clamp to valid range
        if (index < 0) {
          index = 0;
        } else if (allQuestions.isNotEmpty) {
          // If we're trying to go past the end, cap at the last question
          index = allQuestions.length - 1;
        } else {
          // No questions, nothing to navigate to
          return;
        }

        print("Adjusted index to $index");

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Navigated to question $index (adjusted)")),
          );
        }
      }

      // Also update totalQuestions to match allQuestions.length to ensure consistency
      if (totalQuestions != allQuestions.length) {
        print(
            "WARNING: totalQuestions ($totalQuestions) doesn't match allQuestions.length (${allQuestions.length}). Fixing...");
        totalQuestions = allQuestions.length;
      }

      // Print the transition for debugging
      print("Navigating from question $currentQuestion to $index");

      // Save current answer if it's a fill-in-blank question and the current index is valid
      if (currentQuestion >= 0 && currentQuestion < allQuestions.length) {
        final currentQuestionData = allQuestions[currentQuestion];
        final currentQ = currentQuestionData['question'];

        if (currentQ.type == 'fill_in_blank' &&
            _textControllers.isNotEmpty &&
            currentQuestion < _textControllers.length) {
          selectedAnswers[currentQuestion] =
              _textControllers[currentQuestion].text;
          print(
              "Saved answer for question $currentQuestion: '${selectedAnswers[currentQuestion]}'");
        }
      }

      // Update the current question index safely
      setState(() {
        currentQuestion = index;

        // Update the tab based on the question type
        if (index < allQuestions.length) {
          final questionData = allQuestions[index];
          final questionType = questionData['type'] as String;

          // Set tab index based on question type (0 for single, 1 for section)
          final newTabIndex = questionType == 'section' ? 1 : 0;
          if (_tabController.index != newTabIndex) {
            _tabController.animateTo(newTabIndex);
            print(
                "Updated tab index to $newTabIndex based on question type $questionType");
          }
        }
      });

      // Make sure controllers reflect previously entered answers for fill-in-blank
      Future.microtask(() {
        if (index < allQuestions.length && mounted) {
          final questionData = allQuestions[index];
          final question = questionData['question'];
          final sectionTitle = questionData['sectionTitle'];

          print(
              "Now at question $index: ${sectionTitle != null ? '(Section: $sectionTitle)' : ''}");

          if (question.type == 'fill_in_blank' &&
              _textControllers.isNotEmpty &&
              index < _textControllers.length) {
            if (_textControllers[index].text != selectedAnswers[index]) {
              _textControllers[index].text = selectedAnswers[index];
            }
          }

          // Debug the state after the navigation is complete
          _debugState();
        }
      });
    } catch (e) {
      print("ERROR in _navigateToQuestion: $e");
      print("Stack trace: ${StackTrace.current}");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error navigating to question: $e")),
        );
      }
    }
  }

  // Check if all questions are answered
  bool _allQuestionsAnswered() {
    if (allQuestions.isEmpty) return false;

    for (int i = 0; i < selectedAnswers.length; i++) {
      if (i >= allQuestions.length) continue;

      final questionData = allQuestions[i];
      final question = questionData['question'];

      bool isAnswered = false;

      if (question.type == 'multiple_choice') {
        isAnswered = selectedAnswers[i].isNotEmpty;
      } else if (question.type == 'fill_in_blank') {
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

  // Debug state information
  void _debugState() {
    print("\n=== DEBUG STATE ===");
    print("totalQuestions: $totalQuestions");
    print("allQuestions.length: ${allQuestions.length}");
    print("answers.length: ${answers.length}");
    print("selectedAnswers.length: ${selectedAnswers.length}");
    print("_textControllers.length: ${_textControllers.length}");
    print("currentQuestion: $currentQuestion");

    if (currentQuestion >= 0 && currentQuestion < allQuestions.length) {
      final questionData = allQuestions[currentQuestion];
      final questionType = questionData['type'];
      final question = questionData['question'];
      final sectionTitle = questionData['sectionTitle'];

      print("Current question type: $questionType");
      if (question != null) {
        final questionText = question.question as String;
        print(
            "Current question text: ${questionText.substring(0, min<int>(30, questionText.length))}...");
      } else {
        print("WARNING: Question object is null");
      }
      print(
          "Current question from section: ${sectionTitle != null ? 'Yes' : 'No'}");
      if (sectionTitle != null) {
        print("Section title: $sectionTitle");
      }
    } else if (allQuestions.isNotEmpty) {
      print(
          "WARNING: Current question index ($currentQuestion) is out of bounds!");
    }

    print("===================\n");
  }

  // Method to ensure all tracking arrays are consistent
  void _ensureArrayConsistency() {
    if (!mounted) return;

    // Don't do anything if allQuestions is empty
    if (allQuestions.isEmpty) return;

    setState(() {
      // Make sure totalQuestions matches allQuestions.length
      if (totalQuestions != allQuestions.length) {
        print(
            "FIXING: totalQuestions ($totalQuestions) != allQuestions.length (${allQuestions.length})");
        totalQuestions = allQuestions.length;
      }

      // Ensure answers array is the correct size
      if (answers.length != totalQuestions) {
        print(
            "FIXING: answers.length (${answers.length}) != totalQuestions ($totalQuestions)");
        // Create new array preserving existing values
        List<bool?> newAnswers = List<bool?>.filled(totalQuestions, null);
        for (int i = 0; i < answers.length && i < totalQuestions; i++) {
          newAnswers[i] = answers[i];
        }
        answers = newAnswers;
      }

      // Ensure selectedAnswers array is the correct size
      if (selectedAnswers.length != totalQuestions) {
        print(
            "FIXING: selectedAnswers.length (${selectedAnswers.length}) != totalQuestions ($totalQuestions)");
        // Create new array preserving existing values
        List<String> newSelectedAnswers =
            List<String>.filled(totalQuestions, '');
        for (int i = 0; i < selectedAnswers.length && i < totalQuestions; i++) {
          newSelectedAnswers[i] = selectedAnswers[i];
        }
        selectedAnswers = newSelectedAnswers;
      }

      // Ensure text controllers array is the correct size
      if (_textControllers.length != totalQuestions) {
        print(
            "FIXING: _textControllers.length (${_textControllers.length}) != totalQuestions ($totalQuestions)");
        // If we need more controllers, add them
        if (_textControllers.length < totalQuestions) {
          for (int i = _textControllers.length; i < totalQuestions; i++) {
            _textControllers.add(TextEditingController());
          }
        }
        // If we have too many controllers, remove extras
        else if (_textControllers.length > totalQuestions) {
          for (int i = _textControllers.length - 1; i >= totalQuestions; i--) {
            _textControllers[i].dispose(); // Dispose controllers we don't need
          }
          _textControllers = _textControllers.sublist(0, totalQuestions);
        }
      }

      // Ensure currentQuestion is valid
      if (currentQuestion < 0 || currentQuestion >= totalQuestions) {
        print(
            "FIXING: Invalid currentQuestion ($currentQuestion), setting to 0");
        currentQuestion = 0;
      }
    });

    // Print debug info
    _debugState();
  }

  // Debug info about sections
  void _debugSectionInfo() {
    print("\n=== SECTION INFO ===");
    print("Number of sections: ${sectionInfoList.length}");
    print(
        "Total single questions: ${allQuestions.where((q) => q['type'] == 'single').length}");
    print(
        "Total section questions: ${allQuestions.where((q) => q['type'] == 'section').length}");

    // Print section question indices
    print("\nSection Question Indices:");
    sectionQuestionIndices.forEach((sectionIndex, indices) {
      print(
          "  Section $sectionIndex: ${indices.length} questions, indices: $indices");
    });

    // Print detailed section info
    print("\nDetailed Section Info:");
    for (int i = 0; i < sectionInfoList.length; i++) {
      final section = sectionInfoList[i];
      final sectionIndex = section['sectionIndex'];
      final questionIndices = sectionQuestionIndices[sectionIndex] ?? [];

      print("Section $i (index $sectionIndex):");
      print("  Title: ${section['title']}");
      print("  Type: ${section['type']}");
      print("  Audio: ${section['audioUrl'] != null ? 'Yes' : 'No'}");
      print("  Start Question Index: ${section['startQuestionIndex']}");
      print("  Questions: ${questionIndices.length}");

      // Print info about each question in this section
      for (int j = 0; j < questionIndices.length; j++) {
        final qIndex = questionIndices[j];
        if (qIndex < allQuestions.length) {
          final qData = allQuestions[qIndex];
          final question = qData['question'];
          final qType = question?.type ?? 'unknown';
          final qText = question?.question != null
              ? question.question
                  .substring(0, min<int>(30, question.question.length))
              : 'null';

          print("    Q$j (idx:$qIndex): [$qType] $qText...");
        } else {
          print("    Q$j (idx:$qIndex): ERROR - Index out of bounds");
        }
      }
    }

    print("===================\n");
  }

  // Find the next question or section to navigate to
  int findNextNavigation(int currentIndex) {
    // If we're at the end, stay there
    if (currentIndex >= allQuestions.length - 1) {
      return currentIndex;
    }

    // Get current question data
    final currentQuestion = allQuestions[currentIndex];
    final isSection = currentQuestion['type'] == 'section';

    if (isSection) {
      // If we're currently in a section, find the next non-section question
      // or the first question of the next section
      final currentSectionIndex = currentQuestion['sectionIndex'] as int?;

      // No section index? Just go to the next question
      if (currentSectionIndex == null) {
        return currentIndex + 1;
      }

      // Find all questions in the current section
      final sectionQuestions =
          sectionQuestionIndices[currentSectionIndex] ?? [];

      // If we're on the last question of the current section,
      // find the next section or next single question
      if (sectionQuestions.contains(currentIndex) &&
          sectionQuestions.last == currentIndex) {
        // Look for the next question after this section
        for (int i = currentIndex + 1; i < allQuestions.length; i++) {
          final nextQuestion = allQuestions[i];

          // If it's a single question, go there
          if (nextQuestion['type'] == 'single') {
            return i;
          }

          // If it's a section question from a different section, go there
          if (nextQuestion['type'] == 'section') {
            final nextSectionIndex = nextQuestion['sectionIndex'] as int?;
            if (nextSectionIndex != null &&
                nextSectionIndex != currentSectionIndex) {
              return i;
            }
          }
        }

        // If no next section found, just return the next question
        return currentIndex + 1;
      }

      // If we're not on the last question of the section,
      // find the next question in the same section
      for (int i = 0; i < sectionQuestions.length - 1; i++) {
        if (sectionQuestions[i] == currentIndex) {
          return sectionQuestions[i + 1];
        }
      }

      // If we can't find the next question in the section, just go to the next question
      return currentIndex + 1;
    } else {
      // For single questions, just go to the next question
      return currentIndex + 1;
    }
  }

  // Find the previous question or section to navigate to
  int findPreviousNavigation(int currentIndex) {
    // If we're at the beginning, stay there
    if (currentIndex <= 0) {
      return currentIndex;
    }

    // Get current question data
    final currentQuestion = allQuestions[currentIndex];
    final isSection = currentQuestion['type'] == 'section';

    if (isSection) {
      // If we're currently in a section
      final currentSectionIndex = currentQuestion['sectionIndex'] as int?;

      // No section index? Just go to the previous question
      if (currentSectionIndex == null) {
        return currentIndex - 1;
      }

      // Find all questions in the current section
      final sectionQuestions =
          sectionQuestionIndices[currentSectionIndex] ?? [];

      // If we're on the first question of a section,
      // go to the previous section or previous single question
      if (sectionQuestions.contains(currentIndex) &&
          sectionQuestions.first == currentIndex) {
        // Look for the previous question before this section
        for (int i = currentIndex - 1; i >= 0; i--) {
          final prevQuestion = allQuestions[i];

          // If it's a single question, go there
          if (prevQuestion['type'] == 'single') {
            return i;
          }

          // If it's a section question from a different section, go to its first question
          if (prevQuestion['type'] == 'section') {
            final prevSectionIndex = prevQuestion['sectionIndex'] as int?;
            if (prevSectionIndex != null &&
                prevSectionIndex != currentSectionIndex) {
              // Find the first question of that section
              final prevSectionQuestions =
                  sectionQuestionIndices[prevSectionIndex] ?? [];
              if (prevSectionQuestions.isNotEmpty) {
                return prevSectionQuestions.first;
              }
              return i;
            }
          }
        }

        // If no previous section or single question found, go to the previous question
        return currentIndex - 1;
      }

      // If we're not on the first question of the section,
      // find the previous question in the same section
      for (int i = 1; i < sectionQuestions.length; i++) {
        if (sectionQuestions[i] == currentIndex) {
          return sectionQuestions[i - 1];
        }
      }

      // If we can't find the previous question in the section, just go to the previous question
      return currentIndex - 1;
    } else {
      // For single questions, just go to the previous question
      return currentIndex - 1;
    }
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
    if (allQuestions.isEmpty) {
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

    // Get the exam
    final exam = examProvider.currentExam!;

    // Safety check for current question index
    if (currentQuestion < 0 || currentQuestion >= allQuestions.length) {
      print(
          "ERROR: Invalid currentQuestion ($currentQuestion), fixing to valid range");

      // Auto-fix the index
      setState(() {
        currentQuestion = currentQuestion < 0 ? 0 : allQuestions.length - 1;
      });

      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Fixed invalid question index: $currentQuestion'),
          backgroundColor: Colors.orange,
        ),
      );
    }

    // Use allQuestions directly instead of any direct references
    // to exam.examSingleQuestions

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
                top: 100 * pix,
                left: 0,
                right: 0,
                bottom: 0,
                child: Column(
                  children: [
                    // Timer
                    Container(
                      width: double.infinity,
                      margin: EdgeInsets.only(
                          bottom: 6 * pix,
                          top: 6 * pix,
                          left: 16 * pix,
                          right: 16 * pix),
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

                    // Question counter and list button
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16 * pix),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Câu ${currentQuestion + 1}/$totalQuestions',
                            style: TextStyle(
                              color: Colors.grey[700],
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
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
                    ),

                    // Progress indicator
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16 * pix),
                      child: LinearProgressIndicator(
                        value: (currentQuestion + 1) / totalQuestions,
                        backgroundColor: Colors.grey[200],
                        color: Colors.blue[800],
                        minHeight: 6,
                      ),
                    ),

                    SizedBox(height: 12 * pix),

                    // Main content: Question display
                    Expanded(
                      child: _buildCurrentQuestionWidget(pix),
                    ),

                    // Navigation buttons
                    Padding(
                      padding: EdgeInsets.only(
                          top: 12 * pix,
                          bottom: 20 * pix,
                          left: 16 * pix,
                          right: 16 * pix),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          ElevatedButton(
                            onPressed: currentQuestion > 0
                                ? () => _navigateToQuestion(
                                    findPreviousNavigation(currentQuestion))
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
                            onPressed: currentQuestion < allQuestions.length - 1
                                ? () => _navigateToQuestion(
                                    findNextNavigation(currentQuestion))
                                : () => _submitQuiz(isTimeout: false),
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
                                  currentQuestion < allQuestions.length - 1
                                      ? 'Tiếp theo'
                                      : 'Nộp bài',
                                ),
                                if (currentQuestion <
                                    allQuestions.length - 1) ...[
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

  Widget _buildCurrentQuestionWidget(double pix) {
    try {
      // Safety check
      if (allQuestions.isEmpty) {
        return Center(
          child: Text(
            "No questions available",
            style: TextStyle(fontSize: 16 * pix, color: Colors.red),
          ),
        );
      }

      // Critical safety check for index bounds
      if (currentQuestion < 0 || currentQuestion >= allQuestions.length) {
        print(
            "ERROR: Question index out of range: currentQuestion=$currentQuestion, allQuestions.length=${allQuestions.length}");

        // Auto-fix the currentQuestion index to a valid value
        setState(() {
          if (allQuestions.isNotEmpty) {
            currentQuestion = 0; // Reset to first question
            print("Auto-fixed currentQuestion index to 0");
          }
        });

        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, color: Colors.orange, size: 48 * pix),
              SizedBox(height: 16 * pix),
              Text(
                "Resetting to first question...",
                style: TextStyle(fontSize: 16 * pix, color: Colors.orange),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 16 * pix),
              ElevatedButton(
                onPressed: () {
                  _navigateToQuestion(0);
                },
                child: Text("Go to First Question"),
              ),
            ],
          ),
        );
      }

      // Check if current question is part of a section
      final isSection = isCurrentQuestionInSection();

      if (isSection) {
        // Get all questions for the section
        return _buildSectionQuestions(pix);
      } else {
        // Build a single question for non-section questions
        return _buildSingleQuestion(pix, currentQuestion);
      }
    } catch (e) {
      print("ERROR in _buildCurrentQuestionWidget: $e");
      print("Stack trace: ${StackTrace.current}");
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, color: Colors.red, size: 48 * pix),
            SizedBox(height: 16 * pix),
            Text(
              "Something went wrong",
              style: TextStyle(fontSize: 18 * pix, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8 * pix),
            Text(
              e.toString(),
              style: TextStyle(fontSize: 14 * pix),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16 * pix),
            ElevatedButton(
              onPressed: _loadExamData,
              child: Text("Try Again"),
            ),
          ],
        ),
      );
    }
  }

  Widget _buildSectionQuestions(double pix) {
    // Get current question data
    final questionData = allQuestions[currentQuestion];
    final sectionIndex = questionData['sectionIndex'] as int?;

    if (sectionIndex == null) {
      return Center(
        child: Text("Error: Missing section index",
            style: TextStyle(fontSize: 16 * pix, color: Colors.red)),
      );
    }

    // Get all questions for this section
    final sectionQuestions = getCurrentSectionQuestions();
    if (sectionQuestions.isEmpty) {
      return Center(
        child: Text("Error: No questions in section",
            style: TextStyle(fontSize: 16 * pix, color: Colors.red)),
      );
    }

    // Get section info
    final sectionTitle = questionData['sectionTitle'];
    final sectionDescription = questionData['sectionDescription'];
    final sectionType = questionData['sectionType'];
    final sectionAudioUrl = questionData['sectionAudioUrl'];

    // Check if this audio has been played
    final hasPlayedAudio =
        sectionAudioUrl != null && playedAudioFiles.contains(sectionAudioUrl);

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 16 * pix),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section header
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: EdgeInsets.all(16 * pix),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (sectionTitle != null) ...[
                    Row(
                      children: [
                        Icon(
                          sectionType == 'listening'
                              ? Icons.headphones
                              : Icons.menu_book,
                          color: Colors.blue[700],
                          size: 20 * pix,
                        ),
                        SizedBox(width: 8 * pix),
                        Expanded(
                          child: Text(
                            sectionTitle,
                            style: TextStyle(
                              fontSize: 16 * pix,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue[800],
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8 * pix),
                  ],

                  if (sectionDescription != null &&
                      sectionDescription.isNotEmpty) ...[
                    Text(
                      sectionDescription,
                      style: TextStyle(
                        fontSize: 14 * pix,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 8 * pix),
                  ],

                  // Audio player for listening sections
                  if (sectionType == 'listening' &&
                      sectionAudioUrl != null) ...[
                    ElevatedButton.icon(
                      icon:
                          Icon(hasPlayedAudio ? Icons.check : Icons.play_arrow),
                      label:
                          Text(hasPlayedAudio ? "Đã nghe audio" : "Nghe audio"),
                      onPressed: hasPlayedAudio
                          ? null // Disable if already played
                          : () {
                              // Mark as played
                              setState(() {
                                playedAudioFiles.add(sectionAudioUrl);
                              });

                              // Implement audio playback
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content: Text(
                                        "Playing audio: $sectionAudioUrl")),
                              );
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            hasPlayedAudio ? Colors.grey : Colors.blue[600],
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: Colors.grey[300],
                        disabledForegroundColor: Colors.grey[600],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          SizedBox(height: 16 * pix),

          // All questions in this section
          ...sectionQuestions.asMap().entries.map((entry) {
            final questionIndex = entry.key;
            final qData = entry.value;
            final qIndex = sectionQuestionIndices[sectionIndex]![questionIndex];

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Question number
                Padding(
                  padding: EdgeInsets.only(left: 4 * pix, bottom: 4 * pix),
                  child: Text(
                    "Question ${questionIndex + 1}:",
                    style: TextStyle(
                      fontSize: 14 * pix,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[700],
                    ),
                  ),
                ),

                // Question content
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(16 * pix),
                    child: _buildQuestionContent(pix, qData, qIndex),
                  ),
                ),

                SizedBox(height: 24 * pix),
              ],
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildSingleQuestion(double pix, int questionIndex) {
    final questionData = allQuestions[questionIndex];

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 16 * pix),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Question card
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: EdgeInsets.all(16 * pix),
              child: _buildQuestionContent(pix, questionData, questionIndex),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionContent(
      double pix, Map<String, dynamic> questionData, int questionIndex) {
    final question = questionData['question'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Question image if available
        if (question.mediaUrl != null) ...[
          Container(
            width: double.infinity,
            height: 180,
            margin: EdgeInsets.only(bottom: 16 * pix),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: CachedNetworkImage(
                imageUrl: question.mediaUrl!,
                fit: BoxFit.contain,
                placeholder: (context, url) => Container(
                  color: Colors.grey[200],
                  child: const Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  color: Colors.grey[200],
                  child: const Center(
                    child: Icon(Icons.error),
                  ),
                ),
              ),
            ),
          ),
        ],

        // Question text
        Text(
          question.question,
          style: TextStyle(
            fontSize: 16 * pix,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 24 * pix),

        // Question type specific UI (multiple choice or fill-in-blank)
        if (question.type == 'multiple_choice' && question.options != null) ...[
          ...processOptions(question.options!).asMap().entries.map((entry) {
            int idx = entry.key;
            String option = entry.value;
            bool isSelected = selectedAnswers[questionIndex] == option;

            return Padding(
              padding: EdgeInsets.only(bottom: 12 * pix),
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () {
                  setState(() {
                    selectedAnswers[questionIndex] = option;
                  });
                },
                child: Container(
                  padding: EdgeInsets.all(16 * pix),
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.blue[50] : Colors.grey[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected ? Colors.blue : Colors.grey[300]!,
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        isSelected
                            ? Icons.radio_button_checked
                            : Icons.radio_button_unchecked,
                        color: isSelected ? Colors.blue : Colors.grey,
                      ),
                      SizedBox(width: 12 * pix),
                      Expanded(
                        child: Text(
                          option,
                          style: TextStyle(
                            fontSize: 15 * pix,
                            color:
                                isSelected ? Colors.blue[800] : Colors.black87,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ] else if (question.type == 'fill_in_blank') ...[
          TextField(
            controller: _textControllers[questionIndex],
            decoration: InputDecoration(
              hintText: 'Nhập câu trả lời của bạn',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: Colors.grey[50],
            ),
            onChanged: (value) {
              selectedAnswers[questionIndex] = value;
            },
          ),
        ],

        // Explanation if available (shown for review mode)
        if (question.explanation != null) ...[
          SizedBox(height: 16 * pix),
          Container(
            padding: EdgeInsets.all(12 * pix),
            decoration: BoxDecoration(
              color: Colors.amber[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.amber[300]!),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Giải thích:",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.amber[800],
                  ),
                ),
                SizedBox(height: 4 * pix),
                Text(
                  question.explanation!,
                  style: TextStyle(
                    fontSize: 14 * pix,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
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
    // Cancel the timer to prevent memory leaks
    _timer.cancel();

    // Dispose tab controller
    _tabController.dispose();

    // Dispose text controllers
    for (var controller in _textControllers) {
      controller.dispose();
    }

    super.dispose();
  }
}
