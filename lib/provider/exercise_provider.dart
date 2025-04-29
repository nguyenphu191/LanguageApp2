import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:language_app/Models/exercise_model.dart';
import 'package:language_app/utils/baseurl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ExerciseProvider with ChangeNotifier {
  String baseUrl = UrlUtils.getBaseUrl();

  List<ExerciseModel> _exercises = [];
  ExerciseModel? _exercise;
  Map<String, dynamic> _grammar = {'completed': 0, 'total': 0};
  Map<String, dynamic> _listening = {'completed': 0, 'total': 0};
  Map<String, dynamic> _speaking = {'completed': 0, 'total': 0};
  bool _isLoading = false;

  List<ExerciseModel> get exercises => _exercises;
  bool get isLoading => _isLoading;
  Map<String, dynamic> get grammarExercises => _grammar;
  Map<String, dynamic> get listeningExercises => _listening;
  Map<String, dynamic> get speakingExercises => _speaking;
  ExerciseModel? get exercise => _exercise;

  // Lấy danh sách bài tập từ dữ liệu ảo
  Future<void> fetchExerciseList(String type) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");
    if (token == null) {
      return;
    }
    _exercises = []; // Đặt lại danh sách bài tập về rỗng trước khi tải mới
    _isLoading = true;
    notifyListeners();
    try {
      Map<String, String> queryParams = {
        'type': type,
      };
      final uri = Uri.parse(
          "${baseUrl}exercises?${Uri(queryParameters: queryParams).query}");
      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        final List<dynamic> exerciseList = data['data']['data'];
        _exercises = exerciseList
            .map((exercise) => ExerciseModel.fromJson(exercise))
            .toList();

        _isLoading = false;
        notifyListeners();
      } else {
        _isLoading = false;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error fetching exercises: $e');
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchExercise(int id) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");
    if (token == null) {
      return;
    }
    _exercise = null;
    _isLoading = true;
    notifyListeners();
    try {
      final uri = Uri.parse("${baseUrl}exercises/$id");
      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);

        // Debug thông tin
        debugPrint('API Response: ${response.body}');

        final exerciseData = data['data'];

        // Debug trước khi parse để kiểm tra từng trường
        debugPrint('ID: ${exerciseData['id']}');
        debugPrint('Title: ${exerciseData['title']}');
        debugPrint('Description: ${exerciseData['description']}');
        debugPrint('Theory: ${exerciseData['theory']}');
        debugPrint('AudioUrl: ${exerciseData['audioUrl']}');
        debugPrint('Type: ${exerciseData['type']}');
        debugPrint('Difficulty: ${exerciseData['difficulty']}');

        try {
          _exercise = ExerciseModel.fromJson(exerciseData);
          // Debug sau khi parse
          debugPrint('Exercise parsed successfully: ${_exercise.toString()}');
        } catch (e) {
          debugPrint('Error during parsing ExerciseModel: $e');
          // Tìm trường gây lỗi
          debugPrint('Stack trace: ${e.toString()}');
        }

        _isLoading = false;
        notifyListeners();
      } else {
        debugPrint('Error response: ${response.statusCode} - ${response.body}');
        _isLoading = false;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error fetching exercise: $e');
      _isLoading = false;
      notifyListeners();
    }
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

  Future<bool> createResult(int exerciseId, int score) async {
    print("exerciseId: $exerciseId, score: $score");
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");
    if (token == null) {
      return false;
    }
    _isLoading = true;
    notifyListeners();
    try {
      final uri = Uri.parse("${baseUrl}exercise-results");
      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'score': score,
          "exerciseId": exerciseId,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        for (var i = 0; i < _exercises.length; i++) {
          if (_exercises[i].id == exerciseId) {
            // Chỉ cập nhật nếu điểm mới cao hơn
            if (_exercises[i].result == -1 || score > _exercises[i].result) {
              _exercises[i].result = score;
              debugPrint(
                  'Updated exercise ${_exercises[i].id} result to $score');
            }
          }
        }
        _isLoading = false;

        notifyListeners();
        return true;
      } else {
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      debugPrint('Error creating result: $e');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}
