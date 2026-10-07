class UserProfile {
  final String name;
  final double monthlyIncome;
  final double monthlyBills;
  final double totalDebt;
  final double savings;
  final double savingsGoal;
  final int pocketWatcherScore;

  const UserProfile({
    required this.name,
    required this.monthlyIncome,
    required this.monthlyBills,
    required this.totalDebt,
    required this.savings,
    required this.savingsGoal,
    required this.pocketWatcherScore,
  });

  double get safeToSpend {
    final remainingMoney = monthlyIncome - monthlyBills;

    if (remainingMoney < 0) {
      return 0;
    }

    return remainingMoney;
  }

  double get netWorth {
    return savings - totalDebt;
  }

  double get savingsProgress {
    if (savingsGoal <= 0) {
      return 0;
    }

    final progress = savings / savingsGoal;

    if (progress > 1) {
      return 1;
    }

    return progress;
  }

  UserProfile copyWith({
    String? name,
    double? monthlyIncome,
    double? monthlyBills,
    double? totalDebt,
    double? savings,
    double? savingsGoal,
    int? pocketWatcherScore,
  }) {
    return UserProfile(
      name: name ?? this.name,
      monthlyIncome: monthlyIncome ?? this.monthlyIncome,
      monthlyBills: monthlyBills ?? this.monthlyBills,
      totalDebt: totalDebt ?? this.totalDebt,
      savings: savings ?? this.savings,
      savingsGoal: savingsGoal ?? this.savingsGoal,
      pocketWatcherScore:
          pocketWatcherScore ?? this.pocketWatcherScore,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'monthlyIncome': monthlyIncome,
      'monthlyBills': monthlyBills,
      'totalDebt': totalDebt,
      'savings': savings,
      'savingsGoal': savingsGoal,
      'pocketWatcherScore': pocketWatcherScore,
    };
  }

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      name: map['name'] as String? ?? '',
      monthlyIncome:
          (map['monthlyIncome'] as num?)?.toDouble() ?? 0,
      monthlyBills:
          (map['monthlyBills'] as num?)?.toDouble() ?? 0,
      totalDebt:
          (map['totalDebt'] as num?)?.toDouble() ?? 0,
      savings:
          (map['savings'] as num?)?.toDouble() ?? 0,
      savingsGoal:
          (map['savingsGoal'] as num?)?.toDouble() ?? 0,
      pocketWatcherScore:
          (map['pocketWatcherScore'] as num?)?.toInt() ?? 0,
    );
  }
}