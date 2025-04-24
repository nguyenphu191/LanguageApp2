class ForumPost {
  final String id;
  final String title;
  final String content;
  final String authorName;
  final String? authorAvatar;
  final DateTime postedTime;
  final List<String> imageUrls;
  final int likes;
  final int comments;
  final List<String> topics;
  final bool isPinned;

  ForumPost({
    required this.id,
    required this.title,
    required this.content,
    required this.authorName,
    this.authorAvatar,
    required this.postedTime,
    this.imageUrls = const [],
    this.likes = 0,
    this.comments = 0,
    this.topics = const [],
    this.isPinned = false,
  });

  // Tạo bản sao với các giá trị cập nhật
  ForumPost copyWith({
    String? id,
    String? title,
    String? content,
    String? authorName,
    String? authorAvatar,
    DateTime? postedTime,
    List<String>? imageUrls,
    int? likes,
    int? comments,
    List<String>? topics,
    bool? isPinned,
  }) {
    return ForumPost(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      authorName: authorName ?? this.authorName,
      authorAvatar: authorAvatar ?? this.authorAvatar,
      postedTime: postedTime ?? this.postedTime,
      imageUrls: imageUrls ?? this.imageUrls,
      likes: likes ?? this.likes,
      comments: comments ?? this.comments,
      topics: topics ?? this.topics,
      isPinned: isPinned ?? this.isPinned,
    );
  }

  // Chuyển đổi từ JSON (để fetch từ API)
  factory ForumPost.fromJson(Map<String, dynamic> json) {
    return ForumPost(
      id: json['id'],
      title: json['title'],
      content: json['content'],
      authorName: json['authorName'],
      authorAvatar: json['authorAvatar'],
      postedTime: DateTime.parse(json['postedTime']),
      imageUrls: List<String>.from(json['imageUrls'] ?? []),
      likes: json['likes'] ?? 0,
      comments: json['comments'] ?? 0,
      topics: List<String>.from(json['topics'] ?? []),
      isPinned: json['isPinned'] ?? false,
    );
  }

  // Chuyển đổi thành JSON (để gửi lên API)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'authorName': authorName,
      'authorAvatar': authorAvatar,
      'postedTime': postedTime.toIso8601String(),
      'imageUrls': imageUrls,
      'likes': likes,
      'comments': comments,
      'topics': topics,
      'isPinned': isPinned,
    };
  }

  @override
  String toString() {
    return 'ForumPost{id: $id, title: $title, authorName: $authorName}';
  }
}