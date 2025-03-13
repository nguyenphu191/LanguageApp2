import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:language_app/res/imagesLA/AppImages.dart';
import 'package:http/http.dart' as http;

class Vocabularyscreen extends StatefulWidget {
  const Vocabularyscreen({super.key, required this.title});
  final String title;

  @override
  State<Vocabularyscreen> createState() => _VocabularyscreenState();
}

class _VocabularyscreenState extends State<Vocabularyscreen> {
  PageController _pageController = PageController();
  int _currentIndex = 0;
  bool _isFlipped = false;

  final List<Map<String, String>> cards = [
    {
      "front": "Lion",
      "back": "Sư tử",
      "image": AppImages.lion,
      "desc": "The Lion is the forest king",
      "meaning": "Con sư tử là vua rừng"
    },
    {
      "front": "Tiger",
      "back": "Hổ",
      "image": AppImages.lion,
      "desc": "The tiger is strong",
      "meaning": "Con hổ rất mạnh"
    },
    {
      "front": "Elephant",
      "back": "Voi",
      "image": AppImages.lion,
      "desc": "The elephant is big",
      "meaning": "Con voi rất to"
    },
  ];

  void _flipCard() {
    setState(() {
      _isFlipped = !_isFlipped;
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final pix = size.width / 375;
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              height: 100 * pix,
              width: size.width,
              color: Color(0xff43AAFF),
              child: Row(
                children: [
                  Container(
                    width: pix * 50,
                    margin: EdgeInsets.only(top: 16 * pix),
                    child: IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: Icon(
                        Icons.arrow_back_ios,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  Container(
                    width: size.width - 100 * pix,
                    height: 80 * pix,
                    padding: EdgeInsets.only(top: 30 * pix),
                    child: Text(
                      'Chủ đề ${widget.title}',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 24 * pix,
                          fontWeight: FontWeight.w500,
                          fontFamily: 'BeVietnamPro'),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              height: 542 * pix,
              width: 340 * pix,
              child: PageView.builder(
                controller: _pageController,
                itemCount: cards.length,
                onPageChanged: (index) {
                  setState(() {
                    if (index >= cards.length) {
                      _pageController.jumpToPage(0); // Quay lại thẻ đầu tiên
                    } else if (index < 0) {
                      _pageController.jumpToPage(
                          cards.length - 1); // Quay lại thẻ cuối cùng
                    } else {
                      _currentIndex = index;
                    }
                    _isFlipped = false; // Reset trạng thái lật thẻ
                  });
                },
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: _flipCard,
                    child: AnimatedSwitcher(
                      duration: Duration(milliseconds: 500),
                      transitionBuilder:
                          (Widget child, Animation<double> animation) {
                        final rotate =
                            Tween(begin: 1.0, end: 0.0).animate(animation);
                        return RotationYTransition(turns: rotate, child: child);
                      },
                      child: _isFlipped
                          ? FlashCard(
                              key: ValueKey('back'),
                              title: cards[index]['back']!,
                              description: cards[index]['meaning']!,
                              image: cards[index]['image']!,
                              isFlipped: _isFlipped,
                            )
                          : FlashCard(
                              key: ValueKey('front'),
                              title: cards[index]['front']!,
                              description: cards[index]['desc']!,
                              image: cards[index]['image']!,
                              isFlipped: _isFlipped,
                            ),
                    ),
                  );
                },
              ),
            ),
            Container(
              width: size.width,
              height: 110 * pix,
              padding: EdgeInsets.all(16),
              margin: EdgeInsets.only(top: 10 * pix),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Row(
                    children: [
                      Image.asset(AppImages.iconsend, width: 24, height: 24),
                      SizedBox(width: 10 * pix),
                      Text("Ấn vào thẻ để xem nghĩa",
                          style: TextStyle(
                              fontSize: 16 * pix,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'BeVietnamPro')),
                    ],
                  ),
                  Row(
                    children: [
                      Image.asset(AppImages.iconsend, width: 24, height: 24),
                      SizedBox(width: 10 * pix),
                      Text("Vuốt trái cho thẻ tiếp theo",
                          style: TextStyle(
                              fontSize: 16 * pix,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'BeVietnamPro')),
                    ],
                  ),
                  Row(
                    children: [
                      Image.asset(AppImages.iconsend, width: 24, height: 24),
                      SizedBox(width: 10 * pix),
                      Text("Vuốt phải để quay lại thẻ trước",
                          style: TextStyle(
                              fontSize: 16 * pix,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'BeVietnamPro')),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class FlashCard extends StatelessWidget {
  final String title;
  final String description;
  final String image;
  final bool isFlipped;
  final AudioPlayer _audioPlayer = AudioPlayer(); // Khởi tạo AudioPlayer

  FlashCard({
    Key? key,
    required this.title,
    required this.description,
    required this.image,
    required this.isFlipped,
  }) : super(key: key);

  void _playAudio(String mes) async {
    final audioPlayer = AudioPlayer(); // Tạo AudioPlayer mới mỗi lần phát
    final url = isFlipped
        ? "https://translate.google.com/translate_tts?ie=UTF-8&tl=vi&client=tw-ob&q=$mes"
        : 'https://translate.google.com/translate_tts?ie=UTF-8&tl=en&client=tw-ob&q=$mes';

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'User-Agent':
              'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
        },
      );

      if (response.statusCode == 200) {
        await audioPlayer.play(BytesSource(response.bodyBytes));
      } else {
        print("Failed to fetch audio: ${response.statusCode}");
      }
    } catch (e) {
      print("Error fetching audio: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final pix = size.width / 375;
    return Container(
      height: 542 * pix,
      width: 340 * pix,
      margin: EdgeInsets.only(top: 20 * pix),
      padding: EdgeInsets.only(top: 20 * pix),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16 * pix),
        gradient: LinearGradient(
          colors: [
            isFlipped ? Color(0xff5053FF) : Color(0xffFFD2BF),
            isFlipped ? Color(0xffFFD2BF) : Color(0xff5053FF),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            offset: Offset(0, 5),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        children: [
          Text(title,
              style: TextStyle(
                  fontSize: 40 * pix,
                  fontFamily: 'BeVietnamPro',
                  fontWeight: FontWeight.bold,
                  color: Colors.white)),
          SizedBox(height: 10 * pix),
          Image.asset(image, width: 320, height: 253),
          SizedBox(height: 38 * pix),
          InkWell(
              onTap: () {
                _playAudio(title);
              },
              child: Icon(Icons.volume_up, color: Colors.white, size: 56)),
          SizedBox(height: 16 * pix),
          Container(
            height: 80 * pix,
            padding: EdgeInsets.only(left: 16 * pix, right: 16 * pix),
            width: double.maxFinite,
            child: Row(
              children: [
                Container(
                  width: 260 * pix,
                  child: Text(description,
                      style:
                          TextStyle(fontSize: 20 * pix, color: Colors.white)),
                ),
                Spacer(),
                InkWell(
                    onTap: () {
                      _playAudio(description);
                    },
                    child:
                        Icon(Icons.volume_up, color: Colors.white, size: 36)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class RotationYTransition extends StatelessWidget {
  final Animation<double> turns;
  final Widget child;

  RotationYTransition({required this.turns, required this.child});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: turns,
      child: child,
      builder: (context, child) {
        final double angle = turns.value * 3.1416;
        return Transform(
          transform: Matrix4.rotationY(angle),
          alignment: Alignment.center,
          child: child,
        );
      },
    );
  }
}
