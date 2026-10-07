import '../models/debt.dart';

class DebtForecast {
  final int monthsToPayoff;
  final double totalInterest;
  final double totalPaid;
  final DateTime payoffDate;
  final bool canPayOff;

  const DebtForecast({
    required this.monthsToPayoff,
    required this.totalInterest,
    required this.totalPaid,
    required this.payoffDate,
    required this.canPayOff,
  });
}

class DebtForecastService {
  static DebtForecast calculateForecast(Debt debt) {
    double balance = debt.balance;
    final monthlyRate = debt.interestRate / 100 / 12;
    final payment = debt.minimumPayment;

    int months = 0;
    double totalInterest = 0;
    double totalPaid = 0;

    if (balance <= 0 || payment <= 0) {
      return DebtForecast(
        monthsToPayoff: 0,
        totalInterest: 0,
        totalPaid: 0,
        payoffDate: DateTime.now(),
        canPayOff: false,
      );
    }

    if (monthlyRate > 0) {
      final firstMonthInterest = balance * monthlyRate;

      if (payment <= firstMonthInterest) {
        return DebtForecast(
          monthsToPayoff: 0,
          totalInterest: 0,
          totalPaid: 0,
          payoffDate: DateTime.now(),
          canPayOff: false,
        );
      }
    }

    while (balance > 0 && months < 1200) {
      final interest = balance * monthlyRate;

      totalInterest += interest;
      balance += interest;

      final paymentThisMonth =
          payment > balance ? balance : payment;

      balance -= paymentThisMonth;
      totalPaid += paymentThisMonth;

      months++;
    }

    final now = DateTime.now();

    final payoffDate = DateTime(
      now.year,
      now.month + months,
      now.day,
    );

    return DebtForecast(
      monthsToPayoff: months,
      totalInterest: totalInterest,
      totalPaid: totalPaid,
      payoffDate: payoffDate,
      canPayOff: balance <= 0,
    );
  }

  static String formatPayoffTime(int months) {
    if (months <= 0) {
      return 'N/A';
    }

    final years = months ~/ 12;
    final remainingMonths = months % 12;

    if (years == 0) {
      return '$remainingMonths months';
    }

    if (remainingMonths == 0) {
      return '$years ${years == 1 ? 'year' : 'years'}';
    }

    return '$years ${years == 1 ? 'year' : 'years'}, '
        '$remainingMonths ${remainingMonths == 1 ? 'month' : 'months'}';
  }
}