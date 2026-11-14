import 'package:flutter/material.dart';

import '../services/score_service.dart';

/// Personal savings ideas, each showing how many points it is worth.
class ScoreTipsCard extends StatelessWidget {
  final List<ScoreTip> tips;
  final int maxTips;

  const ScoreTipsCard({
    super.key,
    required this.tips,
    this.maxTips = 3,
  });

  @override
  Widget build(BuildContext context) {
    final shown = tips.take(maxTips).toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Ways to raise your score',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            if (shown.isEmpty)
              const Text(
                'You are doing everything right. Keep it up and check back next week.',
              )
            else
              ...shown.map((tip) => _TipTile(tip: tip)),
          ],
        ),
      ),
    );
  }
}

class _TipTile extends StatelessWidget {
  final ScoreTip tip;

  const _TipTile({required this.tip});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 58,
            padding: const EdgeInsets.symmetric(vertical: 6),
            decoration: BoxDecoration(
              color: tip.pointGain > 0
                  ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.14)
                  : Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              tip.pointGain > 0 ? '+${tip.pointGain}\npts' : '\$',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: tip.pointGain > 0
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tip.title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  tip.detail,
                  style: TextStyle(
                    fontSize: 13,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                if (tip.moneyImpact != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    tip.moneyImpact!,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}