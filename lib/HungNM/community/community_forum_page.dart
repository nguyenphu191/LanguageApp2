import 'package:flutter/material.dart';
import 'package:language_app/Models/post_model.dart';
import 'package:language_app/PhuNV/Notification/notification_screen.dart';
import 'package:language_app/provider/post_provider.dart';
import 'package:language_app/widget/top_bar.dart';
import 'package:provider/provider.dart';
import 'forum_detail_page.dart';
import 'create_post_page.dart';
import '../profile/profile_sceen.dart';
import 'topic_page.dart';
import 'search_page.dart';
import './widgets/forum_post_card.dart';

class CommunityForumPage extends StatefulWidget {
  const CommunityForumPage({Key? key}) : super(key: key);

  @override
  State<CommunityForumPage> createState() => _CommunityForumPageState();
}

class _CommunityForumPageState extends State<CommunityForumPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  String _selectedFilter = 'Tất cả';
  bool _isLoading = false;
  final List<String> _filters = [
    'Tất cả',
    'Ngữ pháp',
    'Từ vựng',
    'Phát âm',
    'Nói',
    'Viết',
    'Khác'
  ];
  List<PostModel> _mockPosts = [];
  List<PostModel> _filteredPosts = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    _tabController.addListener(_filterPosts);
    WidgetsBinding.instance.addPostFrameCallback((_) {});
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    final postProvider = Provider.of<PostProvider>(context, listen: false);

    try {
      await postProvider.fetchPosts();
    } catch (e) {
      // Xử lý lỗi nếu cần
      print('Error loading topics: $e');
    } finally {
      setState(() {
        _isLoading = false;
        _mockPosts = postProvider.posts;
        _filteredPosts = List.from(_mockPosts);
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _filterPosts() {
    setState(() {
      if (_selectedFilter == 'Tất cả') {
        _filteredPosts = List.from(_mockPosts);
      } else {
        _filteredPosts = _mockPosts
            .where((post) => post.tags?.contains(_selectedFilter) ?? false)
            .toList();
      }

      // if (_tabController.index == 1) {
      //   _filteredPosts.sort((a, b) => b.likes.compareTo(a.likes));
      // } else if (_tabController.index == 2) {
      //   // Logic cho tab "Đang theo dõi"
      // }
    });
  }

  void _navigateToCreatePost() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CreatePostPage()),
    );
  }

  void _navigateToPostDetail(PostModel post) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ForumDetailPage(post: post)),
    );
  }

  void _navigateToUserProfile(String userId, String userName) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ProfileScreen()),
    );
  }

  void _navigateToTopicPage(String topic) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => TopicPage(topic: topic)),
    );
  }

  void _navigateToNotifications() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const Notificationsscreen()),
    );
  }

  void _navigateToSearch() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SearchPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final pix = size.width / 375;
    return Scaffold(
      body: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: TopBar(title: 'Diễn đàn'),
          ),
          Positioned(
              top: 40 * pix,
              right: 16 * pix,
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.search,
                        color: Color.fromARGB(255, 255, 255, 255), size: 28),
                    onPressed: _navigateToSearch,
                  ),
                  IconButton(
                    icon: const Icon(Icons.notifications,
                        color: Color.fromARGB(255, 255, 255, 255), size: 28),
                    onPressed: _navigateToNotifications,
                  ),
                ],
              )),
          Positioned(
            top: 100 * pix,
            left: 0,
            right: 0,
            bottom: 0,
            child: NestedScrollView(
              headerSliverBuilder: (context, innerBoxIsScrolled) {
                return [
                  SliverToBoxAdapter(
                    child: Column(
                      children: [
                        // TabBar
                        Container(
                          color: Colors.white,
                          child: TabBar(
                            controller: _tabController,
                            labelColor: Theme.of(context).primaryColor,
                            unselectedLabelColor: Colors.grey,
                            indicatorColor: Theme.of(context).primaryColor,
                            tabs: const [
                              Tab(text: 'Mới nhất'),
                              Tab(text: 'Phổ biến'),
                              Tab(text: 'Đang theo dõi'),
                            ],
                          ),
                        ),

                        // Filter Chips
                        Container(
                          height: 60,
                          color: Colors.grey[50],
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 8),
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: _filters.length,
                            itemBuilder: (context, index) {
                              final filter = _filters[index];
                              return Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 4),
                                child: ChoiceChip(
                                  label: Text(filter),
                                  selected: _selectedFilter == filter,
                                  onSelected: (selected) {
                                    if (selected) {
                                      setState(() {
                                        _selectedFilter = filter;
                                        _filterPosts();
                                      });
                                    }
                                  },
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ];
              },
              body: TabBarView(
                controller: _tabController,
                children: [
                  // Tab Mới nhất
                  _buildPostList(),

                  // Tab Phổ biến
                  _buildPostList(),

                  // Tab Đang theo dõi
                  _buildPostList(),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToCreatePost,
        child: const Icon(Icons.add),
        backgroundColor: Theme.of(context).primaryColor,
      ),
    );
  }

  Widget _buildPostList() {
    return RefreshIndicator(
      onRefresh: () async {
        await Future.delayed(const Duration(seconds: 1));
        _filterPosts();
      },
      child: _filteredPosts.isEmpty
          ? const Center(child: Text('Không có bài viết nào phù hợp'))
          : ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: _filteredPosts.length,
              itemBuilder: (context, index) {
                final post = _filteredPosts[index];
                return ForumPostCard(
                  post: post,
                  onTap: () => _navigateToPostDetail(post),
                  onAuthorTap: () => _navigateToUserProfile(
                      'author-${post.id}', post.userName ?? ''),
                  onTopicTap: (topic) => _navigateToTopicPage(topic),
                );
              },
            ),
    );
  }
}
