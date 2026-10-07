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
}