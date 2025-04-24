import 'package:flutter/material.dart';
import 'package:language_app/provider/notification_provider.dart';
import 'package:provider/provider.dart';
import 'package:language_app/PhuNV/Notification/notification_detail_screen.dart';
import 'package:language_app/widget/top_bar.dart';

class Notificationsscreen extends StatefulWidget {
  const Notificationsscreen({super.key});

  @override
  State<Notificationsscreen> createState() => _NotificationsscreenState();
}

class _NotificationsscreenState extends State<Notificationsscreen> {
  @override
  void initState() {
    super.initState();
    // Khởi tạo và lấy thông báo
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<NotificationProvider>(context, listen: false)
          .fetchNotifications();
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final pix = size.width / 375;

    return Scaffold(
      body: Consumer<NotificationProvider>(
        builder: (context, notificationProvider, child) {
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.blue.shade200, Colors.indigo.shade50],
                stops: const [0.0, 0.7],
              ),
            ),
            child: Stack(
              children: [
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: TopBar(
                    title: "Thông báo",
                  ),
                ),
                Positioned(
                    top: 100 * pix,
                    right: 10 * pix,
                    left: 10 * pix,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: Icon(Icons.refresh),
                          onPressed: () {
                            notificationProvider.fetchNotifications();
                          },
                        ),
                        if (notificationProvider.unreadCount > 0)
                          TextButton(
                            child: Text(
                              "Đánh dấu tất cả đã đọc",
                              style: TextStyle(color: Colors.white),
                            ),
                            onPressed: () {
                              notificationProvider.markAllAsRead();
                            },
                          ),
                      ],
                    )),
                Positioned(
                  top: 135 * pix,
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: notificationProvider.isLoading
                      ? Center(child: CircularProgressIndicator())
                      : notificationProvider.notifications.isEmpty
                          ? Center(child: Text("Không có thông báo"))
                          : _buildNotificationList(notificationProvider),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildNotificationList(NotificationProvider provider) {
    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: provider.notifications.length,
      itemBuilder: (context, index) {
        final notification = provider.notifications[index];
        return Card(
          elevation: 2,
          margin: EdgeInsets.only(bottom: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          // Thêm màu nền cho thông báo chưa đọc
          color: notification.isRead
              ? Colors.white
              : const Color.fromARGB(255, 224, 255, 247),
          child: ListTile(
            leading: Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color:
                    const Color.fromARGB(255, 181, 181, 181).withOpacity(0.5),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                notification.icon,
                color: notification.color,
                size: 30,
              ),
            ),
            title: Text(
              notification.title,
              style: TextStyle(
                fontSize: 18,
                fontWeight:
                    notification.isRead ? FontWeight.normal : FontWeight.bold,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 5),
                Text(
                  notification.content,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  notification.time,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
            onTap: () {
              // Đánh dấu thông báo đã đọc
              if (!notification.isRead && notification.id != null) {
                provider.markAsRead(notification.id!);
              }

              // Chuyển hướng sang trang chi tiết thông báo
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => NotificationDetailscreen(
                    notification: {
                      "icon": notification.icon,
                      "title": notification.title,
                      "content": notification.content,
                      "time": notification.time,
                      "color": notification.color,
                    },
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
