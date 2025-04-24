import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:async';

import 'package:language_app/Models/notification_model.dart';
import 'package:language_app/utils/baseurl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationProvider with ChangeNotifier {
  String baseUrl = "${UrlUtils.getBaseUrl()}noti/";
  List<NotificationModel> _notifications = [];
  bool _isLoading = false;
  String? _error;
  Timer? _refreshTimer;

  // Getters
  List<NotificationModel> get notifications => _notifications;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get unreadCount =>
      _notifications.where((notification) => !notification.isRead).length;

  // Khởi tạo Provider với userId
  void initialize(String userId) {
    fetchNotifications();

    // Thiết lập timer để tự động làm mới thông báo mỗi 1 phút
    _refreshTimer?.cancel();
    _refreshTimer = Timer.periodic(Duration(minutes: 1), (_) {
      fetchNotifications();
    });
  }

  // Hủy timer khi không cần thiết
  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  // Lấy danh sách thông báo
  Future<void> fetchNotifications() async {
    _isLoading = true;
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");

    if (token == null) {
      _isLoading = false;
      _error = "Token không hợp lệ";
      print("Token không hợp lệ");
      notifyListeners();
    }
    try {
      final response = await http.get(
        Uri.parse('${baseUrl}user'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _notifications = (data['data'] as List)
            .map((item) => _parseNotification(item))
            .toList();
        _notifications.sort((a, b) => b.time.compareTo(a.time));
        print("Thông báo: ${_notifications[0]}");
        _isLoading = false;
        notifyListeners();
      } else {
        throw Exception('Failed to load notifications');
      }
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }

  // Chuyển đổi dữ liệu JSON thành NotificationModel
  NotificationModel _parseNotification(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['_id'],
      type: _getNotificationType(json['type']),
      title: json['title'],
      content: json['content'],
      time: json['time'],
      isRead: json['isRead'] ?? false,
    );
  }

  // Chuyển đổi chuỗi type thành enum NotificationType
  NotificationType _getNotificationType(String typeStr) {
    switch (typeStr) {
      case 'event':
        return NotificationType.event;
      case 'warning':
        return NotificationType.warning;
      case 'message':
        return NotificationType.message;
      case 'reminder':
        return NotificationType.reminder;
      default:
        return NotificationType.general;
    }
  }

  // Đánh dấu thông báo đã đọc
  Future<void> markAsRead(String notificationId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");

    if (token == null) {
      _isLoading = false;
      _error = "Token không hợp lệ";
    }
    try {
      final response = await http.put(
        Uri.parse('$baseUrl$notificationId/read'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token', // Thay thế bằng token thực tế
        },
      );

      if (response.statusCode == 200) {
        // Cập nhật trạng thái local
        final index = _notifications.indexWhere((n) => n.id == notificationId);
        if (index != -1) {
          final updatedNotification = NotificationModel(
            id: _notifications[index].id,
            type: _notifications[index].type,
            title: _notifications[index].title,
            content: _notifications[index].content,
            time: _notifications[index].time,
            isRead: true,
          );
          _notifications[index] = updatedNotification;
          notifyListeners();
        }
      } else {
        throw Exception('Failed to mark notification as read');
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  // Đánh dấu tất cả thông báo đã đọc
  Future<void> markAllAsRead() async {
    print("Đánh dấu tất cả thông báo đã đọc");
    if (_notifications.isEmpty) return;

    _isLoading = true;
    notifyListeners();

    try {
      for (var notification in _notifications.where((n) => !n.isRead)) {
        await markAsRead(notification.id!);
      }
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }
}
