import 'package:flutter/material.dart';

import '../models/financial_data.dart';
import '../services/storage_service.dart';
import 'ai_coach_screen.dart';
import 'budget_screen.dart';
import 'dashboard_screen.dart';
import 'debt_screen.dart';
import 'timeline_screen.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation>
    with WidgetsBindingObserver {
  int selectedIndex = 0;

  // Replaced by your saved data on startup
  FinancialData financialData = FinancialData();

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadData();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  // Loads your saved data from the device when the app starts
  Future<void> _loadData() async {
    final loadedData = await StorageService.loadFinancialData();

    // Move monthly bills to their next due date when needed.
    if (loadedData.rollBillsForward()) {
      await StorageService.saveFinancialData(loadedData);
    }

    if (!mounted) {
      return;
    }

    setState(() {
      financialData = loadedData;
      isLoading = false;
    });
  }

  // Saves automatically when the app is closed or backgrounded
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive ||
        state == AppLifecycleState.detached) {
      StorageService.saveFinancialData(financialData);
    }
  }

  void _selectTab(int index) {
    // Saves every time you switch tabs
    StorageService.saveFinancialData(financialData);

    setState(() {
      selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Brief spinner while saved data loads
    if (isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    final screens = [
      DashboardScreen(
        financialData: financialData,
        onDataChanged: () {
          StorageService.saveFinancialData(financialData);
          setState(() {});
        },
        onOpenTimeline: () => _selectTab(2),
      ),
      BudgetScreen(
        financialData: financialData,
      ),
      TimelineScreen(
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
        onDestinationSelected: _selectTab,
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
            icon: Icon(Icons.calendar_month_outlined),
            selectedIcon: Icon(Icons.calendar_month),
            label: 'Timeline',
          ),
          NavigationDestination(
            icon: Icon(Icons.credit_card_outlined),
            selectedIcon: Icon(Icons.credit_card),
            label: 'Debt',
          ),
          NavigationDestination(
            icon: Icon(Icons.smart_toy_outlined),
            selectedIcon: Icon(Icons.smart_toy),
            label: 'Coach',
          ),
        ],
      ),
    );
  }
}