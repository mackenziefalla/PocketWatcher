import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class CashFlowChart extends StatelessWidget {
  final double income;
  final double bills;
  final double expenses;

  const CashFlowChart({
    super.key,
    required this.income,
    required this.bills,
    required this.expenses,
  });

  double get netCashFlow {
    return income - bills - expenses;
  }

  @override
  Widget build(BuildContext context) {
    final maxValue = [
      income,
      bills,
      expenses,
      netCashFlow.abs(),
    ].reduce((current, next) => current > next ? current : next);

    final maxY = maxValue == 0 ? 100.0 : maxValue * 1.25;

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Cash Flow',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 6),

            Text(
              'Compare your monthly income, bills, and spending.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),

            const SizedBox(height: 24),

            SizedBox(
              height: 280,
              child: BarChart(
                BarChartData(
                  minY: netCashFlow < 0 ? netCashFlow * 1.25 : 0,
                  maxY: maxY,
                  alignment: BarChartAlignment.spaceAround,
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
                        reservedSize: 55,
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
                        getTitlesWidget: (value, meta) {
                          switch (value.toInt()) {
                            case 0:
                              return const Text('Income');

                            case 1:
                              return const Text('Bills');

                            case 2:
                              return const Text('Expenses');

                            case 3:
                              return const Text('Net');

                            default:
                              return const SizedBox.shrink();
                          }
                        },
                      ),
                    ),
                  ),
                  barGroups: [
                    _buildBar(
                      index: 0,
                      value: income,
                    ),
                    _buildBar(
                      index: 1,
                      value: bills,
                    ),
                    _buildBar(
                      index: 2,
                      value: expenses,
                    ),
                    _buildBar(
                      index: 3,
                      value: netCashFlow,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 18),

            Row(
              children: [
                Icon(
                  netCashFlow >= 0
                      ? Icons.trending_up
                      : Icons.trending_down,
                  color:
                      netCashFlow >= 0 ? Colors.green : Colors.red,
                ),

                const SizedBox(width: 10),

                Expanded(
                  child: Text(
                    _buildCashFlowMessage(),
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            Text(
              'Net Cash Flow: \$${netCashFlow.toStringAsFixed(2)}',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  BarChartGroupData _buildBar({
    required int index,
    required double value,
  }) {
    return BarChartGroupData(
      x: index,
      barRods: [
        BarChartRodData(
          toY: value,
          width: 28,
          borderRadius: BorderRadius.circular(6),
        ),
      ],
    );
  }

  String _buildCashFlowMessage() {
    if (income == 0) {
      return 'Add income to begin analyzing your monthly cash flow.';
    }

    if (netCashFlow > 0) {
      return 'You are currently bringing in more money than you are spending.';
    }

    if (netCashFlow < 0) {
      return 'Your bills and expenses are currently higher than your income.';
    }

    return 'Your income currently matches your bills and expenses.';
  }
}