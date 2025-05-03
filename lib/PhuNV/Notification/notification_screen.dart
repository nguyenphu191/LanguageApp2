import 'package:flutter/material.dart';
import 'package:language_app/Models/notification_model.dart';
import 'package:provider/provider.dart';
import 'package:language_app/provider/notification_provider.dart';
import 'package:language_app/PhuNV/Notification/notification_detail_screen.dart';
import 'package:language_app/widget/top_bar.dart';

class Notificationsscreen extends StatefulWidget {
  const Notificationsscreen({super.key});

  @override
  State<Notificationsscreen> createState() => _NotificationsscreenState();
}

class _NotificationsscreenState extends State<Notificationsscreen>
    with WidgetsBindingObserver {
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshNotifications();
    });
  }

  Future<void> _refreshNotifications() async {
    final notificationProvider =
        Provider.of<NotificationProvider>(context, listen: false);
    bool res = await notificationProvider.getListNotification();
    if (!res) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to load notifications'),
          duration: Duration(seconds: 2),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
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
                        icon: Icon(Icons.refresh, color: Colors.white),
                        onPressed: () async {
                          await _refreshNotifications();
                        },
                        tooltip: "Làm mới thông báo",
                      ),
                      if (notificationProvider.unreadCount > 0)
                        TextButton.icon(
                          icon: Icon(Icons.check_circle_outline,
                              color: Colors.white),
                          label: Text(
                            "Đánh dấu tất cả đã đọc",
                            style: TextStyle(color: Colors.white),
                          ),
                          onPressed: () {},
                        ),
                    ],
                  ),
                ),
                Positioned(
                  top: 135 * pix,
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: _buildNotificationList(),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // Empty state widget
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_off_outlined,
            size: 70,
            color: Colors.grey[400],
          ),
          SizedBox(height: 16),
          Text(
            "Không có thông báo",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 8),
          Text(
            "Thông báo mới sẽ xuất hiện ở đây",
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationList() {
    return Consumer<NotificationProvider>(
        builder: (context, notiProvider, child) {
      if (notiProvider.loading) {
        return Center(
          child: CircularProgressIndicator(),
        );
      } else if (notiProvider.getNotificationList.isEmpty) {
        return _buildEmptyState();
      }

      return RefreshIndicator(
        onRefresh: () => _refreshNotifications(),
        child: ListView.builder(
          controller: _scrollController,
          padding: EdgeInsets.all(16),
          itemCount: notiProvider.getNotificationList.length,
          itemBuilder: (context, index) {
            NotificationModel notification =
                notiProvider.getNotificationList[index];
            return _buildNotificationItem(notification);
          },
        ),
      );
    });
  }

  Widget _buildNotificationItem(NotificationModel notification) {
    return Card(
      elevation: 2,
      margin: EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      // Add background color for unread notifications
      color: notification.isRead
          ? Colors.white
          : const Color.fromARGB(255, 224, 255, 247),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: () {},
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Notification icon with background
              Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: notification.color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  notification.icon,
                  color: notification.color,
                  size: 30,
                ),
              ),
              SizedBox(width: 16),

              // Notification content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title with bold for unread
                    Text(
                      notification.title,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: notification.isRead
                            ? FontWeight.normal
                            : FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),

                    // Content preview
                    Text(
                      notification.content,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 8),

                    // Time with right alignment
                    Align(
                      alignment: Alignment.bottomRight,
                      child: Text(
                        notification.time,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[500],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
