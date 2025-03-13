class Topicmodel {
  String topic;
  String description;
  String image;
  String id;
  int numbervocabulary;

  Topicmodel(
      {required this.topic,
      required this.description,
      required this.image,
      required this.id,
      required this.numbervocabulary});

  factory Topicmodel.fromJson(Map<String, dynamic> json) => Topicmodel(
        topic: json['topic'],
        description: json['description'],
        image: json['image'],
        id: json['id'],
        numbervocabulary: json['numbervocabulary'],
      );
  Map<String, dynamic> toJson() => {
        'topic': topic,
        'description': description,
        'image': image,
        'id': id,
        'numbervocabulary': numbervocabulary,
      };
}
