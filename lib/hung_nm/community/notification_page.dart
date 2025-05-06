import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;

class NotificationPage extends StatelessWidget {
  const NotificationPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Mock data
    final notifications = [
      {
        'text': 'Mai Anh đã thích bài viết của bạn',
        'time': DateTime.now().subtract(const Duration(minutes: 10)),
        'read': false
      },
      {
        'text': 'Quang Minh đã bình luận bài viết của bạn',
        'time': DateTime.now().subtract(const Duration(hours: 1)),
        'read': true
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Thông báo'),
      ),
      body: ListView.builder(
        itemCount: notifications.length,
        itemBuilder: (context, index) => ListTile(
          title: Text(notifications[index]['text'] as String),
          subtitle: Text(timeago
              .format(notifications[index]['time'] as DateTime, locale: 'vi')),
          tileColor: (notifications[index]['read'] as bool)
              ? null
              : Colors.grey.shade100,
          onTap: () {
            // Logic điều hướng đến bài viết hoặc hồ sơ
          },
        ),
      ),
    );
  }
}
