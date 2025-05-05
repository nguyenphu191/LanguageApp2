import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:language_app/models/like_model.dart';
import 'package:language_app/models/post_model.dart';
import 'package:language_app/models/comment_model.dart';
import 'package:language_app/utils/baseurl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PostProvider with ChangeNotifier {
  String baseUrl = UrlUtils.getBaseUrl();
  List<PostModel> _posts = [];
  PostModel? _postDetail;

  bool _isLoading = false;
  bool get isLoading => _isLoading;
  List<PostModel> get posts => _posts;
  PostModel? get postDetail => _postDetail;

  final Dio _dio = Dio()
    ..interceptors.add(
      LogInterceptor(
        requestBody: true,
        responseBody: true,
        error: true,
      ),
    );

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
      // Tạo một Map để chứa dữ liệu
      final Map<String, dynamic> formDataMap = {
        'title': title,
        'content': content,
        'languageId': languageId,
      };

      // Thêm tags như một mảng nếu có
      if (tags != null && tags.isNotEmpty) {
        formDataMap['tags'] = tags; // Gửi trực tiếp là mảng
      }

      // Tạo FormData từ Map
      final formData = FormData.fromMap(formDataMap);

      // Add files if present
      if (files != null && files.isNotEmpty) {
        for (var i = 0; i < files.length; i++) {
          final file = files[i];
          final fileName = file.path.split('/').last;

          // Ensure correct file size
          final fileSize = await file.length();
          if (fileSize > 10 * 1024 * 1024) {
            // 10MB limit
            throw Exception(
                'File $fileName quá lớn (${(fileSize / 1024 / 1024).toStringAsFixed(2)}MB). Vui lòng chọn file nhỏ hơn 10MB.');
          }

          formData.files.add(MapEntry(
            'files',
            await MultipartFile.fromFile(
              file.path,
              filename: fileName,
            ),
          ));
        }
      }

      final response = await _dio.post(
        '${baseUrl}posts',
        data: formData,
        options: Options(
          contentType: 'multipart/form-data',
          headers: {
            'Authorization': 'Bearer $token',
          },
          validateStatus: (status) {
            return status! < 500;
          },
          receiveTimeout: const Duration(seconds: 30),
          sendTimeout: const Duration(seconds: 30),
        ),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;
        final postModel = PostModel.fromJson(data['data']);
        debugPrint('Bài viết đã tạo: $postModel');
        _posts.add(postModel);
        debugPrint('Danh sách bài viết sau khi thêm: $_posts');
        _isLoading = false;

        notifyListeners();
        return true;
      } else {
        _isLoading = false;

        // Get detailed error message from response
        var errorMessage = 'Lỗi không xác định';
        if (response.data != null && response.data is Map) {
          errorMessage = response.data['message'] ?? errorMessage;
        }

        debugPrint('Error creating post: $errorMessage');
        notifyListeners();
        return false;
      }
    } catch (e) {
      _isLoading = false;

      // Improved error handling
      String errorMessage = 'Đã xảy ra lỗi khi đăng bài viết';

      if (e is DioException) {
        if (e.response != null) {
          print('Response error data: ${e.response?.data}');
          errorMessage = 'Lỗi server: ${e.response?.statusCode}';

          if (e.response?.data is Map) {
            final errorData = e.response?.data as Map;
            if (errorData.containsKey('message')) {
              errorMessage = errorData['message'].toString();
            }
          }
        } else if (e.type == DioExceptionType.connectionTimeout) {
          errorMessage = 'Kết nối tới server quá lâu, vui lòng thử lại sau';
        } else if (e.type == DioExceptionType.sendTimeout) {
          errorMessage = 'Gửi dữ liệu quá lâu, vui lòng thử lại sau';
        }
      }

      debugPrint('Error creating post: $e');
      debugPrint('Error message: $errorMessage');
      notifyListeners();
      return false;
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
          'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);

        List<dynamic> postsData = data['data']['data'];

        _posts = postsData
            .map((e) {
              try {
                return PostModel.fromJson(e);
              } catch (parseError) {
                debugPrint('Lỗi khi phân tích bài đăng: $parseError');
                return null;
              }
            })
            .whereType<PostModel>()
            .toList();

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

  // Phương thức để thích bài viết và cập nhật UI
  Future<bool> likePost(int postId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");
    if (token == null) {
      return false;
    }
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _dio.post(
        '${baseUrl}post-likes',
        data: {
          'postId': postId,
        },
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
        ),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;
        final likeModel = LikeModel.fromJson(data);
        if (_postDetail != null) {
          _postDetail!.likes!.add(likeModel);
        }
        _posts.forEach((post) {
          if (post.id == postId.toString()) {
            post.likes!.add(likeModel);
          }
        });
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _isLoading = false;
        notifyListeners();
        debugPrint('Error liking post: ${response.data}');
        return false;
      }
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      debugPrint('Error liking post: $e');
      return false;
    }
  }

  // Phương thức để thêm bình luận và cập nhật UI
  Future<bool> addComment(int postId, String content) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");
    if (token == null) {
      return false;
    }

    try {
      final response = await _dio.post(
        '${baseUrl}post-comments',
        data: {
          'postId': postId,
          'content': content,
        },
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
        ),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Tạo comment tạm thời để hiển thị ngay lập tức
        final newCommentData = response.data['data'];
        if (newCommentData != null) {
          final newComment = CommentModel.fromJson(newCommentData);
          addCommentToPost(postId, newComment);
        }

        // Sau đó lấy dữ liệu chính xác từ server
        final updatedPost = await getPostDetail(postId);
        if (updatedPost != null) {
          // updatePostInList(updatedPost);
        }

        return true;
      } else {
        debugPrint('Error adding comment: ${response.data}');
        return false;
      }
    } catch (e) {
      debugPrint('Error adding comment: $e');
      return false;
    }
  }

  // Thêm bình luận tạm thời vào bài viết
  void addCommentToPost(int postId, CommentModel comment) {
    final index = _posts.indexWhere((post) => post.id == postId.toString());
    if (index != -1) {
      final updatedPosts = List<PostModel>.from(_posts);
      // Đảm bảo trường comments không null
      if (updatedPosts[index].comments == null) {
        updatedPosts[index].comments = [];
      }

      updatedPosts[index].comments!.add(comment);
      _posts = updatedPosts;
      notifyListeners();
    }
  }

  // Cập nhật bài viết trong danh sách
  void updatePostInList(PostModel updatedPost) {
    final index = _posts.indexWhere((post) => post.id == updatedPost.id);
    if (index != -1) {
      final updatedPosts = List<PostModel>.from(_posts);
      updatedPosts[index] = updatedPost;
      _posts = updatedPosts;
      notifyListeners();
    }
  }

  // Lấy chi tiết bài viết
  Future<bool> getPostDetail(int postId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");
    if (token == null) {
      return false;
    }
    _isLoading = true;
    notifyListeners();
    try {
      final response = await http.get(
        Uri.parse("${baseUrl}posts/$postId"),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('Chi tiết bài viết: ${data['data']}');
        final postModel = PostModel.fromJson(data['data']);
        print(
            'Chi tiết bài viết: ${postModel.toJson()}'); // In ra chi tiết bài viết
        _postDetail = postModel;
        _isLoading = false;
        notifyListeners();

        return true;
      } else {
        return false;
      }
    } catch (e) {
      debugPrint('Error getting post detail: $e');
      return false;
    }
  }
}
