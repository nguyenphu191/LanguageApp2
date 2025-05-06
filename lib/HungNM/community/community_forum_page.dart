import 'package:flutter/material.dart';
import 'package:language_app/Models/post_model.dart';
import 'package:language_app/PhuNV/Notification/notification_screen.dart';
import 'package:language_app/provider/post_provider.dart';
import 'package:language_app/provider/user_provider.dart';
import 'package:language_app/widget/top_bar.dart';
import 'package:provider/provider.dart';
import 'forum_detail_page.dart';
import 'create_post_page.dart';
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
  bool _isLiking = false;
  final List<String> _filters = [
    'Tất cả',
    'Ngữ pháp',
    'Từ vựng',
    'Phát âm',
    'Nói',
    'Viết',
    'Khác'
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    _tabController.addListener(_filterPosts);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    final postProvider = Provider.of<PostProvider>(context, listen: false);

    try {
      await postProvider.fetchPosts();
    } catch (e) {
      debugPrint('Error loading posts: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }
  Future<void> _likePost(PostModel post) async {
    // Tránh double click
    if (_isLiking) return;

    setState(() {
      _isLiking = true;
    });

    try {
      final userId = Provider.of<UserProvider>(context, listen: false).user?.id;
      if (post.likes!.any((like) => like.userId == userId)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Bạn đã thích bài viết này')),
        );
        setState(() {
          _isLiking = false;
        });
        return;
      }
      final postProvider = Provider.of<PostProvider>(context, listen: false);
      final success = await postProvider.likePost(int.parse(post.id!));

      if (success) {
        setState(() {
          _isLiking = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đã thích bài viết')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Không thể thích bài viết')),
        );
        setState(() {
          _isLiking = false;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi: ${e.toString()}')),
      );
      setState(() {
        _isLiking = false;
      });
    }
  }

  void _filterPosts() {
    final postProvider = Provider.of<PostProvider>(context, listen: false);
    // Gọi notifyListeners để cập nhật UI khi tab thay đổi
    postProvider.notifyListeners();
  }

  void _navigateToCreatePost() async {
    // Sử dụng await để đợi khi người dùng quay lại từ màn hình tạo bài viết
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CreatePostPage()),
    );

    // Nếu có kết quả trả về và là true, thì cập nhật lại danh sách bài viết
    if (result == true) {
      _loadData();
    }
  }

  void _navigateToPostDetail(PostModel post) async {
    // Sử dụng await để đợi khi người dùng quay lại từ màn hình chi tiết bài viết
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ForumDetailPage(post: post)),
    );

    // Khi quay lại từ màn hình chi tiết, giao diện sẽ tự động cập nhật
    // vì đã sử dụng Consumer với PostProvider
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
            child:
                Consumer<PostProvider>(builder: (context, postProvider, child) {
              if (_isLoading || postProvider.isLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              // Lọc bài viết dựa trên bộ lọc đã chọn
              List<PostModel> filteredPosts = postProvider.posts;
              if (_selectedFilter != 'Tất cả') {
                filteredPosts = postProvider.posts
                    .where(
                        (post) => post.tags?.contains(_selectedFilter) ?? false)
                    .toList();
              }

              // Sắp xếp bài viết dựa trên tab đang chọn
              if (_tabController.index == 1) {
                // Tab "Phổ biến" - sắp xếp theo số lượt thích
                filteredPosts.sort((a, b) =>
                    (b.likes?.length ?? 0).compareTo(a.likes?.length ?? 0));
              } else if (_tabController.index == 0) {
                // Tab "Mới nhất" - sắp xếp theo thời gian tạo
                filteredPosts.sort((a, b) => (b.createdAt ?? DateTime(1970))
                    .compareTo(a.createdAt ?? DateTime(1970)));
              }
              // Tab "Đang theo dõi" có thể được thêm logic ở đây

              return NestedScrollView(
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
                    _buildPostList(filteredPosts),

                    // Tab Phổ biến
                    _buildPostList(filteredPosts),

                    // Tab Đang theo dõi
                    _buildPostList(filteredPosts),
                  ],
                ),
              );
            }),
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

  Widget _buildPostList(List<PostModel> posts) {
    return RefreshIndicator(
      onRefresh: _loadData,
      child: posts.isEmpty
          ? const Center(child: Text('Không có bài viết nào phù hợp'))
          : ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: posts.length,
              itemBuilder: (context, index) {
                final post = posts[index];
                return ForumPostCard(
                  post: post,
                  onTap: () => _navigateToPostDetail(post),
                );
              },
            ),
    );
  }
}
