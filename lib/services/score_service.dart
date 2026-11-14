import '../models/bill.dart';
import '../models/debt.dart';
import '../models/expense.dart';
import '../models/financial_data.dart';
import 'debt_forecast_service.dart';

// ============================================================
// RESULT TYPES
// ============================================================

/// One part of the PocketWatcher Score (for example "Cash Flow").
class ScorePillar {
  final String name;
  final String description;
  final int points;
  final int maxPoints;
  final String status;

  const ScorePillar({
    required this.name,
    required this.description,
    required this.points,
    required this.maxPoints,
    required this.status,
  });

  double get progress => maxPoints == 0 ? 0 : points / maxPoints;
}

/// A specific, personal action the user can take, with the number of
/// points it is worth and what it does for their money.
class ScoreTip {
  final String title;
  final String detail;
  final int pointGain;
  final String? moneyImpact;

  const ScoreTip({
    required this.title,
    required this.detail,
    required this.pointGain,
    this.moneyImpact,
  });
}

class ScoreResult {
  final int score;
  final bool hasEnoughData;
  final List<ScorePillar> pillars;
  final List<ScoreTip> tips;

  const ScoreResult({
    required this.score,
    required this.hasEnoughData,
    required this.pillars,
    required this.tips,
  });

  ScoreTip? get nextBestMove => tips.isEmpty ? null : tips.first;
}

// ============================================================
// SCORE INPUTS
// ============================================================

/// Plain numbers the score is calculated from. Kept separate from
/// FinancialData so tips can ask "what if?" by changing one number
/// and re-scoring.
class _ScoreInputs {
  final double income;
  final double bills;
  final double expenses;
  final double savings;
  final double savingsGoal;
  final double totalDebt;
  final double minimumPayments;
  final double highAprDebt;
  final int overdueBills;
  final bool loggedRecently;
  final bool hasSpendingData;

  const _ScoreInputs({
    required this.income,
    required this.bills,
    required this.expenses,
    required this.savings,
    required this.savingsGoal,
    required this.totalDebt,
    required this.minimumPayments,
    required this.highAprDebt,
    required this.overdueBills,
    required this.loggedRecently,
    required this.hasSpendingData,
  });

  _ScoreInputs copyWith({
    double? expenses,
    double? bills,
    double? savings,
    double? savingsGoal,
    double? totalDebt,
    double? highAprDebt,
    int? overdueBills,
    bool? loggedRecently,
    bool? hasSpendingData,
  }) {
    return _ScoreInputs(
      income: income,
      bills: bills ?? this.bills,
      expenses: expenses ?? this.expenses,
      savings: savings ?? this.savings,
      savingsGoal: savingsGoal ?? this.savingsGoal,
      totalDebt: totalDebt ?? this.totalDebt,
      minimumPayments: minimumPayments,
      highAprDebt: highAprDebt ?? this.highAprDebt,
      overdueBills: overdueBills ?? this.overdueBills,
      loggedRecently: loggedRecently ?? this.loggedRecently,
      hasSpendingData: hasSpendingData ?? this.hasSpendingData,
    );
  }
}

// ============================================================
// SCORE SERVICE
// ============================================================

class ScoreService {
  // Point weights. They add up to 1000.
  static const int cashFlowMax = 250;
  static const int bufferMax = 250;
  static const int debtMax = 250;
  static const int spendingMax = 150;
  static const int habitsMax = 100;

  /// APR at or above this counts as "high interest" debt.
  static const double highAprThreshold = 15;

  /// Categories treated as flexible "wants" when looking for savings.
  static const List<ExpenseCategory> flexibleCategories = [
    ExpenseCategory.dining,
    ExpenseCategory.shopping,
    ExpenseCategory.entertainment,
    ExpenseCategory.subscriptions,
    ExpenseCategory.other,
  ];

  static ScoreResult calculate(FinancialData data, {DateTime? now}) {
    final today = now ?? DateTime.now();
    final inputs = _inputsFrom(data, today);

    if (inputs.income <= 0) {
      return const ScoreResult(
        score: 0,
        hasEnoughData: false,
        pillars: [],
        tips: [
          ScoreTip(
            title: 'Add your income',
            detail:
                'Your score starts once PocketWatcher knows what you earn. '
                'Add your income on the Budget tab.',
            pointGain: 0,
          ),
        ],
      );
    }

    final pillars = _pillarsFor(inputs);
    final score = _total(pillars);
    final tips = _buildTips(data, inputs, score, today);

    return ScoreResult(
      score: score,
      hasEnoughData: true,
      pillars: pillars,
      tips: tips,
    );
  }

  // ----------------------------------------------------------
  // Inputs
  // ----------------------------------------------------------

  static _ScoreInputs _inputsFrom(FinancialData data, DateTime today) {
    final highAprDebt = data.debts
        .where((debt) => debt.interestRate >= highAprThreshold)
        .fold(0.0, (total, debt) => total + debt.balance);

    final weekAgo = today.subtract(const Duration(days: 7));
    final loggedRecently =
        data.expenses.any((expense) => expense.date.isAfter(weekAgo));

    return _ScoreInputs(
      income: data.totalMonthlyIncome,
      bills: data.totalBills,
      expenses: data.totalExpenses,
      savings: data.currentSavings,
      savingsGoal: data.savingsGoal,
      totalDebt: data.totalDebt,
      minimumPayments: data.totalMinimumDebtPayments,
      highAprDebt: highAprDebt,
      overdueBills: _overdueBills(data.bills, today).length,
      loggedRecently: loggedRecently,
      hasSpendingData: data.currentMonthExpenses.isNotEmpty,
    );
  }

  static List<Bill> _overdueBills(List<Bill> bills, DateTime today) {
    final startOfToday = DateTime(today.year, today.month, today.day);
    return bills
        .where((bill) => !bill.isPaid && bill.dueDate.isBefore(startOfToday))
        .toList();
  }

  // ----------------------------------------------------------
  // Pillars
  // ----------------------------------------------------------

  static int _total(List<ScorePillar> pillars) {
    return pillars.fold(0, (total, pillar) => total + pillar.points);
  }

  static int _scoreOnly(_ScoreInputs inputs) => _total(_pillarsFor(inputs));

  static double _clamp01(double value) {
    if (value.isNaN) return 0;
    if (value < 0) return 0;
    if (value > 1) return 1;
    return value;
  }

  static List<ScorePillar> _pillarsFor(_ScoreInputs i) {
    return [
      _cashFlow(i),
      _buffer(i),
      _debt(i),
      _spending(i),
      _habits(i),
    ];
  }

  /// Cash Flow: share of income left after bills and spending.
  /// Keeping 20% or more earns full points.
  static ScorePillar _cashFlow(_ScoreInputs i) {
    final leftover = i.income - i.bills - i.expenses;
    final rate = leftover / i.income;
    int points = (_clamp01(rate / 0.20) * cashFlowMax).round();

    // Without any spending logged, leftover money looks bigger than it
    // really is, so cap this part until spending is tracked.
    if (!i.hasSpendingData) {
      const cap = 150;
      if (points > cap) points = cap;
      return ScorePillar(
        name: 'Cash Flow',
        description: 'Money left after bills and spending',
        points: points,
        maxPoints: cashFlowMax,
        status: 'No spending logged this month. Log expenses to unlock full points.',
      );
    }

    String status;
    if (rate < 0) {
      status = 'Spending more than you earn this month.';
    } else if (rate < 0.10) {
      status = 'Keeping ${(rate * 100).toStringAsFixed(0)}% of income. Aim for 20%.';
    } else if (rate < 0.20) {
      status = 'Keeping ${(rate * 100).toStringAsFixed(0)}% of income. Almost there.';
    } else {
      status = 'Keeping ${(rate * 100).toStringAsFixed(0)}% of income. Great.';
    }

    return ScorePillar(
      name: 'Cash Flow',
      description: 'Money left after bills and spending',
      points: points,
      maxPoints: cashFlowMax,
      status: status,
    );
  }

  /// Emergency Buffer: months of bills covered by savings.
  /// Three months earns full points.
  static ScorePillar _buffer(_ScoreInputs i) {
    final monthlyNeeds = i.bills > 0 ? i.bills : i.income * 0.5;
    final months = monthlyNeeds > 0 ? i.savings / monthlyNeeds : 0.0;
    final points = (_clamp01(months / 3) * bufferMax).round();

    String status;
    if (i.savings <= 0) {
      status = 'No savings entered yet.';
    } else if (months >= 3) {
      status = '${months.toStringAsFixed(1)} months of bills covered. Solid.';
    } else {
      status =
          '${months.toStringAsFixed(1)} months of bills covered. Goal: 3.';
    }

    return ScorePillar(
      name: 'Emergency Buffer',
      description: 'Months of bills your savings could cover',
      points: points,
      maxPoints: bufferMax,
      status: status,
    );
  }

  /// Debt Load: 200 pts for how much of income goes to minimum
  /// payments (10% or less = full, 40%+ = none) and 50 pts for how
  /// little of the debt is high-interest.
  static ScorePillar _debt(_ScoreInputs i) {
    if (i.totalDebt <= 0) {
      return const ScorePillar(
        name: 'Debt Load',
        description: 'Debt payments and interest cost',
        points: debtMax,
        maxPoints: debtMax,
        status: 'No debt entered. Full points.',
      );
    }

    final ratio = i.minimumPayments / i.income;
    final ratioPoints = _clamp01((0.40 - ratio) / 0.30) * 200;
    final highShare = _clamp01(i.highAprDebt / i.totalDebt);
    final aprPoints = (1 - highShare) * 50;
    final points = (ratioPoints + aprPoints).round();

    String status =
        '${(ratio * 100).toStringAsFixed(0)}% of income goes to minimum payments.';
    if (highShare > 0) {
      status += ' ${(highShare * 100).toStringAsFixed(0)}% of your debt is high-interest.';
    }

    return ScorePillar(
      name: 'Debt Load',
      description: 'Debt payments and interest cost',
      points: points,
      maxPoints: debtMax,
      status: status,
    );
  }

  /// Spending Control: this month's flexible spending as a share of
  /// income. 25% or less = full points, 50%+ = none.
  static ScorePillar _spending(_ScoreInputs i) {
    if (!i.hasSpendingData) {
      return const ScorePillar(
        name: 'Spending Control',
        description: 'This month\'s spending compared with income',
        points: 75,
        maxPoints: spendingMax,
        status: 'No spending logged this month yet. Half credit until you do.',
      );
    }

    final share = i.expenses / i.income;
    final points = (_clamp01((0.50 - share) / 0.25) * spendingMax).round();

    return ScorePillar(
      name: 'Spending Control',
      description: 'This month\'s spending compared with income',
      points: points,
      maxPoints: spendingMax,
      status:
          'Spent ${(share * 100).toStringAsFixed(0)}% of income this month. Target: 25% or less.',
    );
  }

  /// Habits: bills on time (40), tracking this week (30),
  /// having a savings goal (30).
  static ScorePillar _habits(_ScoreInputs i) {
    int billPoints = 40 - i.overdueBills * 20;
    if (billPoints < 0) billPoints = 0;
    final trackPoints = i.loggedRecently ? 30 : 0;
    final goalPoints = i.savingsGoal > 0 ? 30 : 0;

    final parts = <String>[];
    parts.add(i.overdueBills == 0
        ? 'No overdue bills'
        : '${i.overdueBills} overdue bill${i.overdueBills == 1 ? '' : 's'}');
    parts.add(i.loggedRecently ? 'tracked this week' : 'nothing logged this week');
    parts.add(i.savingsGoal > 0 ? 'goal set' : 'no savings goal');

    return ScorePillar(
      name: 'Habits',
      description: 'Paying on time, tracking, and setting goals',
      points: billPoints + trackPoints + goalPoints,
      maxPoints: habitsMax,
      status: '${parts.join(', ')}.',
    );
  }

  // ----------------------------------------------------------
  // Tips: each one re-scores a "what if" to get its point value
  // ----------------------------------------------------------

  static String _money(double value) => '\$${value.toStringAsFixed(0)}';

  static List<ScoreTip> _buildTips(
    FinancialData data,
    _ScoreInputs inputs,
    int currentScore,
    DateTime today,
  ) {
    final tips = <ScoreTip>[];

    int gain(_ScoreInputs whatIf) => _scoreOnly(whatIf) - currentScore;

    // 1. Pay overdue bills.
    final overdue = _overdueBills(data.bills, today);
    if (overdue.isNotEmpty) {
      final names = overdue.map((bill) => bill.name).take(2).join(' and ');
      tips.add(ScoreTip(
        title: 'Pay $names',
        detail: 'Overdue bills cost you points and can bring late fees. '
            'Tap them on the Budget tab once they are paid.',
        pointGain: gain(inputs.copyWith(overdueBills: 0)),
      ));
    }

    // 2. Trim the biggest flexible spending category by 20%.
    final byCategory = <ExpenseCategory, double>{};
    for (final expense in data.currentMonthExpenses) {
      if (flexibleCategories.contains(expense.category)) {
        byCategory[expense.category] =
            (byCategory[expense.category] ?? 0) + expense.amount;
      }
    }
    if (byCategory.isNotEmpty) {
      final top = byCategory.entries
          .reduce((a, b) => a.value >= b.value ? a : b);
      final cut = top.value * 0.20;
      if (cut >= 5) {
        final groceries = data.currentMonthExpenses
            .where((e) => e.category == ExpenseCategory.groceries)
            .fold(0.0, (total, e) => total + e.amount);
        String detail =
            'You have spent ${_money(top.value)} on ${top.key.label.toLowerCase()} this month.';
        if (top.key == ExpenseCategory.dining && groceries > 0) {
          final multiple = top.value / groceries;
          if (multiple >= 1.2) {
            detail += ' That is ${multiple.toStringAsFixed(1)}× your grocery spending.';
          }
        }
        detail += ' Cutting 20% frees up ${_money(cut)}.';
        tips.add(ScoreTip(
          title: 'Cut ${top.key.label} by ${_money(cut)}',
          detail: detail,
          pointGain: gain(inputs.copyWith(expenses: inputs.expenses - cut)),
          moneyImpact: '${_money(cut * 12)}/year',
        ));
      }
    }

    // 3. Review subscriptions (bills tagged as subscriptions).
    final subscriptionBills = data.bills
        .where((bill) => bill.category == BillCategory.subscriptions)
        .toList();
    final subscriptionTotal =
        subscriptionBills.fold(0.0, (total, bill) => total + bill.amount);
    if (subscriptionBills.length >= 2 && subscriptionTotal > 0) {
      final smallest = subscriptionBills
          .reduce((a, b) => a.amount <= b.amount ? a : b);
      tips.add(ScoreTip(
        title: 'Cancel one subscription',
        detail: 'You have ${subscriptionBills.length} subscriptions totaling '
            '${_money(subscriptionTotal)}/month. Dropping ${smallest.name} '
            'alone saves ${_money(smallest.amount)}/month.',
        pointGain:
            gain(inputs.copyWith(bills: inputs.bills - smallest.amount)),
        moneyImpact: '${_money(smallest.amount * 12)}/year',
      ));
    }

    // 4. Move part of this month's leftover into savings.
    final leftover = inputs.income - inputs.bills - inputs.expenses;
    final monthlyNeeds = inputs.bills > 0 ? inputs.bills : inputs.income * 0.5;
    final bufferTarget = monthlyNeeds * 3;
    if (leftover > 25 && inputs.savings < bufferTarget) {
      double transfer = leftover * 0.30;
      final stillNeeded = bufferTarget - inputs.savings;
      if (transfer > stillNeeded) transfer = stillNeeded;
      String detail = 'You have about ${_money(leftover)} left this month. '
          'Moving ${_money(transfer)} to savings grows your emergency buffer.';
      if (inputs.savingsGoal > inputs.savings && transfer > 0) {
        final monthsToGoal =
            ((inputs.savingsGoal - inputs.savings) / transfer).ceil();
        detail += ' At that pace you reach your ${_money(inputs.savingsGoal)} '
            'goal in about $monthsToGoal month${monthsToGoal == 1 ? '' : 's'}.';
      }
      tips.add(ScoreTip(
        title: 'Move ${_money(transfer)} to savings',
        detail: detail,
        pointGain: gain(inputs.copyWith(savings: inputs.savings + transfer)),
      ));
    }

    // 5. Extra payment on the highest-APR debt.
    final payable = data.debts
        .where((debt) => debt.balance > 0 && debt.minimumPayment > 0)
        .toList();
    if (payable.isNotEmpty && leftover > 25) {
      final target =
          payable.reduce((a, b) => a.interestRate >= b.interestRate ? a : b);
      double extra = leftover * 0.25;
      if (extra > target.balance) extra = target.balance;
      extra = (extra / 5).floorToDouble() * 5;
      if (extra >= 10) {
        final tip = _extraPaymentTip(target, extra, inputs, gain);
        if (tip != null) tips.add(tip);
      }
    }

    // 6. Set a savings goal.
    if (inputs.savingsGoal <= 0) {
      tips.add(ScoreTip(
        title: 'Set a savings goal',
        detail: 'People with a specific target save more consistently. '
            'Tap the Savings goal card on the Home tab to set one.',
        pointGain: gain(inputs.copyWith(savingsGoal: 1)),
      ));
    }

    // 7. Log spending.
    if (!inputs.loggedRecently || !inputs.hasSpendingData) {
      final whatIf = inputs.copyWith(
        loggedRecently: true,
        hasSpendingData: true,
      );
      tips.add(ScoreTip(
        title: inputs.hasSpendingData
            ? 'Log this week\'s spending'
            : 'Log this month\'s spending',
        detail: inputs.hasSpendingData
            ? 'Your score is only as accurate as your data. '
                'Add anything you have spent in the last 7 days.'
            : 'Your score cannot see your spending yet, so Cash Flow and '
                'Spending Control are only getting partial credit. '
                'Add what you have spent this month to unlock up to these points.',
        pointGain: gain(whatIf),
      ));
    }

    // Biggest point gains first; money-saving tips break ties.
    tips.sort((a, b) {
      final byPoints = b.pointGain.compareTo(a.pointGain);
      if (byPoints != 0) return byPoints;
      return (b.moneyImpact == null ? 0 : 1)
          .compareTo(a.moneyImpact == null ? 0 : 1);
    });

    return tips;
  }

  static ScoreTip? _extraPaymentTip(
    Debt target,
    double extra,
    _ScoreInputs inputs,
    int Function(_ScoreInputs) gain,
  ) {
    final base = DebtForecastService.calculateForecast(target);
    final faster = DebtForecastService.calculateForecast(
      target.copyWith(minimumPayment: target.minimumPayment + extra),
    );

    String detail = '${target.name} has the highest APR '
        '(${target.interestRate.toStringAsFixed(1)}%). '
        'Adding ${_money(extra)}/month to it';
    String? impact;

    if (base.canPayOff && faster.canPayOff) {
      final monthsSooner = base.monthsToPayoff - faster.monthsToPayoff;
      final interestSaved = base.totalInterest - faster.totalInterest;
      detail += ' pays it off $monthsSooner month${monthsSooner == 1 ? '' : 's'} '
          'sooner and saves about ${_money(interestSaved)} in interest.';
      if (interestSaved >= 1) impact = '${_money(interestSaved)} interest saved';
    } else if (!base.canPayOff && faster.canPayOff) {
      detail += ' finally gets it shrinking. Right now the minimum barely '
          'covers the interest. Payoff in ${faster.monthsToPayoff} months.';
      impact = 'Debt-free in ${faster.monthsToPayoff} mo';
    } else {
      detail += ' speeds up your payoff.';
    }

    // Points: one month of the extra payment lowers the balance.
    final isHighApr = target.interestRate >= highAprThreshold;
    final whatIf = inputs.copyWith(
      totalDebt: inputs.totalDebt - extra,
      highAprDebt: isHighApr ? inputs.highAprDebt - extra : inputs.highAprDebt,
    );

    return ScoreTip(
      title: 'Pay ${_money(extra)} extra on ${target.name}',
      detail: detail,
      pointGain: gain(whatIf),
      moneyImpact: impact,
    );
  }
}