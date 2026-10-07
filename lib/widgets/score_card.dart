import 'package:flutter/material.dart';

class ScoreCard extends StatelessWidget {
  final int score;

  const ScoreCard({
    super.key,
    required this.score,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Text(
              'PocketWatcher Score',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 150,
              width: 150,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  CircularProgressIndicator(
                    value: score / 1000,
                    strokeWidth: 14,
                    backgroundColor: Colors.greenAccent,
                    color: Colors.green,
                  ),
                  Center(
                    child: Text(
                      '$score',
                      style: const TextStyle(
                        fontSize: 42,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              _getScoreMessage(score),
              style: const TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  String _getScoreMessage(int score) {
    if (score >= 850) {
      return 'Excellent financial health.';
    } else if (score >= 700) {
      return 'Stable — keep building momentum.';
    } else if (score >= 550) {
      return 'Improving — focus on savings and debt.';
    } else {
      return 'Needs attention — start with essential expenses.';
    }
  }
}