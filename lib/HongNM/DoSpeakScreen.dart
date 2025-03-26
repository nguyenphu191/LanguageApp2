import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:language_app/widget/TopBar.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';
import 'package:string_similarity/string_similarity.dart';

class DoSpeakscreen extends StatefulWidget {
  const DoSpeakscreen({super.key, required this.title, required this.index});
  final String title;
  final int index;
  @override
  _DoSpeakscreenState createState() => _DoSpeakscreenState();
}

class _DoSpeakscreenState extends State<DoSpeakscreen>
    with SingleTickerProviderStateMixin {
  FlutterTts flutterTts = FlutterTts();
  stt.SpeechToText speech = stt.SpeechToText();
  bool isListening = false;
  String recognizedText = "";
  double accuracy = 0.0;
  late AnimationController _animationController;
  bool _isSpeechInitialized = false; // Kiểm tra khởi tạo speech-to-text
  bool _isMicrophonePermissionGranted = false; // Kiểm tra quyền microphone
  bool _isSpeechAvailable = false; // Kiểm tra hỗ trợ nhận diện giọng nói

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
    _initializeSpeech(); // Khởi tạo speech-to-text và kiểm tra quyền
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
      // Yêu cầu quyền nếu chưa được cấp
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
            _isSpeechAvailable = true; // Thiết bị hỗ trợ nhận diện giọng nói
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
    if (!_isSpeechInitialized ||
        !_isMicrophonePermissionGranted ||
        !_isSpeechAvailable) {
      print(
          "Speech-to-Text chưa được khởi tạo, không có quyền microphone hoặc không hỗ trợ!");
      return;
    }

    if (!isListening) {
      setState(() => isListening = true);
      _animationController.repeat(); // Bắt đầu hiệu ứng animation
      speech.listen(
        onResult: (result) {
          setState(() {
            recognizedText = result.recognizedWords;
            accuracy = words[currentWordIndex]["word"]
                    .toLowerCase()
                    .similarityTo(recognizedText.toLowerCase()) *
                100;
          });
        },
      );
    }
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
        "https://translate.google.com/translate_tts?ie=UTF-8&tl=en&client=tw-ob&q=$text";

    try {
      await _audioPlayer.play(UrlSource(url));
    } catch (e) {
      print("Lỗi phát âm thanh: $e");
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
      accuracy = 0.0;
    });
  }

  // Lấy màu dựa trên độ chính xác
  Color getAccuracyColor() {
    if (accuracy >= 80) return Colors.green;
    if (accuracy >= 50) return Colors.orange;
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
        child: SafeArea(
          child: Stack(
            children: [
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child:
                    TopBar(title: "Bài tập ${widget.index + 1}", isBack: true),
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
                          padding: EdgeInsets.symmetric(
                              horizontal: 40, vertical: 15),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30)),
                        ),
                      ),

                      SizedBox(height: 20),

                      // Nút thu âm
                      _isSpeechAvailable
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
                                        borderRadius:
                                            BorderRadius.circular(30)),
                                    elevation: isListening ? 8 : 4,
                                  ),
                                );
                              })
                          : Text(
                              "Nhận diện giọng nói không khả dụng trên thiết bị này!",
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.red,
                                fontWeight: FontWeight.bold,
                              ),
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
                            accuracy > 0
                                ? LinearProgressIndicator(
                                    value: accuracy / 100,
                                    backgroundColor: Colors.grey.shade200,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        getAccuracyColor()),
                                    minHeight: 10,
                                    borderRadius: BorderRadius.circular(5),
                                  )
                                : SizedBox(),
                            SizedBox(height: 10),
                            accuracy > 0
                                ? Text(
                                    "Độ chính xác: ${accuracy.toStringAsFixed(1)}%",
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: getAccuracyColor(),
                                    ),
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
                        label: Text("Từ tiếp theo",
                            style: TextStyle(fontSize: 18)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.amber,
                          foregroundColor: Colors.black87,
                          padding: EdgeInsets.symmetric(
                              horizontal: 40, vertical: 15),
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
      ),
    );
  }
}
