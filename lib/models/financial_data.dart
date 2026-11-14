import 'bill.dart';
import 'debt.dart';
import 'expense.dart';
import 'income.dart';
import 'score_snapshot.dart';

class FinancialData {
  final List<Income> incomes;
  final List<Bill> bills;
  final List<Expense> expenses;
  final List<Debt> debts;

  // One score per day, oldest first. Used for the history chart.
  final List<ScoreSnapshot> scoreHistory;

  // How much the user has saved right now, and what they are aiming for.
  double currentSavings;
  double savingsGoal;

  FinancialData({
    List<Income>? incomes,
    List<Bill>? bills,
    List<Expense>? expenses,
    List<Debt>? debts,
    List<ScoreSnapshot>? scoreHistory,
    this.currentSavings = 0,
    this.savingsGoal = 0,
  })  : incomes = incomes ?? [],
        bills = bills ?? [],
        expenses = expenses ?? [],
        debts = debts ?? [],
        scoreHistory = scoreHistory ?? [];

  double get totalMonthlyIncome {
    return incomes.fold(
      0,
      (total, income) => total + income.estimatedMonthlyIncome,
    );
  }

  double get totalBills {
    return bills.fold(
      0,
      (total, bill) => total + bill.amount,
    );
  }

  // Only expenses dated in the current calendar month. Older expenses
  // stay saved for history but no longer count against this month.
  List<Expense> get currentMonthExpenses {
    final now = DateTime.now();
    return expenses
        .where((expense) =>
            expense.date.year == now.year && expense.date.month == now.month)
        .toList();
  }

  // This month's spending total.
  double get totalExpenses {
    return currentMonthExpenses.fold(
      0,
      (total, expense) => total + expense.amount,
    );
  }

  // Every expense ever entered (for history and trends).
  double get allTimeExpenses {
    return expenses.fold(
      0,
      (total, expense) => total + expense.amount,
    );
  }

  double get totalDebt {
    return debts.fold(
      0,
      (total, debt) => total + debt.balance,
    );
  }

  double get totalMinimumDebtPayments {
    return debts.fold(
      0,
      (total, debt) => total + debt.minimumPayment,
    );
  }

  double get totalMonthlyInterest {
    return debts.fold(
      0,
      (total, debt) => total + debt.estimatedMonthlyInterest,
    );
  }

  double get safeToSpend {
    return totalMonthlyIncome - totalBills - totalExpenses;
  }

  // ============================================================
  // SCORE HISTORY
  // ============================================================

  /// Saves today's score. If a score was already saved today it is
  /// replaced, so there is at most one entry per day.
  void recordScore(int score, {DateTime? now}) {
    final today = _dateOnly(now ?? DateTime.now());

    if (scoreHistory.isNotEmpty &&
        _dateOnly(scoreHistory.last.date) == today) {
      if (scoreHistory.last.score == score) return;
      scoreHistory[scoreHistory.length - 1] =
          ScoreSnapshot(date: today, score: score);
    } else {
      scoreHistory.add(ScoreSnapshot(date: today, score: score));
    }

    // Keep about six months of history.
    while (scoreHistory.length > 180) {
      scoreHistory.removeAt(0);
    }
  }

  /// How much the score changed compared with about a week ago.
  /// Returns null until there is an older score to compare against.
  int? weeklyScoreChange(int currentScore, {DateTime? now}) {
    final today = _dateOnly(now ?? DateTime.now());
    final weekAgo = today.subtract(const Duration(days: 7));

    ScoreSnapshot? baseline;
    for (final snapshot in scoreHistory) {
      if (!_dateOnly(snapshot.date).isAfter(weekAgo)) {
        baseline = snapshot; // latest one that is at least 7 days old
      }
    }

    // Not a full week of history yet: compare with the oldest day we
    // have, as long as it is not today.
    if (baseline == null && scoreHistory.isNotEmpty) {
      final oldest = scoreHistory.first;
      if (_dateOnly(oldest.date).isBefore(today)) baseline = oldest;
    }

    if (baseline == null) return null;
    return currentScore - baseline.score;
  }

  // ============================================================
  // BILL ROLLOVER
  // ============================================================

  /// Bills repeat monthly. This moves a bill to its next due date when
  /// it was paid and the due date has passed, or when it has been
  /// unpaid for more than 30 days (most likely just not marked paid).
  /// Returns true if anything changed so the caller can save.
  bool rollBillsForward({DateTime? now}) {
    final today = _dateOnly(now ?? DateTime.now());
    final staleCutoff = today.subtract(const Duration(days: 30));
    bool changed = false;

    for (int i = 0; i < bills.length; i++) {
      final bill = bills[i];
      final due = _dateOnly(bill.dueDate);

      final paidAndPassed = bill.isPaid && due.isBefore(today);
      final longOverdue = !bill.isPaid && due.isBefore(staleCutoff);

      if (paidAndPassed || longOverdue) {
        DateTime next = due;
        int guard = 0;
        while (next.isBefore(today) && guard < 120) {
          next = addMonths(next, 1);
          guard++;
        }
        bills[i] = bill.copyWith(dueDate: next, isPaid: false);
        changed = true;
      }
    }

    return changed;
  }

  /// Adds months to a date, keeping the day where possible
  /// (Jan 31 + 1 month = Feb 28/29).
  static DateTime addMonths(DateTime date, int months) {
    final totalMonths = date.month - 1 + months;
    final year = date.year + (totalMonths / 12).floor();
    final month = totalMonths % 12 + 1;
    final lastDay = DateTime(year, month + 1, 0).day;
    final day = date.day > lastDay ? lastDay : date.day;
    return DateTime(year, month, day);
  }

  static DateTime _dateOnly(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  void addIncome(Income income) {
    incomes.add(income);
  }

  void addBill(Bill bill) {
    bills.add(bill);
  }

  void addExpense(Expense expense) {
    expenses.add(expense);
  }

  void addDebt(Debt debt) {
    debts.add(debt);
  }

  // Turns all your financial data into a map so it can be saved
  Map<String, dynamic> toMap() {
    return {
      'incomes': incomes.map((income) => income.toMap()).toList(),
      'bills': bills.map((bill) => bill.toMap()).toList(),
      'expenses': expenses.map((expense) => expense.toMap()).toList(),
      'debts': debts.map((debt) => debt.toMap()).toList(),
      'currentSavings': currentSavings,
      'savingsGoal': savingsGoal,
      'scoreHistory':
          scoreHistory.map((snapshot) => snapshot.toMap()).toList(),
    };
  }

  // Rebuilds FinancialData from a saved map when the app loads
  factory FinancialData.fromMap(Map<String, dynamic> map) {
    return FinancialData(
      incomes: (map['incomes'] as List<dynamic>? ?? [])
          .map((item) => Income.fromMap(item as Map<String, dynamic>))
          .toList(),
      bills: (map['bills'] as List<dynamic>? ?? [])
          .map((item) => Bill.fromMap(item as Map<String, dynamic>))
          .toList(),
      expenses: (map['expenses'] as List<dynamic>? ?? [])
          .map((item) => Expense.fromMap(item as Map<String, dynamic>))
          .toList(),
      debts: (map['debts'] as List<dynamic>? ?? [])
          .map((item) => Debt.fromMap(item as Map<String, dynamic>))
          .toList(),
      scoreHistory: (map['scoreHistory'] as List<dynamic>? ?? [])
          .map((item) => ScoreSnapshot.fromMap(item as Map<String, dynamic>))
          .toList(),
      currentSavings: (map['currentSavings'] as num?)?.toDouble() ?? 0,
      savingsGoal: (map['savingsGoal'] as num?)?.toDouble() ?? 0,
    );
  }
}