import 'package:flutter/material.dart';
import 'package:language_app/widget/TopBar.dart';

class DoGrammarscreen extends StatefulWidget {
  const DoGrammarscreen({super.key, required this.title, required this.index});
  final String title;
  final int index;

  @override
  State<DoGrammarscreen> createState() => _DoGrammarscreenState();
}

class _DoGrammarscreenState extends State<DoGrammarscreen> {
  int currentQuestion = 0;
  int correctAnswers = 0;
  bool showHint = false;
  String selectedAnswer = "";
  bool answerChecked = false;

  final List<Map<String, dynamic>> questions = [
    {
      "question": "She ______ to school on foot sometimes.",
      "options": ["goes", "went", "has gone", "will go"],
      "answer": "goes",
      "hint":
          "Công thức thì Hiện tại đơn: Chủ ngữ số ít + động từ thêm 's'/'es'."
    },
    {
      "question": "They ______ to school on foot every day.",
      "options": ["goes", "went", "has gone", "will go"],
      "answer": "go",
      "hint": "Chủ ngữ số nhiều (They) nên dùng động từ nguyên mẫu."
    },
  ];

  void checkAnswer(String answer) {
    setState(() {
      selectedAnswer = answer;
      answerChecked = true;
      if (answer == questions[currentQuestion]["answer"]) {
        correctAnswers++;
      }
      Future.delayed(Duration(seconds: 1), () {
        if (currentQuestion < questions.length - 1) {
          setState(() {
            currentQuestion++;
            selectedAnswer = "";
            showHint = false;
            answerChecked = false;
          });
        } else {
          showResult();
        }
      });
    });
  }

  void showResult() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        title: Text(
          "Kết quả",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).primaryColor,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: correctAnswers == questions.length
                    ? Colors.green.withOpacity(0.1)
                    : Colors.amber.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    correctAnswers == questions.length
                        ? Icons.star
                        : Icons.emoji_events,
                    color: correctAnswers == questions.length
                        ? Colors.green
                        : Colors.amber,
                    size: 40,
                  ),
                  SizedBox(width: 10),
                  Text(
                    "$correctAnswers/${questions.length}",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: correctAnswers == questions.length
                          ? Colors.green
                          : Colors.amber,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 15),
            Text(
              correctAnswers == questions.length
                  ? "Tuyệt vời! Bạn đã trả lời đúng tất cả các câu hỏi."
                  : "Bạn đã làm đúng $correctAnswers/${questions.length} câu!",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    setState(() {
                      currentQuestion = 0;
                      correctAnswers = 0;
                      selectedAnswer = "";
                      showHint = false;
                      answerChecked = false;
                    });
                  },
                  icon: Icon(Icons.refresh),
                  label: Text("Làm lại"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pop(context);
                  },
                  icon: Icon(Icons.arrow_back),
                  label: Text("Quay lại"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[300],
                    foregroundColor: Colors.black87,
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final pix = size.width / 375;

    return Scaffold(
      backgroundColor: Colors.grey[50],
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
              TopBar(title: "Bài tập ${widget.index + 1}", isBack: true),
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(16 * pix),
                  child: Column(
                    children: [
                      Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(16),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: Colors.blue.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      "Câu ${currentQuestion + 1}/${questions.length}",
                                      style: TextStyle(
                                        color: Colors.blue,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: Colors.green.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      "Đúng: $correctAnswers",
                                      style: TextStyle(
                                        color: Colors.green,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 20),
                              Text(
                                questions[currentQuestion]["question"],
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                      ...questions[currentQuestion]["options"]
                          .map<Widget>((option) {
                        bool isCorrect =
                            option == questions[currentQuestion]["answer"];
                        bool isSelected = option == selectedAnswer;

                        Color bgColor = Colors.white;
                        Color borderColor = Colors.grey.shade300;
                        Color textColor = Colors.black87;
                        IconData? optionIcon;

                        if (answerChecked) {
                          if (isSelected) {
                            if (isCorrect) {
                              bgColor = Colors.green.withOpacity(0.1);
                              borderColor = Colors.green;
                              textColor = Colors.green;
                              optionIcon = Icons.check_circle;
                            } else {
                              bgColor = Colors.red.withOpacity(0.1);
                              borderColor = Colors.red;
                              textColor = Colors.red;
                              optionIcon = Icons.cancel;
                            }
                          } else if (isCorrect) {
                            bgColor = Colors.green.withOpacity(0.1);
                            borderColor = Colors.green;
                            textColor = Colors.green;
                            optionIcon = Icons.check_circle;
                          }
                        } else if (isSelected) {
                          bgColor = Colors.blue.withOpacity(0.1);
                          borderColor = Colors.blue;
                          textColor = Colors.blue;
                        }

                        return GestureDetector(
                          onTap: () {
                            if (!answerChecked) {
                              checkAnswer(option);
                            }
                          },
                          child: Container(
                            margin: EdgeInsets.symmetric(vertical: 8),
                            padding: EdgeInsets.all(16),
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: bgColor,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: borderColor, width: 2),
                              boxShadow: !answerChecked
                                  ? [
                                      BoxShadow(
                                        color: Colors.grey.withOpacity(0.1),
                                        blurRadius: 5,
                                        offset: Offset(0, 2),
                                      )
                                    ]
                                  : null,
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    option,
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: textColor,
                                      fontWeight: isSelected ||
                                              (answerChecked && isCorrect)
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                    ),
                                  ),
                                ),
                                if (optionIcon != null)
                                  Icon(
                                    optionIcon,
                                    color: textColor,
                                  ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                      SizedBox(height: 25),
                      if (!answerChecked)
                        Column(
                          children: [
                            ElevatedButton.icon(
                              onPressed: () =>
                                  setState(() => showHint = !showHint),
                              icon: Icon(
                                showHint
                                    ? Icons.visibility_off
                                    : Icons.lightbulb_outline,
                              ),
                              label: Text(showHint ? "Ẩn gợi ý" : "Hiện gợi ý"),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.amber,
                                foregroundColor: Colors.white,
                                padding: EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                            AnimatedCrossFade(
                              firstChild: SizedBox(height: 0),
                              secondChild: Container(
                                margin: EdgeInsets.only(top: 16),
                                padding: EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.amber.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: Colors.amber.withOpacity(0.5),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.lightbulb,
                                      color: Colors.amber,
                                    ),
                                    SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        questions[currentQuestion]["hint"],
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.black87,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              crossFadeState: showHint
                                  ? CrossFadeState.showSecond
                                  : CrossFadeState.showFirst,
                              duration: Duration(milliseconds: 300),
                            ),
                          ],
                        ),
                      SizedBox(height: 30),
                      if (answerChecked)
                        Container(
                          padding: EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: selectedAnswer ==
                                    questions[currentQuestion]["answer"]
                                ? Colors.green.withOpacity(0.1)
                                : Colors.red.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: selectedAnswer ==
                                      questions[currentQuestion]["answer"]
                                  ? Colors.green
                                  : Colors.red,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                selectedAnswer ==
                                        questions[currentQuestion]["answer"]
                                    ? Icons.check_circle
                                    : Icons.info,
                                color: selectedAnswer ==
                                        questions[currentQuestion]["answer"]
                                    ? Colors.green
                                    : Colors.red,
                              ),
                              SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  selectedAnswer ==
                                          questions[currentQuestion]["answer"]
                                      ? "Chính xác! Đáp án đúng là '${questions[currentQuestion]["answer"]}'."
                                      : "Đáp án đúng là '${questions[currentQuestion]["answer"]}'.\n${questions[currentQuestion]["hint"]}",
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.black87,
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
            ],
          ),
        ),
      ),
    );
  }
}
