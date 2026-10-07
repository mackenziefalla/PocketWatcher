enum BillCategory {
  housing,
  utilities,
  transportation,
  insurance,
  subscriptions,
  debt,
  other,
}

extension BillCategoryLabel on BillCategory {
  String get label {
    switch (this) {
      case BillCategory.housing:
        return 'Housing';
      case BillCategory.utilities:
        return 'Utilities';
      case BillCategory.transportation:
        return 'Transportation';
      case BillCategory.insurance:
        return 'Insurance';
      case BillCategory.subscriptions:
        return 'Subscriptions';
      case BillCategory.debt:
        return 'Debt';
      case BillCategory.other:
        return 'Other';
    }
  }
}

class Bill {
  final String name;
  final double amount;
  final DateTime dueDate;
  final BillCategory category;
  final bool isPaid;

  const Bill({
    required this.name,
    required this.amount,
    required this.dueDate,
    required this.category,
    this.isPaid = false,
  });

  Bill copyWith({
    String? name,
    double? amount,
    DateTime? dueDate,
    BillCategory? category,
    bool? isPaid,
  }) {
    return Bill(
      name: name ?? this.name,
      amount: amount ?? this.amount,
      dueDate: dueDate ?? this.dueDate,
      category: category ?? this.category,
      isPaid: isPaid ?? this.isPaid,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'amount': amount,
      'dueDate': dueDate.toIso8601String(),
      'category': category.name,
      'isPaid': isPaid,
    };
  }

  factory Bill.fromMap(Map<String, dynamic> map) {
    return Bill(
      name: map['name'] as String? ?? '',
      amount: (map['amount'] as num?)?.toDouble() ?? 0,
      dueDate:
          DateTime.tryParse(map['dueDate'] as String? ?? '') ??
          DateTime.now(),
      category: BillCategory.values.firstWhere(
        (category) => category.name == map['category'],
        orElse: () => BillCategory.other,
      ),
      isPaid: map['isPaid'] as bool? ?? false,
    );
  }
}