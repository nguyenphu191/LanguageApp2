import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:language_app/Models/post_model.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../profile/profile_sceen.dart';
import './topic_page.dart';

class ForumDetailPage extends StatefulWidget {
  final PostModel post;

  const ForumDetailPage({Key? key, required this.post}) : super(key: key);

  @override
  State<ForumDetailPage> createState() => _ForumDetailPageState();
}

class _ForumDetailPageState extends State<ForumDetailPage> {
  late PostModel _post;
  final TextEditingController _commentController = TextEditingController();
  List<Map<String, dynamic>> _comments = []; // Mock comments

  @override
  void initState() {
    super.initState();
    _post = widget.post;
    _comments = [
      {
        'user': 'Ngọc Lan',
        'text': 'Bài viết rất hữu ích, cảm ơn bạn!',
        'time': DateTime.now().subtract(const Duration(minutes: 30)),
        'helpful': 5
      },
      {
        'user': 'Minh Tuấn',
        'text': 'Mình cũng áp dụng cách này, hiệu quả lắm!',
        'time': DateTime.now().subtract(const Duration(hours: 1)),
        'helpful': 2
      },
    ];
  }

  // void _likePost() {
  //   setState(() {
  //     _post = _post.copyWith(likes: _post.likes + 1);
  //   });
  // }

  void _addComment() {
    if (_commentController.text.isNotEmpty) {
      setState(() {
        _comments.add({
          'user': 'Current User', // Thay bằng user thực tế
          'text': _commentController.text,
          'time': DateTime.now(),
          'helpful': 0,
        });
        // _post = _post.copyWith(comments: _post.comments + 1);
        _commentController.clear();
      });
    }
  }

  void _markHelpful(int index) {
    setState(() {
      _comments[index]['helpful'] += 1;
    });
  }

  void _navigateToUserProfile(String userId, String userName) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ProfileScreen()),
    );
  }

  void _navigateToTopic(String topic) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => TopicPage(topic: topic)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_post.title ?? 'Untitled'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              // Logic chia sẻ
            },
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'edit') {
                // Logic chỉnh sửa bài viết
              } else if (value == 'report') {
                // Logic báo cáo
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'edit', child: Text('Chỉnh sửa')),
              const PopupMenuItem(value: 'report', child: Text('Báo cáo')),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Author info
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => _navigateToUserProfile(
                        'author-${_post.id}', _post.userName ?? ''),
                    child: CircleAvatar(
                      radius: 20,
                      backgroundImage: _post.userAvatar != null
                          ? CachedNetworkImageProvider(_post.userAvatar!)
                          : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(_post.userName ?? 'Unknown User',
                            style:
                                const TextStyle(fontWeight: FontWeight.bold)),
                        Text(timeago.format(_post.createdAt!, locale: 'vi'),
                            style: TextStyle(color: Colors.grey.shade600)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Content
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(_post.content ?? "",
                  style: const TextStyle(fontSize: 16)),
            ),
            // Images
            if (_post.imageUrls!.isNotEmpty)
              SizedBox(
                height: 200,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _post.imageUrls!.length,
                  itemBuilder: (context, index) => GestureDetector(
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (_) => Dialog(
                          child: CachedNetworkImage(
                              imageUrl: _post.imageUrls![index],
                              fit: BoxFit.contain),
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: CachedNetworkImage(
                          imageUrl: _post.imageUrls![index],
                          width: 200,
                          fit: BoxFit.cover),
                    ),
                  ),
                ),
              ),
            // Topics
            Padding(
              padding: const EdgeInsets.all(16),
              child: Wrap(
                spacing: 8,
                children: _post.tags!
                    .map((topic) => GestureDetector(
                          onTap: () => _navigateToTopic(topic),
                          child: Chip(label: Text('#$topic')),
                        ))
                    .toList(),
              ),
            ),
            // Interaction
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  IconButton(
                      icon: const Icon(Icons.thumb_up), onPressed: () {}),
                  Text('${_post.likes}'),
                  const SizedBox(width: 16),
                  Text('${_post.comments} bình luận'),
                ],
              ),
            ),
            const Divider(),
            // Comments
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Bình luận',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ..._comments
                      .map((comment) => ListTile(
                            leading: const CircleAvatar(radius: 16),
                            title: Text(comment['user'],
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold)),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(comment['text']),
                                Text(
                                    timeago.format(comment['time'],
                                        locale: 'vi'),
                                    style:
                                        TextStyle(color: Colors.grey.shade600)),
                              ],
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.thumb_up_outlined),
                              onPressed: () =>
                                  _markHelpful(_comments.indexOf(comment)),
                            ),
                          ))
                      .toList(),
                  TextField(
                    controller: _commentController,
                    decoration: InputDecoration(
                      hintText: 'Viết bình luận...',
                      suffixIcon: IconButton(
                          icon: const Icon(Icons.send), onPressed: _addComment),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
