import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:language_app/Models/exercise_model.dart';
import 'package:language_app/widget/top_bar.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';

class DoSpeakscreen extends StatefulWidget {
  const DoSpeakscreen({super.key, required this.exercise});
  final ExerciseModel exercise;
  @override
  _DoSpeakscreenState createState() => _DoSpeakscreenState();
}

class _DoSpeakscreenState extends State<DoSpeakscreen>
    with SingleTickerProviderStateMixin {
  FlutterTts flutterTts = FlutterTts();
  stt.SpeechToText speech = stt.SpeechToText();
  bool isListening = false;
  String recognizedText = "";
  double pronunciationScore = 0.0;
  String assessmentFeedback = "";
  late AnimationController _animationController;
  bool _isSpeechInitialized = false;
  bool _isMicrophonePermissionGranted = false;

  // Danh sách từ vựng với hình ảnh minh họa
  List<Map<String, dynamic>> words = [
    {"word": "School", "image": "assets/images/school.png"},
    {"word": "Student", "image": "assets/images/student.png"},
    {"word": "Cat", "image": "assets/images/cat.png"},
  ];

  int currentWordIndex = 0;
  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    _initializeSpeech();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  // Khởi tạo speech-to-text và kiểm tra quyền microphone
  void _initializeSpeech() async {
    // Kiểm tra và yêu cầu quyền truy cập microphone
    final microphoneStatus = await Permission.microphone.status;
    if (microphoneStatus.isDenied) {
      final result = await Permission.microphone.request();
      if (result.isGranted) {
        setState(() {
          _isMicrophonePermissionGranted = true;
        });
      } else {
        print("Quyền truy cập microphone bị từ chối!");
        return;
      }
    } else if (microphoneStatus.isGranted) {
      setState(() {
        _isMicrophonePermissionGranted = true;
      });
    }

    // Khởi tạo speech-to-text nếu có quyền microphone
    if (_isMicrophonePermissionGranted) {
      try {
        _isSpeechInitialized = await speech.initialize(
          onError: (error) => print("Lỗi Speech: $error"),
          onStatus: (status) => print("Trạng thái: $status"),
        );

        if (_isSpeechInitialized) {
          setState(() {
            // Thiết bị hỗ trợ nhận diện giọng nói
          });
        } else {
          print("Speech-to-Text không khả dụng trên thiết bị này!");
        }
      } catch (e) {
        print("Lỗi khi khởi tạo Speech-to-Text: $e");
      }
    }
  }

  // Bắt đầu nghe
  void startListening() async {
    if (!_isSpeechInitialized || !_isMicrophonePermissionGranted) {
      print(
          "Speech-to-Text chưa được khởi tạo hoặc không có quyền microphone!");
      return;
    }

    if (!isListening) {
      setState(() {
        isListening = true;
        recognizedText = "";
        pronunciationScore = 0.0;
        assessmentFeedback = "";
      });

      _animationController.repeat(); // Bắt đầu hiệu ứng animation

      speech.listen(
        onResult: (result) {
          final targetWord = words[currentWordIndex]["word"].toLowerCase();
          final recognized = result.recognizedWords.toLowerCase();

          setState(() {
            recognizedText = result.recognizedWords;

            // Đánh giá phát âm dựa trên nhận dạng từ
            if (recognized.contains(targetWord)) {
              // Tính điểm dựa trên độ chính xác
              double confidence = result.confidence;
              pronunciationScore = (confidence * 100).clamp(0.0, 100.0);

              // Phản hồi dựa trên điểm số
              if (pronunciationScore >= 80) {
                assessmentFeedback = "Phát âm tuyệt vời!";
              } else if (pronunciationScore >= 60) {
                assessmentFeedback = "Phát âm tốt. Hãy tiếp tục luyện tập!";
              } else {
                assessmentFeedback = "Hãy cố gắng phát âm rõ ràng hơn.";
              }
            } else if (recognized.isNotEmpty) {
              // Từ không được nhận dạng đúng
              pronunciationScore =
                  calculateSimilarityScore(targetWord, recognized);
              assessmentFeedback = "Phát âm chưa chính xác. Hãy thử lại.";
            }
          });
        },
      );
    }
  }

  // Tính toán điểm tương đồng giữa hai chuỗi (thuật toán Levenshtein đơn giản hóa)
  double calculateSimilarityScore(String target, String actual) {
    if (actual.isEmpty) return 0;
    if (target == actual) return 100;

    // Kiểm tra nếu actual chứa target
    if (actual.contains(target)) return 80;

    // Kiểm tra âm đầu tiên
    if (actual.startsWith(target.substring(0, 1))) {
      // Có một số ký tự đúng
      int commonChars = 0;
      for (int i = 0; i < target.length && i < actual.length; i++) {
        if (target[i] == actual[i]) commonChars++;
      }

      return (commonChars / target.length * 70).clamp(0.0, 70.0);
    }

    return 30.0; // Điểm cơ bản khi phát âm hoàn toàn khác
  }

  // Dừng nghe
  void stopListening() {
    if (isListening) {
      setState(() => isListening = false);
      _animationController.stop(); // Dừng hiệu ứng animation
      speech.stop();
    }
  }

  // Đọc từ bằng TTS
  Future<void> speak(String text) async {
    final url =
        "https://translate.google.com/translate_tts?ie=UTF-8&tl=en&client=tw-ob&q=${Uri.encodeComponent(text)}";

    try {
      await _audioPlayer.play(UrlSource(url));
    } catch (e) {
      print("Lỗi phát âm thanh: $e");
      // Fallback to Flutter TTS if Google TTS fails
      await flutterTts.setLanguage("en-US");
      await flutterTts.setPitch(1.0);
      await flutterTts.speak(text);
    }
  }

  // Chuyển sang từ tiếp theo
  void nextWord() {
    setState(() {
      if (currentWordIndex < words.length - 1) {
        currentWordIndex++;
      } else {
        currentWordIndex = 0; // Quay lại từ đầu
      }
      recognizedText = "";
      pronunciationScore = 0.0;
      assessmentFeedback = "";
    });
  }

  // Lấy màu dựa trên độ chính xác
  Color getAccuracyColor() {
    if (pronunciationScore >= 80) return Colors.green;
    if (pronunciationScore >= 50) return Colors.orange;
    return Colors.red;
  }

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
              child: TopBar(title: "Bài tập phát âm", isBack: true),
            ),
            Positioned(
              top: 100 * pix,
              left: 0,
              right: 0,
              bottom: 0,
              child: Padding(
                padding: EdgeInsets.all(16 * pix),
                child: Column(
                  children: [
                    // Thẻ từ vựng hiện tại
                    Card(
                      elevation: 8,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15)),
                      child: Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(20),
                        child: Column(
                          children: [
                            Text(
                              "Từ cần phát âm:",
                              style: TextStyle(
                                  fontSize: 16, color: Colors.grey.shade700),
                            ),
                            SizedBox(height: 10),
                            Text(
                              words[currentWordIndex]["word"],
                              style: TextStyle(
                                fontSize: 38,
                                fontWeight: FontWeight.bold,
                                color: Colors.indigo,
                              ),
                            ),
                            SizedBox(height: 20),
                            // Có thể thêm hình ảnh nếu có
                            // Image.asset(
                            //   words[currentWordIndex]["image"],
                            //   height: 100,
                            // ),
                          ],
                        ),
                      ),
                    ),

                    SizedBox(height: 30),

                    // Nút nghe từ
                    ElevatedButton.icon(
                      onPressed: () => speak(words[currentWordIndex]["word"]),
                      icon: Icon(Icons.volume_up, size: 28),
                      label: Text("Nghe từ", style: TextStyle(fontSize: 18)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.indigo,
                        padding:
                            EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30)),
                      ),
                    ),

                    SizedBox(height: 20),

                    // Nút thu âm
                    _isMicrophonePermissionGranted && _isSpeechInitialized
                        ? AnimatedBuilder(
                            animation: _animationController,
                            builder: (context, child) {
                              return ElevatedButton.icon(
                                onPressed: isListening
                                    ? stopListening
                                    : startListening,
                                icon: Icon(
                                  isListening ? Icons.stop : Icons.mic,
                                  size: isListening
                                      ? 28 + (_animationController.value * 5)
                                      : 28,
                                  color:
                                      isListening ? Colors.red : Colors.white,
                                ),
                                label: Text(
                                    isListening
                                        ? "Dừng thu âm"
                                        : "Bắt đầu thu âm",
                                    style: TextStyle(fontSize: 18)),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: isListening
                                      ? Colors.white
                                      : Colors.indigo,
                                  foregroundColor: isListening
                                      ? Colors.indigo
                                      : Colors.white,
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 40, vertical: 15),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30)),
                                  elevation: isListening ? 8 : 4,
                                ),
                              );
                            })
                        : Text(
                            "Nhận diện giọng nói không khả dụng hoặc cần quyền truy cập!",
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),

                    SizedBox(height: 30),

                    // Kết quả nhận diện trong một thẻ
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            offset: Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Text(
                            "Kết quả",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey.shade700,
                            ),
                          ),
                          SizedBox(height: 10),
                          Text(
                            recognizedText.isEmpty
                                ? "Chưa có ghi âm"
                                : recognizedText,
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w500,
                              color: Colors.black87,
                            ),
                          ),
                          SizedBox(height: 15),
                          pronunciationScore > 0
                              ? LinearProgressIndicator(
                                  value: pronunciationScore / 100,
                                  backgroundColor: Colors.grey.shade200,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      getAccuracyColor()),
                                  minHeight: 10,
                                  borderRadius: BorderRadius.circular(5),
                                )
                              : SizedBox(),
                          SizedBox(height: 10),
                          pronunciationScore > 0
                              ? Text(
                                  "Độ chính xác: ${pronunciationScore.toStringAsFixed(1)}%",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: getAccuracyColor(),
                                  ),
                                )
                              : SizedBox(),
                          SizedBox(height: 10),
                          assessmentFeedback.isNotEmpty
                              ? Text(
                                  assessmentFeedback,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontStyle: FontStyle.italic,
                                    color: Colors.black87,
                                  ),
                                  textAlign: TextAlign.center,
                                )
                              : SizedBox(),
                        ],
                      ),
                    ),

                    Spacer(),

                    // Nút chuyển sang từ tiếp theo
                    ElevatedButton.icon(
                      onPressed: nextWord,
                      icon: Icon(Icons.arrow_forward),
                      label:
                          Text("Từ tiếp theo", style: TextStyle(fontSize: 18)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.amber,
                        foregroundColor: Colors.black87,
                        padding:
                            EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30)),
                      ),
                    ),
                    SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
