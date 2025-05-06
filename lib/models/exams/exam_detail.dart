class ExamDetailModel {
  final int id;
  final String title;
  final String description;
  final String type;
  final int languageId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<ExamSingleQuestion> examSingleQuestions;
  final List<ExamSection> examSections;

  ExamDetailModel({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.languageId,
    required this.createdAt,
    required this.updatedAt,
    required this.examSingleQuestions,
    required this.examSections,
  });

  factory ExamDetailModel.fromJson(Map<String, dynamic> json) {
    return ExamDetailModel(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      type: json['type'],
      languageId: json['languageId'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      examSingleQuestions: List<ExamSingleQuestion>.from(
        (json['examSingleQuestions'] as List)
            .map((x) => ExamSingleQuestion.fromJson(x)),
      ),
      examSections: List<ExamSection>.from(
        (json['examSections'] as List).map((x) => ExamSection.fromJson(x)),
      ),
    );
  }
}

class ExamSingleQuestion {
  final int id;
  final int examId;
  final int questionId;
  final Question question;

  ExamSingleQuestion({
    required this.id,
    required this.examId,
    required this.questionId,
    required this.question,
  });

  factory ExamSingleQuestion.fromJson(Map<String, dynamic> json) {
    return ExamSingleQuestion(
      id: json['id'],
      examId: json['examId'],
      questionId: json['questionId'],
      question: Question.fromJson(json['question']),
    );
  }
}

class Question {
  final int id;
  final String type;
  final String question;
  final List<String>? options;
  final String answer;
  final int languageId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? mediaUrl;
  final String? explanation;

  Question({
    required this.id,
    required this.type,
    required this.question,
    this.options,
    required this.answer,
    required this.languageId,
    required this.createdAt,
    required this.updatedAt,
    this.mediaUrl,
    this.explanation,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      id: json['id'],
      type: json['type'],
      question: json['question'],
      options:
          json['options'] != null ? List<String>.from(json['options']) : null,
      answer: json['answer'],
      languageId: json['languageId'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      mediaUrl: json['mediaUrl'],
      explanation: json['explanation'],
    );
  }
}

class ExamSection {
  final int id;
  final int examId;
  final String type;
  final String? title;
  final String? description;
  final String? audioUrl;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<ExamSectionItem> examSectionItems;

  ExamSection({
    required this.id,
    required this.examId,
    required this.type,
    this.title,
    this.description,
    this.audioUrl,
    required this.createdAt,
    required this.updatedAt,
    required this.examSectionItems,
  });

  factory ExamSection.fromJson(Map<String, dynamic> json) {
    return ExamSection(
      id: json['id'],
      examId: json['examId'],
      type: json['type'],
      title: json['title'],
      description: json['description'],
      audioUrl: json['audioUrl'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      examSectionItems: List<ExamSectionItem>.from(
        (json['examSectionItems'] as List)
            .map((x) => ExamSectionItem.fromJson(x)),
      ),
    );
  }
}

class ExamSectionItem {
  final int id;
  final int sectionId;
  final String type;
  final String content;
  final DateTime createdAt;
  final DateTime updatedAt;

  ExamSectionItem({
    required this.id,
    required this.sectionId,
    required this.type,
    required this.content,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ExamSectionItem.fromJson(Map<String, dynamic> json) {
    return ExamSectionItem(
      id: json['id'],
      sectionId: json['sectionId'],
      type: json['type'],
      content: json['content'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }
}
