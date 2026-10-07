class Income {
  final String source;
  final double amount;
  final PayFrequency frequency;
  final DateTime nextPayDate;

  const Income({
    required this.source,
    required this.amount,
    required this.frequency,
    required this.nextPayDate,
  });

  double get estimatedMonthlyIncome {
    switch (frequency) {
      case PayFrequency.weekly:
        return amount * 52 / 12;

      case PayFrequency.biweekly:
        return amount * 26 / 12;

      case PayFrequency.twiceMonthly:
        return amount * 2;

      case PayFrequency.monthly:
        return amount;
    }
  }

  Income copyWith({
    String? source,
    double? amount,
    PayFrequency? frequency,
    DateTime? nextPayDate,
  }) {
    return Income(
      source: source ?? this.source,
      amount: amount ?? this.amount,
      frequency: frequency ?? this.frequency,
      nextPayDate: nextPayDate ?? this.nextPayDate,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'source': source,
      'amount': amount,
      'frequency': frequency.name,
      'nextPayDate': nextPayDate.toIso8601String(),
    };
  }

  factory Income.fromMap(Map<String, dynamic> map) {
    return Income(
      source: map['source'] as String? ?? '',
      amount: (map['amount'] as num?)?.toDouble() ?? 0,
      frequency: PayFrequency.values.firstWhere(
        (frequency) => frequency.name == map['frequency'],
        orElse: () => PayFrequency.monthly,
      ),
      nextPayDate: DateTime.tryParse(
            map['nextPayDate'] as String? ?? '',
          ) ??
          DateTime.now(),
    );
  }
}

enum PayFrequency {
  weekly,
  biweekly,
  twiceMonthly,
  monthly,
}

extension PayFrequencyLabel on PayFrequency {
  String get label {
    switch (this) {
      case PayFrequency.weekly:
        return 'Weekly';

      case PayFrequency.biweekly:
        return 'Biweekly';

      case PayFrequency.twiceMonthly:
        return 'Twice Monthly';

      case PayFrequency.monthly:
        return 'Monthly';
    }
  }
}