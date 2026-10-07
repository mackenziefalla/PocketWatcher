import 'package:flutter/material.dart';

import '../models/debt.dart';

class AddDebtScreen extends StatefulWidget {
  const AddDebtScreen({super.key});

  @override
  State<AddDebtScreen> createState() => _AddDebtScreenState();
}

class _AddDebtScreenState extends State<AddDebtScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController balanceController = TextEditingController();
  final TextEditingController interestRateController = TextEditingController();
  final TextEditingController minimumPaymentController = TextEditingController();

  DebtType selectedType = DebtType.creditCard;

  @override
  void dispose() {
    nameController.dispose();
    balanceController.dispose();
    interestRateController.dispose();
    minimumPaymentController.dispose();
    super.dispose();
  }

  void _saveDebt() {
    final name = nameController.text.trim();
    final balance = double.tryParse(balanceController.text.trim());
    final interestRate =
        double.tryParse(interestRateController.text.trim());
    final minimumPayment =
        double.tryParse(minimumPaymentController.text.trim());

    if (name.isEmpty ||
        balance == null ||
        balance <= 0 ||
        interestRate == null ||
        interestRate < 0 ||
        minimumPayment == null ||
        minimumPayment <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please enter valid debt information.',
          ),
        ),
      );
      return;
    }

    final debt = Debt(
      name: name,
      type: selectedType,
      balance: balance,
      interestRate: interestRate,
      minimumPayment: minimumPayment,
    );

    Navigator.pop(context, debt);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Debt'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Debt Details',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 6),
            Text(
              'Add a debt account so PocketWatcher can estimate payoff progress.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),

            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: 'Debt Name',
                hintText: 'Example: Chase Credit Card',
                prefixIcon: const Icon(Icons.credit_card_outlined),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),

            const SizedBox(height: 16),

            DropdownButtonFormField<DebtType>(
              initialValue: selectedType,
              decoration: InputDecoration(
                labelText: 'Debt Type',
                prefixIcon: const Icon(Icons.category_outlined),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              items: DebtType.values.map((type) {
                return DropdownMenuItem(
                  value: type,
                  child: Text(type.label),
                );
              }).toList(),
              onChanged: (type) {
                if (type == null) {
                  return;
                }

                setState(() {
                  selectedType = type;
                });
              },
            ),

            const SizedBox(height: 16),

            TextField(
              controller: balanceController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: InputDecoration(
                labelText: 'Current Balance',
                hintText: 'Example: 4500',
                prefixIcon: const Icon(Icons.attach_money),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),

            const SizedBox(height: 16),

            TextField(
              controller: interestRateController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: InputDecoration(
                labelText: 'Interest Rate (APR %)',
                hintText: 'Example: 24.99',
                prefixIcon: const Icon(Icons.percent),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),

            const SizedBox(height: 16),

            TextField(
              controller: minimumPaymentController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: InputDecoration(
                labelText: 'Minimum Monthly Payment',
                hintText: 'Example: 150',
                prefixIcon: const Icon(Icons.payments_outlined),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),

            const SizedBox(height: 24),

            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    const Icon(
                      Icons.timeline,
                      color: Colors.green,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'PocketWatcher will use the balance, APR, and payment amount to forecast your debt payoff.',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _saveDebt,
                icon: const Icon(Icons.save_outlined),
                label: const Text('Save Debt'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}