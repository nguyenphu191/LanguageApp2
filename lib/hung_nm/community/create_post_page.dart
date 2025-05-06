import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:language_app/provider/language_provider.dart';
import 'package:provider/provider.dart';
import 'package:language_app/provider/post_provider.dart';
import 'package:language_app/models/language_model.dart';
import 'package:timeago/timeago.dart' as timeago;

class CreatePostPage extends StatefulWidget {
  const CreatePostPage({Key? key}) : super(key: key);

  @override
  State<CreatePostPage> createState() => _CreatePostPageState();
}

class _CreatePostPageState extends State<CreatePostPage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  final TextEditingController _topicController = TextEditingController();
  List<String> _topics = [];
  bool _isAnonymous = false;
  bool _isSubmitting = false;
  List<File> _selectedImages = [];
  final ImagePicker _picker = ImagePicker();
  int? _selectedLanguageId;

  @override
  void initState() {
    super.initState();
    // Thêm cài đặt locale tiếng Việt cho timeago
    timeago.setLocaleMessages('vi', timeago.ViMessages());

    // Tải danh sách ngôn ngữ khi trang được khởi tạo
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<LanguageProvider>(context, listen: false).fetchLanguages();
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _topicController.dispose();
    super.dispose();
  }

  // Chọn ảnh từ thư viện
  Future<void> _pickImages() async {
    try {
      final List<XFile>? pickedImages = await _picker.pickMultiImage();
      if (pickedImages != null && pickedImages.isNotEmpty) {
        // Kiểm tra kích thước file
        for (var image in pickedImages) {
          final file = File(image.path);
          final fileSize = await file.length();

          // Giới hạn kích thước file là 10MB
          if (fileSize > 10 * 1024 * 1024) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text(
                      'Ảnh ${image.name} quá lớn, vui lòng chọn ảnh nhỏ hơn 10MB')),
            );
            continue;
          }

          setState(() {
            _selectedImages.add(file);
          });
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Không thể chọn ảnh: $e")),
      );
    }
  }

  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  void _addTopic() {
    if (_topicController.text.isNotEmpty) {
      setState(() {
        _topics.add(_topicController.text);
        _topicController.clear();
      });
    }
  }

  void _submitPost() async {
    if (_titleController.text.isEmpty || _contentController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Vui lòng nhập đầy đủ tiêu đề và nội dung')),
      );
      return;
    }

    if (_selectedLanguageId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn ngôn ngữ cho bài viết')),
      );
      return;
    }

    try {
      setState(() {
        _isSubmitting = true;
      });

      final postProvider = Provider.of<PostProvider>(context, listen: false);
      final success = await postProvider.createPost(
        title: _titleController.text,
        content: _contentController.text,
        languageId: _selectedLanguageId!,
        tags: _topics.isNotEmpty ? _topics : null,
        files: _selectedImages.isNotEmpty ? _selectedImages : null,
      );

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đăng bài thành công')),
        );

        // Trả về kết quả thành công để CommunityForumPage biết cần cập nhật
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Đăng bài thất bại, vui lòng thử lại sau')),
        );
        setState(() {
          _isSubmitting = false;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi: ${e.toString()}')),
      );
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);
    final bool isLoadingLanguages = languageProvider.isLoading;
    final List<LanguageModel> languages = languageProvider.languages;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tạo bài viết mới'),
      ),
      body: Consumer<PostProvider>(builder: (context, postProvider, child) {
        if (postProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Tiêu đề và nội dung
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Tiêu đề',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _contentController,
                maxLines: 5,
                decoration: const InputDecoration(
                  labelText: 'Nội dung',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),

              // Chọn ngôn ngữ
              const Text('Ngôn ngữ bài viết:',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),

              isLoadingLanguages
                  ? const Center(child: CircularProgressIndicator())
                  : Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<int>(
                          isExpanded: true,
                          hint: const Text('Chọn ngôn ngữ'),
                          value: _selectedLanguageId,
                          items: languages.map((language) {
                            return DropdownMenuItem<int>(
                              value: int.tryParse(language.id),
                              child: Row(
                                children: [
                                  if (language.imageUrl.isNotEmpty)
                                    Image.network(
                                      language.imageUrl,
                                      width: 24,
                                      height: 24,
                                      errorBuilder: (context, error,
                                              stackTrace) =>
                                          const Icon(Icons.language, size: 24),
                                    ),
                                  const SizedBox(width: 8),
                                  Text(language.name),
                                ],
                              ),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedLanguageId = value;
                            });
                          },
                        ),
                      ),
                    ),
              const SizedBox(height: 20),

              // Thêm chủ đề
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _topicController,
                      decoration: const InputDecoration(
                        labelText: 'Thêm chủ đề',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.add_circle),
                    onPressed: _addTopic,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _topics
                    .map((topic) => Chip(
                          label: Text(topic),
                          deleteIcon: const Icon(Icons.close),
                          onDeleted: () {
                            setState(() {
                              _topics.remove(topic);
                            });
                          },
                        ))
                    .toList(),
              ),
              const SizedBox(height: 20),

              // Chọn ảnh
              ElevatedButton.icon(
                onPressed: _pickImages,
                icon: const Icon(Icons.photo_library),
                label: const Text('Chọn ảnh từ thư viện'),
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
              const SizedBox(height: 12),

              // Hiển thị ảnh đã chọn
              if (_selectedImages.isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Ảnh đã chọn:',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 120,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _selectedImages.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: Stack(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.file(
                                    _selectedImages[index],
                                    width: 120,
                                    height: 120,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                Positioned(
                                  right: 0,
                                  top: 0,
                                  child: GestureDetector(
                                    onTap: () => _removeImage(index),
                                    child: Container(
                                      padding: const EdgeInsets.all(2),
                                      decoration: BoxDecoration(
                                        color: Colors.red,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: const Icon(
                                        Icons.close,
                                        color: Colors.white,
                                        size: 18,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              const SizedBox(height: 16),

              // Đăng ẩn danh
              CheckboxListTile(
                title: const Text('Đăng ẩn danh'),
                value: _isAnonymous,
                contentPadding: EdgeInsets.zero,
                controlAffinity: ListTileControlAffinity.leading,
                onChanged: (value) {
                  setState(() {
                    _isAnonymous = value ?? false;
                  });
                },
              ),
              const SizedBox(height: 20),

              // Nút đăng bài
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submitPost,
                  child: Text("Dang bai"),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      }),
    );
  }
}
