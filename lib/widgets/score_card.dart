import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class ScoreCard extends StatelessWidget {
  final int score;
  final bool hasEnoughData;

  /// Change since about a week ago. Null when there is no history yet.
  final int? weeklyChange;

  const ScoreCard({
    super.key,
    required this.score,
    this.hasEnoughData = true,
    this.weeklyChange,
  });

  static Color colorFor(int score) {
    if (score >= 850) return AppColors.emerald;
    if (score >= 700) return AppColors.mint;
    if (score >= 550) return AppColors.gold;
    return AppColors.warningRed;
  }

  static String labelFor(int score) {
    if (score >= 850) return 'Excellent';
    if (score >= 700) return 'Strong';
    if (score >= 550) return 'Improving';
    return 'Needs attention';
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final color = hasEnoughData ? colorFor(score) : scheme.onSurfaceVariant;

    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
        child: Column(
          children: [
            Row(
              children: [
                Text(
                  'PocketWatcher Score',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const Spacer(),
                if (hasEnoughData) _ChangeChip(change: weeklyChange),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 170,
              width: 170,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  TweenAnimationBuilder<double>(
                    tween: Tween(
                      begin: 0,
                      end: hasEnoughData ? score / 1000 : 0,
                    ),
                    duration: const Duration(milliseconds: 900),
                    curve: Curves.easeOutCubic,
                    builder: (context, value, _) => CircularProgressIndicator(
                      value: value,
                      strokeWidth: 14,
                      strokeCap: StrokeCap.round,
                      backgroundColor: color.withValues(alpha: 0.14),
                      color: color,
                    ),
                  ),
                  Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          hasEnoughData ? '$score' : '—',
                          style: TextStyle(
                            fontSize: 46,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -1,
                            color: scheme.onSurface,
                          ),
                        ),
                        Text(
                          hasEnoughData ? labelFor(score) : 'No score yet',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: color,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            Text(
              hasEnoughData
                  ? _getScoreMessage(score)
                  : 'Add your income to get your score.',
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Text(
              'Out of 1000 • Measures your money habits. Not a credit score.',
              style: Theme.of(context).textTheme.bodySmall,
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
      return 'Needs attention — start with the tips below.';
    }
  }
}

/// Small pill showing "▲ 14 this week".
class _ChangeChip extends StatelessWidget {
  final int? change;

  const _ChangeChip({required this.change});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    String text;
    Color color;
    if (change == null) {
      text = 'New';
      color = scheme.onSurfaceVariant;
    } else if (change! > 0) {
      text = '▲ $change this week';
      color = AppColors.emerald;
    } else if (change! < 0) {
      text = '▼ ${-change!} this week';
      color = AppColors.warningRed;
    } else {
      text = 'No change this week';
      color = scheme.onSurfaceVariant;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }
}