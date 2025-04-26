class CommentModel {
  String? id;
  String? userId;
  String? postId;
  String? content;
  String? createdAt;
  String? updatedAt;

  CommentModel({
    this.id,
    this.userId,
    this.postId,
    this.createdAt,
    this.updatedAt,
  });

  CommentModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userId = json['user_id'];
    postId = json['post_id'];
    content = json['content'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['user_id'] = userId;
    data['post_id'] = postId;
    data['content'] = content;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    return data;
  }
}