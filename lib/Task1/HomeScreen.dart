import 'package:flutter/material.dart';
import 'package:language_app/Task1/VocabularyScreen.dart';
import 'package:language_app/Task1/widget/TopicWidget.dart';
import 'package:language_app/models/TopicModel.dart';
import 'package:language_app/res/imagesLA/AppImages.dart';
import 'package:language_app/widget/BottomBar.dart';

class Homescreen extends StatefulWidget {
  const Homescreen({super.key});

  @override
  State<Homescreen> createState() => _HomescreenState();
}

class _HomescreenState extends State<Homescreen> {
  List<Topicmodel> _list = [
    Topicmodel(
      id: '1',
      topic: 'English',
      image: AppImages.animal,
      numbervocabulary: 50,
      description: 'normal',
    ),
    Topicmodel(
      id: '2',
      topic: 'Math',
      image: AppImages.family,
      numbervocabulary: 50,
      description: 'normal',
    ),
    Topicmodel(
      id: '3',
      topic: 'Science',
      image: AppImages.animal,
      numbervocabulary: 50,
      description: 'normal',
    ),
    Topicmodel(
      id: '4',
      topic: 'History',
      image: AppImages.family,
      numbervocabulary: 50,
      description: 'normal',
    ),
    Topicmodel(
      id: '5',
      topic: 'Geography',
      image: AppImages.animal,
      numbervocabulary: 50,
      description: 'normal',
    ),
  ];
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final pix = size.width / 375;
    return Stack(
      children: [
        Scaffold(
          body: SingleChildScrollView(
            child: Column(
              children: [
                Container(
                    height: 192 * pix,
                    width: size.width,
                    color: Color(0xff43AAFF),
                    child: Column(
                      children: [
                        Container(
                          height: 31 * pix,
                          width: size.width,
                          alignment: Alignment.topRight,
                          margin: EdgeInsets.only(top: 30 * pix),
                          padding: EdgeInsets.only(right: 10 * pix),
                          child: IconButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            icon: Icon(
                              Icons.notifications,
                              color: Colors.white,
                              size: 30 * pix,
                            ),
                          ),
                        ),
                        Container(
                          height: 72 * pix,
                          width: size.width,
                          padding:
                              EdgeInsets.only(left: 20 * pix, right: 20 * pix),
                          child: Row(
                            children: [
                              Container(
                                height: 72 * pix,
                                width: 72 * pix,
                                decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                        color: const Color.fromARGB(
                                            255, 120, 120, 120),
                                        width: 1 * pix),
                                    image: DecorationImage(
                                        image:
                                            AssetImage(AppImages.personlearn4),
                                        fit: BoxFit.cover)),
                              ),
                              Container(
                                height: 72 * pix,
                                width: size.width - 120 * pix,
                                padding: EdgeInsets.only(
                                    left: 16 * pix, top: 16 * pix),
                                child: Text(
                                  'Duong Quoc Hoang',
                                  style: TextStyle(
                                      fontSize: 24 * pix,
                                      fontWeight: FontWeight.w500,
                                      fontFamily: 'BeVietnamPro',
                                      color: Colors.white),
                                  textAlign: TextAlign.left,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              )
                            ],
                          ),
                        ),
                        Container(
                          height: 10 * pix,
                        ),
                        Container(
                          height: 30 * pix,
                          width: size.width,
                          padding: EdgeInsets.only(left: 20 * pix),
                          child: Text(
                            'Chúc bạn 1 ngày tốt lành!',
                            style: TextStyle(
                                fontSize: 16 * pix,
                                fontWeight: FontWeight.normal,
                                fontFamily: 'BeVietnamPro',
                                color: Colors.white),
                            textAlign: TextAlign.left,
                          ),
                        )
                      ],
                    )),
                Container(
                  height: 55 * pix,
                  width: size.width,
                  margin: EdgeInsets.only(
                      left: 16 * pix,
                      right: 16 * pix,
                      top: 10 * pix,
                      bottom: 10 * pix),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildStatItem('Số ngày học', '456', pix),
                      Container(
                        height: 55 * pix,
                        width: 0.5 * pix,
                        margin: EdgeInsets.all(10 * pix),
                        color: Color(0xff165598),
                      ),
                      _buildStatItem('Số khóa học', '321', pix),
                      Container(
                        height: 55 * pix,
                        width: 0.5 * pix,
                        margin: EdgeInsets.all(10 * pix),
                        color: Color(0xff165598),
                      ),
                      _buildStatItem('Điểm trung bình', '8.5', pix),
                    ],
                  ),
                ),
                Container(
                  height: 42 * pix,
                  width: size.width,
                  padding: EdgeInsets.only(left: 16 * pix, right: 16 * pix),
                  child: Row(
                    children: [
                      Container(
                        height: 0.5 * pix,
                        width: 95 * pix,
                        margin: EdgeInsets.all(10 * pix),
                        color: Color(0xff165598),
                      ),
                      Image.asset(
                        AppImages.score,
                        width: 34,
                        height: 42,
                      ),
                      Text(
                        'Trang chủ',
                        style: TextStyle(
                            fontSize: 14 * pix,
                            fontFamily: 'BeVietnamPro',
                            fontWeight: FontWeight.bold,
                            color: Color(0xff165598)),
                      ),
                      Container(
                        height: 0.5 * pix,
                        width: 95 * pix,
                        margin: EdgeInsets.all(10 * pix),
                        color: Color(0xff165598),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(left: 16 * pix, right: 16 * pix),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              "18/50",
                              style: TextStyle(
                                  fontSize: 16 * pix,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'BeVietnamPro',
                                  color: Color(0xff165598)),
                            ),
                            Text(
                              " Khóa học đã hoàn thành",
                              style: TextStyle(
                                fontSize: 14 * pix,
                                fontWeight: FontWeight.normal,
                                fontFamily: 'BeVietnamPro',
                                color: Color(0xff165598),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 5 * pix),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: LinearProgressIndicator(
                            value: 18 / 50, // 18 trên 50
                            minHeight: 15,
                            backgroundColor: Colors.grey[300],
                            valueColor: AlwaysStoppedAnimation<Color>(
                                Color(0xff7DD339)),
                          ),
                        ),
                      ]),
                ),
                Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.only(
                          left: 16 * pix, right: 16 * pix, top: 32 * pix),
                      child: Row(
                        children: [
                          Text(
                            'Hot Topic',
                            style: TextStyle(
                              fontSize: 16 * pix,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'BeVietnamPro',
                              color: Color(0xff165598),
                            ),
                          ),
                          Image.asset(
                            AppImages.fire,
                            width: 19,
                            height: 25,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 10 * pix),
                    Padding(
                      padding: EdgeInsets.only(left: 0 * pix, right: 0 * pix),
                      child: Container(
                        height: 217 * pix,
                        width: double.maxFinite,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          itemCount: _list.length,
                          itemBuilder: (context, index) {
                            return Topicwidget(
                              title: _list[index].topic,
                              image: _list[index].image,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => Vocabularyscreen(
                                      title: _list[index].topic,
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
                Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.only(
                          left: 16 * pix, right: 16 * pix, top: 32 * pix),
                      child: Row(
                        children: [
                          Text(
                            'Bắt đầu với chủ đề cơ bản',
                            style: TextStyle(
                              fontSize: 16 * pix,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'BeVietnamPro',
                              color: Color(0xff165598),
                            ),
                          ),
                          Image.asset(
                            AppImages.start,
                            width: 25,
                            height: 25,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 10 * pix),
                    Padding(
                      padding: EdgeInsets.only(left: 0 * pix, right: 0 * pix),
                      child: Container(
                        height: 217 * pix,
                        width: double.maxFinite,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          itemCount: _list.length,
                          itemBuilder: (context, index) {
                            return Topicwidget(
                              title: _list[index].topic,
                              image: _list[index].image,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => Vocabularyscreen(
                                      title: _list[index].topic,
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
                Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.only(
                          left: 16 * pix, right: 16 * pix, top: 32 * pix),
                      child: Row(
                        children: [
                          Text(
                            'Cộng đồng học tập',
                            style: TextStyle(
                              fontSize: 16 * pix,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'BeVietnamPro',
                              color: Color(0xff165598),
                            ),
                          ),
                          Image.asset(
                            AppImages.communication,
                            width: 28,
                            height: 28,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 10 * pix),
                    Center(
                      child: InkWell(
                        onTap: () {},
                        child: Container(
                            height: 170 * pix,
                            width: 310 * pix,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16 * pix),
                                image: DecorationImage(
                                    image: AssetImage(AppImages.communication1),
                                    fit: BoxFit.cover))),
                      ),
                    ),
                    SizedBox(height: 50 * pix),
                  ],
                ),
              ],
            ),
          ),
        ),
        Positioned(
          bottom: 50 * pix,
          left: (size.width - 312 * pix) / 2,
          child: Bottombar(type: 1),
        ),
      ],
    );
  }

  Widget _buildStatItem(String title, String value, double pix) {
    return Column(
      children: [
        Text(
          title,
          style: TextStyle(fontSize: 14 * pix, color: Color(0xff165598)),
        ),
        SizedBox(height: 5 * pix),
        Text(
          value,
          style: TextStyle(
              fontSize: 20 * pix,
              fontWeight: FontWeight.bold,
              color: Color(0xff165598)),
        ),
      ],
    );
  }
}
