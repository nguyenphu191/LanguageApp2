class CommentModel {
  String? id;
  String? userId;
  String? userName;
  String? userAvatar;
  String? postId;
  String? content;
  DateTime? createdAt;
  DateTime? updatedAt;

  CommentModel({
    this.id,
    this.userId,
    this.postId,
    this.userName,
    this.userAvatar,
    this.content,
    this.createdAt,
    this.updatedAt,
  });

  CommentModel.fromJson(Map<String, dynamic> json) {
    id = json['id'].toString();
    userId = json['userId'].toString();
    postId = json['postId'].toString();

    // Xử lý dữ liệu người dùng đúng cách
    if (json['user'] != null) {
      userName = "${json['user']['firstName']} ${json['user']['lastName']}";
      userAvatar = json['user']['profileImageUrl'];
    } else {
      userName = "";
      userAvatar = "";
    }

    content = json['content'] ?? "";

    // Xử lý ngày tháng
    createdAt =
        json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null;
    updatedAt =
        json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['userId'] = userId;
    data['postId'] = postId;
    data['content'] = content;
    data['createdAt'] = createdAt?.toIso8601String();
    data['updatedAt'] = updatedAt?.toIso8601String();

    return data;
  }
}
