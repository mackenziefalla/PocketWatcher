import '../models/debt.dart';
import 'debt_strategy_service.dart';

class FinancialCoachService {
  static String getBudgetRecommendation({
    required double income,
    required double bills,
    required double expenses,
  }) {
    if (income <= 0) {
      return 'Add your income first so I can give you a useful budget recommendation.';
    }

    final remaining = income - bills - expenses;
    final spendingPercent = ((bills + expenses) / income) * 100;

    if (remaining < 0) {
      return 'You are currently spending more than you earn. Focus first on reducing non-essential expenses and reviewing your largest monthly costs.';
    }

    if (spendingPercent >= 90) {
      return 'Your budget is very tight right now. Try reducing flexible spending and avoid adding new recurring bills.';
    }

    if (spendingPercent >= 75) {
      return 'You still have money left over, but most of your income is already committed. Consider putting part of the remaining amount toward savings or debt.';
    }

    return 'Your budget currently has healthy breathing room. Consider using some of the remaining money for savings, debt payoff, or another financial goal.';
  }

  static String getSpendingAdvice({
    required double income,
    required double expenses,
  }) {
    if (income <= 0) {
      return 'Add your income so I can compare your spending against what you earn.';
    }

    final expensePercent = (expenses / income) * 100;

    if (expensePercent >= 50) {
      return 'Your flexible spending is taking up a large portion of your income. Review your biggest spending categories and look for places to cut back.';
    }

    if (expensePercent >= 30) {
      return 'Your spending is moderate. Keep watching your largest categories so they do not begin crowding out savings or debt payments.';
    }

    return 'Your current spending level looks manageable compared with your income.';
  }

  static String getDebtAdvice({
    required double totalDebt,
    required double monthlyInterest,
  }) {
    if (totalDebt <= 0) {
      return 'You do not currently have debt entered. Add debt accounts if you want payoff recommendations.';
    }

    if (monthlyInterest >= 200) {
      return 'Your debt is generating a significant amount of interest each month. Prioritize high-interest balances first to reduce how much interest you pay over time.';
    }

    if (monthlyInterest >= 75) {
      return 'Your debt is costing you a noticeable amount in interest. Extra payments toward your highest-APR debt could help shorten your payoff timeline.';
    }

    return 'Your monthly interest cost is relatively low, but extra payments can still help you become debt-free sooner.';
  }

  static String getDebtOptimization({
    required List<Debt> debts,
  }) {
    if (debts.isEmpty) {
      return 'Add your debt accounts first so I can build a payoff strategy for you.';
    }

    final snowball =
        DebtStrategyService.getSnowballRecommendation(debts);

    final avalanche =
        DebtStrategyService.getAvalancheRecommendation(debts);

    final totalDebt = debts.fold(
      0.0,
      (total, debt) => total + debt.balance,
    );

    final monthlyInterest = debts.fold(
      0.0,
      (total, debt) => total + debt.estimatedMonthlyInterest,
    );

    final snowballDebt = snowball.targetDebt;
    final avalancheDebt = avalanche.targetDebt;

    if (snowballDebt == null || avalancheDebt == null) {
      return 'I need more debt information before I can recommend a payoff strategy.';
    }

    if (snowballDebt.name == avalancheDebt.name) {
      return 'You currently have \$${totalDebt.toStringAsFixed(2)} in debt '
          'and about \$${monthlyInterest.toStringAsFixed(2)} in estimated monthly interest. '
          'Both the Snowball and Avalanche methods point to ${snowballDebt.name} as your first target. '
          'Consider putting any extra debt-payment money toward this account while continuing the minimum payments on your other debts.';
    }

    return 'You currently have \$${totalDebt.toStringAsFixed(2)} in debt '
        'and about \$${monthlyInterest.toStringAsFixed(2)} in estimated monthly interest. '
        'The Snowball method would target ${snowballDebt.name} first because it has the smallest balance. '
        'The Avalanche method would target ${avalancheDebt.name} first because it has the highest APR at '
        '${avalancheDebt.interestRate.toStringAsFixed(2)}%. '
        'Avalanche generally prioritizes reducing interest costs, while Snowball prioritizes getting a balance paid off sooner.';
  }

  static String getGeneralRecommendation({
    required double income,
    required double bills,
    required double expenses,
    required double totalDebt,
    required double monthlyInterest,
  }) {
    final remaining = income - bills - expenses;

    if (income <= 0) {
      return 'Start by adding your income, bills, expenses, and debts so I can give you personalized guidance.';
    }

    if (remaining < 0) {
      return 'Your first priority should be getting monthly cash flow back above zero. Review flexible spending before putting extra money toward other goals.';
    }

    if (totalDebt > 0 && monthlyInterest >= 100) {
      return 'You have positive cash flow, so consider using part of your remaining money to make extra payments toward your highest-interest debt.';
    }

    if (remaining > income * 0.20) {
      return 'You have a healthy amount left after bills and spending. Consider splitting some of it between savings and additional debt payments.';
    }

    return 'Your budget is fairly balanced. Keep monitoring spending, maintain a savings cushion, and make consistent debt payments.';
  }
}