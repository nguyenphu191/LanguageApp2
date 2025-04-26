import 'package:flutter/material.dart';
import 'package:language_app/Models/post_model.dart';
import './forum_detail_page.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({Key? key}) : super(key: key);

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  List<PostModel> _searchResults = [];

  void _search(String query) {
    // Mock search logic
    final allPosts = [
      PostModel(id: '1', title: 'Post 1', content: 'Content 1',),
    ];
    setState(() {
      _searchResults = allPosts.where((post) =>
          post.title!.toLowerCase().contains(query.toLowerCase()) ||
          post.content!.toLowerCase().contains(query.toLowerCase())).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          decoration: const InputDecoration(hintText: 'Tìm kiếm...'),
          onChanged: _search,
        ),
      ),
      body: ListView.builder(
        itemCount: _searchResults.length,
        itemBuilder: (context, index) => ListTile(
          title: Text(_searchResults[index].title ?? 'No Title'),
          subtitle: Text(_searchResults[index].content ?? 'No Content', maxLines: 1, overflow: TextOverflow.ellipsis),
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ForumDetailPage(post: _searchResults[index]))),
        ),
      ),
    );
  }
}