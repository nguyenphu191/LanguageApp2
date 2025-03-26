import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:language_app/PhuNV/NotificationScreen.dart';
import 'package:language_app/PhuNV/VocabularyScreen.dart';
import 'package:language_app/PhuNV/widget/TopicWidget.dart';
import 'package:language_app/models/TopicModel.dart';
import 'package:language_app/res/imagesLA/AppImages.dart';
import 'package:language_app/widget/BottomBar.dart';

class Homescreen extends StatefulWidget {
  const Homescreen({super.key});

  @override
  State<Homescreen> createState() => _HomescreenState();
}

class _HomescreenState extends State<Homescreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  final List<Topicmodel> _topics = [
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

  final int completedCourses = 18;
  final int totalCourses = 50;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final pix = size.width / 375;

    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ));

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.blue.shade100,
              Colors.white,
              Colors.blue.shade100,
              Colors.white
            ],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              _buildHeader(size, pix),
              _buildScrollableContent(size, pix),
              Positioned(
                bottom: 0 * pix,
                left: 0,
                right: 0,
                child: FadeTransition(
                  opacity: _animation,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0, 1),
                      end: Offset.zero,
                    ).animate(_animation),
                    child: Bottombar(type: 1),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(Size size, double pix) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        height: 220 * pix,
        width: size.width,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xff3B82F6), Color(0xff4F46E5)],
            stops: [0.2, 0.8],
          ),
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(30 * pix),
            bottomRight: Radius.circular(30 * pix),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              offset: const Offset(0, 10),
              blurRadius: 20,
              spreadRadius: -5,
            ),
          ],
        ),
        child: Stack(
          children: [
            // Abstract background patterns
            Positioned(
              top: -20 * pix,
              right: -20 * pix,
              child: Opacity(
                opacity: 0.1,
                child: Container(
                  height: 150 * pix,
                  width: 150 * pix,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: -60 * pix,
              left: -30 * pix,
              child: Opacity(
                opacity: 0.1,
                child: Container(
                  height: 180 * pix,
                  width: 180 * pix,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            // Content
            SafeArea(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20 * pix),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 10 * pix),
                    Container(
                        alignment: Alignment.centerRight,
                        child: _buildCircleIconButton(
                          icon: Icons.notifications_outlined,
                          pix: pix,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => Notificationsscreen(),
                              ),
                            );
                          },
                        )),
                    Row(
                      children: [
                        Container(
                          height: 80 * pix,
                          width: 80 * pix,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white,
                              width: 3 * pix,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                offset: const Offset(0, 5),
                                blurRadius: 10,
                              ),
                            ],
                          ),
                          child: ClipOval(
                            child: Image.asset(
                              AppImages.personlearn4,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        SizedBox(width: 20 * pix),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Xin chào,',
                                style: TextStyle(
                                  fontSize: 16 * pix,
                                  fontWeight: FontWeight.normal,
                                  fontFamily: 'BeVietnamPro',
                                  color: Colors.white.withOpacity(0.9),
                                ),
                              ),
                              SizedBox(height: 4 * pix),
                              Text(
                                'Duong Quoc Hoang',
                                style: TextStyle(
                                  fontSize: 22 * pix,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'BeVietnamPro',
                                  color: Colors.white,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              SizedBox(height: 8 * pix),
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 12 * pix,
                                  vertical: 6 * pix,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.25),
                                  borderRadius: BorderRadius.circular(20 * pix),
                                ),
                                child: Text(
                                  'Chúc bạn học tốt!',
                                  style: TextStyle(
                                    fontSize: 14 * pix,
                                    fontWeight: FontWeight.w500,
                                    fontFamily: 'BeVietnamPro',
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCircleIconButton(
      {required IconData icon,
      required double pix,
      required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 40 * pix,
        width: 40 * pix,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white24,
        ),
        child: Icon(
          icon,
          color: Colors.white,
          size: 22 * pix,
        ),
      ),
    );
  }

  Widget _buildScrollableContent(Size size, double pix) {
    return Positioned(
      top: 200 * pix,
      left: 0,
      right: 0,
      bottom: 0,
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            _buildStatisticsCard(size, pix),
            _buildProgressIndicator(pix),
            _buildTopicSection(pix, 'Hot Topic', AppImages.fire, _topics),
            _buildTopicSection(pix, 'Chủ đề cơ bản', AppImages.start, _topics),
            _buildCommunitySection(pix),
            SizedBox(height: 100 * pix), // Bottom padding for scrolling
          ],
        ),
      ),
    );
  }

  Widget _buildStatisticsCard(Size size, double pix) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20 * pix, vertical: 16 * pix),
      padding: EdgeInsets.all(20 * pix),
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
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildStatItem('Số ngày học', '456', pix),
          _buildStatDivider(pix),
          _buildStatItem('Số bài học', '321', pix),
          _buildStatDivider(pix),
          _buildStatItem('Điểm trung bình', '8.5', pix),
        ],
      ),
    );
  }

  Widget _buildStatDivider(double pix) {
    return Container(
      height: 50 * pix,
      width: 1 * pix,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xff165598).withOpacity(0.1),
            const Color(0xff165598).withOpacity(0.3),
            const Color(0xff165598).withOpacity(0.1),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String title, String value, double pix) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 22 * pix,
            fontWeight: FontWeight.bold,
            fontFamily: 'BeVietnamPro',
            color: const Color(0xff165598),
          ),
        ),
        SizedBox(height: 6 * pix),
        Text(
          title,
          style: TextStyle(
            fontSize: 12 * pix,
            fontWeight: FontWeight.w500,
            color: const Color(0xff165598).withOpacity(0.8),
            fontFamily: 'BeVietnamPro',
          ),
        ),
      ],
    );
  }

  Widget _buildProgressIndicator(double pix) {
    final size = MediaQuery.of(context).size;
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20 * pix, vertical: 10 * pix),
      padding: EdgeInsets.all(20 * pix),
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
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Tiến độ học tập',
                    style: TextStyle(
                      fontSize: 18 * pix,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'BeVietnamPro',
                      color: const Color(0xff165598),
                    ),
                  ),
                  SizedBox(height: 6 * pix),
                  Text(
                    "$completedCourses/$totalCourses khóa học đã hoàn thành",
                    style: TextStyle(
                      fontSize: 14 * pix,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'BeVietnamPro',
                      color: const Color(0xff165598).withOpacity(0.8),
                    ),
                  ),
                ],
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 12 * pix,
                  vertical: 8 * pix,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xff7DD339).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12 * pix),
                ),
                child: Text(
                  "${(completedCourses / totalCourses * 100).toInt()}%",
                  style: TextStyle(
                    fontSize: 16 * pix,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'BeVietnamPro',
                    color: const Color(0xff7DD339),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16 * pix),
          Container(
            height: 16 * pix,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(8 * pix),
            ),
            child: Row(
              children: [
                Container(
                  height: 16 * pix,
                  width: (completedCourses / totalCourses) *
                      (size.width - 80 * pix),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [Color(0xff7DD339), Color(0xff9AE259)],
                    ),
                    borderRadius: BorderRadius.circular(8 * pix),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xff7DD339).withOpacity(0.4),
                        offset: const Offset(0, 2),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(double pix, String title, String iconPath) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20 * pix,
        right: 20 * pix,
        top: 24 * pix,
        bottom: 12 * pix,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8 * pix),
                child: Container(
                  padding: EdgeInsets.all(8 * pix),
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 254, 254, 255)
                        .withOpacity(0.9),
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: Image.asset(
                    iconPath,
                    width: 26 * pix,
                    height: 26 * pix,
                  ),
                ),
              ),
              SizedBox(width: 12 * pix),
              Text(
                title,
                style: TextStyle(
                  fontSize: 18 * pix,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'BeVietnamPro',
                  color: const Color(0xff165598),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTopicSection(
      double pix, String title, String iconPath, List<Topicmodel> topics) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(pix, title, iconPath),
        SizedBox(height: 8 * pix),
        Container(
          height: 230 * pix,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.symmetric(horizontal: 12 * pix),
            itemCount: topics.length,
            itemBuilder: (context, index) {
              return Topicwidget(topic: topics[index]);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCommunitySection(double pix) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(pix, 'Cộng đồng học tập', AppImages.communication),
        SizedBox(height: 8 * pix),
        Container(
          margin: EdgeInsets.symmetric(horizontal: 20 * pix),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24 * pix),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                offset: const Offset(0, 10),
                blurRadius: 20,
                spreadRadius: -5,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24 * pix),
            child: InkWell(
              onTap: () {},
              child: Stack(
                children: [
                  Image.asset(
                    AppImages.communication1,
                    height: 200 * pix,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                  Container(
                    height: 200 * pix,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withOpacity(0.1),
                          Colors.black.withOpacity(0.7),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      padding: EdgeInsets.all(20 * pix),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Tham gia ngay',
                            style: TextStyle(
                              fontSize: 14 * pix,
                              fontWeight: FontWeight.w500,
                              color: Colors.white.withOpacity(0.9),
                            ),
                          ),
                          SizedBox(height: 8 * pix),
                          Text(
                            'Cộng đồng học tập sôi động',
                            style: TextStyle(
                              fontSize: 22 * pix,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 16 * pix),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 16 * pix,
                              vertical: 10 * pix,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(30 * pix),
                            ),
                            child: Text(
                              'Tham gia ngay',
                              style: TextStyle(
                                fontSize: 14 * pix,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xff4F46E5),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
