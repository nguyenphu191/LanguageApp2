import 'package:flutter/material.dart';
import 'package:language_app/LoginSignup/SelectLanguage/SelectLanguageScreen.dart';
import 'package:language_app/res/imagesLA/AppImages.dart';

class Start1screen extends StatefulWidget {
  const Start1screen({super.key});

  @override
  State<Start1screen> createState() => _Start1screenState();
}

class _Start1screenState extends State<Start1screen> {
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
                      '',
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
            Center(
              child: Container(
                width: 240 * pix,
                height: 229 * pix,
                margin: EdgeInsets.only(top: 20 * pix, left: 20 * pix),
                padding: EdgeInsets.all(10 * pix),
                child: Image.asset(AppImages.personlearn3),
              ),
            ),
            SizedBox(
              height: 150 * pix,
            ),
            Center(
              child: Text(
                'Tự tin vào ngôn ngữ giao tiếp',
                style: TextStyle(
                    fontSize: 18 * pix,
                    fontFamily: 'BeVietnamPro',
                    fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(
              height: 100 * pix,
            ),
            Padding(
              padding: EdgeInsets.all(16 * pix),
              child: InkWell(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => SelectLanguescreen()));
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
                  child: Text('Chọn ngôn ngữ muốn học',
                      style: TextStyle(
                          fontSize: 20 * pix,
                          fontFamily: 'BeVietnamPro',
                          fontWeight: FontWeight.w500,
                          color: Colors.white),
                      textAlign: TextAlign.center),
                ),
              ),
            ),
            SizedBox(
              height: 10 * pix,
            ),
          ],
        ),
      ),
    );
  }
}
