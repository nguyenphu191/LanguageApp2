import 'package:flutter/material.dart';

class TermsAndConditionsDialog extends StatelessWidget {
  const TermsAndConditionsDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(
        'Chính sách & Điều khoản',
        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
      ),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('1. Điều khoản sử dụng'),
            _buildSectionContent(
                'Ứng dụng LanguageApp cung cấp các bài học ngôn ngữ miễn phí và trả phí. Bạn đồng ý sử dụng ứng dụng đúng mục đích.'),
            const SizedBox(height: 12),
            _buildSectionTitle('2. Quyền riêng tư'),
            _buildSectionContent(
                'Chúng tôi thu thập dữ liệu cá nhân để cải thiện trải nghiệm người dùng. Dữ liệu sẽ không được bán cho bên thứ ba.'),
            const SizedBox(height: 12),
            _buildSectionTitle('3. Hủy tài khoản'),
            _buildSectionContent(
                'Bạn có thể yêu cầu hủy tài khoản bất kỳ lúc nào. Mọi dữ liệu sẽ bị xóa vĩnh viễn sau 30 ngày.'),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String text) {
    return Text(
      text,
      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
    );
  }

  Widget _buildSectionContent(String text) {
    return Text(
      text,
      style: const TextStyle(fontSize: 14),
    );
  }
}
