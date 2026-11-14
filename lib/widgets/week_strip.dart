import 'package:flutter/material.dart';

import '../services/timeline_service.dart';
import '../theme/app_theme.dart';

/// Seven day chips for the coming week with dots for paydays and bills.
class WeekStrip extends StatelessWidget {
  final List<TimelineDay> days;
  final VoidCallback? onOpenTimeline;

  const WeekStrip({
    super.key,
    required this.days,
    this.onOpenTimeline,
  });

  static const List<String> _weekdays = [
    'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun',
  ];

  String _money(double value) => '\$${value.toStringAsFixed(0)}';

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final moneyIn = days.fold(0.0, (total, day) => total + day.moneyIn);
    final moneyOut = days.fold(0.0, (total, day) => total + day.moneyOut);

    TimelineEvent? nextEvent;
    for (final day in days) {
      if (day.events.isNotEmpty) {
        nextEvent = day.events.first;
        break;
      }
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text('Next 7 days', style: textTheme.titleLarge),
                const Spacer(),
                if (onOpenTimeline != null)
                  TextButton(
                    onPressed: onOpenTimeline,
                    child: const Text('Timeline'),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                for (int i = 0; i < days.length; i++)
                  Expanded(
                    child: _DayChip(
                      label: i == 0 ? 'Today' : _weekdays[days[i].date.weekday - 1],
                      dayNumber: days[i].date.day,
                      isToday: i == 0,
                      hasPayday: days[i].hasPayday,
                      hasBill: days[i].hasBill,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _Legend(color: AppColors.emerald, label: 'In ${_money(moneyIn)}'),
                const SizedBox(width: 16),
                _Legend(color: AppColors.gold, label: 'Out ${_money(moneyOut)}'),
              ],
            ),
            if (nextEvent != null) ...[
              const SizedBox(height: 10),
              Text(
                'Next up: ${nextEvent.title} '
                '(${nextEvent.amount >= 0 ? '+' : '−'}${_money(nextEvent.amount.abs())})',
                style: textTheme.bodyMedium?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
            ] else ...[
              const SizedBox(height: 10),
              Text(
                'No paydays or bills in the next 7 days.',
                style: textTheme.bodyMedium?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _DayChip extends StatelessWidget {
  final String label;
  final int dayNumber;
  final bool isToday;
  final bool hasPayday;
  final bool hasBill;

  const _DayChip({
    required this.label,
    required this.dayNumber,
    required this.isToday,
    required this.hasPayday,
    required this.hasBill,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 3),
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: isToday
            ? scheme.primary.withValues(alpha: 0.14)
            : scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(14),
        border: isToday ? Border.all(color: scheme.primary, width: 1.2) : null,
      ),
      child: Column(
        children: [
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.fade,
            softWrap: false,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: scheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '$dayNumber',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: scheme.onSurface,
            ),
          ),
          const SizedBox(height: 6),
          SizedBox(
            height: 6,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (hasPayday) const _Dot(color: AppColors.emerald),
                if (hasPayday && hasBill) const SizedBox(width: 3),
                if (hasBill) const _Dot(color: AppColors.gold),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  final Color color;

  const _Dot({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 6,
      height: 6,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}

class _Legend extends StatelessWidget {
  final Color color;
  final String label;

  const _Legend({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _Dot(color: color),
        const SizedBox(width: 6),
        Text(
          label,
          style: Theme.of(context).textTheme.labelLarge,
        ),
      ],
    );
  }
}