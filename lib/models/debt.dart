enum DebtType {
  creditCard,
  personalLoan,
  studentLoan,
  autoLoan,
  medical,
  other,
}

extension DebtTypeLabel on DebtType {
  String get label {
    switch (this) {
      case DebtType.creditCard:
        return 'Credit Card';
      case DebtType.personalLoan:
        return 'Personal Loan';
      case DebtType.studentLoan:
        return 'Student Loan';
      case DebtType.autoLoan:
        return 'Auto Loan';
      case DebtType.medical:
        return 'Medical';
      case DebtType.other:
        return 'Other';
    }
  }
}

class Debt {
  final String name;
  final DebtType type;
  final double balance;
  final double interestRate;
  final double minimumPayment;

  const Debt({
    required this.name,
    required this.type,
    required this.balance,
    required this.interestRate,
    required this.minimumPayment,
  });

  double get monthlyInterestRate {
    return interestRate / 100 / 12;
  }

  double get estimatedMonthlyInterest {
    return balance * monthlyInterestRate;
  }

  Debt copyWith({
    String? name,
    DebtType? type,
    double? balance,
    double? interestRate,
    double? minimumPayment,
  }) {
    return Debt(
      name: name ?? this.name,
      type: type ?? this.type,
      balance: balance ?? this.balance,
      interestRate: interestRate ?? this.interestRate,
      minimumPayment: minimumPayment ?? this.minimumPayment,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'type': type.name,
      'balance': balance,
      'interestRate': interestRate,
      'minimumPayment': minimumPayment,
    };
  }

  factory Debt.fromMap(Map<String, dynamic> map) {
    return Debt(
      name: map['name'] as String? ?? '',
      type: DebtType.values.firstWhere(
        (type) => type.name == map['type'],
        orElse: () => DebtType.other,
      ),
      balance: (map['balance'] as num?)?.toDouble() ?? 0,
      interestRate:
          (map['interestRate'] as num?)?.toDouble() ?? 0,
      minimumPayment:
          (map['minimumPayment'] as num?)?.toDouble() ?? 0,
    );
  }
}