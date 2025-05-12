import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:language_app/models/post_model.dart';
import 'package:language_app/phu_nv/Notification/notification_screen.dart';
import 'package:language_app/provider/post_provider.dart';
import 'package:language_app/provider/user_provider.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:lottie/lottie.dart';
import 'forum_detail_page.dart';
import 'create_post_page.dart';
import 'search_page.dart';
import 'widgets/forum_post_card.dart';

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

  // Các icon cho categories
  final List<IconData> _filterIcons = [
    Icons.apps,
    Icons.format_quote,
    Icons.book,
    Icons.record_voice_over,
    Icons.mic,
    Icons.edit,
    Icons.more_horiz
  ];

  // Các màu sắc gradient cho từng category
  final List<List<Color>> _filterGradients = [
    [Colors.blue, Colors.lightBlue],
    [Colors.purple, Colors.purpleAccent],
    [Colors.green, Colors.lightGreen],
    [Colors.orange, Colors.amber],
    [Colors.red, Colors.redAccent],
    [Colors.indigo, Colors.indigoAccent],
    [Colors.grey, Colors.blueGrey],
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    _tabController.addListener(_filterPosts);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });

    // Thiết lập màu thanh trạng thái
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ));
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
        _showSnackBar('Bạn đã thích bài viết này');
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
        _showSnackBar('Đã thích bài viết');
      } else {
        _showSnackBar('Không thể thích bài viết');
        setState(() {
          _isLiking = false;
        });
      }
    } catch (e) {
      _showSnackBar('Lỗi: ${e.toString()}');
      setState(() {
        _isLiking = false;
      });
    }
  }

  // Hiển thị SnackBar được thiết kế lại
  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.info_outline, color: Colors.white),
            SizedBox(width: 10),
            Expanded(child: Text(message)),
          ],
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        backgroundColor: Colors.blueAccent,
        duration: Duration(seconds: 2),
        margin: EdgeInsets.all(16),
        elevation: 4,
      ),
    );
  }

  void _filterPosts() {
    final postProvider = Provider.of<PostProvider>(context, listen: false);
    postProvider.notifyListeners();
  }

  void _navigateToCreatePost() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CreatePostPage()),
    );

    if (result == true) {
      _loadData();
    }
  }

  void _navigateToPostDetail(PostModel post) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ForumDetailPage(post: post),
      ),
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
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              isDarkMode ? Color(0xFF1A1A2E) : Color(0xFF4B6CB7),
              isDarkMode ? Color(0xFF16213E) : Color(0xFF182848),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Custom App Bar
              _buildAppBar(pix, isDarkMode),

              // Main Content
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                      color: isDarkMode ? Colors.black : Colors.white,
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(25),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: Offset(0, -2),
                        )
                      ]),
                  child: ClipRRect(
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(25)),
                    child: Consumer<PostProvider>(
                      builder: (context, postProvider, child) {
                        if (_isLoading || postProvider.isLoading) {
                          return _buildSkeletonLoading(pix);
                        }

                        // Lọc bài viết dựa trên bộ lọc đã chọn
                        List<PostModel> filteredPosts = postProvider.posts;
                        if (_selectedFilter != 'Tất cả') {
                          filteredPosts = postProvider.posts
                              .where((post) =>
                                  post.tags?.contains(_selectedFilter) ?? false)
                              .toList();
                        }

                        // Sắp xếp bài viết dựa trên tab đang chọn
                        if (_tabController.index == 1) {
                          // Tab "Phổ biến" - sắp xếp theo số lượt thích
                          filteredPosts.sort((a, b) => (b.likes?.length ?? 0)
                              .compareTo(a.likes?.length ?? 0));
                        } else if (_tabController.index == 0) {
                          // Tab "Mới nhất" - sắp xếp theo thời gian tạo
                          filteredPosts.sort((a, b) =>
                              (b.createdAt ?? DateTime(1970))
                                  .compareTo(a.createdAt ?? DateTime(1970)));
                        }

                        return Column(
                          children: [
                            // TabBar
                            Container(
                              decoration: BoxDecoration(
                                  color: isDarkMode
                                      ? Colors.grey[900]
                                      : Colors.white,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.05),
                                      blurRadius: 5,
                                      offset: Offset(0, 2),
                                    )
                                  ]),
                              child: TabBar(
                                controller: _tabController,
                                labelColor: isDarkMode
                                    ? Colors.white
                                    : Theme.of(context).primaryColor,
                                unselectedLabelColor: isDarkMode
                                    ? Colors.grey[400]
                                    : Colors.grey[600],
                                indicatorColor: Theme.of(context).primaryColor,
                                indicatorWeight: 3,
                                labelStyle: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  fontFamily: 'BeVietnamPro',
                                ),
                                unselectedLabelStyle: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 15,
                                  fontFamily: 'BeVietnamPro',
                                ),
                                tabs: const [
                                  Tab(
                                    icon: Icon(Icons.access_time),
                                    text: 'Mới nhất',
                                  ),
                                  Tab(
                                    icon: Icon(Icons.local_fire_department),
                                    text: 'Phổ biến',
                                  ),
                                  Tab(
                                    icon: Icon(Icons.bookmark),
                                    text: 'Đang theo dõi',
                                  ),
                                ],
                              ),
                            ),

                            // Filter Chips
                            _buildFilterChips(pix, isDarkMode),

                            // Post List
                            Expanded(
                              child: TabBarView(
                                controller: _tabController,
                                children: [
                                  // Tab Mới nhất
                                  _buildPostList(
                                      filteredPosts, pix, isDarkMode),

                                  // Tab Phổ biến
                                  _buildPostList(
                                      filteredPosts, pix, isDarkMode),

                                  // Tab Đang theo dõi
                                  _buildPostList(
                                      filteredPosts, pix, isDarkMode),
                                ],
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  // App Bar hiện đại
  Widget _buildAppBar(double pix, bool isDarkMode) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          Text(
            'Cộng đồng học tập',
            style: TextStyle(
              fontSize: 20 * pix,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontFamily: 'BeVietnamPro',
            ),
          ),
          Spacer(),
          IconButton(
            icon: Icon(Icons.search, color: Colors.white, size: 26),
            onPressed: _navigateToSearch,
            style: IconButton.styleFrom(
              backgroundColor: Colors.white.withOpacity(0.2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          SizedBox(width: 8),
          IconButton(
            icon: Icon(Icons.notifications, color: Colors.white, size: 26),
            onPressed: _navigateToNotifications,
            style: IconButton.styleFrom(
              backgroundColor: Colors.white.withOpacity(0.2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Hiệu ứng skeleton loading
  Widget _buildSkeletonLoading(double pix) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Column(
        children: [
          // Tab skeleton
          Container(
            height: 50,
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(
                  3,
                  (index) => Container(
                        width: 100,
                        height: 40,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: Colors.white,
                        ),
                      )),
            ),
          ),

          // Filter skeleton
          Container(
            height: 60,
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: 5,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Container(
                    width: 80,
                    height: 40,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Colors.white,
                    ),
                  ),
                );
              },
            ),
          ),

          // Posts skeleton
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: 5,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Container(
                    height: 220,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      color: Colors.white,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // Floating Action Button được cải tiến
  Widget _buildFloatingActionButton() {
    return FloatingActionButton.extended(
      onPressed: _navigateToCreatePost,
      icon: Icon(Icons.add, size: 22),
      label: Text(
        'Tạo bài viết',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontFamily: 'BeVietnamPro',
        ),
      ),
      elevation: 4,
      backgroundColor: Color(0xFF4B6CB7),
    );
  }

  // Filters được thiết kế lại với gradient và icons
  Widget _buildFilterChips(double pix, bool isDarkMode) {
    return Container(
      height: 70,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey[900] : Colors.grey[50],
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 2,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _filters.length,
        itemBuilder: (context, index) {
          final filter = _filters[index];
          final isSelected = _selectedFilter == filter;

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedFilter = filter;
                });
                // Thêm hiệu ứng haptic feedback
                HapticFeedback.lightImpact();
              },
              child: AnimatedContainer(
                duration: Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  gradient: isSelected
                      ? LinearGradient(
                          colors: _filterGradients[index],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        )
                      : null,
                  color: isSelected
                      ? null
                      : isDarkMode
                          ? Colors.grey[800]
                          : Colors.grey[200],
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: _filterGradients[index][0].withOpacity(0.3),
                            blurRadius: 8,
                            offset: Offset(0, 3),
                          )
                        ]
                      : null,
                ),
                child: Row(
                  children: [
                    Icon(
                      _filterIcons[index],
                      size: 16,
                      color: isSelected
                          ? Colors.white
                          : isDarkMode
                              ? Colors.white70
                              : Colors.grey[800],
                    ),
                    SizedBox(width: 6),
                    Text(
                      filter,
                      style: TextStyle(
                        color: isSelected
                            ? Colors.white
                            : isDarkMode
                                ? Colors.white70
                                : Colors.grey[800],
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.normal,
                        fontSize: 13,
                        fontFamily: 'BeVietnamPro',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // Danh sách bài viết được cải tiến
  Widget _buildPostList(List<PostModel> posts, double pix, bool isDarkMode) {
    if (posts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Sử dụng animation Lottie cho trạng thái trống
            Lottie.network(
              'https://assets1.lottiefiles.com/packages/lf20_KU3FGB.json',
              width: 200,
              height: 200,
              repeat: true,
            ),
            SizedBox(height: 20),
            Text(
              'Chưa có bài viết nào',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                fontFamily: 'BeVietnamPro',
                color: isDarkMode ? Colors.white70 : Colors.grey[800],
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Hãy là người đầu tiên chia sẻ kiến thức',
              style: TextStyle(
                fontSize: 14,
                color: isDarkMode ? Colors.white60 : Colors.grey[600],
                fontFamily: 'BeVietnamPro',
              ),
            ),
            SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _navigateToCreatePost,
              icon: Icon(Icons.add),
              label: Text('Tạo bài viết đầu tiên'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF4B6CB7),
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      color: Colors.blue,
      backgroundColor: isDarkMode ? Colors.grey[800] : Colors.white,
      child: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: posts.length,
        itemBuilder: (context, index) {
          final post = posts[index];
          // Sử dụng Hero widget để tạo animation chuyển màn hình
          return Hero(
            tag: 'post_${post.id}',
            child: ForumPostCard(
              post: post,
              onTap: () => _navigateToPostDetail(post),
            ),
          );
        },
      ),
    );
  }
}
