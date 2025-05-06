import 'package:flutter/material.dart';
import 'package:language_app/duy_anh/question_game/quiz_screen.dart';
import 'package:language_app/models/exams/exam_model.dart';
import 'package:language_app/provider/exam_provider.dart';
import 'package:language_app/widget/top_bar.dart';
import 'package:provider/provider.dart';

class QuestionsScreen extends StatefulWidget {
  final String examType;
  final String title;

  const QuestionsScreen({
    super.key,
    this.examType = 'weekly',
    this.title = 'Trắc nghiệm hàng tuần',
  });

  @override
  State<QuestionsScreen> createState() => _QuestionsScreenState();
}

class _QuestionsScreenState extends State<QuestionsScreen>
    with WidgetsBindingObserver {
  // Add a flag to track if data has been loaded
  bool _hasLoadedData = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Clear existing exams and set loading state
      _clearAndLoadData();
    });
  }

  void _clearAndLoadData() {
    setState(() {
      _isLoading = true;
    });

    final examProvider = Provider.of<ExamProvider>(context, listen: false);
    // Clear existing exams first
    examProvider.clearExams();

    // Then load exams data based on type
    examProvider.fetchExamsByType(widget.examType).then((_) {
      if (mounted) {
        setState(() {
          _hasLoadedData = true;
          _isLoading = false;
        });
      }
    }).catchError((error) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  // Method to handle navigation to quiz screen
  void _navigateToQuiz(ExamModel exam) async {
    print(
        "QuestionsScreen: Navigating to ${widget.examType} exam with ID: ${exam.id}");

    // Navigate to QuizScreen without expecting a result
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => QuizScreen(
          examId: exam.id,
          title: exam.title ?? "Bài kiểm tra",
        ),
      ),
    );

    // Only refresh if the quiz was completed - we'll pass result from summary screen
    if (mounted && result == true) {
      print("QuestionsScreen: Exam completed, refreshing data");
      final examProvider = Provider.of<ExamProvider>(context, listen: false);

      // Show a loading indicator during refresh
      setState(() {
        _isLoading = true;
      });

      try {
        await examProvider.refreshExams(widget.examType);
        print("QuestionsScreen: Data refresh completed");
      } catch (e) {
        print("QuestionsScreen: Error refreshing data: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Không thể cập nhật danh sách bài kiểm tra'),
            backgroundColor: Colors.red,
          ),
        );
      }

      // Update UI after refresh
      setState(() {
        _isLoading = false;
      });
    }
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
        child: Column(
          children: [
            // Use the TopBar widget instead of custom container
            TopBar(title: widget.title),
            // Content
            Expanded(
              child: _isLoading
                  ? Center(child: CircularProgressIndicator())
                  : _buildExamList(
                      context,
                      widget.examType,
                      widget.examType == 'weekly'
                          ? 'Danh Sách Tuần'
                          : 'Danh Sách Bài Kiểm Tra',
                      widget.examType == 'weekly'
                          ? 'Chọn tuần để kiểm tra kiến thức của bạn'
                          : 'Chọn bài kiểm tra để đánh giá kỹ năng của bạn'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExamList(
      BuildContext context, String examType, String title, String subtitle) {
    final pix = (MediaQuery.of(context).size.width / 375).clamp(0.8, 1.2);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final examProvider = Provider.of<ExamProvider>(context);

    return RefreshIndicator(
      onRefresh: () async {
        // Only refresh if manual pull-to-refresh is performed
        setState(() {
          _isLoading = true;
        });
        await Provider.of<ExamProvider>(context, listen: false)
            .refreshExams(examType);
        setState(() {
          _isLoading = false;
        });
        return;
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: 24 * pix, vertical: 16 * pix),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 18 * pix,
                fontFamily: 'BeVietnamPro',
                fontWeight: FontWeight.w600,
                color: isDarkMode ? Colors.white : const Color(0xFF1C2526),
              ),
            ),
            SizedBox(height: 8 * pix),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 14 * pix,
                fontFamily: 'BeVietnamPro',
                color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
              ),
            ),
            SizedBox(height: 24 * pix),

            // Show loading indicator
            if (examProvider.isLoadingExams && examProvider.exams.isEmpty)
              Center(
                child: Padding(
                  padding: EdgeInsets.all(20 * pix),
                  child: CircularProgressIndicator(),
                ),
              ),

            // Show error message
            if (examProvider.errorMessage != null && examProvider.exams.isEmpty)
              Center(
                child: Padding(
                  padding: EdgeInsets.all(20 * pix),
                  child: Text(
                    'Lỗi: ${examProvider.errorMessage}',
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: 14 * pix,
                    ),
                  ),
                ),
              ),

            // Show no exams message
            if (!examProvider.isLoadingExams &&
                examProvider.errorMessage == null &&
                examProvider.exams.isEmpty)
              Center(
                child: Padding(
                  padding: EdgeInsets.all(20 * pix),
                  child: Text(
                    'Không có bài kiểm tra nào',
                    style: TextStyle(
                      fontSize: 14 * pix,
                      fontFamily: 'BeVietnamPro',
                      color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                    ),
                  ),
                ),
              ),

            // Show exams from provider
            ...examProvider.exams.map((exam) {
              // Determine if the exam has been completed
              final hasScore = exam.examResults.isNotEmpty;
              final accentColor =
                  hasScore ? const Color(0xFF10B981) : const Color(0xFFD97706);

              return Padding(
                padding: EdgeInsets.only(bottom: 8 * pix),
                child: GestureDetector(
                  onTap: () => _navigateToQuiz(exam),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeInOut,
                    padding: EdgeInsets.all(16 * pix),
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
                          color:
                              Colors.black.withOpacity(isDarkMode ? 0.3 : 0.05),
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
                            color: accentColor.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            hasScore ? Icons.check_circle : Icons.assessment,
                            size: 24 * pix,
                            color: accentColor,
                          ),
                        ),
                        SizedBox(width: 16 * pix),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                exam.title ?? "Bài kiểm tra",
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
                                "Số câu hỏi: ${exam.numberOfQuestions}",
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
                        if (hasScore)
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 12 * pix, vertical: 6 * pix),
                            decoration: BoxDecoration(
                              color: accentColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(16 * pix),
                            ),
                            child: Text(
                              "${exam.examResults.first.score}/${exam.numberOfQuestions}",
                              style: TextStyle(
                                fontSize: 14 * pix,
                                fontWeight: FontWeight.w500,
                                color: accentColor,
                              ),
                            ),
                          )
                        else
                          Icon(
                            Icons.arrow_forward_ios,
                            size: 18 * pix,
                            color: accentColor,
                          ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),

            // Add pagination controls if needed
            if (examProvider.exams.isNotEmpty &&
                (examProvider.hasNextPage || examProvider.hasPreviousPage))
              Padding(
                padding: EdgeInsets.symmetric(vertical: 16 * pix),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (examProvider.hasPreviousPage)
                      IconButton(
                        onPressed: () =>
                            examProvider.loadPreviousPage(examType),
                        icon: Icon(Icons.arrow_back_ios),
                        color: isDarkMode ? Colors.white : Colors.black87,
                      ),
                    Text(
                      'Trang ${examProvider.currentPage}/${examProvider.totalPages}',
                      style: TextStyle(
                        fontSize: 14 * pix,
                        fontFamily: 'BeVietnamPro',
                        color: isDarkMode ? Colors.white : Colors.black87,
                      ),
                    ),
                    if (examProvider.hasNextPage)
                      IconButton(
                        onPressed: () => examProvider.loadNextPage(examType),
                        icon: Icon(Icons.arrow_forward_ios),
                        color: isDarkMode ? Colors.white : Colors.black87,
                      ),
                  ],
                ),
              ),

            SizedBox(height: 50 * pix), // Add some bottom padding
          ],
        ),
      ),
    );
  }
}
