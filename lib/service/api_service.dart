import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/notification_model.dart';

class ApiService {
  final String baseUrl =
      'https://your-api-url.com'; // Thay bằng URL API thực tế

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  // Phương thức lấy danh sách thông báo
  Future<Map<String, dynamic>> getNotifications(
      {int page = 1, int limit = 20}) async {
    final token = await _getToken();

    if (token == null) {
      throw Exception('Chưa đăng nhập');
    }

    final response = await http.get(
      Uri.parse('$baseUrl/notifications?page=$page&limit=$limit'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      return jsonResponse['data'];
    } else {
      throw Exception('Không thể lấy thông báo: ${response.body}');
    }
  }

  // Phương thức đánh dấu thông báo đã đọc
  Future<void> markNotificationAsRead(int notificationId) async {
    final token = await _getToken();

    if (token == null) {
      throw Exception('Chưa đăng nhập');
    }

    final response = await http.patch(
      Uri.parse('$baseUrl/notifications/$notificationId/read'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Không thể đánh dấu đã đọc: ${response.body}');
    }
  }

  // Phương thức đánh dấu tất cả thông báo đã đọc
  Future<void> markAllNotificationsAsRead() async {
    final token = await _getToken();

    if (token == null) {
      throw Exception('Chưa đăng nhập');
    }

    final response = await http.patch(
      Uri.parse('$baseUrl/notifications/read-all'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Không thể đánh dấu tất cả đã đọc: ${response.body}');
    }
  }

  // Phương thức lấy số lượng thông báo chưa đọc
  Future<int> getUnreadNotificationCount() async {
    final token = await _getToken();

    if (token == null) {
      return 0;
    }

    final response = await http.get(
      Uri.parse('$baseUrl/notifications/unread-count'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      return jsonResponse['data']['count'];
    } else {
      return 0;
    }
  }
}
