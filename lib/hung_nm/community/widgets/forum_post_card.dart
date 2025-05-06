import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:language_app/models/post_model.dart';
import 'package:language_app/phu_nv/widget/network_img.dart';
import 'package:language_app/provider/post_provider.dart';
import 'package:language_app/provider/user_provider.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;

class ForumPostCard extends StatefulWidget {
  const ForumPostCard({
    super.key,
    required this.post,
    required this.onTap,
  });
  final PostModel post;
  final VoidCallback onTap;
  @override
  State<ForumPostCard> createState() => _ForumPostCardState();
}

class _ForumPostCardState extends State<ForumPostCard> {
  bool _isLiking = false;
  @override
  void initState() {
    super.initState();
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

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final pix = size.width / 375;
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: widget.onTap,
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Author info and time
            Padding(
              padding: EdgeInsets.all(12 * pix),
              child: Row(
                children: [
                  InkWell(
                    borderRadius: BorderRadius.circular(20),
                    child: ClipOval(
                        child: (widget.post.userAvatar != null &&
                                widget.post.userAvatar!.isNotEmpty)
                            ? NetworkImageWidget(
                                url: widget.post.userAvatar!,
                                width: 40 * pix,
                                height: 40 * pix)
                            : NetworkImageWidget(
                                url:
                                    "https://static.vecteezy.com/system/resources/thumbnails/009/734/564/small_2x/default-avatar-profile-icon-of-social-media-user-vector.jpg",
                                width: 40 * pix,
                                height: 40 * pix)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.post.userName ?? 'Unknown',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          timeago.format(widget.post.createdAt!, locale: 'vi'),
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.more_vert),
                    onPressed: () {
                      // Show post options
                      showModalBottomSheet(
                        context: context,
                        builder: (context) => Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ListTile(
                              leading: const Icon(Icons.bookmark_border),
                              title: const Text('Lưu bài viết'),
                              onTap: () {
                                Navigator.pop(context);
                                // Add save logic
                              },
                            ),
                            ListTile(
                              leading: const Icon(Icons.share),
                              title: const Text('Chia sẻ'),
                              onTap: () {
                                Navigator.pop(context);
                                // Add share logic
                              },
                            ),
                            ListTile(
                              leading: const Icon(Icons.flag),
                              title: const Text('Báo cáo'),
                              onTap: () {
                                Navigator.pop(context);
                                // Add report logic
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

            // Title
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                widget.post.title ?? 'No Title',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),

            // Content preview
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Text(
                widget.post.content ?? 'No content available',
                style: TextStyle(color: Colors.grey.shade800),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),

            // Post image (if any)
            if (widget.post.imageUrls!.isNotEmpty)
              Container(
                height: 180,
                width: double.infinity,
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: widget.post.imageUrls?.length == 1
                    ? CachedNetworkImage(
                        imageUrl: widget.post.imageUrls!.first,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Center(
                          child: CircularProgressIndicator(
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                        errorWidget: (context, url, error) =>
                            const Icon(Icons.error),
                      )
                    : ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: widget.post.imageUrls?.length,
                        itemBuilder: (context, index) {
                          return Container(
                            width: 160,
                            margin: const EdgeInsets.only(left: 8),
                            child: CachedNetworkImage(
                              imageUrl: widget.post.imageUrls![index],
                              fit: BoxFit.cover,
                              placeholder: (context, url) => Center(
                                child: CircularProgressIndicator(
                                  color: Theme.of(context).primaryColor,
                                ),
                              ),
                              errorWidget: (context, url, error) =>
                                  const Icon(Icons.error),
                            ),
                          );
                        },
                      ),
              ),

            // Topics/tags
            if (widget.post.tags!.isNotEmpty)
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: widget.post.tags!.map((topic) {
                    return InkWell(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          '#$topic',
                          style: TextStyle(
                            color: Colors.blue.shade700,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),

            // Interaction buttons
            Padding(
              padding: const EdgeInsets.all(8),
              child: Row(
                children: [
                  _isLiking
                      ? const Center(
                          child: CircularProgressIndicator(
                            color: Colors.blue,
                            strokeWidth: 2,
                          ),
                        )
                      : TextButton.icon(
                          onPressed: () {
                            _likePost();
                          },
                          icon: Icon(
                            Icons.thumb_up_outlined,
                            size: 18,
                            color: Colors.grey.shade700,
                          ),
                          label: Text(
                            widget.post.likes!.length.toString(),
                            style: TextStyle(color: Colors.grey.shade700),
                          ),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                          ),
                        ),
                  // Comment button
                  TextButton.icon(
                    onPressed: widget.onTap,
                    icon: Icon(
                      Icons.chat_bubble_outline,
                      size: 18,
                      color: Colors.grey.shade700,
                    ),
                    label: Text(
                      widget.post.comments!.length.toString(),
                      style: TextStyle(color: Colors.grey.shade700),
                    ),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
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
