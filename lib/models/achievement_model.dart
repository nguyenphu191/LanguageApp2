class Achievement {
  final int id;
  final String title;
  final String description;
  final String? badgeImageUrl;
  final String triggerCondition;
  final int conditionValue;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isUnlocked;

  Achievement({
    required this.id,
    required this.title,
    required this.description,
    this.badgeImageUrl,
    required this.triggerCondition,
    required this.conditionValue,
    required this.createdAt,
    required this.updatedAt,
    this.isUnlocked = false,
  });

  factory Achievement.fromJson(Map<String, dynamic> json) {
    return Achievement(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      badgeImageUrl: json['badgeImageUrl'],
      triggerCondition: json['triggerCondition'],
      conditionValue: json['conditionValue'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      isUnlocked: false, // Không có dữ liệu user_achievements, giả lập là false
    );
  }
}
