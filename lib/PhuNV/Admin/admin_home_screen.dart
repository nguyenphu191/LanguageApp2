import 'package:flutter/material.dart';
import 'package:language_app/PhuNV/Admin/language_screen.dart';
import 'package:language_app/PhuNV/Admin/topic_manager.dart';
import 'package:language_app/PhuNV/Admin/vocabulary_management_screen.dart';
import 'package:language_app/widget/top_bar.dart';

class AdminScreen extends StatelessWidget {
  const AdminScreen({Key? key}) : super(key: key);

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
                title: "Quản trị viên",
              ),
            ),
            Positioned(
              top: 100 * pix,
              left: 0,
              right: 0,
              bottom: 0,
              child: SingleChildScrollView(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Quản lý hệ thống",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 20),
                    _buildAdminMenuItem(
                      context,
                      title: "Quản lý ngôn ngữ",
                      icon: Icons.language,
                      color: Colors.blue,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => LanguageScreen(),
                          ),
                        );
                      },
                    ),
                    _buildAdminMenuItem(
                      context,
                      title: "Quản lý chủ đề",
                      icon: Icons.topic,
                      color: Colors.green,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => TopicScreen(),
                          ),
                        );
                      },
                    ),
                    _buildAdminMenuItem(
                      context,
                      title: "Quản lý từ vựng",
                      icon: Icons.topic,
                      color: Colors.green,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => VocabularyManagementScreen(),
                          ),
                        );
                      },
                    ),
                    _buildAdminMenuItem(
                      context,
                      title: "Quản lý người dùng",
                      icon: Icons.people,
                      color: Colors.orange,
                      onTap: () {
                        // Navigator.push đến trang quản lý người dùng
                      },
                    ),
                    _buildAdminMenuItem(
                      context,
                      title: "Thống kê hệ thống",
                      icon: Icons.bar_chart,
                      color: Colors.purple,
                      onTap: () {
                        // Navigator.push đến trang thống kê
                      },
                    ),
                    _buildAdminMenuItem(
                      context,
                      title: "Quản lý thông báo",
                      icon: Icons.notifications,
                      color: Colors.red,
                      onTap: () {
                        // Navigator.push đến trang quản lý thông báo
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdminMenuItem(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 4,
      margin: EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 32,
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      "Nhấn để quản lý ${title.toLowerCase()}",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: Colors.grey,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
