import 'dart:math' as Math;

import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:language_app/Models/topic_model.dart';
import 'package:language_app/utils/baseurl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http_parser/http_parser.dart';

class TopicProvider with ChangeNotifier {
  String baseUrl = "${UrlUtils.getBaseUrl()}vocab-topics/";
  final Dio _dio = Dio();
  int _completed = 0;
  int _total = 0;
  int get completed => _completed;
  int get total => _total;

  List<TopicModel> _topics = [];
  bool _isLoading = false;

  // Getters
  List<TopicModel> get topics => _topics;
  bool get isLoading => _isLoading;

  // Lấy danh sách chủ đề
  Future<void> fetchTopics({String? languageId, int? level}) async {
    _isLoading = true;
    _topics = [];
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");

    try {
      // Xây dựng query parameters
      Map<String, String> queryParams = {};
      if (languageId != null) queryParams['languageId'] = languageId.toString();
      if (level != null) queryParams['level'] = level.toString();

      // Xây dựng URL với query parameters
      final uri = Uri.parse("${baseUrl}for-user").replace(
          queryParameters: queryParams.isNotEmpty ? queryParams : null);

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        List<dynamic> data2 = data['data']['data'];
        int doneCount =
            data2.where((topic) => topic['hasProgress'] == true).length;
        int total = data['data']['meta']['total'];
        _completed = doneCount;
        _total = total;
        _topics = (data['data']['data'] as List)
            .map((item) => TopicModel.fromJson(item))
            .toList();
        // print('Fetched topics: ${_topics[0]}');
        // print('Fetched topics count: ${_topics.length}');
        _isLoading = false;
        notifyListeners();
      } else {
        throw Exception('Failed to load topics: ${response.statusCode}');
      }
    } catch (e) {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Tạo chủ đề mới với ảnh
  Future<bool> createTopic({
    required String topic,
    required String languageId,
    required String level,
    required File imageFile,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");
    if (token == null) return false;

    _isLoading = true;
    notifyListeners();

    try {
      // In ra thông tin debug
      print(
          'Creating topic with token: ${token.substring(0, Math.min(10, token.length))}...');
      print('Topic: $topic');
      print('LanguageId: $languageId');
      print('Level: $level');
      print('Image path: ${imageFile.path}');
      print('Image exists: ${await imageFile.exists()}');
      print('Image size: ${await imageFile.length()} bytes');

      // Xác định phần mở rộng file và mediaType
      final String fileExtension = imageFile.path.split('.').last.toLowerCase();

      // Tạo FormData để gửi file với đúng tên trường
      final formData = FormData.fromMap({
        'topic': topic,
        'languageId': languageId,
        'level': level,
        // Đổi từ 'image' sang 'file' nếu server yêu cầu
        'image': await MultipartFile.fromFile(
          imageFile.path,
          filename: 'topic.$fileExtension',
        ),
      });

      // Gửi request với Dio và in thêm thông tin
      final response = await _dio.post(
        baseUrl,
        data: formData,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      print('Response status: ${response.statusCode}');
      print('Response data: ${response.data}');

      if (response.statusCode == 201) {
        await fetchTopics();
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      print('Error creating topic: $e');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Cập nhật chủ đề
  Future<bool> updateTopic({
    required String id,
    required String topic,
    required String languageId,
    required String level,
    File? imageFile,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");
    if (token == null) return false;

    _isLoading = true;
    notifyListeners();

    try {
      // Tạo FormData
      Map<String, dynamic> formMap = {
        'topic': topic,
        'languageId': languageId,
        'level': level,
      };

      // Thêm file ảnh nếu có
      if (imageFile != null) {
        final String fileExtension =
            imageFile.path.split('.').last.toLowerCase();

        // Xác định mediaType dựa trên phần mở rộng của file
        MediaType? mediaType;
        switch (fileExtension) {
          case 'jpg':
          case 'jpeg':
            mediaType = MediaType('image', 'jpeg');
            break;
          case 'png':
            mediaType = MediaType('image', 'png');
            break;
          case 'gif':
            mediaType = MediaType('image', 'gif');
            break;
          case 'webp':
            mediaType = MediaType('image', 'webp');
            break;
          default:
            mediaType = MediaType('image', 'jpeg');
        }

        formMap['image'] = await MultipartFile.fromFile(
          imageFile.path,
          filename: 'topic.$fileExtension',
          contentType: mediaType,
        );
      }

      final formData = FormData.fromMap(formMap);

      // Gửi request với Dio
      final response = await _dio.put(
        '$baseUrl$id',
        data: formData,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
          followRedirects: true,
          validateStatus: (status) => true,
        ),
      );

      if (response.statusCode == 200) {
        // Cập nhật danh sách chủ đề
        await fetchTopics();
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Xóa chủ đề
  Future<bool> deleteTopic(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");
    if (token == null) return false;

    _isLoading = true;
    notifyListeners();

    try {
      final response = await http.delete(
        Uri.parse('$baseUrl$id'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        // Xóa chủ đề khỏi danh sách cục bộ
        _topics.removeWhere((topic) => topic.id == id);
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}
