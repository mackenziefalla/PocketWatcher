import 'package:flutter/material.dart';

import '../models/financial_data.dart';
import 'ai_coach_screen.dart';
import 'budget_screen.dart';
import 'dashboard_screen.dart';
import 'debt_screen.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int selectedIndex = 0;

  final FinancialData financialData = FinancialData();

  @override
  Widget build(BuildContext context) {
    final screens = [
      const DashboardScreen(),
      BudgetScreen(
        financialData: financialData,
      ),
      DebtScreen(
        financialData: financialData,
      ),
      AiCoachScreen(
        financialData: financialData,
      ),
    ];

    return Scaffold(
      body: screens[selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            selectedIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.pie_chart_outline),
            selectedIcon: Icon(Icons.pie_chart),
            label: 'Budget',
          ),
          NavigationDestination(
            icon: Icon(Icons.credit_card_outlined),
            selectedIcon: Icon(Icons.credit_card),
            label: 'Debt',
          ),
          NavigationDestination(
            icon: Icon(Icons.smart_toy_outlined),
            selectedIcon: Icon(Icons.smart_toy),
            label: 'AI Coach',
          ),
        ],
      ),
    );
  }
}