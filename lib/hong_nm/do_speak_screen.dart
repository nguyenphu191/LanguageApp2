import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:language_app/models/exercise_model.dart';
import 'package:language_app/models/speaking_data_model.dart';
import 'package:language_app/provider/exercise_provider.dart';
import 'package:language_app/widget/top_bar.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
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
  bool loading = false;

  int currentWordIndex = 0;
  final AudioPlayer _audioPlayer = AudioPlayer();

  // Biến để theo dõi điểm số và trạng thái
  List<double> wordScores = []; // Lưu điểm của từng từ
  double averageAccuracy = 0.0; // Độ chính xác trung bình
  bool completedExercise = false; // Đánh dấu đã hoàn thành bài tập
  bool showingDialog = false; // Tránh hiển thị dialog nhiều lần

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    _initializeSpeech();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ExerciseProvider>(context, listen: false)
          .fetchSpeaking(widget.exercise.id);
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _audioPlayer.dispose();
    _scrollController.dispose();
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
  void startListening(String text) async {
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
          final targetText = text.toLowerCase();
          final recognized = result.recognizedWords.toLowerCase();

          setState(() {
            recognizedText = result.recognizedWords;

            // Đánh giá phát âm dựa trên nhận dạng từ/câu
            if (recognized.contains(targetText) ||
                targetText.contains(recognized)) {
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
              // Từ/câu không được nhận dạng đúng
              pronunciationScore =
                  calculateSimilarityScore(targetText, recognized);
              assessmentFeedback = "Phát âm chưa chính xác. Hãy thử lại.";
            }
          });
        },
      );
    }
  }

  // Tính toán điểm tương đồng giữa hai chuỗi với phương pháp cải tiến cho câu dài
  double calculateSimilarityScore(String target, String actual) {
    if (actual.isEmpty) return 0;
    if (target == actual) return 100;

    // Tính số từ chung giữa target và actual
    List<String> targetWords = target.split(' ');
    List<String> actualWords = actual.split(' ');
    int commonWords = 0;

    for (String word in actualWords) {
      if (targetWords.contains(word)) {
        commonWords++;
      }
    }

    // Tính tỷ lệ từ chung
    double wordMatchRatio =
        targetWords.isEmpty ? 0 : (commonWords / targetWords.length);

    // Kiểm tra nếu actual chứa target
    if (actual.contains(target)) return 85;

    // Nếu target chứa actual (nhận dạng một phần của câu)
    if (target.contains(actual) && actual.length > 5) {
      return 65 + (actual.length / target.length * 15);
    }

    // Trả về điểm dựa trên tỷ lệ từ khớp
    return (wordMatchRatio * 75).clamp(0.0, 75.0);
  }

  // Dừng nghe
  void stopListening() {
    if (isListening) {
      setState(() => isListening = false);
      _animationController.stop(); // Dừng hiệu ứng animation
      speech.stop();
    }
  }

  // Đọc từ/câu bằng TTS
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

  // Chuyển sang từ tiếp theo và tính điểm
  void nextWord(List<SpeakingData> words, double pix) {
    // Lưu điểm của từ hiện tại nếu có
    if (pronunciationScore > 0) {
      wordScores.add(pronunciationScore);
    }

    setState(() {
      if (currentWordIndex < words.length - 1) {
        currentWordIndex++;
        recognizedText = "";
        pronunciationScore = 0.0;
        assessmentFeedback = "";
      } else {
        // Đã hoàn thành tất cả các từ
        completedExercise = true;

        // Tính điểm trung bình (nếu có ít nhất một điểm)
        if (wordScores.isNotEmpty) {
          double sum = wordScores.reduce((a, b) => a + b);
          averageAccuracy = sum / wordScores.length;
        }

        // Hiển thị dialog thông báo kết quả (tránh hiển thị nhiều lần)
        if (!showingDialog) {
          showingDialog = true;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            createResult(widget.exercise, pix);
          });
        }
      }
    });
  }

  Future<void> createResult(ExerciseModel exercise, double pix) async {
    setState(() {
      loading = true;
    });

    final exProvider = Provider.of<ExerciseProvider>(context, listen: false);
    bool res = await exProvider.createResult(
      exercise.id,
      (averageAccuracy / 10).round(),
    );

    if (res) {
      setState(() {
        loading = false;
      });
      _showCompletionDialog(context, pix);
    } else {
      setState(() {
        loading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Có lỗi xảy ra trong quá trình tạo kết quả."),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Hiển thị dialog kết quả cuối cùng
  void _showCompletionDialog(BuildContext context, double pix) {
    // Xác định màu dựa trên độ chính xác trung bình
    Color accuracyColor = Colors.red;
    String performanceText = "Cần cải thiện";

    if (averageAccuracy >= 80) {
      accuracyColor = Colors.green;
      performanceText = "Xuất sắc";
    } else if (averageAccuracy >= 60) {
      accuracyColor = Colors.orange;
      performanceText = "Khá tốt";
    }

    showDialog(
      context: context,
      barrierDismissible: false, // Ngăn chặn đóng dialog khi nhấn bên ngoài
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                averageAccuracy >= 80
                    ? Icons.emoji_events
                    : (averageAccuracy >= 60
                        ? Icons.thumb_up_alt
                        : Icons.history_edu),
                color: accuracyColor,
                size: 28,
              ),
              SizedBox(width: 10),
              Text(
                "Hoàn thành!",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.indigo,
                  fontFamily: 'BeVietnamPro',
                  fontSize: 20 * pix,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Độ chính xác trung bình:",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16 * pix,
                ),
              ),
              SizedBox(height: 16 * pix),
              Container(
                width: 150 * pix,
                height: 150 * pix,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.indigo.shade50,
                  border: Border.all(
                    color: accuracyColor,
                    width: 8,
                  ),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "${averageAccuracy.toStringAsFixed(1)}%",
                        style: TextStyle(
                          fontSize: 30 * pix,
                          fontWeight: FontWeight.bold,
                          color: accuracyColor,
                        ),
                      ),
                      Text(
                        performanceText,
                        style: TextStyle(
                          fontSize: 14 * pix,
                          color: Colors.black87,
                          fontFamily: 'BeVietnamPro',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20),
              Text(
                _getPerformanceFeedback(averageAccuracy),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontStyle: FontStyle.italic,
                  fontSize: 14 * pix,
                  fontFamily: 'BeVietnamPro',
                ),
              ),
            ],
          ),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(context).pop(); // Đóng dialog

                    // Reset lại bài tập
                    setState(() {
                      currentWordIndex = 0;
                      wordScores.clear();
                      averageAccuracy = 0.0;
                      completedExercise = false;
                      showingDialog = false;
                      recognizedText = "";
                      pronunciationScore = 0.0;
                      assessmentFeedback = "";
                    });
                  },
                  icon: Icon(Icons.replay),
                  label: Text("Làm lại"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  ),
                ),
                SizedBox(width: 10),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).pop();
                  },
                  icon: Icon(Icons.exit_to_app),
                  label: Text("Thoát"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber,
                    foregroundColor: Colors.black87,
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  ),
                ),
              ],
            ),
          ],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          elevation: 10,
        );
      },
    );
  }

  // Phản hồi dựa trên độ chính xác
  String _getPerformanceFeedback(double accuracy) {
    if (accuracy >= 90) {
      return "Tuyệt vời! Phát âm của bạn rất chuẩn xác.";
    } else if (accuracy >= 80) {
      return "Rất tốt! Bạn đã phát âm chính xác hầu hết các từ.";
    } else if (accuracy >= 70) {
      return "Khá tốt! Tiếp tục luyện tập để hoàn thiện hơn.";
    } else if (accuracy >= 60) {
      return "Tạm được. Hãy chú ý đến việc phát âm rõ ràng hơn.";
    } else if (accuracy >= 50) {
      return "Cần cải thiện thêm. Hãy tập trung vào nghe và bắt chước.";
    } else {
      return "Hãy tiếp tục luyện tập. Nghe và lặp lại nhiều lần sẽ giúp bạn cải thiện.";
    }
  }

  // Lấy màu dựa trên độ chính xác
  Color getAccuracyColor() {
    if (pronunciationScore >= 80) return Colors.green;
    if (pronunciationScore >= 50) return Colors.orange;
    return Colors.red;
  }

  // Tính toán kích thước font dựa trên độ dài của câu
  double calculateFontSize(String text, double basePix) {
    int length = text.length;
    if (length <= 10) return 36 * basePix;
    if (length <= 20) return 32 * basePix;
    if (length <= 40) return 28 * basePix;
    if (length <= 60) return 24 * basePix;
    if (length <= 80) return 22 * basePix;
    return 20 * basePix; // Cho câu rất dài
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
              child: TopBar(title: widget.exercise.name, isBack: true),
            ),
            Positioned(
              top: 100 * pix,
              left: 0,
              right: 0,
              bottom: 0,
              child: Consumer<ExerciseProvider>(
                  builder: (context, exerciseProvider, child) {
                // Kiểm tra xem đã fetch exercise thành công chưa
                if (exerciseProvider.isLoading) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }

                final words = exerciseProvider.speakingDataModel?.data ?? [];

                // Kiểm tra nếu không có dữ liệu
                if (words.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.warning_amber_rounded,
                          size: 80,
                          color: Colors.amber,
                        ),
                        SizedBox(height: 16 * pix),
                        Text(
                          "Không tìm thấy dữ liệu luyện phát âm cho bài tập này",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade700,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 20),
                        ElevatedButton.icon(
                          onPressed: () {
                            // Thử tải lại dữ liệu
                            Provider.of<ExerciseProvider>(context,
                                    listen: false)
                                .fetchSpeaking(widget.exercise.id);
                          },
                          icon: Icon(Icons.refresh),
                          label: Text("Thử lại"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.indigo,
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(
                                horizontal: 30 * pix, vertical: 15 * pix),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30)),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                // Tính font size dựa trên độ dài của câu hiện tại
                final currentText = words[currentWordIndex].sentence;
                final dynamicFontSize = calculateFontSize(currentText, pix);

                return Padding(
                  padding: EdgeInsets.all(16 * pix),
                  child: SingleChildScrollView(
                    controller: _scrollController,
                    child: Column(
                      children: [
                        // Thẻ từ/câu cần phát âm
                        Card(
                          elevation: 8,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15)),
                          child: Container(
                            width: double.infinity,
                            padding: EdgeInsets.all(12 * pix),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: double.infinity,
                                  padding: EdgeInsets.all(12 * pix),
                                  decoration: BoxDecoration(
                                    color: Colors.indigo.withOpacity(0.05),
                                    borderRadius:
                                        BorderRadius.circular(10 * pix),
                                    border: Border.all(
                                      color: Colors.indigo.withOpacity(0.2),
                                      width: 1,
                                    ),
                                  ),
                                  child: Text(
                                    currentText,
                                    style: TextStyle(
                                      fontSize: dynamicFontSize,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.indigo,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                SizedBox(height: 16 * pix),
                                // Hiển thị bản dịch tiếng Việt
                                Text(
                                  "Nghĩa: ${words[currentWordIndex].translation}",
                                  style: TextStyle(
                                    fontSize: 16 * pix,
                                    fontStyle: FontStyle.italic,
                                    color: Colors.grey.shade700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        SizedBox(height: 16 * pix),

                        // Nút nghe từ
                        ElevatedButton.icon(
                          onPressed: () =>
                              speak(words[currentWordIndex].sentence),
                          icon: Icon(Icons.volume_up, size: 28),
                          label:
                              Text("Nghe mẫu", style: TextStyle(fontSize: 18)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.indigo,
                            padding: EdgeInsets.symmetric(
                                horizontal: 40, vertical: 15),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30)),
                          ),
                        ),

                        SizedBox(height: 16 * pix),

                        // Nút thu âm
                        _isMicrophonePermissionGranted && _isSpeechInitialized
                            ? AnimatedBuilder(
                                animation: _animationController,
                                builder: (context, child) {
                                  return ElevatedButton.icon(
                                    onPressed: isListening
                                        ? stopListening
                                        : () => startListening(
                                            words[currentWordIndex].sentence),
                                    icon: Icon(
                                      isListening ? Icons.stop : Icons.mic,
                                      size: isListening
                                          ? 28 +
                                              (_animationController.value * 5)
                                          : 28,
                                      color: isListening
                                          ? Colors.red
                                          : Colors.white,
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
                                "Nhận diện giọng nói không khả dụng hoặc cần quyền truy cập!",
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.red,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),

                        SizedBox(height: 16 * pix),

                        // Kết quả nhận diện trong một thẻ
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(20 * pix),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.9),
                            borderRadius: BorderRadius.circular(15 * pix),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 10,
                                offset: Offset(0, 5),
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                "Kết quả",
                                style: TextStyle(
                                  fontSize: 18 * pix,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey.shade700,
                                ),
                              ),
                              SizedBox(height: 10 * pix),

                              // Kết quả nhận dạng với container có chiều cao cố định và khả năng cuộn
                              Container(
                                height: 100 * pix, // Chiều cao cố định
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(10 * pix),
                                  border: Border.all(
                                    color: Colors.grey.shade300,
                                  ),
                                ),
                                padding: EdgeInsets.all(8 * pix),
                                child: SingleChildScrollView(
                                  child: Text(
                                    recognizedText.isEmpty
                                        ? "Chưa có ghi âm"
                                        : recognizedText,
                                    style: TextStyle(
                                      fontSize: 18 * pix,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(height: 15 * pix),
                              pronunciationScore > 0
                                  ? Column(
                                      children: [
                                        // Điểm số với hiệu ứng tốt hơn
                                        Container(
                                          width: double.infinity,
                                          height: 16 * pix,
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(8 * pix),
                                            color: Colors.grey.shade200,
                                          ),
                                          child: Stack(
                                            children: [
                                              FractionallySizedBox(
                                                widthFactor:
                                                    pronunciationScore / 100,
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8 * pix),
                                                    gradient: LinearGradient(
                                                      colors: [
                                                        getAccuracyColor()
                                                            .withOpacity(0.7),
                                                        getAccuracyColor(),
                                                      ],
                                                      begin:
                                                          Alignment.centerLeft,
                                                      end:
                                                          Alignment.centerRight,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        SizedBox(height: 8 * pix),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              "Độ chính xác: ",
                                              style: TextStyle(
                                                fontSize: 16 * pix,
                                                fontWeight: FontWeight.w500,
                                                color: Colors.grey.shade800,
                                              ),
                                            ),
                                            Text(
                                              "${pronunciationScore.toStringAsFixed(1)}%",
                                              style: TextStyle(
                                                fontSize: 18 * pix,
                                                fontWeight: FontWeight.bold,
                                                color: getAccuracyColor(),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    )
                                  : SizedBox(),
                              SizedBox(height: 10 * pix),
                              // Phản hồi với hiệu ứng tốt hơn
                              assessmentFeedback.isNotEmpty
                                  ? Container(
                                      padding: EdgeInsets.all(10 * pix),
                                      decoration: BoxDecoration(
                                        color: pronunciationScore >= 80
                                            ? Colors.green.withOpacity(0.1)
                                            : pronunciationScore >= 60
                                                ? Colors.orange.withOpacity(0.1)
                                                : Colors.red.withOpacity(0.1),
                                        borderRadius:
                                            BorderRadius.circular(8 * pix),
                                        border: Border.all(
                                          color: pronunciationScore >= 80
                                              ? Colors.green.withOpacity(0.3)
                                              : pronunciationScore >= 60
                                                  ? Colors.orange
                                                      .withOpacity(0.3)
                                                  : Colors.red.withOpacity(0.3),
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(
                                            pronunciationScore >= 80
                                                ? Icons.check_circle
                                                : pronunciationScore >= 60
                                                    ? Icons.info
                                                    : Icons.error,
                                            color: pronunciationScore >= 80
                                                ? Colors.green
                                                : pronunciationScore >= 60
                                                    ? Colors.orange
                                                    : Colors.red,
                                          ),
                                          SizedBox(width: 8 * pix),
                                          Expanded(
                                            child: Text(
                                              assessmentFeedback,
                                              style: TextStyle(
                                                fontSize: 16 * pix,
                                                fontStyle: FontStyle.italic,
                                                color: pronunciationScore >= 80
                                                    ? Colors.green.shade800
                                                    : pronunciationScore >= 60
                                                        ? Colors.orange.shade800
                                                        : Colors.red.shade800,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                                  : SizedBox(),
                            ],
                          ),
                        ),

                        SizedBox(height: 16 * pix),

                        // Hiển thị tiến trình với thiết kế đẹp hơn
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 16 * pix,
                            vertical: 8 * pix,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.8),
                            borderRadius: BorderRadius.circular(30 * pix),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 5,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                "Tiến trình: ",
                                style: TextStyle(
                                  fontSize: 16 * pix,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.grey.shade700,
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 10 * pix,
                                  vertical: 4 * pix,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.indigo.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(15 * pix),
                                ),
                                child: Text(
                                  "${currentWordIndex + 1}/${words.length}",
                                  style: TextStyle(
                                    fontSize: 16 * pix,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.indigo,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        SizedBox(height: 16 * pix),

                        // Nút chuyển sang từ tiếp theo hoặc hoàn thành
                        ElevatedButton.icon(
                          onPressed: () => nextWord(words, pix),
                          icon: Icon(currentWordIndex == words.length - 1
                              ? Icons.check_circle
                              : Icons.arrow_forward),
                          label: Text(
                              currentWordIndex == words.length - 1
                                  ? "Hoàn thành"
                                  : "Từ tiếp theo",
                              style: TextStyle(fontSize: 18)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                currentWordIndex == words.length - 1
                                    ? Colors.green
                                    : Colors.amber,
                            foregroundColor:
                                currentWordIndex == words.length - 1
                                    ? Colors.white
                                    : Colors.black87,
                            padding: EdgeInsets.symmetric(
                                horizontal: 40, vertical: 15),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30)),
                            elevation: 4,
                          ),
                        ),
                        SizedBox(
                            height: 32 *
                                pix), // Khoảng trống dưới cùng để tránh bị che khuất
                      ],
                    ),
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
