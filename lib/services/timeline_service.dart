import '../models/bill.dart';
import '../models/expense.dart';
import '../models/financial_data.dart';
import '../models/income.dart';

enum TimelineEventType { payday, bill, spending }

/// Something that happens to your money on a specific day.
class TimelineEvent {
  final DateTime date;
  final String title;
  final String subtitle;
  final double amount; // positive = money in, negative = money out
  final TimelineEventType type;
  final bool isPaid;

  const TimelineEvent({
    required this.date,
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.type,
    this.isPaid = false,
  });
}

/// All the events on one calendar day.
class TimelineDay {
  final DateTime date;
  final List<TimelineEvent> events;

  const TimelineDay({required this.date, required this.events});

  double get net => events.fold(0.0, (total, event) => total + event.amount);
  double get moneyIn => events
      .where((event) => event.amount > 0)
      .fold(0.0, (total, event) => total + event.amount);
  double get moneyOut => events
      .where((event) => event.amount < 0)
      .fold(0.0, (total, event) => total - event.amount);
  bool get hasPayday =>
      events.any((event) => event.type == TimelineEventType.payday);
  bool get hasBill => events.any((event) => event.type == TimelineEventType.bill);
  bool get hasSpending =>
      events.any((event) => event.type == TimelineEventType.spending);
}

class TimelineService {
  static DateTime dateOnly(DateTime date) =>
      DateTime(date.year, date.month, date.day);

  /// Adds calendar days safely (no daylight-saving drift).
  static DateTime addDays(DateTime date, int days) =>
      DateTime(date.year, date.month, date.day + days);

  /// Paydays and bills coming up from today through [days] days ahead.
  static List<TimelineDay> upcoming(
    FinancialData data, {
    int days = 30,
    DateTime? now,
  }) {
    final start = dateOnly(now ?? DateTime.now());
    final end = addDays(start, days);
    final events = <TimelineEvent>[];

    for (final income in data.incomes) {
      for (final date in _paydays(income, start, end)) {
        events.add(TimelineEvent(
          date: date,
          title: income.source.isEmpty ? 'Payday' : income.source,
          subtitle: 'Payday • ${income.frequency.label}',
          amount: income.amount,
          type: TimelineEventType.payday,
        ));
      }
    }

    for (final bill in data.bills) {
      for (final date in _billDates(bill, start, end)) {
        final isThisCycle = dateOnly(bill.dueDate) == date;
        events.add(TimelineEvent(
          date: date,
          title: bill.name,
          subtitle: '${bill.category.label} bill',
          amount: -bill.amount,
          type: TimelineEventType.bill,
          isPaid: isThisCycle && bill.isPaid,
        ));
      }
    }

    return _groupByDay(events, ascending: true);
  }

  /// Spending you logged over the last [days] days, newest first.
  static List<TimelineDay> recentSpending(
    FinancialData data, {
    int days = 14,
    DateTime? now,
  }) {
    final today = dateOnly(now ?? DateTime.now());
    final start = addDays(today, -(days - 1));
    final events = <TimelineEvent>[];

    for (final Expense expense in data.expenses) {
      final date = dateOnly(expense.date);
      if (date.isBefore(start) || date.isAfter(today)) continue;
      events.add(TimelineEvent(
        date: date,
        title: expense.name,
        subtitle: expense.category.label,
        amount: -expense.amount,
        type: TimelineEventType.spending,
      ));
    }

    return _groupByDay(events, ascending: false);
  }

  /// One entry per day for the next 7 days (including empty days),
  /// used by the week strip on the Home tab.
  static List<TimelineDay> nextSevenDays(FinancialData data, {DateTime? now}) {
    final start = dateOnly(now ?? DateTime.now());
    final upcomingDays = upcoming(data, days: 6, now: start);
    return List.generate(7, (index) {
      final date = addDays(start, index);
      final match = upcomingDays.where((day) => day.date == date);
      return match.isEmpty
          ? TimelineDay(date: date, events: const [])
          : match.first;
    });
  }

  // ----------------------------------------------------------
  // Helpers
  // ----------------------------------------------------------

  static List<TimelineDay> _groupByDay(
    List<TimelineEvent> events, {
    required bool ascending,
  }) {
    final byDay = <DateTime, List<TimelineEvent>>{};
    for (final event in events) {
      byDay.putIfAbsent(event.date, () => []).add(event);
    }

    final days = byDay.entries
        .map((entry) => TimelineDay(date: entry.key, events: entry.value))
        .toList();

    days.sort((a, b) =>
        ascending ? a.date.compareTo(b.date) : b.date.compareTo(a.date));

    for (final day in days) {
      // Money in first, then biggest costs.
      day.events.sort((a, b) => b.amount.compareTo(a.amount));
    }

    return days;
  }

  /// Bills repeat monthly from their due date.
  static List<DateTime> _billDates(Bill bill, DateTime start, DateTime end) {
    final dates = <DateTime>[];
    DateTime date = dateOnly(bill.dueDate);
    int guard = 0;

    // An unpaid, overdue bill still shows up today so it is not missed.
    if (date.isBefore(start) && !bill.isPaid) {
      dates.add(start);
    }

    while (date.isBefore(start) && guard < 240) {
      date = FinancialData.addMonths(date, 1);
      guard++;
    }
    while (!date.isAfter(end) && guard < 240) {
      if (!dates.contains(date)) dates.add(date);
      date = FinancialData.addMonths(date, 1);
      guard++;
    }
    return dates;
  }

  /// Works out paydays from the next pay date and how often you are paid.
  static List<DateTime> _paydays(Income income, DateTime start, DateTime end) {
    final anchor = dateOnly(income.nextPayDate);
    final dates = <DateTime>[];

    switch (income.frequency) {
      case PayFrequency.weekly:
      case PayFrequency.biweekly:
        final step = income.frequency == PayFrequency.weekly ? 7 : 14;
        DateTime date = anchor;
        while (date.isBefore(start)) {
          date = addDays(date, step);
        }
        // Step back in case the anchor is further in the future.
        while (!addDays(date, -step).isBefore(start)) {
          date = addDays(date, -step);
        }
        while (!date.isAfter(end)) {
          dates.add(date);
          date = addDays(date, step);
        }
        break;

      case PayFrequency.monthly:
        dates.addAll(_monthlyFrom(anchor, start, end));
        break;

      case PayFrequency.twiceMonthly:
        dates.addAll(_monthlyFrom(anchor, start, end));
        dates.addAll(
          _monthlyFrom(addDays(anchor, 15), start, end),
        );
        dates.sort();
        break;
    }

    return dates;
  }

  static List<DateTime> _monthlyFrom(
    DateTime anchor,
    DateTime start,
    DateTime end,
  ) {
    final dates = <DateTime>[];
    DateTime date = anchor;
    int guard = 0;
    while (date.isBefore(start) && guard < 240) {
      date = FinancialData.addMonths(date, 1);
      guard++;
    }
    while (date.isAfter(start) && guard < 480) {
      final previous = FinancialData.addMonths(date, -1);
      if (previous.isBefore(start)) break;
      date = previous;
      guard++;
    }
    while (!date.isAfter(end) && guard < 720) {
      dates.add(date);
      date = FinancialData.addMonths(date, 1);
      guard++;
    }
    return dates;
  }
}