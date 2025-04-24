import 'package:flutter/material.dart';
import 'package:language_app/Models/exam_model.dart';

class ExamProvider with ChangeNotifier {
  List<ExamModel> _exams = [];

  List<ExamModel> get exams => _exams;

  Future<void> addExam(ExamModel exam) async {
    _exams.add(exam);
    notifyListeners();
  }

  Future<void> removeExam(int index) async {
    _exams.removeAt(index);
    notifyListeners();
  }

  Future<void> fetchExams() async {
    _exams.clear();
    notifyListeners();
  }
}
