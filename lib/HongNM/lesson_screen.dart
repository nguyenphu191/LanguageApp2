import 'package:flutter/material.dart';
import 'package:language_app/HongNM/do_grammar_screen.dart';
import 'package:language_app/Models/exercise_model.dart';
import 'package:language_app/res/theme/app_colors.dart';
import 'package:language_app/widget/top_bar.dart';

class Lessonscreen extends StatefulWidget {
  const Lessonscreen({super.key, required this.title});
  final String title;
  @override
  State<Lessonscreen> createState() => _LessonscreenState();
}

class _LessonscreenState extends State<Lessonscreen> {
  // Sử dụng ExerciseModel thay vì hardcode
  ExerciseModel exercises = ExerciseModel(
    id: 1,
    name: 'Bài tập Hiện tại đơn',
    type: 'grammar',
    level: 'easy',
    audio: '',
    theory:
        "Thì hiện tại đơn diễn tả một hành động xảy ra thường xuyên, thói quen hoặc sự thật hiển nhiên.\n"
        "- Cấu trúc: \n"
        "  + Khẳng định: S + V(s/es) + O \n"
        "  + Phủ định: S + do/does + not + V + O \n"
        "  + Nghi vấn: Do/Does + S + V + O ?"
        "Thì hiện tại đơn diễn tả một hành động xảy ra thường xuyên, thói quen hoặc sự thật hiển nhiên.\n"
        "- Cấu trúc: \n"
        "  + Khẳng định: S + V(s/es) + O \n"
        "  + Phủ định: S + do/does + not + V + O \n"
        "  + Nghi vấn: Do/Does + S + V + O ?"
        "Thì hiện tại đơn diễn tả một hành động xảy ra thường xuyên, thói quen hoặc sự thật hiển nhiên.\n"
        "- Cấu trúc: \n"
        "  + Khẳng định: S + V(s/es) + O \n"
        "  + Phủ định: S + do/does + not + V + O \n"
        "  + Nghi vấn: Do/Does + S + V + O ?",
    description: 'Bài tập về thì hiện tại đơn',
    imageUrl: 'assets/images/grammar.png',
    duration: 15,
  );

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
              right: 0,
              left: 0,
              child: TopBar(title: widget.title),
            ),
            Positioned(
              top: 116 * pix,
              right: 0,
              left: 0,
              bottom: 16 * pix,
              child: exercises.theory != null
                  ? Container(
                      width: size.width - 32 * pix,
                      height: size.height - 150 * pix,
                      margin: EdgeInsets.symmetric(horizontal: 16 * pix),
                      padding: EdgeInsets.all(16 * pix),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.all(Radius.circular(16)),
                      ),
                      child: SingleChildScrollView(
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
                              exercises.theory!,
                              style: TextStyle(
                                  fontSize: 18 * pix,
                                  fontFamily: 'BeVietnamPro'),
                            ),
                            SizedBox(height: 126 * pix),
                          ],
                        ),
                      ),
                    )
                  : SizedBox.shrink(),
            ),
            Positioned(
              bottom: 32 * pix,
              right: 16 * pix,
              left: 16 * pix,
              child: _buildExerciseItem(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DoGrammarscreen(
                        exercise: exercises,
                      ),
                    ),
                  );
                },
                exercise: exercises,
              ),
            )
          ],
        ),
      ),
    );
  }

  // Widget để hiển thị từng bài tập
  Widget _buildExerciseItem({
    required VoidCallback onTap,
    required ExerciseModel exercise,
  }) {
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
          gradient: LinearGradient(
            colors: [
              const Color.fromARGB(255, 255, 173, 33),
              AppColors.accent.withOpacity(0.7),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(50),
          border: Border.all(
            color: AppColors.accent,
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
            "Làm ngay",
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
