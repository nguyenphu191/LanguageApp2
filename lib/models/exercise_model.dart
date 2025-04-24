class ExerciseModel {
  int id;
  String name;
  String type;
  String level;
  String audio;
  String theory;
  String description;
  String imageUrl;
  int duration;

  ExerciseModel({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.duration,
    required this.level,
    required this.type,
    required this.audio,
    required this.theory,
  });

  factory ExerciseModel.fromJson(Map<String, dynamic> json) {
    return ExerciseModel(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      imageUrl: json['imageUrl'],
      duration: json['duration'],
      type: json['type'],
      audio: json['audio'],
      level: json['level'],
      theory: json['theory'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'imageUrl': imageUrl,
      'duration': duration,
      'type': type,
      'audio': audio,
      'level': level,
      'theory': theory,
    };
  }

  @override
  String toString() {
    return 'ExerciseModel{id: $id, name: $name, type: $type, level: $level, audio: $audio, theory: $theory, description: $description, imageUrl: $imageUrl, duration: $duration}';
  }
}
