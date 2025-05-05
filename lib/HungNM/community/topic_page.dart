import 'package:flutter/material.dart';
import 'package:language_app/models/post_model.dart';
import './forum_detail_page.dart';

class TopicPage extends StatelessWidget {
  final String topic;

  const TopicPage({Key? key, required this.topic}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Mock data
    final posts = [
      PostModel(id: '1', title: 'Post 1', content: 'Content 1',),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text('Chủ đề: #$topic'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Bài viết về $topic', style: const TextStyle(fontSize: 18)),
                ElevatedButton(
                  onPressed: () {
                    // Logic theo dõi chủ đề
                  },
                  child: const Text('Theo dõi'),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: posts.length,
              itemBuilder: (context, index) => ListTile(
                title: Text(posts[index].title ?? 'No Title'),
                subtitle: Text(posts[index].content ?? 'No Content', maxLines: 1, overflow: TextOverflow.ellipsis),
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ForumDetailPage(post: posts[index]))),
              ),
            ),
          ),
        ],
      ),
    );
  }
}