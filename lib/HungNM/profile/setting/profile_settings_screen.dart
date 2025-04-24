import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import 'package:language_app/widget/top_bar.dart';

class ProfileSettingsScreen extends StatefulWidget {
  const ProfileSettingsScreen({super.key});

  @override
  State<ProfileSettingsScreen> createState() => _ProfileSettingsScreenState();
}

class _ProfileSettingsScreenState extends State<ProfileSettingsScreen> {
  File? _avatarImage;
  final TextEditingController _usernameController =
      TextEditingController(text: 'Nguyễn Mạnh Hùng');
  final TextEditingController _loginNameController =
      TextEditingController(text: 'hungnm');
  final TextEditingController _passwordController =
      TextEditingController(text: '********');
  final TextEditingController _emailController =
      TextEditingController(text: 'hungnm@example.com');
  bool _obscurePassword = true;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _avatarImage = File(pickedFile.path);
      });
    }
  }

  void _showDeleteAccountDialog(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final pix = (size.width / 375).clamp(0.8, 1.2);

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20 * pix),
        ),
        elevation: 8,
        child: Container(
          padding: EdgeInsets.all(20 * pix),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20 * pix),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.all(16 * pix),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.delete_forever_rounded,
                  color: Colors.red,
                  size: 40 * pix,
                ),
              ),
              SizedBox(height: 16 * pix),
              Text(
                "Xóa tài khoản",
                style: TextStyle(
                  fontSize: 20 * pix,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8 * pix),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 8 * pix),
                child: Text(
                  "Xác nhận xóa tài khoản",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16 * pix,
                    color: Colors.black87,
                  ),
                ),
              ),
              SizedBox(height: 24 * pix),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey.shade200,
                        foregroundColor: Colors.black87,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12 * pix),
                        ),
                        padding: EdgeInsets.symmetric(vertical: 12 * pix),
                      ),
                      child: Text(
                        "Hủy",
                        style: TextStyle(
                          fontSize: 16 * pix,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 16 * pix),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.pushReplacementNamed(context, '/login');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12 * pix),
                        ),
                        padding: EdgeInsets.symmetric(vertical: 12 * pix),
                      ),
                      child: Text(
                        "Xóa",
                        style: TextStyle(
                          fontSize: 16 * pix,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final pix = (size.width / 375).clamp(0.8, 1.2);

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.blue.shade50,
            Colors.white,
          ],
        ),
      ),
      child: Scaffold(
        body: Stack(
          children: [
            Positioned(
              top: 100 * pix,
              left: 0,
              right: 0,
              bottom: 0,
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.all(16 * pix),
                  child: Column(
                    children: [
                      _buildAvatarSection(pix),
                      SizedBox(height: 24 * pix),
                      _buildInfoCard(pix),
                      SizedBox(height: 16 * pix),
                      _buildSaveButton(pix),
                      SizedBox(height: 16 * pix),
                      _buildDeleteAccountButton(pix),
                      SizedBox(height: 32 * pix),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: TopBar(title: "Thông tin cá nhân"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatarSection(double pix) {
    return Center(
      child: GestureDetector(
        onTap: _pickImage,
        child: Stack(
          children: [
            Container(
              width: 120 * pix,
              height: 120 * pix,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white,
                  width: 4 * pix,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: ClipOval(
                  child: _avatarImage != null
                      ? Image.file(
                          _avatarImage!,
                          fit: BoxFit.cover,
                        )
                      : Image.asset(
                          'lib/res/imagesLA/vietnam.jpg',
                          fit: BoxFit.cover,
                        )),
            ),
            Positioned(
              right: 0,
              bottom: 0,
              child: Container(
                padding: EdgeInsets.all(8 * pix),
                decoration: BoxDecoration(
                  color: const Color(0xff5B7BFE),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white,
                    width: 2 * pix,
                  ),
                ),
                child: Icon(
                  Icons.camera_alt,
                  color: Colors.white,
                  size: 20 * pix,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(double pix) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16 * pix),
      ),
      child: Padding(
        padding: EdgeInsets.all(16 * pix),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle("Thông tin cá nhân", pix),
            SizedBox(height: 16 * pix),
            _buildTextField(
                "Tài khoản", _usernameController, Icons.person, pix),
            SizedBox(height: 16 * pix),
            _buildTextField(
                "Tên đăng nhập", _loginNameController, Icons.login, pix),
            SizedBox(height: 16 * pix),
            _buildSectionTitle("Bảo mật", pix),
            SizedBox(height: 16 * pix),
            _buildPasswordField("Mật khẩu", _passwordController, pix),
            SizedBox(height: 16 * pix),
            _buildTextField("Email", _emailController, Icons.email, pix),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, double pix) {
    return Padding(
      padding: EdgeInsets.only(left: 4 * pix, bottom: 4 * pix),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18 * pix,
          fontWeight: FontWeight.bold,
          color: const Color(0xff5B7BFE),
        ),
      ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller,
    IconData icon,
    double pix,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: 4 * pix, bottom: 8 * pix),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14 * pix,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(12 * pix),
            border: Border.all(
              color: Colors.grey[300]!,
              width: 1,
            ),
          ),
          child: TextField(
            controller: controller,
            decoration: InputDecoration(
              prefixIcon: Container(
                margin: EdgeInsets.all(8 * pix),
                padding: EdgeInsets.all(8 * pix),
                decoration: BoxDecoration(
                  color: const Color(0xff5B7BFE).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10 * pix),
                ),
                child: Icon(
                  icon,
                  size: 20 * pix,
                  color: const Color(0xff5B7BFE),
                ),
              ),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                vertical: 16 * pix,
                horizontal: 8 * pix,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordField(
    String label,
    TextEditingController controller,
    double pix,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: 4 * pix, bottom: 8 * pix),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14 * pix,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(12 * pix),
            border: Border.all(
              color: Colors.grey[300]!,
              width: 1,
            ),
          ),
          child: TextField(
            controller: controller,
            obscureText: _obscurePassword,
            decoration: InputDecoration(
              prefixIcon: Container(
                margin: EdgeInsets.all(8 * pix),
                padding: EdgeInsets.all(8 * pix),
                decoration: BoxDecoration(
                  color: const Color(0xff5B7BFE).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10 * pix),
                ),
                child: Icon(
                  Icons.lock,
                  size: 20 * pix,
                  color: const Color(0xff5B7BFE),
                ),
              ),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword ? Icons.visibility_off : Icons.visibility,
                  color: Colors.grey[600],
                  size: 20 * pix,
                ),
                onPressed: () {
                  setState(() {
                    _obscurePassword = !_obscurePassword;
                  });
                },
              ),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                vertical: 16 * pix,
                horizontal: 8 * pix,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSaveButton(double pix) {
    return Container(
      width: double.infinity,
      height: 56 * pix,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xff5B7BFE),
            Color(0xff7381FF),
          ],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(12 * pix),
        boxShadow: [
          BoxShadow(
            color: const Color(0xff5B7BFE).withOpacity(0.3),
            offset: const Offset(0, 4),
            blurRadius: 12,
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text("Cập nhật thành công"),
              backgroundColor: const Color(0xff5B7BFE),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10 * pix),
              ),
              margin: EdgeInsets.only(
                bottom: 20 * pix,
                left: 16 * pix,
                right: 16 * pix,
              ),
            ),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12 * pix),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.save, size: 20 * pix),
            SizedBox(width: 8 * pix),
            Text(
              "Lưu thay đổi",
              style: TextStyle(
                fontSize: 16 * pix,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeleteAccountButton(double pix) {
    return Container(
      width: double.infinity,
      child: TextButton.icon(
        onPressed: () => _showDeleteAccountDialog(context),
        icon: Icon(
          Icons.delete_forever,
          color: Colors.red[600],
          size: 20 * pix,
        ),
        label: Text(
          "Xóa tài khoản",
          style: TextStyle(
            fontSize: 16 * pix,
            color: Colors.red[600],
            fontWeight: FontWeight.w500,
          ),
        ),
        style: TextButton.styleFrom(
          padding: EdgeInsets.symmetric(vertical: 12 * pix),
        ),
      ),
    );
  }
}
