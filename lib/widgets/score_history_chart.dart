import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../models/score_snapshot.dart';

/// Line chart of the score over time.
class ScoreHistoryChart extends StatelessWidget {
  final List<ScoreSnapshot> history;

  const ScoreHistoryChart({
    super.key,
    required this.history,
  });

  static const List<String> _months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    // Show the last 12 weeks at most.
    final points = history.length > 84
        ? history.sublist(history.length - 84)
        : history;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Score history', style: textTheme.titleLarge),
            const SizedBox(height: 4),
            Text(
              'Saved once a day while you use the app.',
              style: textTheme.bodySmall,
            ),
            const SizedBox(height: 16),
            if (points.length < 2)
              SizedBox(
                height: 120,
                child: Center(
                  child: Text(
                    'Your trend line starts tomorrow. Come back to see it grow.',
                    textAlign: TextAlign.center,
                    style: textTheme.bodyMedium?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ),
              )
            else
              SizedBox(
                height: 180,
                child: LineChart(
                  LineChartData(
                    minY: _minY(points),
                    maxY: _maxY(points),
                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: false,
                      horizontalInterval: 100,
                      getDrawingHorizontalLine: (value) => FlLine(
                        color: scheme.outlineVariant,
                        strokeWidth: 1,
                      ),
                    ),
                    borderData: FlBorderData(show: false),
                    titlesData: FlTitlesData(
                      topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 36,
                          interval: 100,
                          getTitlesWidget: (value, meta) => Text(
                            value.toInt().toString(),
                            style: textTheme.bodySmall,
                          ),
                        ),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 26,
                          interval: _labelInterval(points.length),
                          getTitlesWidget: (value, meta) {
                            final index = value.round();
                            if (index < 0 || index >= points.length) {
                              return const SizedBox.shrink();
                            }
                            final date = points[index].date;
                            return Padding(
                              padding: const EdgeInsets.only(top: 6),
                              child: Text(
                                '${_months[date.month - 1]} ${date.day}',
                                style: textTheme.bodySmall,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    lineBarsData: [
                      LineChartBarData(
                        spots: [
                          for (int i = 0; i < points.length; i++)
                            FlSpot(i.toDouble(), points[i].score.toDouble()),
                        ],
                        isCurved: true,
                        preventCurveOverShooting: true,
                        color: scheme.primary,
                        barWidth: 3,
                        isStrokeCapRound: true,
                        dotData: FlDotData(show: points.length <= 14),
                        belowBarData: BarAreaData(
                          show: true,
                          color: scheme.primary.withValues(alpha: 0.12),
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

  double _minY(List<ScoreSnapshot> points) {
    final lowest = points.map((p) => p.score).reduce((a, b) => a < b ? a : b);
    final floor = ((lowest - 50) / 100).floor() * 100.0;
    return floor < 0 ? 0.0 : floor;
  }

  double _maxY(List<ScoreSnapshot> points) {
    final highest = points.map((p) => p.score).reduce((a, b) => a > b ? a : b);
    final ceiling = ((highest + 50) / 100).ceil() * 100.0;
    return ceiling > 1000 ? 1000.0 : ceiling;
  }

  double _labelInterval(int count) {
    if (count <= 7) return 1;
    return (count / 4).ceilToDouble();
  }
}