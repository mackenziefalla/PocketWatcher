import 'package:flutter/material.dart';

import '../models/user_profile.dart';
import '../widgets/financial_snapshot.dart';
import '../widgets/info_card.dart';
import '../widgets/score_card.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const user = UserProfile(
      name: 'Mackenzie',
      monthlyIncome: 5200,
      monthlyBills: 3650,
      totalDebt: 8400,
      savings: 6200,
      savingsGoal: 10000,
      pocketWatcherScore: 720,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('PocketWatcher'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Welcome back, ${user.name}',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 6),
          Text(
            'Here is your financial overview.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 20),

          ScoreCard(
            score: user.pocketWatcherScore,
          ),

          const SizedBox(height: 16),

          FinancialSnapshot(
            monthlyIncome: user.monthlyIncome,
            monthlyBills: user.monthlyBills,
            savings: user.savings,
            totalDebt: user.totalDebt,
          ),

          const SizedBox(height: 16),

          InfoCard(
            title: 'Safe to Spend',
            amount: '\$${user.safeToSpend.toStringAsFixed(0)}',
            subtitle: 'After monthly bills are covered.',
            icon: Icons.attach_money,
          ),

          InfoCard(
            title: 'Net Worth',
            amount: '\$${user.netWorth.toStringAsFixed(0)}',
            subtitle: 'Savings minus total debt.',
            icon: Icons.account_balance_wallet_outlined,
          ),

          InfoCard(
            title: 'Savings Goal',
            amount:
                '${(user.savingsProgress * 100).toStringAsFixed(0)}%',
            subtitle:
                '\$${user.savings.toStringAsFixed(0)} saved toward your \$${user.savingsGoal.toStringAsFixed(0)} goal.',
            icon: Icons.savings_outlined,
          ),

          const InfoCard(
            title: 'Upcoming Bills',
            amount: '\$1,450',
            subtitle:
                'Rent, car insurance, phone, and credit card.',
            icon: Icons.calendar_month,
          ),

          const InfoCard(
            title: 'Next Best Move',
            amount: 'Pay \$175',
            subtitle:
                'Put this toward your highest-interest credit card.',
            icon: Icons.lightbulb_outline,
          ),
        ],
      ),
    );
  }
}