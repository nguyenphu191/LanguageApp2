import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:language_app/models/common_response.dart';
import 'package:language_app/models/exams/exam_detail.dart';
import 'package:language_app/models/exams/exam_model.dart';
import 'package:language_app/models/exams/exam_overview.dart';
import 'package:language_app/models/pagination.dart';
import 'package:language_app/provider/auth_provider.dart';
import 'package:http/http.dart' as http;

class ExamProvider with ChangeNotifier {
  List<ExamModel> _exams = [];
  List<ExamModel> get exams => _exams;

  CommonResponse<ExamOverviewData>? examOverviewData;
  bool isLoading = false;
  String? errorMessage;

  bool _isRefreshingAfterSubmission = false;

  int currentPage = 1;
  int totalPages = 1;
  int totalExams = 0;
  bool hasNextPage = false;
  bool hasPreviousPage = false;

  bool isLoadingExams = false;

  final String baseUrl;
  final AuthProvider authProvider;

  ExamDetailModel? _currentExam;
  bool isLoadingExamDetail = false;
  String? examDetailError;

  // Keep track of all questions (single + section)
  List<Map<String, dynamic>> _allQuestions = [];
  int get totalQuestions => _allQuestions.length;
  List<Map<String, dynamic>> get allQuestions => _allQuestions;

  ExamDetailModel? get currentExam => _currentExam;

  bool isSubmittingResult = false;
  String? resultSubmissionError;

  ExamProvider({
    required this.baseUrl,
    required this.authProvider,
  });

  Future<void> fetchExamOverview({bool forceRefresh = false}) async {
    if (isLoading) {
      return;
    }

    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      print("fetchExamOverview: Fetching fresh data");
      final token = authProvider.token;

      if (token == null) {
        throw Exception("User not authenticated");
      }

      final response = await http.get(
        Uri.parse('${baseUrl}exams/overview'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        examOverviewData = CommonResponse<ExamOverviewData>.fromJson(
          jsonData,
          (data) => ExamOverviewData.fromJson(data as Map<String, dynamic>),
        );
        print("fetchExamOverview: Successfully fetched and updated data");
      } else {
        throw Exception('Server returned an error: ${response.statusCode}');
      }
    } catch (error) {
      errorMessage = error.toString();
      print("fetchExamOverview: Error: $errorMessage");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  double getCompletionPercentage(String examType) {
    if (examOverviewData == null) return 0.0;

    ExamTypeStats? stats;

    switch (examType) {
      case 'weeklyExams':
        stats = examOverviewData!.data.weeklyExams;
        break;
      case 'comprehensiveExams':
        stats = examOverviewData!.data.comprehensiveExams;
        break;
      case 'vocabGames':
        stats = examOverviewData!.data.vocabGames;
        break;
      default:
        return 0.0;
    }

    if (stats.total == 0) return 0.0;

    return stats.completed / stats.total;
  }

  Future<void> fetchExamsByType(String type,
      {int page = 1, int limit = 10}) async {
    isLoadingExams = true;
    errorMessage = null;
    notifyListeners();

    try {
      final token = authProvider.token;

      if (token == null) {
        throw Exception("User not authenticated");
      }

      final response = await http.get(
        Uri.parse('${baseUrl}exams?type=$type&page=$page&limit=$limit'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        print(jsonData.toString());

        final dataMap = jsonData['data'] as Map<String, dynamic>;
        final examsList = (dataMap['data'] as List<dynamic>)
            .map((examJson) =>
                ExamModel.fromJson(examJson as Map<String, dynamic>))
            .toList();

        _exams = examsList;

        final metaData = dataMap['meta'] as Map<String, dynamic>;
        currentPage = metaData['page'] ?? 1;
        totalPages = metaData['totalPages'] ?? 1;
        totalExams = metaData['total'] ?? 0;
        hasNextPage = metaData['hasNextPage'] ?? false;
        hasPreviousPage = metaData['hasPreviousPage'] ?? false;
      } else {
        throw Exception('Server returned an error: ${response.statusCode}');
      }
    } catch (e) {
      errorMessage = e.toString();
      _exams = [];
    } finally {
      isLoadingExams = false;
      notifyListeners();
    }
  }

  Future<void> loadNextPage(String type) async {
    if (hasNextPage && !isLoadingExams) {
      await fetchExamsByType(type, page: currentPage + 1);
    }
  }

  Future<void> loadPreviousPage(String type) async {
    if (hasPreviousPage && !isLoadingExams) {
      await fetchExamsByType(type, page: currentPage - 1);
    }
  }

  Future<void> refreshExams(String type) async {
    await fetchExamsByType(type, page: 1);
  }

  Future<void> fetchExamById(int examId) async {
    isLoadingExamDetail = true;
    examDetailError = null;
    _currentExam = null;
    _allQuestions = []; // Reset the combined questions list
    notifyListeners();

    try {
      print("fetchExamById: Starting to fetch exam data for ID $examId");
      final token = authProvider.token;

      if (token == null) {
        throw Exception("User not authenticated");
      }

      final response = await http.get(
        Uri.parse('${baseUrl}exams/$examId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print(
          "fetchExamById: Received response with status ${response.statusCode}");

      if (response.body.isEmpty) {
        throw Exception("Empty response received from server");
      }

      print(
          "fetchExamById: Response body start: ${response.body.substring(0, min(100, response.body.length))}...");

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        print("fetchExamById: Successfully decoded JSON");

        try {
          print("fetchExamById: Attempting to parse ExamDetailModel");

          // Check if the API returns data wrapped in a data field
          final examData =
              jsonData.containsKey('data') ? jsonData['data'] : jsonData;

          _currentExam = ExamDetailModel.fromJson(examData);
          print(_currentExam?.toString());
          print(
              "fetchExamById: Successfully parsed ExamDetailModel with ${_currentExam?.examSingleQuestions.length ?? 0} questions");

          if (_currentExam?.examSingleQuestions.isEmpty ?? true) {
            print("fetchExamById: Warning - No questions in exam");
          }

          // Process and combine all questions from both single questions and sections
          _processAllQuestions();
        } catch (parseError) {
          print("fetchExamById: Error parsing ExamDetailModel: $parseError");
          throw Exception("Failed to parse exam data: $parseError");
        }
      } else {
        throw Exception('Server returned an error: ${response.statusCode}');
      }
    } catch (e) {
      print("fetchExamById: Error: $e");
      examDetailError = e.toString();
    } finally {
      isLoadingExamDetail = false;
      notifyListeners();
      print(
          "fetchExamById: Finished with ${_currentExam != null ? 'successful' : 'failed'} result");
      print("fetchExamById: Total combined questions: ${_allQuestions.length}");
    }
  }

  // Process and combine all questions from an exam
  void _processAllQuestions() {
    if (_currentExam == null) {
      _allQuestions = [];
      return;
    }

    List<Map<String, dynamic>> questions = [];

    // Add single questions first
    if (_currentExam!.examSingleQuestions.isNotEmpty) {
      print(
          "Processing ${_currentExam!.examSingleQuestions.length} single questions");
      for (var sq in _currentExam!.examSingleQuestions) {
        questions.add({
          'type': 'single',
          'question': sq.question,
          'sectionTitle': null,
          'sectionDescription': null,
          'sectionType': null,
          'sectionAudioUrl': null,
        });
      }
    }

    // Add section questions
    if (_currentExam!.examSections.isNotEmpty) {
      print("Processing ${_currentExam!.examSections.length} sections");
      for (int sectionIndex = 0;
          sectionIndex < _currentExam!.examSections.length;
          sectionIndex++) {
        final section = _currentExam!.examSections[sectionIndex];
        print(
            "Processing section ${sectionIndex + 1}/${_currentExam!.examSections.length}: '${section.title ?? "Untitled"}' with ${section.examSectionItems.length} questions");

        for (int itemIndex = 0;
            itemIndex < section.examSectionItems.length;
            itemIndex++) {
          try {
            final item = section.examSectionItems[itemIndex];

            questions.add({
              'type': 'section',
              'question': item.question,
              'sectionTitle': section.title,
              'sectionDescription': section.description,
              'sectionType': section.type,
              'sectionAudioUrl': section.audioUrl,
              'sectionIndex': sectionIndex,
              'itemIndex': itemIndex,
            });
          } catch (e) {
            print("ERROR processing section item: $e");
          }
        }
      }
    }

    // Update the combined questions list
    _allQuestions = questions;
    print("Total combined questions: ${_allQuestions.length}");

    // Extra safety check to verify the combined list
    if (_allQuestions.isEmpty &&
        (_currentExam!.examSingleQuestions.isNotEmpty ||
            _currentExam!.examSections.isNotEmpty)) {
      print(
          "ERROR: Failed to process questions! Questions exist but _allQuestions is empty");
    }
  }

  Future<bool> submitExamResult(int examId, int score) async {
    isSubmittingResult = true;
    resultSubmissionError = null;
    notifyListeners();

    try {
      final token = authProvider.token;

      if (token == null) {
        throw Exception("User not authenticated");
      }

      final response = await http.put(
        Uri.parse('${baseUrl}exam-results'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({"examId": examId, "score": score}),
      );

      print(
          "submitExamResult: Submitted with status code ${response.statusCode}");

      if (response.statusCode == 201 || response.statusCode == 200) {
        print("submitExamResult: Successful submission, refreshing exam data");

        // Prevent multiple refreshes happening at once
        if (!_isRefreshingAfterSubmission) {
          _isRefreshingAfterSubmission = true;

          // Refresh all exam-related data
          try {
            // Force a fresh fetch of overview data
            await fetchExamOverview(forceRefresh: true);
            await refreshExams('weekly');
            print("submitExamResult: Successfully refreshed exam data");
          } catch (refreshError) {
            print(
                "submitExamResult: Error refreshing data after submission: $refreshError");
            // Still return true for submission since it succeeded
          } finally {
            _isRefreshingAfterSubmission = false;
          }
        } else {
          print(
              "submitExamResult: Refresh already in progress, skipping duplicate refresh");
        }

        return true;
      } else {
        throw Exception('Failed to submit result: ${response.statusCode}');
      }
    } catch (e) {
      print("submitExamResult error: $e");
      resultSubmissionError = e.toString();
      return false;
    } finally {
      isSubmittingResult = false;
      notifyListeners();
    }
  }

  // Method to clear exams list before loading a new exam type
  void clearExams() {
    _exams = [];
    notifyListeners();
  }
}
