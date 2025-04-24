import 'package:flutter/material.dart';

enum NotificationType {
  general, // Thông báo chung
  event, // Sự kiện
  warning, // Cảnh báo
  message, // Tin nhắn
  reminder // Nhắc nhở
}

class NotificationModel {
  final String? id;
  final NotificationType type;
  final String title;
  final String content;
  final String time;
  final bool isRead;

  NotificationModel({
    this.id,
    required this.type,
    required this.title,
    required this.content,
    required this.time,
    this.isRead = false,
  });

  // Phương thức lấy biểu tượng dựa trên loại thông báo
  IconData get icon {
    switch (type) {
      case NotificationType.general:
        return Icons.notifications;
      case NotificationType.event:
        return Icons.event;
      case NotificationType.warning:
        return Icons.warning;

      case NotificationType.message:
        return Icons.message;

      case NotificationType.reminder:
        return Icons.alarm;
    }
  }

  // Phương thức lấy màu dựa trên loại thông báo
  Color get color {
    switch (type) {
      case NotificationType.general:
        return Colors.blue;
      case NotificationType.event:
        return Colors.green;
      case NotificationType.warning:
        return Colors.orange;

      case NotificationType.message:
        return Colors.indigo;

      case NotificationType.reminder:
        return Colors.amber;
    }
  }

  // Tạo model từ JSON
  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json["_id"],
      type: json["type"] ?? "general",
      title: json["title"] ?? "",
      content: json["content"] ?? "",
      time: json["time"] ?? "",
      isRead: json["isRead"] ?? false,
    );
  }

  // Chuyển đổi model thành JSON
  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "type": type.toString().split('.').last,
      "title": title,
      "content": content,
      "time": time,
      "isRead": isRead,
    };
  }

  @override
  String toString() {
    return 'NotificationModel{id: $id, type: $type, title: $title, content: $content, time: $time, isRead: $isRead}';
  }
}
