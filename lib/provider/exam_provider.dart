import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:language_app/Models/exam_model.dart';
import 'package:language_app/models/common_response.dart';
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

  int currentPage = 1;
  int totalPages = 1;
  int totalExams = 0;
  bool hasNextPage = false;
  bool hasPreviousPage = false;

  bool isLoadingExams = false;

  final String baseUrl;
  final AuthProvider authProvider;

  ExamProvider({
    required this.baseUrl,
    required this.authProvider,
  });

  Future<void> fetchExamOverview() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
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
      } else {
        throw Exception('Server returned an error: ${response.statusCode}');
      }
    } catch (error) {
      errorMessage = error.toString();
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

        final CommonResponse<PaginatedResponse<ExamModel>> paginatedResponse =
            CommonResponse<PaginatedResponse<ExamModel>>.fromJson(
          jsonData,
          (data) => PaginatedResponse<ExamModel>.fromJson(
            data as Map<String, dynamic>,
            (item) => ExamModel.fromJson(item),
          ),
        );

        _exams = paginatedResponse.data.data;

        currentPage = paginatedResponse.data.meta.page;
        totalPages = paginatedResponse.data.meta.totalPages;
        totalExams = paginatedResponse.data.meta.total;
        hasNextPage = paginatedResponse.data.meta.hasNextPage;
        hasPreviousPage = paginatedResponse.data.meta.hasPreviousPage;
      } else {
        throw Exception('Server returned an error: ${response.statusCode}');
      }
    } catch (e) {
      errorMessage = e.toString();
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
}
