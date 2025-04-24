import 'package:flutter/material.dart';
import 'package:language_app/PhuNV/Notification/notification_screen.dart';
import 'package:language_app/widget/top_bar.dart';
import 'forum_detail_page.dart';
import 'create_post_page.dart';
import '../profile/profile_sceen.dart';
import 'topic_page.dart';
import 'search_page.dart';
import './models/forum_post.dart';
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
  final List<String> _filters = [
    'Tất cả',
    'Ngữ pháp',
    'Từ vựng',
    'Phát âm',
    'Nói',
    'Viết',
    'Khác'
  ];

  final List<ForumPost> _mockPosts = [
    ForumPost(
      id: '1',
      title: 'Cách học từ vựng hiệu quả',
      content:
          'Tôi muốn chia sẻ phương pháp học từ vựng hiệu quả mà tôi đã áp dụng và cải thiện vốn từ của mình...',
      authorName: 'Mai Anh',
      authorAvatar: 'https://randomuser.me/api/portraits/women/44.jpg',
      postedTime: DateTime.now().subtract(const Duration(hours: 2)),
      imageUrls: ['https://picsum.photos/id/1/800/400'],
      likes: 24,
      comments: 8,
      topics: ['Từ vựng', 'Học tập'],
    ),
    ForumPost(
      id: '2',
      title: 'Kinh nghiệm luyện thi IELTS',
      content:
          'Sau một thời gian dài ôn luyện, tôi đã đạt được band điểm 7.5 IELTS. Hôm nay tôi muốn chia sẻ hành trình và kinh nghiệm của mình...',
      authorName: 'Quang Minh',
      authorAvatar: 'https://randomuser.me/api/portraits/men/32.jpg',
      postedTime: DateTime.now().subtract(const Duration(days: 1)),
      imageUrls: ['https://picsum.photos/id/20/800/400'],
      likes: 56,
      comments: 20,
      topics: ['IELTS', 'Kinh nghiệm'],
    ),
    ForumPost(
      id: '3',
      title: 'Có nên học ngữ pháp trước khi tập nói?',
      content:
          'Tôi là người mới bắt đầu học tiếng Anh và đang phân vân giữa việc nên tập trung vào ngữ pháp trước hay nên luyện nói trước...',
      authorName: 'Thu Hà',
      authorAvatar: 'https://randomuser.me/api/portraits/women/22.jpg',
      postedTime: DateTime.now().subtract(const Duration(days: 2)),
      likes: 12,
      comments: 32,
      topics: ['Ngữ pháp', 'Nói'],
    ),
    ForumPost(
      id: '4',
      title: 'Chia sẻ tài liệu học tiếng Anh miễn phí',
      content:
          'Chào mọi người, tôi muốn chia sẻ một số tài liệu học tiếng Anh miễn phí mà tôi thấy rất hữu ích...',
      authorName: 'Đức Thắng',
      authorAvatar: 'https://randomuser.me/api/portraits/men/62.jpg',
      postedTime: DateTime.now().subtract(const Duration(days: 3)),
      imageUrls: [
        'https://picsum.photos/id/15/800/400',
        'https://picsum.photos/id/25/800/400'
      ],
      likes: 78,
      comments: 14,
      topics: ['Tài liệu', 'Miễn phí'],
    ),
  ];

  List<ForumPost> _filteredPosts = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _filteredPosts = List.from(_mockPosts);
    _tabController.addListener(_filterPosts);
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
            .where((post) => post.topics.contains(_selectedFilter))
            .toList();
      }

      if (_tabController.index == 1) {
        _filteredPosts.sort((a, b) => b.likes.compareTo(a.likes));
      } else if (_tabController.index == 2) {
        // Logic cho tab "Đang theo dõi"
      }
    });
  }

  void _navigateToCreatePost() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CreatePostPage()),
    );
  }

  void _navigateToPostDetail(ForumPost post) {
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
                      'author-${post.id}', post.authorName),
                  onTopicTap: (topic) => _navigateToTopicPage(topic),
                );
              },
            ),
    );
  }
}
