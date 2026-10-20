import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class SpendingTrendChart extends StatelessWidget {
  final List<double> weeklySpending;

  const SpendingTrendChart({
    super.key,
    required this.weeklySpending,
  });

  @override
  Widget build(BuildContext context) {
    if (weeklySpending.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Center(
            child: Text('No spending data available yet.'),
          ),
        ),
      );
    }

    final maxSpending = weeklySpending.reduce(
      (current, next) => current > next ? current : next,
    );

    final maxY = maxSpending == 0 ? 100.0 : maxSpending * 1.25;

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Spending Trend',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Track how your spending changes throughout the month.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),

            SizedBox(
              height: 260,
              child: LineChart(
                LineChartData(
                  minY: 0,
                  maxY: maxY,
                  gridData: const FlGridData(
                    show: true,
                  ),
                  borderData: FlBorderData(
                    show: false,
                  ),
                  titlesData: FlTitlesData(
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: false,
                      ),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: false,
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 50,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            '\$${value.toInt()}',
                            style: const TextStyle(
                              fontSize: 11,
                            ),
                          );
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: 1, //  one label per week
                        getTitlesWidget: (value, meta) {
                          final week = value.toInt();

                          if (week < 0 ||
                              week >= weeklySpending.length) {
                            return const SizedBox.shrink();
                          }

                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              'W${week + 1}',
                              style: const TextStyle(
                                fontSize: 12,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  lineBarsData: [
                    LineChartBarData(
                      spots: List.generate(
                        weeklySpending.length,
                        (index) => FlSpot(
                          index.toDouble(),
                          weeklySpending[index],
                        ),
                      ),
                      isCurved: false, //straight lines, no fake curve
                      barWidth: 4,
                      dotData: const FlDotData(
                        show: true,
                      ),
                      belowBarData: BarAreaData(
                        show: true,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            Row(
              children: [
                const Icon(
                  Icons.insights_outlined,
                  color: Colors.green,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    _buildInsight(),
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // honest insight — names your biggest spending week
  String _buildInsight() {
    if (weeklySpending.length < 2) {
      return 'Add more expense history to see spending trends.';
    }

    final total = weeklySpending.fold(0.0, (sum, week) => sum + week);

    if (total == 0) {
      return 'No spending recorded yet this month.';
    }

    final allEqual =
        weeklySpending.every((week) => week == weeklySpending.first);

    if (allEqual) {
      return 'Your weekly spending has stayed relatively consistent.';
    }

    final highest = weeklySpending.reduce(
      (current, next) => current > next ? current : next,
    );
    final highestWeek = weeklySpending.indexOf(highest) + 1;

    return 'Your biggest spending week so far is Week $highestWeek '
        'at \$${highest.toStringAsFixed(0)}.';
  }
}
