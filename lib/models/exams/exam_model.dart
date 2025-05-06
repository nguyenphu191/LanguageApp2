class ExamModel {
  int id;
  String? title;
  String? type;
  List<ExamResult> examResults;
  int numberOfQuestions;

  ExamModel({
    required this.id,
    this.title,
    this.type,
    required this.examResults,
    required this.numberOfQuestions,
  });

  factory ExamModel.fromJson(Map<String, dynamic> json) {
    return ExamModel(
      id: json['id'],
      title: json['title'],
      type: json['type'],
      numberOfQuestions: json['numberOfQuestions'] ?? 0,
      examResults: json['examResults'] != null
          ? List<ExamResult>.from(
              (json['examResults'] as List).map(
                (x) => ExamResult.fromJson(x),
              ),
            )
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['title'] = title;
    data['type'] = type;
    data['numberOfQuestions'] = numberOfQuestions;
    data['examResults'] = examResults.map((x) => x.toJson()).toList();
    return data;
  }
}

class ExamResult {
  int? score;

  ExamResult({
    required this.score,
  });

  factory ExamResult.fromJson(Map<String, dynamic> json) {
    return ExamResult(
      score: json['score'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['score'] = score;
    return data;
  }
}
