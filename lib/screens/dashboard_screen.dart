import 'package:flutter/material.dart';

import '../models/financial_data.dart';
import '../services/score_service.dart';
import '../services/timeline_service.dart';
import '../theme/app_theme.dart';
import '../widgets/score_breakdown_card.dart';
import '../widgets/score_card.dart';
import '../widgets/score_history_chart.dart';
import '../widgets/score_tips_card.dart';
import '../widgets/week_strip.dart';

class DashboardScreen extends StatefulWidget {
  final FinancialData financialData;

  /// Called after the dashboard changes data (e.g. savings) so the
  /// parent can save it.
  final VoidCallback onDataChanged;

  /// Switches to the Timeline tab.
  final VoidCallback? onOpenTimeline;

  const DashboardScreen({
    super.key,
    required this.financialData,
    required this.onDataChanged,
    this.onOpenTimeline,
  });

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  FinancialData get data => widget.financialData;

  static const List<String> _weekdays = [
    'Monday', 'Tuesday', 'Wednesday', 'Thursday',
    'Friday', 'Saturday', 'Sunday',
  ];

  static const List<String> _months = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December',
  ];

  String _money(double value) {
    final negative = value < 0;
    final digits = value.abs().toStringAsFixed(0);
    final withCommas = digits.replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (match) => ',',
    );
    return '${negative ? '−' : ''}\$$withCommas';
  }

  String get _greeting {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  String get _todayText {
    final now = DateTime.now();
    return '${_weekdays[now.weekday - 1]}, ${_months[now.month - 1]} ${now.day}';
  }

  Future<void> _editSavings() async {
    final savingsController = TextEditingController(
      text: data.currentSavings > 0
          ? data.currentSavings.toStringAsFixed(0)
          : '',
    );
    final goalController = TextEditingController(
      text: data.savingsGoal > 0 ? data.savingsGoal.toStringAsFixed(0) : '',
    );

    final saved = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Update savings'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: savingsController,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Current savings',
                prefixText: '\$',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: goalController,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Savings goal',
                prefixText: '\$',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (saved == true) {
      double parse(String text) =>
          double.tryParse(text.replaceAll(',', '').trim()) ?? 0;

      setState(() {
        data.currentSavings = parse(savingsController.text);
        data.savingsGoal = parse(goalController.text);
      });
      widget.onDataChanged();
    }

    savingsController.dispose();
    goalController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final result = ScoreService.calculate(data);
    if (result.hasEnoughData) {
      data.recordScore(result.score);
    }
    final weeklyChange =
        result.hasEnoughData ? data.weeklyScoreChange(result.score) : null;

    final safeToSpend = data.safeToSpend;
    final netWorth = data.currentSavings - data.totalDebt;
    final savingsProgress = data.savingsGoal > 0
        ? (data.currentSavings / data.savingsGoal).clamp(0.0, 1.0)
        : 0.0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('PocketWatcher'),
        actions: [
          IconButton(
            tooltip: isDark ? 'Switch to light mode' : 'Switch to dark mode',
            icon: Icon(
              isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
            ),
            onPressed: () => ThemeController.toggle(context),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
        children: [
          Text(_greeting, style: textTheme.headlineMedium),
          const SizedBox(height: 2),
          Text(
            _todayText,
            style: textTheme.bodyMedium?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 18),

          ScoreCard(
            score: result.score,
            hasEnoughData: result.hasEnoughData,
            weeklyChange: weeklyChange,
          ),

          Row(
            children: [
              Expanded(
                child: _StatTile(
                  label: 'Safe to spend',
                  value: _money(safeToSpend < 0 ? 0 : safeToSpend),
                  caption: 'Left this month',
                  icon: Icons.account_balance_wallet_outlined,
                  color: scheme.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatTile(
                  label: 'Net worth',
                  value: _money(netWorth),
                  caption: 'Savings − debt',
                  icon: Icons.trending_up,
                  color: netWorth >= 0 ? scheme.primary : AppColors.warningRed,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          _SavingsGoalCard(
            saved: _money(data.currentSavings),
            goal: data.savingsGoal > 0 ? _money(data.savingsGoal) : null,
            progress: savingsProgress,
            onTap: _editSavings,
          ),

          WeekStrip(
            days: TimelineService.nextSevenDays(data),
            onOpenTimeline: widget.onOpenTimeline,
          ),

          ScoreTipsCard(tips: result.tips),

          if (result.hasEnoughData) ...[
            ScoreBreakdownCard(pillars: result.pillars),
            ScoreHistoryChart(history: data.scoreHistory),
          ],
        ],
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  final String label;
  final String value;
  final String caption;
  final IconData icon;
  final Color color;

  const _StatTile({
    required this.label,
    required this.value,
    required this.caption,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(height: 12),
            Text(label, style: textTheme.bodySmall),
            const SizedBox(height: 2),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                value,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ),
            Text(caption, style: textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}

class _SavingsGoalCard extends StatelessWidget {
  final String saved;
  final String? goal;
  final double progress;
  final VoidCallback onTap;

  const _SavingsGoalCard({
    required this.saved,
    required this.goal,
    required this.progress,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.savings_outlined, color: scheme.primary),
                  const SizedBox(width: 10),
                  Text('Savings goal', style: textTheme.titleMedium),
                  const Spacer(),
                  Text(
                    goal == null ? 'Set goal' : '${(progress * 100).round()}%',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      color: scheme.primary,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.edit_outlined,
                    size: 16,
                    color: scheme.onSurfaceVariant,
                  ),
                ],
              ),
              const SizedBox(height: 14),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 10,
                  backgroundColor: scheme.surfaceContainerHighest,
                  color: scheme.primary,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                goal == null
                    ? 'Tap to enter your savings and set a goal.'
                    : '$saved saved of $goal',
                style: textTheme.bodyMedium?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}