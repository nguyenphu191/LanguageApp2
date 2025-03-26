import 'package:flutter/material.dart';
import 'package:language_app/PhuNV/VocabularyScreen.dart';
import 'package:language_app/models/TopicModel.dart';
import 'package:language_app/res/imagesLA/AppImages.dart';

class Topicwidget extends StatefulWidget {
  const Topicwidget({super.key, required this.topic});
  final Topicmodel topic;

  @override
  State<Topicwidget> createState() => _TopicwidgetState();
}

class _TopicwidgetState extends State<Topicwidget> {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final pix = size.width / 375;
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 8 * pix, vertical: 4 * pix),
      width: 180 * pix,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24 * pix),
        boxShadow: [
          BoxShadow(
            color: const Color.fromARGB(255, 35, 0, 189).withOpacity(0.2),
            offset: const Offset(0, 5),
            blurRadius: 10,
          ),
        ],
        border: Border.all(
          width: 0.5 * pix,
          color: const Color.fromARGB(255, 52, 194, 255),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(24 * pix),
                topRight: Radius.circular(24 * pix),
              ),
              child: Stack(
                children: [
                  Container(
                    height: 136 * pix,
                    width: 180 * pix,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage(widget.topic.image),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Positioned(
                    top: 10 * pix,
                    right: 10 * pix,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 8 * pix,
                        vertical: 4 * pix,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.8),
                        borderRadius: BorderRadius.circular(12 * pix),
                      ),
                      child: Text(
                        '${widget.topic.numbervocabulary} từ',
                        style: TextStyle(
                          fontSize: 12 * pix,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xff165598),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.only(
                left: 16 * pix,
                right: 16 * pix,
                top: 8 * pix,
                bottom: 8 * pix,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.topic.topic,
                    style: TextStyle(
                      fontSize: 18 * pix,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'BeVietnamPro',
                      color: const Color(0xff165598),
                    ),
                  ),
                  SizedBox(height: 5 * pix),
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8 * pix,
                          vertical: 4 * pix,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xff4F46E5).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8 * pix),
                        ),
                        child: Text(
                          widget.topic.description,
                          style: TextStyle(
                            fontSize: 12 * pix,
                            fontFamily: 'BeVietnamPro',
                            color: const Color(0xff4F46E5),
                          ),
                        ),
                      ),
                      Spacer(),
                      InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => Vocabularyscreen(
                                title: widget.topic.topic,
                              ),
                            ),
                          );
                        },
                        child: Container(
                          height: 30 * pix,
                          width: 30 * pix,
                          decoration: BoxDecoration(
                            color: const Color(0xff4F46E5),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.arrow_forward_rounded,
                            color: Colors.white,
                            size: 18 * pix,
                          ),
                        ),
                      ),
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
