import 'package:flutter/material.dart';
import 'package:language_app/LoginSignup/LoginScreen.dart';
import 'package:language_app/Task1/HomeScreen.dart';
import 'package:language_app/Task1/VocabularyTopicScreen.dart';
import 'package:language_app/res/imagesLA/AppImages.dart';
import 'package:language_app/res/theme/app_colors.dart';

class Bottombar extends StatefulWidget {
  const Bottombar({super.key, required this.type});
  final int type;

  @override
  State<Bottombar> createState() => _BottombarState();
}

class _BottombarState extends State<Bottombar> {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final pix = size.width / 375;
    return Container(
      height: 64 * pix,
      width: 312 * pix,
      padding: EdgeInsets.symmetric(horizontal: 8 * pix),
      decoration: BoxDecoration(
        color: Color(0xffD1D1D6),
        borderRadius: BorderRadius.circular(50),
        border: Border.all(
          color: const Color.fromARGB(255, 130, 130, 130),
          width: 1 * pix,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color.fromARGB(255, 0, 0, 0),
            offset: Offset(0, 0),
            blurRadius: 5,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildActionButton(
              onTap: () {
                Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (context) => Homescreen()));
              },
              image: AppImages.iconhome,
              enabled: widget.type == 1 ? true : false),
          _buildActionButton(
              onTap: () {
                Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) => VocabularyTopicscreen()));
              },
              image: AppImages.iconvocabulary,
              enabled: widget.type == 2 ? true : false),
          _buildActionButton(
              onTap: () {
                Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (context) => Loginscreen()));
              },
              image: AppImages.iconstudy,
              enabled: widget.type == 3 ? true : false),
          _buildActionButton(
              onTap: () {
                Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (context) => Loginscreen()));
              },
              image: AppImages.icontest,
              enabled: widget.type == 4 ? true : false),
          _buildActionButton(
              onTap: () {
                Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (context) => Loginscreen()));
              },
              image: AppImages.iconprofile,
              enabled: widget.type == 5 ? true : false),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required VoidCallback onTap,
    required String image,
    required bool enabled,
  }) {
    final size = MediaQuery.of(context).size;
    final pix = size.width / 375;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 56 * pix,
        width: 56 * pix,
        decoration: BoxDecoration(
          color: enabled ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(50),
        ),
        child: Center(
          child: Image.asset(image, width: 32 * pix, height: 32 * pix),
        ),
      ),
    );
  }
}
