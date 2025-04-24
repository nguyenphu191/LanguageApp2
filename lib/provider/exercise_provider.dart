import 'package:flutter/material.dart';

import 'package:language_app/Models/exercise_model.dart';
import 'package:language_app/service/getEXdata.dart';

class ExerciseProvider with ChangeNotifier {
  List<ExerciseModel> _exercises = [];
  List<ExerciseModel> _grammarExercises = [];
  List<ExerciseModel> _listeningExercises = [];
  List<ExerciseModel> _speakingExercises = [];
  bool _isLoading = false;
  String? _error;

  List<ExerciseModel> get exercises => _exercises;
  bool get isLoading => _isLoading;
  String? get error => _error;
  List<ExerciseModel> get grammarExercises => _grammarExercises;
  List<ExerciseModel> get listeningExercises => _listeningExercises;
  List<ExerciseModel> get speakingExercises => _speakingExercises;

  // Lấy danh sách bài tập từ dữ liệu ảo
  Future<void> fetchExercises(String type) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    print('Fetching exercises for type: $type');

    try {
      if (type == 'grammar' || type == "Ngữ pháp") {
        _grammarExercises = MockExerciseData.getGrammarExercises();
      } else if (type == 'listening' || type == "Nghe") {
        _listeningExercises = MockExerciseData.getListeningExercises();
      } else if (type == 'speaking' || type == "Phát âm") {
        _speakingExercises = MockExerciseData.getSpeakingExercises();
      } else {
        throw Exception('Loại bài tập không hợp lệ');
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Lỗi tải bài tập: $e';
      _isLoading = false;
      notifyListeners();
    }
  }
}
