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

  final ScrollController scrollController = ScrollController();

  final List<ChatMessage> messages = [
    const ChatMessage(
      text:
          'Hi! I’m your PocketWatcher Financial Coach. I can help you understand your budget, spending, savings, debt, and financial goals.',
      isUser: false,
    ),
    const ChatMessage(
      text:
          'Try asking: “What should I pay first?”, “How much should I save?”, or “How does my budget look?”',
      isUser: false,
    ),
  ];

  @override
  void dispose() {
    messageController.dispose();
    scrollController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final text = messageController.text.trim();

    if (text.isEmpty) {
      return;
    }

    final response = _generateResponse(text);

    setState(() {
      messages.add(
        ChatMessage(
          text: text,
          isUser: true,
        ),
      );

      messages.add(
        ChatMessage(
          text: response,
          isUser: false,
        ),
      );
    });

    messageController.clear();

    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  bool _containsAny(String message, List<String> phrases) {
    for (final phrase in phrases) {
      if (message.contains(phrase)) {
        return true;
      }
    }

    return false;
  }

  String _generateResponse(String message) {
    final lowerMessage = message.toLowerCase().trim();

    final income = widget.financialData.totalMonthlyIncome;
    final bills = widget.financialData.totalBills;
    final expenses = widget.financialData.totalExpenses;
    final totalDebt = widget.financialData.totalDebt;
    final monthlyInterest = widget.financialData.totalMonthlyInterest;
    final debts = widget.financialData.debts;

    // ==========================================================
    // SAVINGS QUESTIONS
    // ==========================================================

    if (_containsAny(
      lowerMessage,
      [
        'saving',
        'savings',
        'save',
        'how much should i save',
        'how much should i put away',
        'put in savings',
        'emergency fund',
        'save this month',
      ],
    )) {
      return FinancialCoachService.getSavingsRecommendation(
        income: income,
        bills: bills,
        expenses: expenses,
      );
    }

    // ==========================================================
    // DEBT PAYOFF / WHICH DEBT SHOULD I PAY FIRST?
    // ==========================================================

    if (_containsAny(
      lowerMessage,
      [
        'snowball',
        'avalanche',
        'pay off',
        'payoff',
        'pay first',
        'pay this month',
        'which debt',
        'which one should i pay',
        'which should i pay',
        'what should i pay',
        'debt strategy',
        'debt first',
        'pay down',
        'highest interest',
        'highest apr',
        'lowest balance',
        'best debt',
        'debt payoff',
        'get out of debt',
      ],
    )) {
      return FinancialCoachService.getDebtOptimization(
        debts: debts,
      );
    }

    // ==========================================================
    // BUDGET QUESTIONS
    // ==========================================================

    if (_containsAny(
      lowerMessage,
      [
        'budget',
        'budgeting',
        'how does my budget look',
        'is my budget good',
        'monthly budget',
        'afford',
        'cash flow',
        'money left',
        'left over',
        'leftover',
      ],
    )) {
      return FinancialCoachService.getBudgetRecommendation(
        income: income,
        bills: bills,
        expenses: expenses,
      );
    }

    // ==========================================================
    // SPENDING QUESTIONS
    // ==========================================================

    if (_containsAny(
      lowerMessage,
      [
        'spending',
        'spend',
        'expenses',
        'expense',
        'spending too much',
        'cut back',
        'where am i spending',
        'where is my money going',
      ],
    )) {
      return FinancialCoachService.getSpendingAdvice(
        income: income,
        expenses: expenses,
      );
    }

    // ==========================================================
    // GENERAL DEBT QUESTIONS
    // ==========================================================

    if (_containsAny(
      lowerMessage,
      [
        'debt',
        'credit card',
        'credit cards',
        'loan',
        'loans',
        'interest',
        'apr',
        'owe',
        'balance',
      ],
    )) {
      return FinancialCoachService.getDebtAdvice(
        totalDebt: totalDebt,
        monthlyInterest: monthlyInterest,
      );
    }

    // ==========================================================
    // GENERAL FINANCIAL ADVICE
    // ==========================================================

    if (_containsAny(
      lowerMessage,
      [
        'focus',
        'recommend',
        'recommendation',
        'advice',
        'what should i do',
        'what should i focus on',
        'financial health',
        'how am i doing',
        'what do you think',
        'help me',
      ],
    )) {
      return FinancialCoachService.getGeneralRecommendation(
        income: income,
        bills: bills,
        expenses: expenses,
        totalDebt: totalDebt,
        monthlyInterest: monthlyInterest,
      );
    }

    // ==========================================================
    // FALLBACK
    // ==========================================================

    return 'I can help you with your budget, spending, savings, and debt. '
        'Try asking me something like:\n\n'
        '• How much should I save this month?\n'
        '• What debt should I pay first?\n'
        '• How does my budget look?\n'
        '• Am I spending too much?\n'
        '• What should I focus on financially?';
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
              controller: scrollController,
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
                        height: 1.4,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // ====================================================
          // MESSAGE INPUT
          // ====================================================

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
