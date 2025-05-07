import 'package:flutter/material.dart';

class HelpDialog extends StatelessWidget {
  const HelpDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(
        'Trung tâm Trợ giúp',
        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange),
      ),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHelpItem(
              icon: Icons.account_circle,
              title: 'Tài khoản',
              content: 'Đổi mật khẩu, cập nhật thông tin cá nhân.',
            ),
            const Divider(),
            _buildHelpItem(
              icon: Icons.payment,
              title: 'Thanh toán',
              content: 'Hướng dẫn mua gói Premium, hoàn tiền.',
            ),
            const Divider(),
            _buildHelpItem(
              icon: Icons.language,
              title: 'Ngôn ngữ',
              content: 'Cách thay đổi ngôn ngữ trong ứng dụng.',
            ),
            const Divider(),
            _buildHelpItem(
              icon: Icons.contact_support,
              title: 'Liên hệ',
              content: 'Email: support@languageapp.com\nHotline: 1900 1234',
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Đóng'),
        ),
      ],
    );
  }

  Widget _buildHelpItem({
    required IconData icon,
    required String title,
    required String content,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 24, color: Colors.blue),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(content, style: const TextStyle(fontSize: 14)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
