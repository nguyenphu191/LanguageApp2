import 'package:flutter/material.dart';
import 'package:language_app/HongNM/DoListenScreen.dart';
import 'package:language_app/HongNM/DoSpeakScreen.dart';
import 'package:language_app/HongNM/LessonScreen.dart';
import 'package:language_app/widget/TopBar.dart';

class Levelscreen extends StatefulWidget {
  const Levelscreen({super.key, required this.type});
  final String type;

  @override
  State<Levelscreen> createState() => _LevelscreenState();
}

class _LevelscreenState extends State<Levelscreen> {
  final List<Map<String, dynamic>> levels = [
    {
      "title": "Người mới bắt đầu",
      "subtitle": "Khởi đầu học tập",
      "icon": Icons.school,
      "color": Colors.green,
      "lessons": [
        "Hiện tại đơn",
        "Quá khứ đơn",
        "Tương lai đơn",
      ]
    },
    {
      "title": "Cơ bản",
      "subtitle": "Nền tảng vững chắc",
      "icon": Icons.auto_stories,
      "color": Colors.blue,
      "lessons": [
        "Hiện tại đơn",
        "Quá khứ đơn",
        "Tương lai đơn",
      ]
    },
    {
      "title": "Trung cấp",
      "subtitle": "Nâng cao kỹ năng",
      "icon": Icons.psychology,
      "color": Colors.orange,
      "lessons": [
        "Hiện tại đơn",
        "Quá khứ đơn",
        "Tương lai đơn",
      ]
    },
    {
      "title": "Nâng cao",
      "subtitle": "Thành thạo ngôn ngữ",
      "icon": Icons.emoji_events,
      "color": Colors.purple,
      "lessons": [
        "Hiện tại đơn",
        "Quá khứ đơn",
        "Tương lai đơn",
      ]
    },
  ];

  final List<Map<String, dynamic>> levelslis = [
    {
      "title": "Người mới bắt đầu",
      "subtitle": "Bài tập cơ bản",
      "icon": Icons.headphones,
      "color": Colors.green,
      "lessons": [
        "Bài 1",
        "Bài 2",
        "Bài 3",
      ]
    },
    {
      "title": "Cơ bản",
      "subtitle": "Luyện nghe hàng ngày",
      "icon": Icons.hearing,
      "color": Colors.blue,
      "lessons": [
        "Bài 1",
        "Bài 2",
        "Bài 3",
      ]
    },
    {
      "title": "Trung cấp",
      "subtitle": "Đang phát triển",
      "icon": Icons.hourglass_empty,
      "color": Colors.orange,
      "lessons": []
    },
    {
      "title": "Nâng cao",
      "subtitle": "Sắp ra mắt",
      "icon": Icons.lock_clock,
      "color": Colors.purple,
      "lessons": []
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
          child: Column(
            children: [
              TopBar(title: widget.type, isBack: true),
              SizedBox(height: 12 * pix),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20 * pix),
                child: Container(
                  padding: EdgeInsets.all(15 * pix),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.85),
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        spreadRadius: 2,
                      )
                    ],
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _getTypeIcon(),
                        size: 32 * pix,
                        color: _getTypeColor(),
                      ),
                      SizedBox(width: 12 * pix),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Học ${widget.type}",
                              style: TextStyle(
                                fontSize: 18 * pix,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'BeVietnamPro',
                              ),
                            ),
                            Text(
                              _getTypeDescription(),
                              style: TextStyle(
                                fontSize: 14 * pix,
                                color: Colors.grey.shade700,
                                fontFamily: 'BeVietnamPro',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 12 * pix),
              Expanded(
                child: widget.type == "Ngữ pháp"
                    ? _buildLevelList(levels, pix)
                    : _buildLevelList(levelslis, pix),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLevelList(List<Map<String, dynamic>> levelData, double pix) {
    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 16 * pix, vertical: 8 * pix),
      itemCount: levelData.length,
      itemBuilder: (context, index) {
        final level = levelData[index];
        return buildCategory(
          level["title"] as String,
          level["subtitle"] as String? ?? "",
          level["icon"] as IconData? ?? Icons.folder,
          level["color"] as Color? ?? Colors.blue,
          List<String>.from(level["lessons"]),
          pix,
        );
      },
    );
  }

  Widget buildCategory(String title, String subtitle, IconData icon,
      Color color, List<String> items, double pix) {
    return Card(
      elevation: 4,
      margin: EdgeInsets.symmetric(vertical: 10 * pix, horizontal: 4 * pix),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(
          dividerColor: Colors.transparent,
        ),
        child: ExpansionTile(
          leading: Container(
            padding: EdgeInsets.all(8 * pix),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: color,
              size: 24 * pix,
            ),
          ),
          title: Text(
            title,
            style: TextStyle(
              fontSize: 18 * pix,
              fontWeight: FontWeight.bold,
              fontFamily: 'BeVietnamPro',
            ),
          ),
          subtitle: Text(
            subtitle,
            style: TextStyle(
              fontSize: 14 * pix,
              color: Colors.grey.shade600,
              fontFamily: 'BeVietnamPro',
            ),
          ),
          childrenPadding:
              EdgeInsets.symmetric(horizontal: 16 * pix, vertical: 8 * pix),
          expandedCrossAxisAlignment: CrossAxisAlignment.start,
          children: items.isEmpty
              ? [
                  Container(
                    padding: EdgeInsets.all(16 * pix),
                    alignment: Alignment.center,
                    child: Column(
                      children: [
                        Icon(
                          Icons.lock_clock,
                          size: 48 * pix,
                          color: Colors.grey.shade400,
                        ),
                        SizedBox(height: 8 * pix),
                        Text(
                          "Nội dung đang được phát triển",
                          style: TextStyle(
                            fontSize: 16 * pix,
                            color: Colors.grey.shade600,
                            fontFamily: 'BeVietnamPro',
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  )
                ]
              : items
                  .asMap()
                  .entries
                  .map(
                    (entry) => buildLessonItem(
                      index: entry.key,
                      totalItems: items.length,
                      title: entry.value,
                      color: color,
                      pix: pix,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => widget.type == "Ngữ pháp"
                                ? Lessonscreen(title: entry.value)
                                : widget.type == "Nghe"
                                    ? DoListenscreen(
                                        title: widget.type, index: entry.key)
                                    : DoSpeakscreen(
                                        title: widget.type, index: entry.key),
                          ),
                        );
                      },
                    ),
                  )
                  .toList(),
        ),
      ),
    );
  }

  Widget buildLessonItem({
    required int index,
    required int totalItems,
    required String title,
    required Color color,
    required double pix,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: index < totalItems - 1 ? 12 * pix : 0),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding:
              EdgeInsets.symmetric(vertical: 14 * pix, horizontal: 16 * pix),
          decoration: BoxDecoration(
            color: color.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withOpacity(0.3), width: 1),
          ),
          child: Row(
            children: [
              Container(
                width: 32 * pix,
                height: 32 * pix,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    "${index + 1}",
                    style: TextStyle(
                      fontSize: 16 * pix,
                      fontWeight: FontWeight.bold,
                      color: color,
                      fontFamily: 'BeVietnamPro',
                    ),
                  ),
                ),
              ),
              SizedBox(width: 16 * pix),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 16 * pix,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'BeVietnamPro',
                  ),
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: color,
                size: 24 * pix,
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getTypeIcon() {
    switch (widget.type) {
      case "Ngữ pháp":
        return Icons.menu_book;
      case "Nghe":
        return Icons.headphones;
      case "Nói":
        return Icons.mic;
      default:
        return Icons.school;
    }
  }

  Color _getTypeColor() {
    switch (widget.type) {
      case "Ngữ pháp":
        return Colors.blue;
      case "Nghe":
        return Colors.green;
      case "Nói":
        return Colors.orange;
      default:
        return Colors.purple;
    }
  }

  String _getTypeDescription() {
    switch (widget.type) {
      case "Ngữ pháp":
        return "Học cấu trúc ngôn ngữ thành thạo";
      case "Nghe":
        return "Luyện nghe hiểu các tình huống thực tế";
      case "Nói":
        return "Thực hành phát âm và giao tiếp";
      default:
        return "Nâng cao kỹ năng ngôn ngữ";
    }
  }
}
