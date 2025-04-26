import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:language_app/Models/post_model.dart';
import 'package:language_app/utils/baseurl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PostProvider with ChangeNotifier {
  String baseUrl = UrlUtils.getBaseUrl();
  List<PostModel> _posts = [];

  bool _isLoading = false;
  bool get getIsLoading => _isLoading;
  List<PostModel> get posts => _posts;
  final Dio _dio;

  PostProvider(this._dio);

  Future<bool> createPost({
    required String title,
    required String content,
    required int languageId,
    List<String>? tags,
    List<File>? files,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");
    if (token == null) {
      return false;
    }
    _isLoading = true;
    notifyListeners();

    try {
      // Prepare form data
      final formData = FormData.fromMap({
        'title': title,
        'content': content,
        'languageId': languageId,
        'tags': tags != null ? tags.join(',') : null,
      });

      // Add files if present
      if (files != null && files.isNotEmpty) {
        for (var file in files) {
          formData.files.add(MapEntry(
            'files',
            await MultipartFile.fromFile(file.path,
                filename: file.path.split('/').last),
          ));
        }
      }

      // Make API call
      final response = await _dio.post(
        '${baseUrl}posts',
        data: formData,
        options: Options(
          contentType: 'multipart/form-data',
          headers: {
            'Authorization': 'Bearer ${token}', // Implement token retrieval
          },
        ),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _isLoading = false;
        debugPrint('Error creating post: ${response.data}');
        return false;
      }
    } on DioException catch (e) {
      debugPrint('Error creating post: ${e.response?.data ?? e.message}');
      rethrow;
    }
  }

  Future<bool> fetchPosts({
    int? page,
    int? limit,
    int? languageId,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");
    if (token == null) {
      return false;
    }
    _isLoading = true;
    notifyListeners();

    try {
      Map<String, String> queryParams = {};
      if (languageId != null) queryParams['languageId'] = languageId.toString();
      if (page != null) queryParams['page'] = page.toString();
      if (limit != null) queryParams['limit'] = limit.toString();

      // Xây dựng URL với query parameters
      final uri = Uri.parse("${baseUrl}posts").replace(
          queryParameters: queryParams.isNotEmpty ? queryParams : null);

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${token}',
        },
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        _posts = (data['data']['data'] as List)
            .map((item) => PostModel.fromJson(item))
            .toList();
        print('Fetched posts: ${_posts[0]}');
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _isLoading = false;
        return false;
      }
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}
