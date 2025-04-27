import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:language_app/Models/exercise_model.dart';
import 'package:language_app/utils/baseurl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ExerciseProvider with ChangeNotifier {
  String baseUrl = UrlUtils.getBaseUrl();

  List<ExerciseModel> _exercises = [];
  Map<String, dynamic> _grammar = {'completed': 0, 'total': 0};
  Map<String, dynamic> _listening = {'completed': 0, 'total': 0};
  Map<String, dynamic> _speaking = {'completed': 0, 'total': 0};
  bool _isLoading = false;

  List<ExerciseModel> get exercises => _exercises;
  bool get isLoading => _isLoading;
  Map<String, dynamic> get grammarExercises => _grammar;
  Map<String, dynamic> get listeningExercises => _listening;
  Map<String, dynamic> get speakingExercises => _speaking;

  // Lấy danh sách bài tập từ dữ liệu ảo
  Future<void> fetchExercises(String type) async {
    _isLoading = true;
    notifyListeners();
  }

  Future<bool> fetchProgress() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");
    if (token == null) {
      return false;
    }

    // Khởi tạo giá trị mặc định cho các map
    _grammar = {'completed': 0, 'total': 0};
    _listening = {'completed': 0, 'total': 0};
    _speaking = {'completed': 0, 'total': 0};

    _isLoading = true;
    notifyListeners();

    try {
      final uri = Uri.parse("${baseUrl}exercises/overview");
      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        final progress = data['data']['progress'];

        // Đảm bảo dữ liệu được parse thành đúng kiểu
        _grammar = {
          'completed': progress['grammar']['completed'] ?? 0,
          'total': progress['grammar']['total'] ?? 0,
        };

        _listening = {
          'completed': progress['listening']['completed'] ?? 0,
          'total': progress['listening']['total'] ?? 0,
        };

        _speaking = {
          'completed': progress['speaking']['completed'] ?? 0,
          'total': progress['speaking']['total'] ?? 0,
        };

        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      debugPrint('Error fetching progress: $e');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}
