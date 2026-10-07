import '../models/debt.dart';

enum DebtStrategy {
  snowball,
  avalanche,
}

extension DebtStrategyLabel on DebtStrategy {
  String get label {
    switch (this) {
      case DebtStrategy.snowball:
        return 'Debt Snowball';

      case DebtStrategy.avalanche:
        return 'Debt Avalanche';
    }
  }
}

class DebtStrategyRecommendation {
  final DebtStrategy strategy;
  final Debt? targetDebt;
  final String explanation;

  const DebtStrategyRecommendation({
    required this.strategy,
    required this.targetDebt,
    required this.explanation,
  });
}

class DebtStrategyService {
  static DebtStrategyRecommendation getSnowballRecommendation(
    List<Debt> debts,
  ) {
    if (debts.isEmpty) {
      return const DebtStrategyRecommendation(
        strategy: DebtStrategy.snowball,
        targetDebt: null,
        explanation: 'Add debt accounts to receive a Snowball recommendation.',
      );
    }

    final sortedDebts = [...debts]
      ..sort(
        (a, b) => a.balance.compareTo(b.balance),
      );

    final targetDebt = sortedDebts.first;

    return DebtStrategyRecommendation(
      strategy: DebtStrategy.snowball,
      targetDebt: targetDebt,
      explanation:
          'Focus extra payments on ${targetDebt.name} first because it has the smallest balance.',
    );
  }

  static DebtStrategyRecommendation getAvalancheRecommendation(
    List<Debt> debts,
  ) {
    if (debts.isEmpty) {
      return const DebtStrategyRecommendation(
        strategy: DebtStrategy.avalanche,
        targetDebt: null,
        explanation:
            'Add debt accounts to receive an Avalanche recommendation.',
      );
    }

    final sortedDebts = [...debts]
      ..sort(
        (a, b) => b.interestRate.compareTo(a.interestRate),
      );

    final targetDebt = sortedDebts.first;

    return DebtStrategyRecommendation(
      strategy: DebtStrategy.avalanche,
      targetDebt: targetDebt,
      explanation:
          'Focus extra payments on ${targetDebt.name} first because it has the highest APR at ${targetDebt.interestRate.toStringAsFixed(2)}%.',
    );
  }

  static List<Debt> getSnowballOrder(List<Debt> debts) {
    final sortedDebts = [...debts]
      ..sort(
        (a, b) => a.balance.compareTo(b.balance),
      );

    return sortedDebts;
  }

  static List<Debt> getAvalancheOrder(List<Debt> debts) {
    final sortedDebts = [...debts]
      ..sort(
        (a, b) => b.interestRate.compareTo(a.interestRate),
      );

    return sortedDebts;
  }
}