import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../models/bill.dart';
import '../models/expense.dart';
import '../models/financial_data.dart';
import '../models/income.dart';
import '../widgets/cash_flow_chart.dart';
import '../widgets/spending_trend_chart.dart';
import 'add_bill_screen.dart';
import 'add_expense_screen.dart';
import 'add_income_screen.dart';

class BudgetScreen extends StatefulWidget {
  final FinancialData financialData;

  const BudgetScreen({
    super.key,
    required this.financialData,
  });

  @override
  State<BudgetScreen> createState() => _BudgetScreenState();
}

class _BudgetScreenState extends State<BudgetScreen> {
  List<Income> get incomes => widget.financialData.incomes;
  List<Bill> get bills => widget.financialData.bills;
  List<Expense> get expenses => widget.financialData.expenses;

  double get totalMonthlyIncome {
    return widget.financialData.totalMonthlyIncome;
  }

  double get totalBills {
    return widget.financialData.totalBills;
  }

  double get totalExpenses {
    return widget.financialData.totalExpenses;
  }

  double get remainingMoney {
    return widget.financialData.safeToSpend;
  }

  List<double> get weeklySpending {
    final weeks = [0.0, 0.0, 0.0, 0.0];

    for (final expense in expenses) {
      final day = expense.date.day;

      if (day <= 7) {
        weeks[0] += expense.amount;
      } else if (day <= 14) {
        weeks[1] += expense.amount;
      } else if (day <= 21) {
        weeks[2] += expense.amount;
      } else {
        weeks[3] += expense.amount;
      }
    }

    return weeks;
  }

  Future<void> _addIncome() async {
    final income = await Navigator.push<Income>(
      context,
      MaterialPageRoute(
        builder: (_) => const AddIncomeScreen(),
      ),
    );

    if (income != null) {
      setState(() {
        widget.financialData.addIncome(income);
      });
    }
  }

  Future<void> _addBill() async {
    final bill = await Navigator.push<Bill>(
      context,
      MaterialPageRoute(
        builder: (_) => const AddBillScreen(),
      ),
    );

    if (bill != null) {
      setState(() {
        widget.financialData.addBill(bill);
      });
    }
  }

  Future<void> _addExpense() async {
    final expense = await Navigator.push<Expense>(
      context,
      MaterialPageRoute(
        builder: (_) => const AddExpenseScreen(),
      ),
    );

    if (expense != null) {
      setState(() {
        widget.financialData.addExpense(expense);
      });
    }
  }

  Map<ExpenseCategory, double> get expenseTotalsByCategory {
    final Map<ExpenseCategory, double> totals = {};

    for (final expense in expenses) {
      totals[expense.category] =
          (totals[expense.category] ?? 0) + expense.amount;
    }

    return totals;
  }

  Color _colorForCategory(ExpenseCategory category) {
    switch (category) {
      case ExpenseCategory.groceries:
        return const Color(0xFF2E7D32);

      case ExpenseCategory.dining:
        return const Color(0xFF388E3C);

      case ExpenseCategory.gas:
        return const Color(0xFF43A047);

      case ExpenseCategory.shopping:
        return const Color(0xFF4CAF50);

      case ExpenseCategory.entertainment:
        return const Color(0xFF66BB6A);

      case ExpenseCategory.subscriptions:
        return const Color(0xFF81C784);

      case ExpenseCategory.transportation:
        return const Color(0xFFA5D6A7);

      case ExpenseCategory.health:
        return const Color(0xFFC8E6C9);

      case ExpenseCategory.other:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final categoryTotals = expenseTotalsByCategory;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Budget'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Monthly Budget',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),

          const SizedBox(height: 6),

          Text(
            'See where your money is going this month.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),

          const SizedBox(height: 20),

          Card(
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Income',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 12),

                  if (incomes.isEmpty)
                    const Text('No income added yet.')
                  else
                    ...incomes.map(
                      (income) => ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(
                          Icons.attach_money,
                          color: Colors.green,
                        ),
                        title: Text(income.source),
                        subtitle: Text(income.frequency.label),
                        trailing: Text(
                          '\$${income.estimatedMonthlyIncome.toStringAsFixed(0)}/mo',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),

                  const SizedBox(height: 12),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _addIncome,
                      icon: const Icon(Icons.add),
                      label: const Text('Add Income'),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 18),

          Card(
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Bills',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 12),

                  if (bills.isEmpty)
                    const Text('No bills added yet.')
                  else
                    ...bills.map(
                      (bill) => ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: Icon(
                          bill.isPaid
                              ? Icons.check_circle
                              : Icons.receipt_long_outlined,
                          color: bill.isPaid
                              ? Colors.green
                              : Colors.orange,
                        ),
                        title: Text(bill.name),
                        subtitle: Text(
                          '${bill.category.label} • Due ${bill.dueDate.month}/${bill.dueDate.day}/${bill.dueDate.year}',
                        ),
                        trailing: Text(
                          '\$${bill.amount.toStringAsFixed(0)}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),

                  const SizedBox(height: 12),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _addBill,
                      icon: const Icon(Icons.add),
                      label: const Text('Add Bill'),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 18),

          Card(
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Expenses',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 12),

                  if (expenses.isEmpty)
                    const Text('No expenses added yet.')
                  else
                    ...expenses.map(
                      (expense) => ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: Icon(
                          Icons.shopping_bag_outlined,
                          color: _colorForCategory(expense.category),
                        ),
                        title: Text(expense.name),
                        subtitle: Text(
                          '${expense.category.label} • ${expense.date.month}/${expense.date.day}/${expense.date.year}',
                        ),
                        trailing: Text(
                          '\$${expense.amount.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),

                  const SizedBox(height: 12),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _addExpense,
                      icon: const Icon(Icons.add),
                      label: const Text('Add Expense'),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 18),

          Card(
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const Text(
                    'Spending Breakdown',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 18),

                  if (expenses.isEmpty)
                    const SizedBox(
                      height: 220,
                      child: Center(
                        child: Text(
                          'Add expenses to see your spending chart.',
                          textAlign: TextAlign.center,
                        ),
                      ),
                    )
                  else
                    SizedBox(
                      height: 260,
                      child: PieChart(
                        PieChartData(
                          centerSpaceRadius: 60,
                          sectionsSpace: 3,
                          sections: categoryTotals.entries.map((entry) {
                            final percentage =
                                entry.value / totalExpenses * 100;

                            return PieChartSectionData(
                              value: entry.value,
                              color: _colorForCategory(entry.key),
                              radius: 70,
                              title: '${percentage.toStringAsFixed(0)}%',
                              titleStyle: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),

                  const SizedBox(height: 18),

                  Text(
                    '\$${totalExpenses.toStringAsFixed(2)} spent',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  Text(
                    totalMonthlyIncome > 0
                        ? 'of \$${totalMonthlyIncome.toStringAsFixed(0)} estimated monthly income'
                        : 'Add income to compare against expenses',
                    style: TextStyle(
                      color: Colors.grey.shade700,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 18),

          SpendingTrendChart(
            weeklySpending: weeklySpending,
          ),

          const SizedBox(height: 18),

          CashFlowChart(
            income: totalMonthlyIncome,
            bills: totalBills,
            expenses: totalExpenses,
          ),

          const SizedBox(height: 18),

          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Row(
                children: [
                  const Icon(
                    Icons.account_balance_wallet_outlined,
                    size: 34,
                    color: Colors.green,
                  ),

                  const SizedBox(width: 14),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Safe to Spend',
                          style: TextStyle(
                            fontSize: 16,
                          ),
                        ),

                        const SizedBox(height: 4),

                        Text(
                          incomes.isEmpty
                              ? '--'
                              : '\$${remainingMoney.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 25,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 4),

                        Text(
                          'Income minus bills and expenses.',
                          style: TextStyle(
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 18),

          if (categoryTotals.isNotEmpty) ...[
            Text(
              'Spending Categories',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),

            const SizedBox(height: 10),

            ...categoryTotals.entries.map(
              (entry) => Card(
                margin: const EdgeInsets.only(bottom: 10),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: _colorForCategory(entry.key),
                    radius: 10,
                  ),
                  title: Text(entry.key.label),
                  trailing: Text(
                    '\$${entry.value.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}