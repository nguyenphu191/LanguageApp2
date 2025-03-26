import 'package:flutter/material.dart';
import 'package:language_app/PhuNV/widget/TopicWidget.dart';
import 'package:language_app/models/TopicModel.dart';
import 'package:language_app/res/imagesLA/AppImages.dart';
import 'package:language_app/widget/BottomBar.dart';
import 'package:language_app/widget/TopBar.dart';

class VocabularyTopicscreen extends StatefulWidget {
  const VocabularyTopicscreen({super.key});

  @override
  State<VocabularyTopicscreen> createState() => _VocabularyTopicscreenState();
}

class _VocabularyTopicscreenState extends State<VocabularyTopicscreen>
    with SingleTickerProviderStateMixin {
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
    Topicmodel(
      id: '6',
      topic: 'Music',
      image: AppImages.family,
      numbervocabulary: 50,
      description: 'normal',
    ),
    Topicmodel(
      id: '7',
      topic: 'English',
      image: AppImages.animal,
      numbervocabulary: 50,
      description: 'normal',
    ),
  ];

  final _searchController = TextEditingController();
  bool _isSearching = false;
  String _searchQuery = "";
  late AnimationController _controller;
  late Animation<double> _animation;
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
    _searchController.dispose();
    _controller.dispose();
    super.dispose();
  }

  List<Topicmodel> get _filteredList {
    if (_searchQuery.isEmpty) {
      return _list;
    }
    return _list
        .where((topic) =>
            topic.topic.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();
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
                right: 0,
                left: 0,
                child: TopBar(title: 'Từ vựng', isBack: false),
              ),
              Positioned(
                top: 100 * pix,
                left: 0,
                right: 0,
                bottom: 0,
                child: Column(
                  children: [
                    _buildSearchBar(pix),
                    _buildStats(size, pix),
                    Expanded(
                      child: _buildTopicGrid(size, pix),
                    ),
                    SizedBox(height: 70 * pix), // Space for bottom bar
                  ],
                ),
              ),
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
                    child: Bottombar(type: 2),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar(double pix) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      height: _isSearching ? 60 * pix : 0,
      child: _isSearching
          ? Padding(
              padding:
                  EdgeInsets.symmetric(horizontal: 16 * pix, vertical: 8 * pix),
              child: TextField(
                controller: _searchController,
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
                decoration: InputDecoration(
                  hintText: "Tìm kiếm chủ đề...",
                  prefixIcon: Icon(Icons.search, color: Color(0xff165598)),
                  suffixIcon: IconButton(
                    icon: Icon(Icons.clear, color: Color(0xff165598)),
                    onPressed: () {
                      setState(() {
                        _searchController.clear();
                        _searchQuery = "";
                        _isSearching = false;
                      });
                    },
                  ),
                  filled: true,
                  fillColor: Colors.grey[100],
                  contentPadding: EdgeInsets.symmetric(vertical: 0),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none,
                  ),
                ),
                cursorColor: Color(0xff165598),
              ),
            )
          : SizedBox.shrink(),
    );
  }

  Widget _buildStats(Size size, double pix) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 16 * pix),
      child: Column(
        children: [
          Container(
            width: size.width * 0.85,
            padding: EdgeInsets.symmetric(vertical: 16 * pix),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 10,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildStatItem('Đã học', '6', pix),
                Container(
                  height: 35 * pix,
                  width: 1 * pix,
                  color: Color(0xff165598).withOpacity(0.3),
                ),
                _buildStatItem('Tổng', '21', pix),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String title, String value, double pix) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 24 * pix,
            fontWeight: FontWeight.bold,
            color: Color(0xff165598),
          ),
        ),
        SizedBox(height: 5 * pix),
        Text(
          title,
          style: TextStyle(
            fontSize: 14 * pix,
            color: Color(0xff165598).withOpacity(0.7),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildTopicGrid(Size size, double pix) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16 * pix),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Tất cả chủ đề',
                style: TextStyle(
                  fontSize: 18 * pix,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'BeVietnamPro',
                  color: Color(0xff165598),
                ),
              ),
              IconButton(
                icon: Icon(
                  _isSearching ? Icons.search_off : Icons.search,
                  color: Color(0xff165598),
                ),
                onPressed: () {
                  setState(() {
                    _isSearching = !_isSearching;
                    if (!_isSearching) {
                      _searchController.clear();
                      _searchQuery = "";
                    }
                  });
                },
              ),
            ],
          ),
        ),
        Expanded(
          child: _filteredList.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.search_off,
                        size: 60 * pix,
                        color: Color(0xff165598).withOpacity(0.5),
                      ),
                      SizedBox(height: 16 * pix),
                      Text(
                        "Không tìm thấy chủ đề",
                        style: TextStyle(
                          fontSize: 16 * pix,
                          color: Color(0xff165598).withOpacity(0.5),
                        ),
                      ),
                    ],
                  ),
                )
              : GridView.builder(
                  padding: EdgeInsets.all(16 * pix),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.75,
                    crossAxisSpacing: 0,
                    mainAxisSpacing: 8 * pix,
                  ),
                  itemCount: _filteredList.length,
                  itemBuilder: (context, index) {
                    return Topicwidget(topic: _filteredList[index]);
                  },
                ),
        ),
      ],
    );
  }
}
