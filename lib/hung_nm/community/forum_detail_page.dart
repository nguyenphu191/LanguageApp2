import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:language_app/models/post_model.dart';
import 'package:language_app/phu_nv/widget/network_img.dart';
import 'package:language_app/provider/user_provider.dart';
import 'package:provider/provider.dart';
import 'package:language_app/provider/post_provider.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'topic_page.dart';

class ForumDetailPage extends StatefulWidget {
  final PostModel post;

  const ForumDetailPage({Key? key, required this.post}) : super(key: key);

  @override
  State<ForumDetailPage> createState() => _ForumDetailPageState();
}

class _ForumDetailPageState extends State<ForumDetailPage> {
  final TextEditingController _commentController = TextEditingController();
  bool _isSubmittingComment = false;
  bool _isLiking = false;

  @override
  void initState() {
    super.initState();
    timeago.setLocaleMessages('vi', timeago.ViMessages());
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final postProvider = Provider.of<PostProvider>(context, listen: false);
      postProvider.getPostDetail(int.parse(widget.post.id!));
    });
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _likePost() async {
    // Tránh double click
    if (_isLiking) return;

    setState(() {
      _isLiking = true;
    });

    try {
      final userId = Provider.of<UserProvider>(context, listen: false).user?.id;
      if (widget.post.likes!.any((like) => like.userId == userId)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Bạn đã thích bài viết này')),
        );
        setState(() {
          _isLiking = false;
        });
        return;
      }
      final postProvider = Provider.of<PostProvider>(context, listen: false);
      final success = await postProvider.likePost(int.parse(widget.post.id!));

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

  Future<void> _addComment() async {
    if (_commentController.text.isEmpty) return;

    setState(() {
      _isSubmittingComment = true;
    });

    try {
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

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đã thêm bình luận')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Không thể thêm bình luận')),
        );
        setState(() {
          _isSubmittingComment = false;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi: ${e.toString()}')),
      );
      setState(() {
        _isSubmittingComment = false;
      });
    }
  }

  void _navigateToTopic(String topic) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => TopicPage(topic: topic)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final pix = size.width / 375;

    // Lắng nghe sự thay đổi từ PostProvider
    return Consumer<PostProvider>(
      builder: (context, postProvider, child) {
        if (postProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        final nowpost = postProvider.postDetail;
        return Scaffold(
          appBar: AppBar(
            title: Text(nowpost?.title ?? 'Chi tiết bài viết'),
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
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Author info
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      ClipOval(
                          child: (nowpost?.userAvatar != null &&
                                  nowpost!.userAvatar != "")
                              ? NetworkImageWidget(
                                  url: nowpost.userAvatar!,
                                  width: 40 * pix,
                                  height: 40 * pix)
                              : NetworkImageWidget(
                                  url:
                                      "https://static.vecteezy.com/system/resources/thumbnails/009/734/564/small_2x/default-avatar-profile-icon-of-social-media-user-vector.jpg",
                                  width: 40 * pix,
                                  height: 40 * pix)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(nowpost?.userName ?? 'Unknown User',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold)),
                            Text(
                                nowpost?.createdAt != null
                                    ? timeago.format(
                                        nowpost!.createdAt ?? DateTime.now(),
                                        locale: 'vi')
                                    : 'Unknown time',
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
                  child: Text(nowpost?.content ?? "",
                      style: const TextStyle(fontSize: 16)),
                ),
                // Images
                if (nowpost?.imageUrls != null && nowpost?.imageUrls != "")
                  SizedBox(
                    height: 200,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: nowpost?.imageUrls!.length,
                      itemBuilder: (context, index) => GestureDetector(
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (_) => Dialog(
                              child: CachedNetworkImage(
                                  imageUrl: nowpost?.imageUrls![index] ?? '',
                                  fit: BoxFit.contain),
                            ),
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(8),
                          child: CachedNetworkImage(
                              imageUrl: nowpost?.imageUrls![index] ?? '',
                              width: 200,
                              fit: BoxFit.cover),
                        ),
                      ),
                    ),
                  ),
                // Topics
                if (nowpost?.tags != null && nowpost!.tags!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Wrap(
                      spacing: 8,
                      children: nowpost.tags!
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
                          icon: const Icon(Icons.thumb_up),
                          onPressed: _likePost),
                      Text('${nowpost?.likes?.length} thích'),
                      const SizedBox(width: 16),
                      Text('${nowpost?.comments?.length ?? 0} bình luận'),
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
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),

                      // Kiểm tra nếu có comments thì hiển thị, không thì hiển thị thông báo
                      if (nowpost?.comments != null &&
                          nowpost!.comments!.isNotEmpty)
                        ...(nowpost.comments!
                            .map((comment) => Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      ClipOval(
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
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              comment.userName ??
                                                  'Unknown User',
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              comment.content ?? '',
                                              style:
                                                  const TextStyle(fontSize: 14),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              comment.createdAt != null
                                                  ? timeago.format(
                                                      comment.createdAt!,
                                                      locale: 'vi')
                                                  : 'Unknown time',
                                              style: TextStyle(
                                                  color: Colors.grey.shade600,
                                                  fontSize: 12),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ))
                            .toList())
                      else
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          child: Text(
                              'Chưa có bình luận nào. Hãy là người đầu tiên bình luận!'),
                        ),

                      const SizedBox(height: 16),
                      // Comment input field
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _commentController,
                              decoration: const InputDecoration(
                                hintText: 'Viết bình luận...',
                                border: OutlineInputBorder(),
                              ),
                              maxLines: null,
                            ),
                          ),
                          const SizedBox(width: 8),
                          _isSubmittingComment
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child:
                                      CircularProgressIndicator(strokeWidth: 2))
                              : IconButton(
                                  icon: const Icon(Icons.send),
                                  onPressed: _addComment,
                                ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
