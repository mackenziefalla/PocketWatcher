import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/financial_data.dart';

class StorageService {
  static const String _financialDataKey = 'financial_data';

  // Saves all financial data to the device as a JSON string
  static Future<void> saveFinancialData(FinancialData data) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = jsonEncode(data.toMap());
    await prefs.setString(_financialDataKey, jsonString);
  }

  // Loads saved financial data, or returns empty data on first run
  static Future<FinancialData> loadFinancialData() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_financialDataKey);

    if (jsonString == null) {
      return FinancialData();
    }

    try {
      final map = jsonDecode(jsonString) as Map<String, dynamic>;
      return FinancialData.fromMap(map);
    } catch (_) {
      return FinancialData();
    }
  }

  // Deletes all saved financial data (useful for a future "reset" option)
  static Future<void> clearFinancialData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_financialDataKey);
  }
}
