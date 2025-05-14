class CommentModel {
  final int id;
  final int postId;
  final int userId;
  final String content;
  final String createdAt;
  final String updatedAt;
  final String? userDisplayName;
  final String? userAvatar;
  final List<CommentModel> replies;

  CommentModel({
    required this.id,
    required this.postId,
    required this.userId,
    required this.content,
    required this.createdAt,
    required this.updatedAt,
    this.userDisplayName,
    this.userAvatar,
    this.replies = const [],
  });

  factory CommentModel.fromJson(Map<String, dynamic> json) {
    final userMap = json['user'] as Map<String, dynamic>?;

    // Xử lý tên hiển thị người dùng
    String? displayName;
    if (userMap != null) {
      // Kiểm tra các trường hợp khác nhau của tên người dùng
      if (userMap.containsKey('displayName') &&
          userMap['displayName'] != null) {
        displayName = userMap['displayName'];
      } else if (userMap.containsKey('firstName') ||
          userMap.containsKey('lastName')) {
        String firstName = userMap['firstName'] ?? '';
        String lastName = userMap['lastName'] ?? '';
        displayName = '$firstName $lastName'.trim();
      } else if (userMap.containsKey('name')) {
        displayName = userMap['name'];
      } else if (userMap.containsKey('username')) {
        displayName = userMap['username'];
      }
    }

    // Xử lý avatar của người dùng
    String? avatarUrl;
    if (userMap != null) {
      // Kiểm tra các trường hợp khác nhau của avatar
      if (userMap.containsKey('avatar') && userMap['avatar'] != null) {
        avatarUrl = userMap['avatar'];
      } else if (userMap.containsKey('profileImageUrl')) {
        avatarUrl = userMap['profileImageUrl'];
      } else if (userMap.containsKey('profileImage')) {
        avatarUrl = userMap['profileImage'];
      } else if (userMap.containsKey('imageUrl')) {
        avatarUrl = userMap['imageUrl'];
      }
    }

    return CommentModel(
      id: json['id'],
      postId: json['postId'],
      userId: json['userId'],
      content: json['content'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
      userDisplayName: displayName,
      userAvatar: avatarUrl,
      replies: json['replies'] != null
          ? List<CommentModel>.from(
              json['replies'].map((x) => CommentModel.fromJson(x)))
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'postId': postId,
      'userId': userId,
      'content': content,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'user': {
        'displayName': userDisplayName,
        'avatar': userAvatar,
      },
      'replies': replies.map((reply) => reply.toJson()).toList(),
    };
  }
}
