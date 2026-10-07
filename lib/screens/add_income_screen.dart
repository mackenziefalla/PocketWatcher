import 'package:flutter/material.dart';

import '../models/income.dart';

class AddIncomeScreen extends StatefulWidget {
  const AddIncomeScreen({super.key});

  @override
  State<AddIncomeScreen> createState() => _AddIncomeScreenState();
}

class _AddIncomeScreenState extends State<AddIncomeScreen> {
  final TextEditingController sourceController = TextEditingController();
  final TextEditingController amountController = TextEditingController();

  PayFrequency selectedFrequency = PayFrequency.biweekly;
  DateTime selectedPayDate = DateTime.now();

  @override
  void dispose() {
    sourceController.dispose();
    amountController.dispose();
    super.dispose();
  }

  Future<void> _selectPayDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedPayDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(
        const Duration(days: 365),
      ),
    );

    if (pickedDate != null) {
      setState(() {
        selectedPayDate = pickedDate;
      });
    }
  }

  void _saveIncome() {
    final source = sourceController.text.trim();
    final amount = double.tryParse(amountController.text.trim());

    if (source.isEmpty || amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please enter a valid income source and amount.',
          ),
        ),
      );
      return;
    }

    final income = Income(
      source: source,
      amount: amount,
      frequency: selectedFrequency,
      nextPayDate: selectedPayDate,
    );

    Navigator.pop(context, income);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Income'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Income Details',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 6),
            Text(
              'Add a paycheck or another recurring source of income.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),

            TextField(
              controller: sourceController,
              decoration: InputDecoration(
                labelText: 'Income Source',
                hintText: 'Example: Southern Fire Control',
                prefixIcon: const Icon(Icons.work_outline),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),

            const SizedBox(height: 16),

            TextField(
              controller: amountController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: InputDecoration(
                labelText: 'Paycheck Amount',
                hintText: 'Example: 2200',
                prefixIcon: const Icon(Icons.attach_money),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),

            const SizedBox(height: 16),

            DropdownButtonFormField<PayFrequency>(
              initialValue: selectedFrequency,
              decoration: InputDecoration(
                labelText: 'Pay Frequency',
                prefixIcon: const Icon(Icons.repeat),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              items: PayFrequency.values.map((frequency) {
                return DropdownMenuItem(
                  value: frequency,
                  child: Text(frequency.label),
                );
              }).toList(),
              onChanged: (frequency) {
                if (frequency == null) {
                  return;
                }

                setState(() {
                  selectedFrequency = frequency;
                });
              },
            ),

            const SizedBox(height: 16),

            InkWell(
              onTap: _selectPayDate,
              borderRadius: BorderRadius.circular(14),
              child: InputDecorator(
                decoration: InputDecoration(
                  labelText: 'Next Payday',
                  prefixIcon: const Icon(Icons.calendar_month),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Text(
                  '${selectedPayDate.month}/${selectedPayDate.day}/${selectedPayDate.year}',
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
                      Icons.auto_graph,
                      color: Colors.green,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'PocketWatcher will use this information to estimate monthly income and calculate Safe to Spend.',
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
                onPressed: _saveIncome,
                icon: const Icon(Icons.save_outlined),
                label: const Text('Save Income'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}