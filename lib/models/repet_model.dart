class RepetitionInfo {
  final double? priorityScore;
  final int? repetitionCount;
  final double? easinessFactor;
  final DateTime? nextReviewAt;
  final int? intervalDays;
  final String? lastDifficulty;

  RepetitionInfo({
    this.priorityScore,
    this.repetitionCount,
    this.easinessFactor,
    this.nextReviewAt,
    this.intervalDays,
    this.lastDifficulty,
  });

  factory RepetitionInfo.fromJson(Map<String, dynamic> json) {
    return RepetitionInfo(
      priorityScore: json['priorityScore']?.toDouble(),
      repetitionCount: json['repetitionCount'],
      easinessFactor: json['easinessFactor']?.toDouble(),
      nextReviewAt: json['nextReviewAt'] != null
          ? DateTime.parse(json['nextReviewAt'])
          : null,
      intervalDays: json['intervalDays'],
      lastDifficulty: json['lastDifficulty'],
    );
  }

  // Tính thời gian còn lại đến lần ôn tập tiếp theo
  String getTimeUntilNextReview() {
    if (nextReviewAt == null) return "Chưa xác định";

    final now = DateTime.now();
    if (nextReviewAt!.isBefore(now)) return "Đã đến hạn ôn tập";

    final difference = nextReviewAt!.difference(now);

    if (difference.inDays > 0) {
      return "${difference.inDays} ngày nữa";
    } else if (difference.inHours > 0) {
      return "${difference.inHours} giờ nữa";
    } else if (difference.inMinutes > 0) {
      return "${difference.inMinutes} phút nữa";
    } else {
      return "Sắp đến giờ ôn tập";
    }
  }
}
