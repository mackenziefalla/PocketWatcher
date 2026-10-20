import 'bill.dart';
import 'debt.dart';
import 'expense.dart';
import 'income.dart';

class FinancialData {
  final List<Income> incomes;
  final List<Bill> bills;
  final List<Expense> expenses;
  final List<Debt> debts;

  FinancialData({
    List<Income>? incomes,
    List<Bill>? bills,
    List<Expense>? expenses,
    List<Debt>? debts,
  })  : incomes = incomes ?? [],
        bills = bills ?? [],
        expenses = expenses ?? [],
        debts = debts ?? [];

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

  double get totalExpenses {
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

  // NEW: turns all your financial data into a map so it can be saved
  Map<String, dynamic> toMap() {
    return {
      'incomes': incomes.map((income) => income.toMap()).toList(),
      'bills': bills.map((bill) => bill.toMap()).toList(),
      'expenses': expenses.map((expense) => expense.toMap()).toList(),
      'debts': debts.map((debt) => debt.toMap()).toList(),
    };
  }

  // NEW: rebuilds FinancialData from a saved map when the app loads
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
    );
  }
}
