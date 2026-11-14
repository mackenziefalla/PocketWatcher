import 'package:flutter/material.dart';

import '../services/score_service.dart';
import '../theme/app_theme.dart';

/// Shows each part of the score as a bar so users can see exactly
/// where their points come from.
class ScoreBreakdownCard extends StatelessWidget {
  final List<ScorePillar> pillars;

  const ScoreBreakdownCard({
    super.key,
    required this.pillars,
  });

  Color _barColor(double progress) {
    if (progress >= 0.8) return AppColors.emerald;
    if (progress >= 0.5) return AppColors.gold;
    return AppColors.warningRed;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'How your score is built',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            ...pillars.map(
              (pillar) => Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            pillar.name,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        Text(
                          '${pillar.points} / ${pillar.maxPoints}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: pillar.progress,
                        minHeight: 8,
                        backgroundColor:
                            Theme.of(context).colorScheme.surfaceContainerHighest,
                        color: _barColor(pillar.progress),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      pillar.status,
                      style: TextStyle(
                        fontSize: 13,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}