import 'package:flutter/material.dart';

import '../models/financial_data.dart';
import '../services/timeline_service.dart';
import '../theme/app_theme.dart';

/// Day-by-day view of your money: upcoming paydays and bills, and the
/// spending you logged recently.
class TimelineScreen extends StatefulWidget {
  final FinancialData financialData;

  const TimelineScreen({
    super.key,
    required this.financialData,
  });

  @override
  State<TimelineScreen> createState() => _TimelineScreenState();
}

class _TimelineScreenState extends State<TimelineScreen> {
  bool showUpcoming = true;

  static const List<String> _weekdays = [
    'Monday', 'Tuesday', 'Wednesday', 'Thursday',
    'Friday', 'Saturday', 'Sunday',
  ];

  static const List<String> _months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

  String _money(double value) => '\$${value.toStringAsFixed(0)}';

  String _dayLabel(DateTime date) {
    final today = TimelineService.dateOnly(DateTime.now());
    final difference = date.difference(today).inHours / 24;
    final days = difference.round();

    final dateText = '${_months[date.month - 1]} ${date.day}';
    if (days == 0) return 'Today • $dateText';
    if (days == 1) return 'Tomorrow • $dateText';
    if (days == -1) return 'Yesterday • $dateText';
    return '${_weekdays[date.weekday - 1]} • $dateText';
  }

  @override
  Widget build(BuildContext context) {
    final data = widget.financialData;
    final days = showUpcoming
        ? TimelineService.upcoming(data, days: 30)
        : TimelineService.recentSpending(data, days: 14);

    final totalIn = days.fold(0.0, (total, day) => total + day.moneyIn);
    final totalOut = days.fold(0.0, (total, day) => total + day.moneyOut);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Timeline'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          SegmentedButton<bool>(
            segments: const [
              ButtonSegment(
                value: true,
                label: Text('Next 30 days'),
                icon: Icon(Icons.event_outlined),
              ),
              ButtonSegment(
                value: false,
                label: Text('Last 14 days'),
                icon: Icon(Icons.history),
              ),
            ],
            selected: {showUpcoming},
            onSelectionChanged: (selection) {
              setState(() {
                showUpcoming = selection.first;
              });
            },
          ),
          const SizedBox(height: 16),

          _SummaryRow(
            showUpcoming: showUpcoming,
            totalIn: totalIn,
            totalOut: totalOut,
          ),
          const SizedBox(height: 8),

          if (days.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 48),
              child: Text(
                showUpcoming
                    ? 'No paydays or bills in the next 30 days.\nAdd income and bills on the Budget tab.'
                    : 'No spending logged in the last 14 days.\nAdd expenses on the Budget tab.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
            )
          else
            ..._buildDays(context, days),
        ],
      ),
    );
  }

  List<Widget> _buildDays(BuildContext context, List<TimelineDay> days) {
    final widgets = <Widget>[];
    double runningTotal = 0;

    for (final day in days) {
      runningTotal += day.net;

      widgets.add(
        Padding(
          padding: const EdgeInsets.fromLTRB(4, 16, 4, 8),
          child: Row(
            children: [
              Text(
                _dayLabel(day.date),
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const Spacer(),
              Text(
                showUpcoming
                    ? 'Running ${runningTotal >= 0 ? '+' : '−'}${_money(runningTotal.abs())}'
                    : 'Spent ${_money(day.moneyOut)}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
      );

      widgets.add(
        Card(
          margin: EdgeInsets.zero,
          child: Column(
            children: [
              for (int i = 0; i < day.events.length; i++) ...[
                if (i > 0)
                  Divider(
                    height: 1,
                    indent: 64,
                    color: Theme.of(context).colorScheme.outlineVariant,
                  ),
                _EventTile(event: day.events[i], money: _money),
              ],
            ],
          ),
        ),
      );
    }

    return widgets;
  }
}

class _SummaryRow extends StatelessWidget {
  final bool showUpcoming;
  final double totalIn;
  final double totalOut;

  const _SummaryRow({
    required this.showUpcoming,
    required this.totalIn,
    required this.totalOut,
  });

  String _money(double value) => '\$${value.toStringAsFixed(0)}';

  @override
  Widget build(BuildContext context) {
    final tiles = showUpcoming
        ? [
            _SummaryTile(
              label: 'Coming in',
              value: _money(totalIn),
              color: AppColors.emerald,
            ),
            _SummaryTile(
              label: 'Going out',
              value: _money(totalOut),
              color: AppColors.gold,
            ),
            _SummaryTile(
              label: 'Net',
              value:
                  '${totalIn - totalOut >= 0 ? '+' : '−'}${_money((totalIn - totalOut).abs())}',
              color: totalIn - totalOut >= 0
                  ? AppColors.emerald
                  : AppColors.warningRed,
            ),
          ]
        : [
            _SummaryTile(
              label: 'Spent',
              value: _money(totalOut),
              color: AppColors.gold,
            ),
            _SummaryTile(
              label: 'Daily average',
              value: _money(totalOut / 14),
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ];

    return Row(
      children: [
        for (int i = 0; i < tiles.length; i++) ...[
          if (i > 0) const SizedBox(width: 10),
          Expanded(child: tiles[i]),
        ],
      ],
    );
  }
}

class _SummaryTile extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _SummaryTile({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EventTile extends StatelessWidget {
  final TimelineEvent event;
  final String Function(double) money;

  const _EventTile({required this.event, required this.money});

  IconData get _icon {
    switch (event.type) {
      case TimelineEventType.payday:
        return Icons.payments_outlined;
      case TimelineEventType.bill:
        return event.isPaid ? Icons.check_circle : Icons.receipt_long_outlined;
      case TimelineEventType.spending:
        return Icons.shopping_bag_outlined;
    }
  }

  Color get _color {
    switch (event.type) {
      case TimelineEventType.payday:
        return AppColors.emerald;
      case TimelineEventType.bill:
        return event.isPaid ? AppColors.emerald : AppColors.gold;
      case TimelineEventType.spending:
        return AppColors.gold;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isIncome = event.amount >= 0;

    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: _color.withValues(alpha: 0.14),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(_icon, color: _color, size: 22),
      ),
      title: Text(
        event.title,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: Text(
        event.isPaid ? '${event.subtitle} • Paid' : event.subtitle,
        style: TextStyle(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
      trailing: Text(
        '${isIncome ? '+' : '−'}${money(event.amount.abs())}',
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w800,
          color: isIncome
              ? AppColors.emerald
              : Theme.of(context).colorScheme.onSurface,
        ),
      ),
    );
  }
}