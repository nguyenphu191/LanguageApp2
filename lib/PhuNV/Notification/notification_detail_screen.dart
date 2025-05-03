import 'package:flutter/material.dart';
import 'package:language_app/widget/top_bar.dart';

class NotificationDetailscreen extends StatelessWidget {
  final Map<String, dynamic> notification;

  const NotificationDetailscreen({Key? key, required this.notification})
      : super(key: key);

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
        child: Stack(
          children: [
            // Top bar with back button
            Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: TopBar(
                  title: "Chi tiết thông báo",
                )),

            // Main content area
            Positioned(
              top: 100 * pix,
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(24 * pix),
                    topRight: Radius.circular(24 * pix),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: Offset(0, -5),
                    ),
                  ],
                ),
                child: _buildNotificationContent(context, pix),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationContent(BuildContext context, double pix) {
    return SingleChildScrollView(
      physics: BouncingScrollPhysics(),
      child: Padding(
        padding: EdgeInsets.all(24 * pix),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with icon and title
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Notification icon
                Container(
                  padding: EdgeInsets.all(14 * pix),
                  decoration: BoxDecoration(
                    color: notification["color"].withOpacity(0.2),
                    borderRadius: BorderRadius.circular(16 * pix),
                  ),
                  child: Icon(
                    notification["icon"],
                    color: notification["color"],
                    size: 30 * pix,
                  ),
                ),
                SizedBox(width: 16 * pix),

                // Title
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        notification["title"],
                        style: TextStyle(
                          fontSize: 24 * pix,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      SizedBox(height: 8 * pix),
                      Text(
                        notification["time"],
                        style: TextStyle(
                          fontSize: 14 * pix,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            SizedBox(height: 32 * pix),

            // Content section
            Container(
              padding: EdgeInsets.all(20 * pix),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(16 * pix),
                border: Border.all(
                  color: Colors.grey[200]!,
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Nội dung thông báo",
                    style: TextStyle(
                      fontSize: 18 * pix,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 16 * pix),
                  Text(
                    notification["content"],
                    style: TextStyle(
                      fontSize: 16 * pix,
                      height: 1.5,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 24 * pix),

            // Action buttons (if any)
            _buildActionButtons(context, pix),
          ],
        ),
      ),
    );
  }

  // Action buttons based on notification type
  Widget _buildActionButtons(BuildContext context, double pix) {
    // You can add different actions based on notification type
    // For example, if it's a comment notification, add a "View comment" button

    // For now, just add a dismiss button
    return Center(
      child: ElevatedButton.icon(
        icon: Icon(Icons.check_circle_outline),
        label: Text("Đánh dấu đã đọc"),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(
            horizontal: 24 * pix,
            vertical: 12 * pix,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30 * pix),
          ),
        ),
        onPressed: () {
          Navigator.pop(context);
        },
      ),
    );
  }
}
