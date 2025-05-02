import 'package:flutter/foundation.dart';
import 'package:language_app/service/api_service.dart';
import 'package:language_app/service/local_notification_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/notification_model.dart';

class NotificationProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  final LocalNotificationService _localNotificationService =
      LocalNotificationService();

  List<NotificationModel> _notifications = [];
  int _unreadCount = 0;
  bool _isLoading = false;
  int _currentPage = 1;
  bool _hasMorePages = true;

  List<NotificationModel> get notifications => _notifications;
  int get unreadCount => _unreadCount;
  bool get isLoading => _isLoading;
  bool get hasMorePages => _hasMorePages;

  NotificationProvider() {
    _loadUnreadCount();
  }

  Future<void> _loadUnreadCount() async {
    try {
      _unreadCount = await _apiService.getUnreadNotificationCount();
      notifyListeners();
    } catch (e) {
      print('Error loading unread count: $e');
    }
  }

  Future<void> fetchNotifications({bool refresh = false}) async {
    if (_isLoading) return;

    if (refresh) {
      _currentPage = 1;
      _hasMorePages = true;
    }

    if (!_hasMorePages && !refresh) return;

    _isLoading = true;
    notifyListeners();

    try {
      final result = await _apiService.getNotifications(
        page: _currentPage,
        limit: 20,
      );

      final List<NotificationModel> newNotifications = (result['data'] as List)
          .map((data) => NotificationModel.fromJson(data))
          .toList();

      if (_currentPage == 1) {
        _notifications = newNotifications;
      } else {
        _notifications.addAll(newNotifications);
      }

      _hasMorePages = _currentPage < (result['meta']['totalPages'] ?? 1);
      if (_hasMorePages) {
        _currentPage++;
      }

      await _loadUnreadCount();
    } catch (e) {
      print('Error fetching notifications: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> markAsRead(int notificationId) async {
    try {
      await _apiService.markNotificationAsRead(notificationId);

      final index = _notifications.indexWhere((n) => n.id == notificationId);
      if (index != -1 && !_notifications[index].isRead) {
        _notifications[index] = _notifications[index].copyWith(isRead: true);
        _unreadCount = _unreadCount > 0 ? _unreadCount - 1 : 0;
        notifyListeners();
      }
    } catch (e) {
      print('Error marking notification as read: $e');
    }
  }

  Future<void> markAllAsRead() async {
    try {
      await _apiService.markAllNotificationsAsRead();

      _notifications =
          _notifications.map((n) => n.copyWith(isRead: true)).toList();

      _unreadCount = 0;
      notifyListeners();
    } catch (e) {
      print('Error marking all notifications as read: $e');
    }
  }

  Future<void> checkForNewNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    final lastCheckTime = prefs.getString('last_notification_check');

    try {
      // Lấy số lượng thông báo chưa đọc mới
      final newUnreadCount = await _apiService.getUnreadNotificationCount();

      // Nếu có thông báo mới
      if (newUnreadCount > _unreadCount) {
        // Refresh danh sách thông báo
        await fetchNotifications(refresh: true);

        // Lấy thông báo mới nhất (chưa đọc) để hiển thị local notification
        final newNotification = _notifications.firstWhere((n) => !n.isRead,
            orElse: () => _notifications[0]);

        // Hiển thị thông báo local
        await _localNotificationService.showNotification(newNotification);
      }

      // Cập nhật thời gian kiểm tra
      prefs.setString(
          'last_notification_check', DateTime.now().toIso8601String());
    } catch (e) {
      print('Error checking for new notifications: $e');
    }
  }
}
