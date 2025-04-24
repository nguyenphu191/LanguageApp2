import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:language_app/models/language_model.dart';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:language_app/utils/baseurl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http_parser/http_parser.dart';

class LanguageProvider with ChangeNotifier {
  String baseUrl = "${UrlUtils.getBaseUrl()}languages/";
  final Dio _dio = Dio();

  List<LanguageModel> _languages = [];
  LanguageModel? _selectedLanguage;
  LanguageModel? get selectedLanguage => _selectedLanguage;
  bool _isLoading = false;
  String? _error;

  // Getters
  List<LanguageModel> get languages => _languages;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Lấy danh sách ngôn ngữ
  Future<void> fetchLanguages() async {
    _isLoading = true;
    _languages = [];
    _error = null;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");

    try {
      final response = await http.get(
        Uri.parse(baseUrl),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _languages = (data['data']['data'] as List)
            .map((item) => LanguageModel.fromJson(item))
            .toList();
        _isLoading = false;
        notifyListeners();
      } else {
        throw Exception('Failed to load languages: ${response.statusCode}');
      }
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

// Lấy ngôn ngữ người dùng chọn
  Future<void> fetchLanguageSelected(String code) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");

    try {
      final response = await http.get(
        Uri.parse('${baseUrl}code/$code'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _selectedLanguage = LanguageModel.fromJson(data['data']);
        print("Selected Language: $_selectedLanguage");
        _isLoading = false;
        notifyListeners();
      } else {
        throw Exception('Failed to load language: ${response.statusCode}');
      }
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Tạo ngôn ngữ mới với ảnh
  Future<bool> createLanguage({
    required String name,
    required String code,
    required String description,
    required File imageFile,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");
    if (token == null) return false;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Xác định phần mở rộng file và mediaType
      final String fileExtension = imageFile.path.split('.').last.toLowerCase();

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
        case 'bmp':
          mediaType = MediaType('image', 'bmp');
          break;
        default:
          mediaType = MediaType('image', 'jpeg'); // Mặc định là jpeg
      }

      // Tạo FormData để gửi file với contentType
      final formData = FormData.fromMap({
        'name': name,
        'code': code,
        'description': description,
        'image': await MultipartFile.fromFile(
          imageFile.path,
          filename: 'image.$fileExtension',
          contentType: mediaType,
        ),
      });

      // In ra thông tin request
      print('Sending request to: $baseUrl');

      // Gửi request với Dio
      final response = await _dio.post(
        baseUrl,
        data: formData,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
          followRedirects: true,
          validateStatus: (status) =>
              true, // Chấp nhận mọi status code để xem lỗi
        ),
      );

      if (response.statusCode == 201) {
        // Cập nhật danh sách ngôn ngữ
        await fetchLanguages();
        _isLoading = false;
        _error = null;
        notifyListeners();
        return true;
      } else {
        _error =
            'Failed to create language: ${response.statusCode} - ${response.data}';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      print('Error creating language: $e');
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Cập nhật ngôn ngữ
  Future<bool> updateLanguage({
    required String id,
    required String name,
    required String description,
    File? imageFile,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");
    if (token == null) return false;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Tạo FormData
      Map<String, dynamic> formMap = {
        'name': name,
        'description': description,
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
          case 'bmp':
            mediaType = MediaType('image', 'bmp');
            break;
          default:
            mediaType = MediaType('image', 'jpeg');
        }

        formMap['image'] = await MultipartFile.fromFile(
          imageFile.path,
          filename: 'image.$fileExtension',
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

      print('Update response status: ${response.statusCode}');
      print('Update response data: ${response.data}');

      if (response.statusCode == 200) {
        // Cập nhật danh sách ngôn ngữ
        await fetchLanguages();
        _isLoading = false;
        _error = null;
        notifyListeners();
        return true;
      } else {
        _error =
            'Failed to update language: ${response.statusCode} - ${response.data}';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      print('Error updating language: $e');
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Xóa ngôn ngữ
  Future<bool> deleteLanguage(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");
    if (token == null) return false;

    _isLoading = true;
    _error = null;
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
        // Xóa ngôn ngữ khỏi danh sách cục bộ
        _languages.removeWhere((language) => language.id == id);
        _isLoading = false;
        _error = null;
        notifyListeners();
        return true;
      } else {
        _error = 'Failed to delete language: ${response.statusCode}';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      print('Error deleting language: $e');
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Lấy thông báo lỗi
  String getErrorMessage() {
    return _error ?? 'Đã có lỗi xảy ra';
  }
}
