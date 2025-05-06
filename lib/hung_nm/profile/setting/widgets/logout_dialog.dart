import 'package:flutter/material.dart';

void showLogoutDialog(BuildContext context) {
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
                Icons.logout_rounded,
                color: Colors.red,
                size: 40 * pix,
              ),
            ),
            SizedBox(height: 16 * pix),
            Text(
              'Đăng xuất',
              style: TextStyle(
                fontSize: 20 * pix,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8 * pix),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 8 * pix),
              child: Text(
                'Bạn có chắc chắn muốn đăng xuất khỏi tài khoản này?',
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
                      'Hủy',
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
                      "Đăng xuất",
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
