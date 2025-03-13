import 'package:flutter/material.dart';
import 'package:language_app/LoginSignup/SelectLanguage/Start2Screen.dart';
import 'package:language_app/res/imagesLA/AppImages.dart';

class SelectLanguescreen extends StatefulWidget {
  const SelectLanguescreen({super.key});

  @override
  State<SelectLanguescreen> createState() => _SelectLanguescreenState();
}

class _SelectLanguescreenState extends State<SelectLanguescreen> {
  List<Map<String, String>> _listLanguages = [
    {'img': AppImages.coviet, "title": 'Tiếng Việt'},
    {'img': AppImages.comy, "title": 'Tiếng Anh'},
    {'img': AppImages.cohan, "title": 'Tiếng Hàn'},
    {'img': AppImages.cotrung, "title": 'Tiếng Trung'},
    {'img': AppImages.cophap, "title": 'Tiếng Pháp'},
    {'img': AppImages.coviet, "title": 'Tiếng Việt'},
    {'img': AppImages.comy, "title": 'Tiếng Anh'},
    {'img': AppImages.cohan, "title": 'Tiếng Hàn'},
    {'img': AppImages.cotrung, "title": 'Tiếng Trung'},
    {'img': AppImages.cophap, "title": 'Tiếng Pháp'},
    {'img': AppImages.coviet, "title": 'Tiếng Việt'},
    {'img': AppImages.comy, "title": 'Tiếng Anh'},
    {'img': AppImages.cohan, "title": 'Tiếng Hàn'},
    {'img': AppImages.cotrung, "title": 'Tiếng Trung'},
    {'img': AppImages.cophap, "title": 'Tiếng Pháp'},
  ];
  int _selected = 0;
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
                      'Chọn ngôn ngữ',
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
              height: size.height - 100 * pix,
              width: size.width,
              child: Stack(
                children: [
                  Container(
                    height: size.height - 100 * pix,
                    width: size.width,
                    padding: EdgeInsets.only(top: 20 * pix),
                    child: ListView.builder(
                      itemCount: _listLanguages.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: EdgeInsets.only(
                              bottom: 16 * pix,
                              left: 24 * pix,
                              right: 24 * pix),
                          child: InkWell(
                            onTap: () {
                              setState(() {
                                _selected = index;
                              });
                            },
                            child: Container(
                              width: 327 * pix,
                              height: 62 * pix,
                              padding: EdgeInsets.all(5 * pix),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(50),
                                color: _selected == index
                                    ? Color(0xff40CEB6)
                                    : Colors.grey[300],
                              ),
                              child: Row(
                                children: [
                                  Container(
                                      height: 52 * pix,
                                      width: 52 * pix,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(50),
                                      ),
                                      child: Image.asset(
                                        _listLanguages[index]['img']!,
                                        height: 52 * pix,
                                        width: 52 * pix,
                                      )),
                                  Container(
                                    height: 52 * pix,
                                    width: 250 * pix,
                                    padding: EdgeInsets.only(top: 10 * pix),
                                    child: Text(
                                      _listLanguages[index]['title']!,
                                      style: TextStyle(
                                          color: const Color.fromARGB(
                                              255, 0, 0, 0),
                                          fontSize: 18 * pix,
                                          fontWeight: FontWeight.bold,
                                          fontFamily: 'BeVietnamPro'),
                                      textAlign: TextAlign.center,
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  Positioned(
                    bottom: 80 * pix,
                    left: 16 * pix,
                    right: 16 * pix,
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => Start2screen()));
                      },
                      child: Container(
                        width: size.width,
                        height: 56 * pix,
                        padding: EdgeInsets.only(
                            left: 16 * pix, right: 16 * pix, top: 12 * pix),
                        decoration: BoxDecoration(
                          color: Color(0xff5B7BFE),
                          borderRadius: BorderRadius.circular(16 * pix),
                        ),
                        child: Text('Tiếp tục',
                            style: TextStyle(
                                fontSize: 20 * pix,
                                fontFamily: 'BeVietnamPro',
                                fontWeight: FontWeight.w500,
                                color: Colors.white),
                            textAlign: TextAlign.center),
                      ),
                    ),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
