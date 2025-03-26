import 'dart:convert';

class Vocabulary {
  String id;
  String word;
  String definition;
  int difficulty;
  String example;
  String meaning;
  String image;
  String topicId;

  Vocabulary(
      {required this.id,
      required this.word,
      required this.definition,
      required this.difficulty,
      required this.example,
      required this.meaning,
      required this.image,
      required this.topicId});

  factory Vocabulary.fromJson(Map<String, dynamic> json) => Vocabulary(
        id: json['id'],
        word: json['word'],
        definition: json['definition'],
        difficulty: json['difficulty'],
        example: json['example'],
        meaning: json['meaning'],
        image: json['image'],
        topicId: json['topic_id'],
      );
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'word': word,
      'definition': definition,
      'difficulty': difficulty,
      'example': example,
      'meaning': meaning,
      'image': image,
      'topic_id': topicId,
    };
  }
}
