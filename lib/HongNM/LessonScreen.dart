import 'package:flutter/material.dart';
import 'package:language_app/HongNM/DoGrammarScreen.dart';
import 'package:language_app/widget/TopBar.dart';

class Lessonscreen extends StatefulWidget {
  const Lessonscreen({super.key, required this.title});
  final String title;
  @override
  State<Lessonscreen> createState() => _LessonscreenState();
}

class _LessonscreenState extends State<Lessonscreen> {
  final String theory =
      "Thì hiện tại đơn diễn tả một hành động xảy ra thường xuyên, thói quen hoặc sự thật hiển nhiên.\n"
      "- Cấu trúc: \n"
      "  + Khẳng định: S + V(s/es) + O \n"
      "  + Phủ định: S + do/does + not + V + O \n"
      "  + Nghi vấn: Do/Does + S + V + O ?";
  List<int> lessons = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10];

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
                right: 0,
                left: 0,
                child: TopBar(title: widget.title),
              ),
              Positioned(
                top: 100 * pix,
                right: 0,
                left: 0,
                bottom: 0,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Container(
                        width: size.width,
                        margin: EdgeInsets.all(16 * pix),
                        padding: EdgeInsets.all(16 * pix),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.all(Radius.circular(16)),
                        ),
                        child: Column(
                          children: [
                            Container(
                              height: 36 * pix,
                              width: size.width,
                              child: Text(
                                "Lý thuyết:",
                                style: TextStyle(
                                    fontSize: 22, fontWeight: FontWeight.bold),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            SizedBox(height: 10),
                            Text(
                              theory,
                              style: TextStyle(
                                  fontSize: 18 * pix,
                                  fontFamily: 'BeVietnamPro'),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 20),
                      ListView.builder(
                        itemCount: lessons.length,
                        itemBuilder: (context, index) {
                          return _selection(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => DoGrammarscreen(
                                    title: "Ngữ pháp",
                                    index: index,
                                  ),
                                ),
                              );
                            },
                            index: index,
                          );
                        },
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _selection({required VoidCallback onTap, required int index}) {
    final size = MediaQuery.of(context).size;
    final pix = size.width / 375;
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 50 * pix,
        width: size.width,
        margin:
            EdgeInsets.only(bottom: 10 * pix, left: 16 * pix, right: 16 * pix),
        decoration: BoxDecoration(
          color: Color.fromARGB(255, 255, 255, 255),
          borderRadius: BorderRadius.circular(50),
          border: Border.all(
            color: const Color.fromARGB(255, 6, 162, 247),
            width: 1 * pix,
          ),
          boxShadow: [
            BoxShadow(
              color: Color.fromARGB(255, 0, 0, 0).withOpacity(0.1),
              offset: Offset(0, 4),
              blurRadius: 10,
            ),
          ],
        ),
        child: Center(
          child: Text(
            "Bài ${index + 1}",
            style: TextStyle(
              color: const Color.fromARGB(255, 0, 0, 0),
              fontSize: 16 * pix,
              fontFamily: 'BeVietnamPro',
              fontWeight: FontWeight.w600,
              decoration: TextDecoration.none,
            ),
          ),
        ),
      ),
    );
  }
}
