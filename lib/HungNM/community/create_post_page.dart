import 'package:flutter/material.dart';
import './models/forum_post.dart';
import './forum_detail_page.dart';

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

  void _addTopic() {
    if (_topicController.text.isNotEmpty) {
      setState(() {
        _topics.add(_topicController.text);
        _topicController.clear();
      });
    }
  }

  void _submitPost() {
    if (_titleController.text.isNotEmpty && _contentController.text.isNotEmpty) {
      final newPost = ForumPost(
        id: DateTime.now().toString(), // Thay bằng ID từ server
        title: _titleController.text,
        content: _contentController.text,
        authorName: _isAnonymous ? 'Ẩn danh' : 'Current User', // Thay bằng user thực tế
        postedTime: DateTime.now(),
        topics: _topics,
      );
      Navigator.pop(context);
      Navigator.push(context, MaterialPageRoute(builder: (_) => ForumDetailPage(post: newPost)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tạo bài viết mới'),
        actions: [
          TextButton(
            onPressed: _submitPost,
            child: const Text('Đăng bài', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Tiêu đề'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _contentController,
              maxLines: 5,
              decoration: const InputDecoration(labelText: 'Nội dung'),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _topicController,
                    decoration: const InputDecoration(labelText: 'Thêm chủ đề'),
                  ),
                ),
                IconButton(icon: const Icon(Icons.add), onPressed: _addTopic),
              ],
            ),
            Wrap(spacing: 8, children: _topics.map((topic) => Chip(label: Text(topic))).toList()),
            CheckboxListTile(
              title: const Text('Đăng ẩn danh'),
              value: _isAnonymous,
              onChanged: (value) => setState(() => _isAnonymous = value!),
            ),
          ],
        ),
      ),
    );
  }
}