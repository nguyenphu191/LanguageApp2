import 'package:flutter/material.dart';
import 'package:language_app/res/imagesLA/AppImages.dart';

class Topicwidget extends StatefulWidget {
  const Topicwidget({
    super.key,
    required this.title,
    required this.image,
    this.color1 = const Color(0xff43AAFF),
    this.color2 = const Color(0xff1A73E8),
    required this.onTap,
  });
  final String title;
  final String image;
  final Color color1;
  final Color color2;
  final VoidCallback onTap;

  @override
  State<Topicwidget> createState() => _TopicwidgetState();
}

class _TopicwidgetState extends State<Topicwidget> {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final pix = size.width / 375;
    return InkWell(
      onTap: widget.onTap,
      child: Container(
        height: 208 * pix,
        width: 145 * pix,
        margin: EdgeInsets.all(10 * pix),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16 * pix),
            gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [widget.color1, widget.color2])),
        child: Stack(
          children: [
            Positioned(
              top: 20 * pix,
              left: 10 * pix,
              right: 10 * pix,
              child: Image.asset(widget.image,
                  height: 125 * pix, width: 125 * pix, fit: BoxFit.cover),
            ),
            Positioned(
              top: 0 * pix,
              child: Image.asset(AppImages.flashdown,
                  width: 125 * pix, fit: BoxFit.cover),
            ),
            Positioned(
              bottom: 20 * pix,
              left: pix * 10,
              child: Text(
                widget.title,
                style: TextStyle(
                    fontSize: 16 * pix,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'BeVietnamPro',
                    color: Colors.white),
              ),
            )
          ],
        ),
      ),
    );
  }
}
