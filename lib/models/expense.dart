enum ExpenseCategory {
  groceries,
  dining,
  gas,
  shopping,
  entertainment,
  subscriptions,
  transportation,
  health,
  other,
}

extension ExpenseCategoryLabel on ExpenseCategory {
  String get label {
    switch (this) {
      case ExpenseCategory.groceries:
        return 'Groceries';
      case ExpenseCategory.dining:
        return 'Dining';
      case ExpenseCategory.gas:
        return 'Gas';
      case ExpenseCategory.shopping:
        return 'Shopping';
      case ExpenseCategory.entertainment:
        return 'Entertainment';
      case ExpenseCategory.subscriptions:
        return 'Subscriptions';
      case ExpenseCategory.transportation:
        return 'Transportation';
      case ExpenseCategory.health:
        return 'Health';
      case ExpenseCategory.other:
        return 'Other';
    }
  }
}

class Expense {
  final String name;
  final double amount;
  final ExpenseCategory category;
  final DateTime date;

  const Expense({
    required this.name,
    required this.amount,
    required this.category,
    required this.date,
  });

  Expense copyWith({
    String? name,
    double? amount,
    ExpenseCategory? category,
    DateTime? date,
  }) {
    return Expense(
      name: name ?? this.name,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      date: date ?? this.date,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'amount': amount,
      'category': category.name,
      'date': date.toIso8601String(),
    };
  }

  factory Expense.fromMap(Map<String, dynamic> map) {
    return Expense(
      name: map['name'] as String? ?? '',
      amount: (map['amount'] as num?)?.toDouble() ?? 0,
      category: ExpenseCategory.values.firstWhere(
        (category) => category.name == map['category'],
        orElse: () => ExpenseCategory.other,
      ),
      date:
          DateTime.tryParse(map['date'] as String? ?? '') ??
          DateTime.now(),
    );
  }
}