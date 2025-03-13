import 'package:flutter/material.dart';
import 'package:language_app/LoginSignup/LoginScreen.dart';
import 'package:language_app/LoginSignup/SignupScreen2.dart';
import 'package:language_app/res/imagesLA/AppImages.dart';

class Signupscreen extends StatefulWidget {
  const Signupscreen({super.key});

  @override
  State<Signupscreen> createState() => _SignupscreenState();
}

class _SignupscreenState extends State<Signupscreen> {
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
                      'Đăng ký',
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
              child: Column(
                children: [
                  Container(
                    width: 105 * pix,
                    height: 82 * pix,
                    padding: EdgeInsets.all(10 * pix),
                    child: Image.asset(AppImages.learnhome),
                  ),
                  Container(
                    width: size.width,
                    height: 70 * pix,
                    padding: EdgeInsets.only(top: 10 * pix),
                    child: Text(
                      'Bắt đầu học ngay thôi nào!',
                      style: TextStyle(
                          fontSize: 22 * pix,
                          fontFamily: 'BeVietnamPro',
                          fontWeight: FontWeight.bold,
                          color: Colors.black),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: size.width,
              height: 20 * pix,
              padding: EdgeInsets.only(left: 16 * pix, right: 20 * pix),
              margin: EdgeInsets.only(bottom: 5 * pix),
              child: Text(
                'Họ và tên đệm',
                style: TextStyle(
                    fontSize: 14 * pix,
                    fontFamily: 'BeVietnamPro',
                    color: Colors.black),
                textAlign: TextAlign.left,
              ),
            ),
            Container(
              width: size.width,
              height: 56 * pix,
              margin: EdgeInsets.only(left: 16 * pix, right: 16 * pix),
              padding: EdgeInsets.only(left: 16 * pix),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(16 * pix),
              ),
              child: TextField(
                  decoration: InputDecoration(
                labelText: 'Nhập họ của bạn',
                labelStyle: TextStyle(
                    fontSize: 14 * pix,
                    fontFamily: 'BeVietnamPro',
                    color: Colors.grey),
                border: InputBorder.none,
              )),
            ),
            SizedBox(
              height: 16 * pix,
            ),
            Container(
              width: size.width,
              height: 20 * pix,
              padding: EdgeInsets.only(left: 16 * pix, right: 20 * pix),
              margin: EdgeInsets.only(bottom: 5 * pix),
              child: Text(
                'Tên',
                style: TextStyle(
                    fontSize: 14 * pix,
                    fontFamily: 'BeVietnamPro',
                    color: Colors.black),
                textAlign: TextAlign.left,
              ),
            ),
            Container(
              width: size.width,
              height: 56 * pix,
              margin: EdgeInsets.only(left: 16 * pix, right: 16 * pix),
              padding: EdgeInsets.only(left: 16 * pix),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(16 * pix),
              ),
              child: TextField(
                  decoration: InputDecoration(
                labelText: 'Nhập tên của bạn',
                labelStyle: TextStyle(
                    fontSize: 14 * pix,
                    fontFamily: 'BeVietnamPro',
                    color: Colors.grey),
                border: InputBorder.none,
              )),
            ),
            SizedBox(
              height: 16 * pix,
            ),
            Container(
              width: size.width,
              height: 20 * pix,
              padding: EdgeInsets.only(left: 16 * pix, right: 20 * pix),
              margin: EdgeInsets.only(bottom: 5 * pix),
              child: Text(
                'Email',
                style: TextStyle(
                    fontSize: 14 * pix,
                    fontFamily: 'BeVietnamPro',
                    color: Colors.black),
                textAlign: TextAlign.left,
              ),
            ),
            Container(
              width: size.width,
              height: 56 * pix,
              margin: EdgeInsets.only(left: 16 * pix, right: 16 * pix),
              padding: EdgeInsets.only(left: 16 * pix),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(16 * pix),
              ),
              child: TextField(
                  decoration: InputDecoration(
                labelText: 'Nhập email của bạn',
                labelStyle: TextStyle(
                    fontSize: 14 * pix,
                    fontFamily: 'BeVietnamPro',
                    color: Colors.grey),
                border: InputBorder.none,
              )),
            ),
            SizedBox(
              height: 69 * pix,
            ),
            Padding(
              padding: EdgeInsets.all(16 * pix),
              child: InkWell(
                onTap: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => Signupscreen2()));
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
            ),
            SizedBox(
              height: 10 * pix,
            ),
            Container(
              width: size.width,
              height: 20 * pix,
              padding: EdgeInsets.only(left: 16 * pix, right: 16 * pix),
              child: Text('Or',
                  style: TextStyle(
                      fontSize: 14 * pix,
                      fontFamily: 'BeVietnamPro',
                      color: Colors.black),
                  textAlign: TextAlign.center),
            ),
            Container(
              width: size.width,
              height: 56 * pix,
              padding: EdgeInsets.only(
                  left: 66 * pix, right: 16 * pix, top: 12 * pix),
              child: Row(
                children: [
                  Text('Bạn đã có tài khoản?',
                      style: TextStyle(
                          fontSize: 14 * pix,
                          fontFamily: 'BeVietnamPro',
                          color: Colors.black),
                      textAlign: TextAlign.center),
                  InkWell(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => Loginscreen()));
                    },
                    child: Text(' Đăng nhập',
                        style: TextStyle(
                            fontSize: 14 * pix,
                            fontFamily: 'BeVietnamPro',
                            color: Color(0xff5B7BFE)),
                        textAlign: TextAlign.center),
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
