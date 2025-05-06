import 'package:flutter/material.dart';
import 'package:language_app/models/vocabulary_model.dart';
import 'package:language_app/provider/vocabulary_provider.dart';
import 'package:provider/provider.dart';

class DifficultyRatingDialog extends StatelessWidget {
  final VocabularyModel vocab;
  final String topicId;
  final Function(bool) onRatingSelected;

  const DifficultyRatingDialog({
    Key? key,
    required this.onRatingSelected,
    required this.vocab,
    required this.topicId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<VocabularyProvider>(
        builder: (context, vocabProvider, child) {
      if (vocabProvider.isLoading) {
        return Center(
          child: CircularProgressIndicator(),
        );
      }
      return AlertDialog(
        title: Text('Đánh giá độ khó từ'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildDifficultyButton(
              context,
              'EASY',
              'Dễ',
              Colors.green,
              () async {
                bool isSuccess =
                    await vocabProvider.updateVocabularyRepetitions(
                  topicId: int.parse(this.topicId),
                  vocabId: int.parse(this.vocab.id),
                  difficulty: 'EASY',
                );
                if (!isSuccess) {
                  onRatingSelected(false);
                } else {
                  onRatingSelected(true);
                }
              },
            ),
            SizedBox(height: 10),
            _buildDifficultyButton(
              context,
              "MEDIUM",
              'Trung bình',
              Colors.blue,
              () async {
                bool isSuccess =
                    await vocabProvider.updateVocabularyRepetitions(
                  topicId: int.parse(this.topicId),
                  vocabId: int.parse(this.vocab.id),
                  difficulty: 'MEDIUM',
                );
                if (!isSuccess) {
                  onRatingSelected(false);
                } else {
                  onRatingSelected(true);
                }
              },
            ),
            SizedBox(height: 10),
            _buildDifficultyButton(
              context,
              'HARD',
              'Khó',
              Colors.orange,
              () async {
                bool isSuccess =
                    await vocabProvider.updateVocabularyRepetitions(
                  topicId: int.parse(this.topicId),
                  vocabId: int.parse(this.vocab.id),
                  difficulty: 'HARD',
                );
                if (!isSuccess) {
                  onRatingSelected(false);
                } else {
                  onRatingSelected(true);
                }
              },
            ),
          ],
        ),
      );
    });
  }

  Widget _buildDifficultyButton(
    BuildContext context,
    String difficulty,
    String label,
    Color color,
    VoidCallback onPressed,
  ) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        minimumSize: Size(double.infinity, 50),
      ),
      onPressed: onPressed,
      child: Text(
        label,
        style: TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
