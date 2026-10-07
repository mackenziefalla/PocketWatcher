import 'package:flutter/material.dart';

class FinancialSnapshot extends StatelessWidget {
  final double monthlyIncome;
  final double monthlyBills;
  final double savings;
  final double totalDebt;

  const FinancialSnapshot({
    super.key,
    required this.monthlyIncome,
    required this.monthlyBills,
    required this.savings,
    required this.totalDebt,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Financial Snapshot',
              style: TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: _SnapshotItem(
                    label: 'Monthly Income',
                    value: '\$${monthlyIncome.toStringAsFixed(0)}',
                    icon: Icons.trending_up,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _SnapshotItem(
                    label: 'Monthly Bills',
                    value: '\$${monthlyBills.toStringAsFixed(0)}',
                    icon: Icons.receipt_long_outlined,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _SnapshotItem(
                    label: 'Savings',
                    value: '\$${savings.toStringAsFixed(0)}',
                    icon: Icons.savings_outlined,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _SnapshotItem(
                    label: 'Total Debt',
                    value: '\$${totalDebt.toStringAsFixed(0)}',
                    icon: Icons.credit_card_outlined,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SnapshotItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _SnapshotItem({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: Colors.green,
          ),
          const SizedBox(height: 10),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}