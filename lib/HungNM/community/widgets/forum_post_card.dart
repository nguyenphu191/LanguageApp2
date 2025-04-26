import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:language_app/Models/post_model.dart';
import 'package:timeago/timeago.dart' as timeago;

class ForumPostCard extends StatelessWidget {
  final PostModel post;
  final VoidCallback onTap;
  final VoidCallback onAuthorTap;
  final Function(String) onTopicTap;

  const ForumPostCard({
    Key? key,
    required this.post,
    required this.onTap,
    required this.onAuthorTap,
    required this.onTopicTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Author info and time
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  InkWell(
                    onTap: onAuthorTap,
                    borderRadius: BorderRadius.circular(20),
                    child: post.userAvatar != null
                        ? CircleAvatar(
                            radius: 20,
                            backgroundImage:
                                CachedNetworkImageProvider(post.userAvatar!),
                          )
                        : CircleAvatar(
                            radius: 20,
                            backgroundColor: Colors.grey.shade300,
                            child: Text(
                              post.userName ?? 'Unknown',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.black54,
                              ),
                            ),
                          ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          post.userName ?? 'Unknown',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          timeago.format(post.createdAt ?? DateTime.now(),
                              locale: 'vi'),
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
                post.title ?? 'No Title',
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
                post.content ?? 'No content available',
                style: TextStyle(color: Colors.grey.shade800),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),

            // Post image (if any)
            if (post.imageUrls!.isNotEmpty)
              Container(
                height: 180,
                width: double.infinity,
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: post.imageUrls?.length == 1
                    ? CachedNetworkImage(
                        imageUrl: post.imageUrls!.first,
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
                        itemCount: post.imageUrls?.length,
                        itemBuilder: (context, index) {
                          return Container(
                            width: 160,
                            margin: const EdgeInsets.only(left: 8),
                            child: CachedNetworkImage(
                              imageUrl: post.imageUrls![index],
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
            if (post.tags!.isNotEmpty)
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: post.tags!.map((topic) {
                    return InkWell(
                      onTap: () => onTopicTap(topic),
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
                  // Like button
                  TextButton.icon(
                    onPressed: () {
                      // Add like logic
                    },
                    icon: Icon(
                      Icons.thumb_up_outlined,
                      size: 18,
                      color: Colors.grey.shade700,
                    ),
                    label: Text(
                      post.likes.toString(),
                      style: TextStyle(color: Colors.grey.shade700),
                    ),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                    ),
                  ),
                  // Comment button
                  TextButton.icon(
                    onPressed: onTap,
                    icon: Icon(
                      Icons.chat_bubble_outline,
                      size: 18,
                      color: Colors.grey.shade700,
                    ),
                    label: Text(
                      post.comments.toString(),
                      style: TextStyle(color: Colors.grey.shade700),
                    ),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                    ),
                  ),
                  const Spacer(),
                  // Share button
                  IconButton(
                    icon: Icon(
                      Icons.share_outlined,
                      size: 18,
                      color: Colors.grey.shade700,
                    ),
                    onPressed: () {
                      // Add share logic
                    },
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
