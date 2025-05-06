import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:language_app/models/exams/exam_model.dart';
import 'package:language_app/models/pagination.dart';
import 'package:language_app/provider/auth_provider.dart';
import 'package:language_app/utils/baseurl.dart';

class QuestionsScreenProvider with ChangeNotifier {
  List<ExamModel> _exams = [];
  bool isLoading = false;
  String? errorMessage;

  // Pagination data
  int currentPage = 1;
  int totalPages = 1;
  int totalExams = 0;
  bool hasNextPage = false;
  bool hasPreviousPage = false;

  // Getters
  List<ExamModel> get exams => _exams;

  final String baseUrl;
  final AuthProvider authProvider;

  QuestionsScreenProvider({
    required this.baseUrl,
    required this.authProvider,
  });

  Future<void> fetchExamsByType(String type,
      {int page = 1, int limit = 10}) async {
    isLoading = true;
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
        print('Fetched exams: ${jsonData.toString()}');

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
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadNextPage(String type) async {
    if (hasNextPage && !isLoading) {
      await fetchExamsByType(type, page: currentPage + 1);
    }
  }

  Future<void> loadPreviousPage(String type) async {
    if (hasPreviousPage && !isLoading) {
      await fetchExamsByType(type, page: currentPage - 1);
    }
  }

  Future<void> refreshExams(String type) async {
    await fetchExamsByType(type, page: 1);
  }

  // Method to clear exams list before loading a new exam type
  void clearExams() {
    _exams = [];
    notifyListeners();
  }
}
