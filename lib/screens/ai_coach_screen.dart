import 'package:flutter/material.dart';

import '../models/financial_data.dart';
import '../services/financial_coach_service.dart';

class AiCoachScreen extends StatefulWidget {
  final FinancialData financialData;

  const AiCoachScreen({
    super.key,
    required this.financialData,
  });

  @override
  State<AiCoachScreen> createState() => _AiCoachScreenState();
}

class _AiCoachScreenState extends State<AiCoachScreen> {
  final TextEditingController messageController = TextEditingController();

  final List<ChatMessage> messages = [
    const ChatMessage(
      text:
          'Hi! I’m your PocketWatcher AI Coach. I can help you understand your budget, spending, debt, and financial goals.',
      isUser: false,
    ),
    const ChatMessage(
      text:
          'Try asking something like: “How should I pay off my debt?”',
      isUser: false,
    ),
  ];

  @override
  void dispose() {
    messageController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final text = messageController.text.trim();

    if (text.isEmpty) {
      return;
    }

    setState(() {
      messages.add(
        ChatMessage(
          text: text,
          isUser: true,
        ),
      );

      messages.add(
        ChatMessage(
          text: _generateResponse(text),
          isUser: false,
        ),
      );
    });

    messageController.clear();
  }

  String _generateResponse(String message) {
    final lowerMessage = message.toLowerCase();

    final income = widget.financialData.totalMonthlyIncome;
    final bills = widget.financialData.totalBills;
    final expenses = widget.financialData.totalExpenses;
    final totalDebt = widget.financialData.totalDebt;
    final monthlyInterest = widget.financialData.totalMonthlyInterest;
    final debts = widget.financialData.debts;

    if (lowerMessage.contains('snowball') ||
        lowerMessage.contains('avalanche') ||
        lowerMessage.contains('pay off') ||
        lowerMessage.contains('payoff') ||
        lowerMessage.contains('which debt') ||
        lowerMessage.contains('debt strategy') ||
        lowerMessage.contains('debt first')) {
      return FinancialCoachService.getDebtOptimization(
        debts: debts,
      );
    }

    if (lowerMessage.contains('budget')) {
      return FinancialCoachService.getBudgetRecommendation(
        income: income,
        bills: bills,
        expenses: expenses,
      );
    }

    if (lowerMessage.contains('spending') ||
        lowerMessage.contains('spend') ||
        lowerMessage.contains('expenses')) {
      return FinancialCoachService.getSpendingAdvice(
        income: income,
        expenses: expenses,
      );
    }

    if (lowerMessage.contains('debt') ||
        lowerMessage.contains('credit card') ||
        lowerMessage.contains('loan')) {
      return FinancialCoachService.getDebtAdvice(
        totalDebt: totalDebt,
        monthlyInterest: monthlyInterest,
      );
    }

    if (lowerMessage.contains('focus') ||
        lowerMessage.contains('recommend') ||
        lowerMessage.contains('advice') ||
        lowerMessage.contains('what should i do')) {
      return FinancialCoachService.getGeneralRecommendation(
        income: income,
        bills: bills,
        expenses: expenses,
        totalDebt: totalDebt,
        monthlyInterest: monthlyInterest,
      );
    }

    return FinancialCoachService.getGeneralRecommendation(
      income: income,
      bills: bills,
      expenses: expenses,
      totalDebt: totalDebt,
      monthlyInterest: monthlyInterest,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Coach'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final message = messages[index];

                return Align(
                  alignment: message.isUser
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    constraints: const BoxConstraints(
                      maxWidth: 600,
                    ),
                    decoration: BoxDecoration(
                      color: message.isUser
                          ? Colors.green.shade100
                          : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      message.text,
                      style: const TextStyle(
                        fontSize: 15,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              border: Border(
                top: BorderSide(
                  color: Colors.grey.shade300,
                ),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: messageController,
                    onSubmitted: (_) => _sendMessage(),
                    decoration: InputDecoration(
                      hintText: 'Ask PocketWatcher anything...',
                      prefixIcon: const Icon(
                        Icons.chat_bubble_outline,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                IconButton.filled(
                  onPressed: _sendMessage,
                  icon: const Icon(
                    Icons.send,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ChatMessage {
  final String text;
  final bool isUser;

  const ChatMessage({
    required this.text,
    required this.isUser,
  });
}