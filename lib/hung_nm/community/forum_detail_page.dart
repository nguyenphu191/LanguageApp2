import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:language_app/models/post_model.dart';
import 'package:language_app/phu_nv/widget/network_img.dart';
import 'package:language_app/provider/user_provider.dart';
import 'package:provider/provider.dart';
import 'package:language_app/provider/post_provider.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:animations/animations.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:shimmer/shimmer.dart';
import 'topic_page.dart';

class ForumDetailPage extends StatefulWidget {
  final PostModel post;

  const ForumDetailPage({Key? key, required this.post}) : super(key: key);

  @override
  State<ForumDetailPage> createState() => _ForumDetailPageState();
}

class _ForumDetailPageState extends State<ForumDetailPage>
    with SingleTickerProviderStateMixin {
  final TextEditingController _commentController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late AnimationController _animationController;
  bool _isSubmittingComment = false;
  bool _isLiking = false;
  int _currentImageIndex = 0;

  @override
  void initState() {
    super.initState();
    // Khởi tạo locale tiếng Việt cho timeago
    timeago.setLocaleMessages('vi', timeago.ViMessages());

    // Khởi tạo animation controller
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    // Load chi tiết bài viết
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final postProvider = Provider.of<PostProvider>(context, listen: false);
      postProvider.getPostDetail(int.parse(widget.post.id!));

      // Thiết lập status bar
      SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ));
    });
  }

  @override
  void dispose() {
    _commentController.dispose();
    _scrollController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  // Like bài viết
  Future<void> _likePost() async {
    if (_isLiking) return;

    setState(() {
      _isLiking = true;
    });

    try {
      final userId = Provider.of<UserProvider>(context, listen: false).user?.id;
      if (widget.post.likes!.any((like) => like.userId == userId)) {
        _showSnackBar('Bạn đã thích bài viết này');
        setState(() {
          _isLiking = false;
        });
        return;
      }

      // Phát hiệu ứng haptic feedback
      HapticFeedback.lightImpact();

      // Animation cho nút like
      _animationController.reset();
      _animationController.forward();

      final postProvider = Provider.of<PostProvider>(context, listen: false);
      final success = await postProvider.likePost(int.parse(widget.post.id!));

      if (success) {
        setState(() {
          _isLiking = false;
        });
        _showSnackBar('Đã thích bài viết');
      } else {
        _showSnackBar('Không thể thích bài viết', isError: true);
        setState(() {
          _isLiking = false;
        });
      }
    } catch (e) {
      _showSnackBar('Lỗi: ${e.toString()}', isError: true);
      setState(() {
        _isLiking = false;
      });
    }
  }

  // Thêm bình luận
  Future<void> _addComment() async {
    if (_commentController.text.isEmpty) return;

    setState(() {
      _isSubmittingComment = true;
    });

    try {
      // Phát hiệu ứng haptic feedback
      HapticFeedback.mediumImpact();

      final postProvider = Provider.of<PostProvider>(context, listen: false);
      final success = await postProvider.addComment(
        int.parse(widget.post.id!),
        _commentController.text,
      );

      if (success) {
        setState(() {
          _commentController.clear();
          _isSubmittingComment = false;
        });

        _showSnackBar('Đã thêm bình luận');

        // Cuộn xuống danh sách bình luận
        Future.delayed(const Duration(milliseconds: 300), () {
          if (_scrollController.hasClients) {
            _scrollController.animateTo(
              _scrollController.position.maxScrollExtent,
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeOut,
            );
          }
        });
      } else {
        _showSnackBar('Không thể thêm bình luận', isError: true);
        setState(() {
          _isSubmittingComment = false;
        });
      }
    } catch (e) {
      _showSnackBar('Lỗi: ${e.toString()}', isError: true);
      setState(() {
        _isSubmittingComment = false;
      });
    }
  }

  // Chuyển hướng đến trang chủ đề
  void _navigateToTopic(String topic) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => TopicPage(topic: topic)),
    );
  }

  // Hiển thị SnackBar được thiết kế lại
  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError ? Icons.error_outline : Icons.check_circle_outline,
              color: Colors.white,
            ),
            const SizedBox(width: 10),
            Expanded(child: Text(message)),
          ],
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        backgroundColor: isError ? Colors.redAccent : Colors.green,
        duration: const Duration(seconds: 2),
        margin: const EdgeInsets.all(16),
        elevation: 4,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final pix = size.width / 375;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    // Lắng nghe sự thay đổi từ PostProvider
    return Consumer<PostProvider>(
      builder: (context, postProvider, child) {
        if (postProvider.isLoading) {
          return Scaffold(
            body: _buildLoadingShimmer(isDarkMode),
          );
        }

        final post = postProvider.postDetail;
        if (post == null) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Chi tiết bài viết'),
              elevation: 0,
            ),
            body: const Center(
              child: Text('Không thể tải bài viết. Vui lòng thử lại sau.'),
            ),
          );
        }

        return Scaffold(
          body: NestedScrollView(
            controller: _scrollController,
            headerSliverBuilder: (context, innerBoxIsScrolled) {
              return [
                SliverAppBar(
                  expandedHeight: 200,
                  floating: false,
                  pinned: true,
                  stretch: true,
                  backgroundColor:
                      isDarkMode ? Color(0xFF1A1A2E) : Color(0xFF4B6CB7),
                  flexibleSpace: FlexibleSpaceBar(
                    title: Text(
                      post.title ?? 'Chi tiết bài viết',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        fontFamily: 'BeVietnamPro',
                        shadows: [
                          Shadow(
                            color: Colors.black.withOpacity(0.5),
                            offset: const Offset(0, 1),
                            blurRadius: 3,
                          ),
                        ],
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                    background: Stack(
                      fit: StackFit.expand,
                      children: [
                        // Ảnh nền hoặc gradient
                        if (post.imageUrls != null &&
                            post.imageUrls!.isNotEmpty)
                          Hero(
                            tag: 'post_${post.id}',
                            child: CachedNetworkImage(
                              imageUrl: post.imageUrls!.first,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: isDarkMode
                                        ? [Color(0xFF1A1A2E), Color(0xFF16213E)]
                                        : [
                                            Color(0xFF4B6CB7),
                                            Color(0xFF182848)
                                          ],
                                  ),
                                ),
                              ),
                              errorWidget: (context, url, error) => Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: isDarkMode
                                        ? [Color(0xFF1A1A2E), Color(0xFF16213E)]
                                        : [
                                            Color(0xFF4B6CB7),
                                            Color(0xFF182848)
                                          ],
                                  ),
                                ),
                                child: Icon(
                                  Icons.image_not_supported,
                                  color: Colors.white70,
                                  size: 50,
                                ),
                              ),
                            ),
                          )
                        else
                          Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: isDarkMode
                                    ? [Color(0xFF1A1A2E), Color(0xFF16213E)]
                                    : [Color(0xFF4B6CB7), Color(0xFF182848)],
                              ),
                            ),
                          ),
                        // Gradient overlay để làm nổi bật tiêu đề
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Colors.black.withOpacity(0.7),
                              ],
                              stops: const [0.5, 1.0],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  leading: IconButton(
                    icon: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.3),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.arrow_back,
                        color: Colors.white,
                      ),
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                  actions: [
                    IconButton(
                      icon: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.3),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.share,
                          color: Colors.white,
                        ),
                      ),
                      onPressed: () {
                        // Logic chia sẻ
                        _showSnackBar('Tính năng đang phát triển');
                      },
                    ),
                    PopupMenuButton<String>(
                      icon: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.3),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.more_vert,
                          color: Colors.white,
                        ),
                      ),
                      onSelected: (value) {
                        if (value == 'edit') {
                          // Logic chỉnh sửa bài viết
                          _showSnackBar('Tính năng đang phát triển');
                        } else if (value == 'report') {
                          // Logic báo cáo
                          _showSnackBar('Đã báo cáo bài viết');
                        } else if (value == 'bookmark') {
                          // Logic lưu bài viết
                          _showSnackBar('Đã lưu bài viết');
                        }
                      },
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          value: 'bookmark',
                          child: Row(
                            children: [
                              Icon(Icons.bookmark,
                                  color: isDarkMode
                                      ? Colors.white70
                                      : Colors.blueAccent),
                              const SizedBox(width: 8),
                              const Text('Lưu bài viết'),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: 'edit',
                          child: Row(
                            children: [
                              Icon(Icons.edit,
                                  color: isDarkMode
                                      ? Colors.white70
                                      : Colors.blueAccent),
                              const SizedBox(width: 8),
                              const Text('Chỉnh sửa'),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: 'report',
                          child: Row(
                            children: [
                              Icon(Icons.flag, color: Colors.orange),
                              const SizedBox(width: 8),
                              const Text('Báo cáo'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ];
            },
            body: RefreshIndicator(
              onRefresh: () async {
                await postProvider.getPostDetail(int.parse(post.id!));
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Container(
                  color: isDarkMode ? Colors.black : Colors.grey[50],
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Card chứa thông tin tác giả và nội dung
                      Card(
                        margin: EdgeInsets.zero,
                        elevation: 0,
                        color: isDarkMode ? Colors.grey[900] : Colors.white,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(16),
                            bottomRight: Radius.circular(16),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Thông tin tác giả
                            _buildAuthorInfo(post, pix, isDarkMode),

                            // Nội dung bài viết
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                              child: Text(
                                post.content ?? "",
                                style: TextStyle(
                                  fontSize: 16,
                                  height: 1.5,
                                  color: isDarkMode
                                      ? Colors.white
                                      : Colors.black87,
                                  fontFamily: 'BeVietnamPro',
                                ),
                              ),
                            ),

                            // Danh sách hình ảnh
                            _buildImageGallery(post, isDarkMode),

                            // Chủ đề
                            _buildTopicChips(post, isDarkMode),

                            // Tương tác (likes, comments)
                            _buildInteractionBar(post, isDarkMode),
                          ],
                        ),
                      ),

                      // Khoảng cách giữa card và phần bình luận
                      const SizedBox(height: 8),

                      // Phần bình luận
                      Card(
                        margin: EdgeInsets.zero,
                        elevation: 0,
                        color: isDarkMode ? Colors.grey[900] : Colors.white,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(16),
                            topRight: Radius.circular(16),
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Tiêu đề phần bình luận
                              Row(
                                children: [
                                  Icon(
                                    Icons.comment,
                                    size: 18,
                                    color: isDarkMode
                                        ? Colors.blueAccent.withOpacity(0.7)
                                        : Colors.blueAccent,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Bình luận',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: isDarkMode
                                          ? Colors.white
                                          : Colors.black87,
                                      fontFamily: 'BeVietnamPro',
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: isDarkMode
                                          ? Colors.blueAccent.withOpacity(0.2)
                                          : Colors.blue[50],
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      '${post.comments?.length ?? 0}',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.blueAccent,
                                        fontFamily: 'BeVietnamPro',
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),

                              // Danh sách bình luận
                              _buildCommentsList(post, pix, isDarkMode),

                              const SizedBox(height: 16),

                              // Input viết bình luận
                              _buildCommentInput(isDarkMode),

                              // Thêm padding dưới đáy
                              const SizedBox(height: 80),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // Widget hiển thị loading với hiệu ứng shimmer
  Widget _buildLoadingShimmer(bool isDarkMode) {
    return Shimmer.fromColors(
      baseColor: isDarkMode ? Colors.grey[800]! : Colors.grey[300]!,
      highlightColor: isDarkMode ? Colors.grey[700]! : Colors.grey[100]!,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // AppBar skeleton
            Container(
              height: 200,
              color: Colors.white,
            ),

            // Author info skeleton
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Avatar
                  Container(
                    width: 40,
                    height: 40,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Name and timestamp
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 120,
                        height: 16,
                        color: Colors.white,
                      ),
                      const SizedBox(height: 4),
                      Container(
                        width: 80,
                        height: 12,
                        color: Colors.white,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Content skeleton
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: List.generate(
                    5,
                    (index) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Container(
                            width: double.infinity,
                            height: 14,
                            color: Colors.white,
                          ),
                        )),
              ),
            ),

            // Image gallery skeleton
            Container(
              margin: const EdgeInsets.symmetric(vertical: 16),
              height: 150,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: 3,
                itemBuilder: (context, index) => Padding(
                  padding: const EdgeInsets.only(left: 16),
                  child: Container(
                    width: 150,
                    color: Colors.white,
                  ),
                ),
              ),
            ),

            // Comments section skeleton
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Container(
                    width: 100,
                    height: 20,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 16),

                  // Comments
                  ...List.generate(
                      3,
                      (index) => Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Avatar
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: const BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                // Comment content
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        width: 80,
                                        height: 16,
                                        color: Colors.white,
                                      ),
                                      const SizedBox(height: 4),
                                      Container(
                                        width: double.infinity,
                                        height: 14,
                                        color: Colors.white,
                                      ),
                                      const SizedBox(height: 4),
                                      Container(
                                        width: 70,
                                        height: 12,
                                        color: Colors.white,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          )),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget hiển thị thông tin tác giả
  Widget _buildAuthorInfo(PostModel post, double pix, bool isDarkMode) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // Avatar
          ClipOval(
            child: Container(
              width: 50 * pix,
              height: 50 * pix,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue[300]!, Colors.blue[600]!],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: (post.userAvatar != null && post.userAvatar != "")
                  ? NetworkImageWidget(
                      url: post.userAvatar!,
                      width: 50 * pix,
                      height: 50 * pix,
                    )
                  : NetworkImageWidget(
                      url:
                          "https://static.vecteezy.com/system/resources/thumbnails/009/734/564/small_2x/default-avatar-profile-icon-of-social-media-user-vector.jpg",
                      width: 50 * pix,
                      height: 50 * pix,
                    ),
            ),
          ),
          const SizedBox(width: 12),

          // Tên người dùng và thời gian
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  post.userName ?? 'Người dùng ẩn danh',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: isDarkMode ? Colors.white : Colors.black87,
                    fontFamily: 'BeVietnamPro',
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      size: 14,
                      color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      post.createdAt != null
                          ? timeago.format(post.createdAt ?? DateTime.now(),
                              locale: 'vi')
                          : 'Thời gian không xác định',
                      style: TextStyle(
                        fontSize: 14,
                        color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                        fontFamily: 'BeVietnamPro',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Button theo dõi
          TextButton.icon(
            onPressed: () {
              _showSnackBar('Đã theo dõi tác giả');
              HapticFeedback.lightImpact();
            },
            icon: Icon(
              Icons.person_add,
              size: 18,
              color: isDarkMode ? Colors.blue[300] : Colors.blue[600],
            ),
            label: Text(
              'Theo dõi',
              style: TextStyle(
                color: isDarkMode ? Colors.blue[300] : Colors.blue[600],
                fontFamily: 'BeVietnamPro',
                fontWeight: FontWeight.w500,
              ),
            ),
            style: TextButton.styleFrom(
              backgroundColor: isDarkMode
                  ? Colors.blue.withOpacity(0.1)
                  : Colors.blue.withOpacity(0.05),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            ),
          ),
        ],
      ),
    );
  }

  // Widget hiển thị gallery hình ảnh
  Widget _buildImageGallery(PostModel post, bool isDarkMode) {
    if (post.imageUrls == null || post.imageUrls!.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Gallery
        Container(
          height: 230,
          width: double.infinity,
          margin: const EdgeInsets.symmetric(vertical: 8),
          child: PageView.builder(
            itemCount: post.imageUrls!.length,
            controller: PageController(viewportFraction: 0.9),
            onPageChanged: (index) {
              setState(() {
                _currentImageIndex = index;
              });
            },
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () {
                  _openGallery(context, post.imageUrls!, index);
                },
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 5),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: CachedNetworkImage(
                      imageUrl: post.imageUrls![index],
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        color: isDarkMode ? Colors.grey[800] : Colors.grey[200],
                        child: const Center(
                          child: CircularProgressIndicator(),
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: isDarkMode ? Colors.grey[800] : Colors.grey[200],
                        child: const Icon(Icons.error),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),

        // Page indicator
        if (post.imageUrls!.length > 1)
          Container(
            padding: const EdgeInsets.only(bottom: 16),
            alignment: Alignment.center,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                post.imageUrls!.length,
                (index) => AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: _currentImageIndex == index ? 16 : 8,
                  height: 8,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    color: _currentImageIndex == index
                        ? Colors.blueAccent
                        : isDarkMode
                            ? Colors.grey[700]
                            : Colors.grey[300],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  // Mở gallery xem ảnh full màn hình
  void _openGallery(
      BuildContext context, List<String> images, int initialIndex) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.black,
            iconTheme: const IconThemeData(color: Colors.white),
            title: Text(
              '${initialIndex + 1}/${images.length}',
              style: const TextStyle(color: Colors.white),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.share),
                onPressed: () {
                  _showSnackBar('Tính năng đang phát triển');
                },
              ),
            ],
          ),
          body: PhotoViewGallery.builder(
            scrollPhysics: const BouncingScrollPhysics(),
            builder: (BuildContext context, int index) {
              return PhotoViewGalleryPageOptions(
                imageProvider: CachedNetworkImageProvider(images[index]),
                initialScale: PhotoViewComputedScale.contained,
                minScale: PhotoViewComputedScale.contained * 0.8,
                maxScale: PhotoViewComputedScale.covered * 2,
                heroAttributes: PhotoViewHeroAttributes(tag: 'image_$index'),
              );
            },
            itemCount: images.length,
            loadingBuilder: (context, event) => Center(
              child: SizedBox(
                width: 40.0,
                height: 40.0,
                child: CircularProgressIndicator(
                  value: event == null
                      ? 0
                      : event.cumulativeBytesLoaded /
                          (event.expectedTotalBytes ?? 1),
                ),
              ),
            ),
            backgroundDecoration: const BoxDecoration(
              color: Colors.black,
            ),
            pageController: PageController(initialPage: initialIndex),
            onPageChanged: (index) {
              // Có thể cập nhật trạng thái nếu cần
            },
          ),
        ),
      ),
    );
  }

  // Widget hiển thị các topics (chủ đề)
  Widget _buildTopicChips(PostModel post, bool isDarkMode) {
    if (post.tags == null || post.tags!.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: post.tags!
            .map((topic) => GestureDetector(
                  onTap: () => _navigateToTopic(topic),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: isDarkMode
                          ? Colors.blueAccent.withOpacity(0.15)
                          : Colors.blue[50],
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isDarkMode
                            ? Colors.blueAccent.withOpacity(0.5)
                            : Colors.blue[200]!,
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.tag,
                          size: 16,
                          color:
                              isDarkMode ? Colors.blue[300] : Colors.blue[600],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          topic,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: isDarkMode
                                ? Colors.blue[300]
                                : Colors.blue[700],
                            fontFamily: 'BeVietnamPro',
                          ),
                        ),
                      ],
                    ),
                  ),
                ))
            .toList(),
      ),
    );
  }

  // Widget hiển thị thanh tương tác (like, comment)
  Widget _buildInteractionBar(PostModel post, bool isDarkMode) {
    final userId = Provider.of<UserProvider>(context, listen: false).user?.id;
    final isLiked =
        post.likes != null && post.likes!.any((like) => like.userId == userId);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          // Like button
          GestureDetector(
            onTap: _likePost,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: isLiked
                    ? (isDarkMode
                        ? Colors.pink.withOpacity(0.2)
                        : Colors.pink[50])
                    : (isDarkMode
                        ? Colors.grey.withOpacity(0.2)
                        : Colors.grey[100]),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  ScaleTransition(
                    scale: Tween<double>(begin: 1.0, end: 1.5).animate(
                      CurvedAnimation(
                        parent: _animationController,
                        curve: Curves.elasticOut,
                      ),
                    ),
                    child: Icon(
                      isLiked ? Icons.favorite : Icons.favorite_border,
                      color: isLiked
                          ? Colors.pink
                          : (isDarkMode ? Colors.grey[400] : Colors.grey[600]),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '${post.likes?.length ?? 0}',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isLiked
                          ? Colors.pink
                          : (isDarkMode ? Colors.grey[400] : Colors.grey[600]),
                      fontFamily: 'BeVietnamPro',
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(width: 12),

          // Comment button
          GestureDetector(
            onTap: () {
              // Cuộn đến phần bình luận
              if (_scrollController.hasClients) {
                _scrollController.animateTo(
                  _scrollController.position.maxScrollExtent,
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeOut,
                );
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: isDarkMode
                    ? Colors.grey.withOpacity(0.2)
                    : Colors.grey[100],
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.chat_bubble_outline,
                    color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                    size: 20,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '${post.comments?.length ?? 0}',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                      fontFamily: 'BeVietnamPro',
                    ),
                  ),
                ],
              ),
            ),
          ),

          const Spacer(),

          // Bookmark button
          IconButton(
            icon: Icon(
              Icons.bookmark_border,
              color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
            ),
            onPressed: () {
              _showSnackBar('Đã lưu bài viết');
              HapticFeedback.lightImpact();
            },
          ),
        ],
      ),
    );
  }

  // Widget hiển thị danh sách bình luận
  Widget _buildCommentsList(PostModel post, double pix, bool isDarkMode) {
    if (post.comments == null || post.comments!.isEmpty) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
        alignment: Alignment.center,
        child: Column(
          children: [
            Icon(
              Icons.question_answer_outlined,
              size: 50,
              color: isDarkMode ? Colors.grey[700] : Colors.grey[400],
            ),
            const SizedBox(height: 12),
            Text(
              'Chưa có bình luận nào',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                fontFamily: 'BeVietnamPro',
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Hãy là người đầu tiên bình luận về bài viết này!',
              style: TextStyle(
                fontSize: 14,
                color: isDarkMode ? Colors.grey[500] : Colors.grey[500],
                fontFamily: 'BeVietnamPro',
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: post.comments!.length,
      separatorBuilder: (context, index) => Divider(
        color: isDarkMode ? Colors.grey[800] : Colors.grey[200],
        height: 24,
      ),
      itemBuilder: (context, index) {
        final comment = post.comments![index];

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Avatar
            ClipOval(
              child: Container(
                width: 40 * pix,
                height: 40 * pix,
                color: Colors.grey[300],
                child: (comment.userAvatar != null &&
                        comment.userAvatar!.isNotEmpty)
                    ? NetworkImageWidget(
                        url: comment.userAvatar!,
                        width: 40 * pix,
                        height: 40 * pix,
                      )
                    : NetworkImageWidget(
                        url:
                            "https://static.vecteezy.com/system/resources/thumbnails/009/734/564/small_2x/default-avatar-profile-icon-of-social-media-user-vector.jpg",
                        width: 40 * pix,
                        height: 40 * pix,
                      ),
              ),
            ),
            const SizedBox(width: 12),

            // Comment content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Author name and time
                  Row(
                    children: [
                      Text(
                        comment.userName ?? 'Người dùng ẩn danh',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: isDarkMode ? Colors.white : Colors.black87,
                          fontFamily: 'BeVietnamPro',
                        ),
                      ),
                      const Spacer(),
                      Text(
                        comment.createdAt != null
                            ? timeago.format(comment.createdAt!, locale: 'vi')
                            : 'Thời gian không xác định',
                        style: TextStyle(
                          fontSize: 12,
                          color:
                              isDarkMode ? Colors.grey[400] : Colors.grey[600],
                          fontFamily: 'BeVietnamPro',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),

                  // Comment text
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isDarkMode ? Colors.grey[850] : Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      comment.content ?? '',
                      style: TextStyle(
                        fontSize: 14,
                        height: 1.4,
                        color: isDarkMode ? Colors.white : Colors.black87,
                        fontFamily: 'BeVietnamPro',
                      ),
                    ),
                  ),

                  // Like & reply buttons
                  Padding(
                    padding: const EdgeInsets.only(top: 4, left: 4),
                    child: Row(
                      children: [
                        TextButton(
                          onPressed: () {
                            HapticFeedback.lightImpact();
                            _showSnackBar('Đã thích bình luận');
                          },
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: const Size(40, 30),
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: Text(
                            'Thích',
                            style: TextStyle(
                              fontSize: 12,
                              color: isDarkMode
                                  ? Colors.blue[300]
                                  : Colors.blue[700],
                              fontWeight: FontWeight.w500,
                              fontFamily: 'BeVietnamPro',
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        TextButton(
                          onPressed: () {
                            HapticFeedback.lightImpact();
                            // Set focus to comment input and prepopulate with @username
                            _commentController.text = '@${comment.userName} ';
                            _commentController.selection =
                                TextSelection.fromPosition(
                              TextPosition(
                                  offset: _commentController.text.length),
                            );
                            FocusScope.of(context).requestFocus(FocusNode());
                            Future.delayed(const Duration(milliseconds: 100),
                                () {
                              FocusScope.of(context).requestFocus();
                            });
                          },
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: const Size(40, 30),
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: Text(
                            'Phản hồi',
                            style: TextStyle(
                              fontSize: 12,
                              color: isDarkMode
                                  ? Colors.blue[300]
                                  : Colors.blue[700],
                              fontWeight: FontWeight.w500,
                              fontFamily: 'BeVietnamPro',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  // Widget hiển thị input nhập bình luận
  Widget _buildCommentInput(bool isDarkMode) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // Input field
        Expanded(
          child: TextField(
            controller: _commentController,
            maxLines: null,
            minLines: 1,
            textCapitalization: TextCapitalization.sentences,
            textInputAction: TextInputAction.newline,
            decoration: InputDecoration(
              hintText: 'Viết bình luận...',
              hintStyle: TextStyle(
                color: isDarkMode ? Colors.grey[400] : Colors.grey[500],
                fontFamily: 'BeVietnamPro',
              ),
              filled: true,
              fillColor: isDarkMode ? Colors.grey[850] : Colors.grey[100],
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(24),
                borderSide: BorderSide.none,
              ),
              suffixIcon: IconButton(
                icon: Icon(
                  Icons.image,
                  color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                ),
                onPressed: () {
                  _showSnackBar('Tính năng đang phát triển');
                },
              ),
            ),
            style: TextStyle(
              fontSize: 15,
              color: isDarkMode ? Colors.white : Colors.black87,
              fontFamily: 'BeVietnamPro',
            ),
          ),
        ),

        const SizedBox(width: 8),

        // Send button
        Container(
          decoration: BoxDecoration(
            color: Colors.blueAccent,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.blueAccent.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: _isSubmittingComment
              ? Container(
                  width: 48,
                  height: 48,
                  padding: const EdgeInsets.all(12),
                  child: const CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : IconButton(
                  icon: const Icon(
                    Icons.send_rounded,
                    color: Colors.white,
                  ),
                  onPressed: _addComment,
                ),
        ),
      ],
    );
  }
}
