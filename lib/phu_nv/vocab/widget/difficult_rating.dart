import 'package:flutter/material.dart';

class DifficultyRatingDialog extends StatelessWidget {
  final Function(String) onRatingSelected;

  const DifficultyRatingDialog({
    Key? key,
    required this.onRatingSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final pix = size.width / 375;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20 * pix),
      ),
      child: Container(
        padding: EdgeInsets.all(24 * pix),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Đánh giá độ khó',
              style: TextStyle(
                fontSize: 18 * pix,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16 * pix),
            Text(
              'Mức độ khó khi bạn nhớ từ vựng này?',
              style: TextStyle(
                fontSize: 16 * pix,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24 * pix),
            _buildRatingButton(
              context,
              'DỄ',
              'EASY',
              Colors.green,
              'Tôi nhớ từ này dễ dàng',
              pix,
            ),
            SizedBox(height: 12 * pix),
            _buildRatingButton(
              context,
              'TRUNG BÌNH',
              'MEDIUM',
              Colors.orange,
              'Tôi mất chút thời gian để nhớ',
              pix,
            ),
            SizedBox(height: 12 * pix),
            _buildRatingButton(
              context,
              'KHÓ',
              'HARD',
              Colors.red,
              'Tôi gặp khó khăn khi nhớ từ này',
              pix,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRatingButton(
    BuildContext context,
    String label,
    String value,
    Color color,
    String description,
    double pix,
  ) {
    return SizedBox(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              onRatingSelected(value);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: color,
              padding: EdgeInsets.symmetric(vertical: 12 * pix),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10 * pix),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  value == 'EASY'
                      ? Icons.sentiment_very_satisfied
                      : value == 'MEDIUM'
                          ? Icons.sentiment_neutral
                          : Icons.sentiment_very_dissatisfied,
                  color: Colors.white,
                  size: 20 * pix,
                ),
                SizedBox(width: 8 * pix),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 16 * pix,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.only(left: 12 * pix, top: 4 * pix),
            child: Text(
              description,
              style: TextStyle(
                fontSize: 12 * pix,
                color: color.withOpacity(0.8),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
