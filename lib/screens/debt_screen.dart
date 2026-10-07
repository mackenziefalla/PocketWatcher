import 'package:flutter/material.dart';

import '../models/debt.dart';
import '../models/financial_data.dart';
import '../services/debt_forecast_service.dart';
import '../services/debt_strategy_service.dart';
import 'add_debt_screen.dart';

class DebtScreen extends StatefulWidget {
  final FinancialData financialData;

  const DebtScreen({
    super.key,
    required this.financialData,
  });

  @override
  State<DebtScreen> createState() => _DebtScreenState();
}

class _DebtScreenState extends State<DebtScreen> {
  List<Debt> get debts => widget.financialData.debts;

  double get totalDebt {
    return widget.financialData.totalDebt;
  }

  double get totalMinimumPayments {
    return widget.financialData.totalMinimumDebtPayments;
  }

  double get totalEstimatedMonthlyInterest {
    return widget.financialData.totalMonthlyInterest;
  }

  Future<void> _addDebt() async {
    final debt = await Navigator.push<Debt>(
      context,
      MaterialPageRoute(
        builder: (_) => const AddDebtScreen(),
      ),
    );

    if (debt != null) {
      setState(() {
        widget.financialData.addDebt(debt);
      });
    }
  }

  String _formatDate(DateTime date) {
    return '${date.month}/${date.day}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final snowballRecommendation =
        DebtStrategyService.getSnowballRecommendation(debts);

    final avalancheRecommendation =
        DebtStrategyService.getAvalancheRecommendation(debts);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Debt'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Debt Overview',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),

          const SizedBox(height: 6),

          Text(
            'Track balances, payments, interest, and payoff timelines.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),

          const SizedBox(height: 20),

          Row(
            children: [
              Expanded(
                child: _SummaryCard(
                  title: 'Total Debt',
                  value: '\$${totalDebt.toStringAsFixed(2)}',
                  icon: Icons.credit_card,
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: _SummaryCard(
                  title: 'Min. Payments',
                  value: '\$${totalMinimumPayments.toStringAsFixed(2)}',
                  icon: Icons.payments_outlined,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          _SummaryCard(
            title: 'Estimated Monthly Interest',
            value: '\$${totalEstimatedMonthlyInterest.toStringAsFixed(2)}',
            icon: Icons.percent,
          ),

          const SizedBox(height: 20),

          Card(
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Debt Accounts',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 12),

                  if (debts.isEmpty)
                    const Text(
                      'No debt accounts added yet.',
                    )
                  else
                    ...debts.map(
                      (debt) {
                        final forecast =
                            DebtForecastService.calculateForecast(debt);

                        return Card(
                          margin: const EdgeInsets.only(bottom: 14),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.account_balance_wallet_outlined,
                                      color: Colors.green,
                                    ),

                                    const SizedBox(width: 10),

                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            debt.name,
                                            style: const TextStyle(
                                              fontSize: 17,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Text(
                                            '${debt.type.label} • ${debt.interestRate.toStringAsFixed(2)}% APR',
                                            style: TextStyle(
                                              color: Colors.grey.shade700,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                    Text(
                                      '\$${debt.balance.toStringAsFixed(2)}',
                                      style: const TextStyle(
                                        fontSize: 17,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 14),

                                const Divider(),

                                const SizedBox(height: 10),

                                _ForecastRow(
                                  label: 'Minimum Payment',
                                  value:
                                      '\$${debt.minimumPayment.toStringAsFixed(2)}/mo',
                                ),

                                const SizedBox(height: 8),

                                _ForecastRow(
                                  label: 'Monthly Interest',
                                  value:
                                      '\$${debt.estimatedMonthlyInterest.toStringAsFixed(2)}',
                                ),

                                const SizedBox(height: 8),

                                if (forecast.canPayOff) ...[
                                  _ForecastRow(
                                    label: 'Estimated Payoff Time',
                                    value:
                                        DebtForecastService.formatPayoffTime(
                                      forecast.monthsToPayoff,
                                    ),
                                  ),

                                  const SizedBox(height: 8),

                                  _ForecastRow(
                                    label: 'Estimated Payoff Date',
                                    value: _formatDate(
                                      forecast.payoffDate,
                                    ),
                                  ),

                                  const SizedBox(height: 8),

                                  _ForecastRow(
                                    label: 'Estimated Interest Paid',
                                    value:
                                        '\$${forecast.totalInterest.toStringAsFixed(2)}',
                                  ),

                                  const SizedBox(height: 8),

                                  _ForecastRow(
                                    label: 'Estimated Total Paid',
                                    value:
                                        '\$${forecast.totalPaid.toStringAsFixed(2)}',
                                  ),
                                ] else ...[
                                  Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.red.shade50,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Text(
                                      'The current payment may not be enough to pay off this debt because interest is accumulating too quickly.',
                                      style: TextStyle(
                                        color: Colors.red,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        );
                      },
                    ),

                  const SizedBox(height: 12),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _addDebt,
                      icon: const Icon(Icons.add),
                      label: const Text('Add Debt'),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          Card(
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Payoff Strategies',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    'Compare two common ways to decide which debt to attack first.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),

                  const SizedBox(height: 18),

                  _StrategyCard(
                    title: 'Debt Snowball',
                    icon: Icons.snowing,
                    targetDebt: snowballRecommendation.targetDebt,
                    explanation: snowballRecommendation.explanation,
                    targetLabel: 'Smallest balance first',
                  ),

                  const SizedBox(height: 12),

                  _StrategyCard(
                    title: 'Debt Avalanche',
                    icon: Icons.trending_down,
                    targetDebt: avalancheRecommendation.targetDebt,
                    explanation: avalancheRecommendation.explanation,
                    targetLabel: 'Highest APR first',
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          Card(
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  const Icon(
                    Icons.timeline,
                    color: Colors.green,
                    size: 34,
                  ),

                  const SizedBox(width: 14),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Debt Forecast',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 6),

                        Text(
                          debts.isEmpty
                              ? 'Add debt accounts to begin forecasting payoff time.'
                              : 'Your payoff estimates are calculated from balance, APR, and monthly payment.',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const _SummaryCard({
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              icon,
              color: Colors.green,
            ),

            const SizedBox(height: 10),

            Text(
              title,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade700,
              ),
            ),

            const SizedBox(height: 4),

            Text(
              value,
              style: const TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ForecastRow extends StatelessWidget {
  final String label;
  final String value;

  const _ForecastRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              color: Colors.grey.shade700,
            ),
          ),
        ),

        const SizedBox(width: 12),

        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

class _StrategyCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Debt? targetDebt;
  final String explanation;
  final String targetLabel;

  const _StrategyCard({
    required this.title,
    required this.icon,
    required this.targetDebt,
    required this.explanation,
    required this.targetLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: Colors.green,
              ),

              const SizedBox(width: 10),

              Text(
                title,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          Text(
            targetLabel,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade700,
            ),
          ),

          const SizedBox(height: 6),

          if (targetDebt != null)
            Text(
              'Target: ${targetDebt!.name}',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            )
          else
            const Text(
              'No target yet',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),

          const SizedBox(height: 8),

          Text(
            explanation,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}