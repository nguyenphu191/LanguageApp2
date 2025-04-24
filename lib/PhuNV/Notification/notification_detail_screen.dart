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
              child: Container(
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Biểu tượng và tiêu đề
                      Row(
                        children: [
                          Container(
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
                          SizedBox(width: 16),
                          Expanded(
                            child: Text(
                              notification["title"],
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 20),

                      // Nội dung thông báo
                      Text(
                        "Nội dung:",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        notification["content"],
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                      SizedBox(height: 20),

                      // Thời gian thông báo
                      Text(
                        "Thời gian:",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        notification["time"],
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
