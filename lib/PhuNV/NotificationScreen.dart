import 'package:flutter/material.dart';
import 'package:language_app/PhuNV/NotificationDetailScreen.dart';
import 'package:language_app/widget/TopBar.dart';

class Notificationsscreen extends StatefulWidget {
  const Notificationsscreen({super.key});

  @override
  State<Notificationsscreen> createState() => _NotificationsscreenState();
}

class _NotificationsscreenState extends State<Notificationsscreen> {
  final List<Map<String, dynamic>> notifications = [
    {
      "icon": Icons.notifications,
      "title": "Thông báo mới",
      "content": "Bạn có một tin nhắn mới từ Nguyễn Văn A.",
      "time": "10 phút trước",
      "color": Colors.blue,
    },
    {
      "icon": Icons.event,
      "title": "Sự kiện sắp diễn ra",
      "content": "Sự kiện 'Hội thảo công nghệ' sẽ bắt đầu vào ngày mai.",
      "time": "1 giờ trước",
      "color": Colors.green,
    },
    {
      "icon": Icons.warning,
      "title": "Cảnh báo",
      "content": "Hệ thống sẽ bảo trì vào lúc 22:00 tối nay.",
      "time": "2 giờ trước",
      "color": Colors.orange,
    },
    {
      "icon": Icons.payment,
      "title": "Thanh toán thành công",
      "content": "Bạn đã thanh toán thành công cho đơn hàng #12345.",
      "time": "3 giờ trước",
      "color": Colors.purple,
    },
    {
      "icon": Icons.discount,
      "title": "Khuyến mãi",
      "content": "Giảm giá 20% cho tất cả sản phẩm trong tuần này.",
      "time": "5 giờ trước",
      "color": Colors.red,
    },
    {
      "icon": Icons.notifications,
      "title": "Thông báo mới",
      "content": "Bạn có một tin nhắn mới từ Nguyễn Văn A.",
      "time": "10 phút trước",
      "color": Colors.blue,
    },
    {
      "icon": Icons.event,
      "title": "Sự kiện sắp diễn ra",
      "content": "Sự kiện 'Hội thảo công nghệ' sẽ bắt đầu vào ngày mai.",
      "time": "1 giờ trước",
      "color": Colors.green,
    },
    {
      "icon": Icons.warning,
      "title": "Cảnh báo",
      "content": "Hệ thống sẽ bảo trì vào lúc 22:00 tối nay.",
      "time": "2 giờ trước",
      "color": Colors.orange,
    },
    {
      "icon": Icons.payment,
      "title": "Thanh toán thành công",
      "content": "Bạn đã thanh toán thành công cho đơn hàng #12345.",
      "time": "3 giờ trước",
      "color": Colors.purple,
    },
    {
      "icon": Icons.discount,
      "title": "Khuyến mãi",
      "content": "Giảm giá 20% cho tất cả sản phẩm trong tuần này.",
      "time": "5 giờ trước",
      "color": Colors.red,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final pix = size.width / 375;
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue.shade200, Colors.indigo.shade50],
            stops: const [0.0, 0.7],
          ),
        ),
        child: SafeArea(
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
                left: 0,
                right: 0,
                bottom: 0,
                child: ListView.builder(
                  padding: EdgeInsets.all(16),
                  itemCount: notifications.length,
                  itemBuilder: (context, index) {
                    final notification = notifications[index];
                    return Card(
                      elevation: 2,
                      margin: EdgeInsets.only(bottom: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: ListTile(
                        leading: Container(
                          padding: EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: notification["color"].withOpacity(0.2),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            notification["icon"],
                            color: notification["color"],
                            size: 30,
                          ),
                        ),
                        title: Text(
                          notification["title"],
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: 5),
                            Text(
                              notification["content"],
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                            SizedBox(height: 5),
                            Text(
                              notification["time"],
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[500],
                              ),
                            ),
                          ],
                        ),
                        onTap: () {
                          // Chuyển hướng sang trang chi tiết thông báo
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => NotificationDetailscreen(
                                  notification: notification),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
