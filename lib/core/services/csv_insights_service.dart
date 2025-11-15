import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

class CSVInsightsService {
  static List<Map<String, dynamic>> _rows = [];

  /// Load CSV one time
  static Future<void> init() async {
    if (_rows.isNotEmpty) return;

    final raw = await rootBundle.loadString("assets/data/chicago_stats.csv");
    final lines = const LineSplitter().convert(raw);

    final headers = lines.first.split(',');

    for (int i = 1; i < lines.length; i++) {
      final values = lines[i].split(',');

      final row = <String, dynamic>{};
      for (int j = 0; j < headers.length; j++) {
        row[headers[j]] = values[j];
      }

      // Parse numeric fields into ints/doubles
      row["Community_Area"] = int.tryParse(row["Community_Area"] ?? "") ?? 0;
      row["Year"] = int.tryParse(row["Year"] ?? "") ?? 0;
      row["Month"] = int.tryParse(row["Month"] ?? "") ?? 0;

      row["Total_Arrests"] = int.tryParse(row["Total_Arrests"] ?? "") ?? 0;
      row["Total_Domestic_Crimes"] =
          int.tryParse(row["Total_Domestic_Crimes"] ?? "") ?? 0;
      row["Total_Crimes"] = int.tryParse(row["Total_Crimes"] ?? "") ?? 0;
      row["Percentage_Domestic"] =
          double.tryParse(row["Percentage_Domestic"] ?? "") ?? 0.0;

      _rows.add(row);
    }
  }

  /// Get latest available row for a community (your original function)
  static Map<String, dynamic>? getLatestInsights(int communityArea) {
    final matches =
    _rows.where((r) => r["Community_Area"] == communityArea).toList();

    if (matches.isEmpty) return null;

    matches.sort((a, b) {
      // Sort by Year desc → Month desc
      final compYear = b["Year"].compareTo(a["Year"]);
      if (compYear != 0) return compYear;
      return b["Month"].compareTo(a["Month"]);
    });

    return matches.first;
  }

  /// Get all available years for a community
  static List<int> getYearsForCommunity(int communityArea) {
    final years = _rows
        .where((r) => r["Community_Area"] == communityArea)
        .map((r) => r["Year"] as int)
        .toSet()
        .toList()
      ..sort();
    return years;
  }

  /// Get all available months for a community + year
  static List<int> getMonthsForCommunity(int communityArea, int year) {
    final months = _rows
        .where((r) =>
    r["Community_Area"] == communityArea && r["Year"] == year)
        .map((r) => r["Month"] as int)
        .toSet()
        .toList()
      ..sort();
    return months;
  }

  /// Fetch exact row for community + year + month
  static Map<String, dynamic>? getDataPoint(
      int communityArea, int year, int month) {
    try {
      return _rows.firstWhere((r) =>
      r["Community_Area"] == communityArea &&
          r["Year"] == year &&
          r["Month"] == month);
    } catch (_) {
      return null;
    }
  }

  /// Fetch all rows for a community (for charts, history, etc.)
  static List<Map<String, dynamic>> getFullHistory(int communityArea) {
    return _rows
        .where((r) => r["Community_Area"] == communityArea)
        .toList()
      ..sort((a, b) {
        final compYear = a["Year"].compareTo(b["Year"]);
        if (compYear != 0) return compYear;
        return a["Month"].compareTo(b["Month"]);
      });
  }
}
