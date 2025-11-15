import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../../core/services/csv_insights_service.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  // API comparison areas
  int _areaA = 1;
  int _areaB = 2;

  // For real-time API (unchanged)
  late int _month;
  late int _hour;
  late int _year;

  // For CSV historical selectors
  int? _csvYearA;
  int? _csvMonthA;
  int? _csvYearB;
  int? _csvMonthB;

  // Loaded CSV rows
  Map<String, dynamic>? _csvA;
  Map<String, dynamic>? _csvB;

  // Loading flags
  bool _loadingA = false;
  bool _loadingB = false;
  String? _errorA;
  String? _errorB;

  // API Results
  double? _severityA;
  double? _safetyA;
  double? _severityB;
  double? _safetyB;

  Color _colorA = Colors.grey.shade400;
  Color _colorB = Colors.grey.shade400;

  final String apiUrl = 'https://aegis-api-sszj.onrender.com/predict';

  @override
  void initState() {
    super.initState();

    final now = DateTime.now();
    _month = now.month;
    _hour = now.hour;
    _year = now.year;

    CSVInsightsService.init().then((_) {
      // Default CSV selectors = latest available year/month
      final latestA = CSVInsightsService.getLatestInsights(_areaA);
      final latestB = CSVInsightsService.getLatestInsights(_areaB);

      _csvYearA = latestA?["Year"];
      _csvMonthA = latestA?["Month"];

      _csvYearB = latestB?["Year"];
      _csvMonthB = latestB?["Month"];

      _fetchBoth();
    });
  }

  Future<void> _fetchBoth() async {
    await Future.wait([
      _fetchForA(),
      _fetchForB(),
      _fetchCsvA(),
      _fetchCsvB(),
    ]);
  }

  Future<void> _fetchCsvA() async {
    if (_csvYearA == null || _csvMonthA == null) return;
    _csvA = CSVInsightsService.getDataPoint(_areaA, _csvYearA!, _csvMonthA!);
    setState(() {});
  }

  Future<void> _fetchCsvB() async {
    if (_csvYearB == null || _csvMonthB == null) return;
    _csvB = CSVInsightsService.getDataPoint(_areaB, _csvYearB!, _csvMonthB!);
    setState(() {});
  }

  // ===================== API FETCH ======================

  Future<void> _fetchForA() async {
    setState(() {
      _loadingA = true;
      _errorA = null;
    });
    try {
      final sev = await _fetchSeverity(_areaA, _month, _hour, _year);
      setState(() {
        _severityA = sev;
        _safetyA = _severityToSafety(sev);
        _colorA = _safetyToColor(_safetyA!);
      });
    } catch (e) {
      setState(() => _errorA = e.toString());
    } finally {
      setState(() => _loadingA = false);
    }
  }

  Future<void> _fetchForB() async {
    setState(() {
      _loadingB = true;
      _errorB = null;
    });
    try {
      final sev = await _fetchSeverity(_areaB, _month, _hour, _year);
      setState(() {
        _severityB = sev;
        _safetyB = _severityToSafety(sev);
        _colorB = _safetyToColor(_safetyB!);
      });
    } catch (e) {
      setState(() => _errorB = e.toString());
    } finally {
      setState(() => _loadingB = false);
    }
  }

  Future<double> _fetchSeverity(int area, int month, int hour, int year) async {
    final body = json.encode({
      "Community_Area": area,
      "Month": month,
      "Hour": hour,
      "Year": year,
    });

    final resp = await http.post(
      Uri.parse(apiUrl),
      headers: {"Content-Type": "application/json"},
      body: body,
    );

    if (resp.statusCode == 200) {
      final data = json.decode(resp.body);
      final sev = data["severity_score"];
      return (sev is num) ? sev.toDouble() : double.tryParse("$sev") ?? 0.0;
    } else {
      throw Exception("API ERROR ${resp.statusCode}");
    }
  }

  // ===================== UTIL LOGIC ======================

  double _severityToSafety(double sev) {
    const double sMin = 0.7;
    const double sMax = 33.5167;
    double scaled = (sev - sMin) / (sMax - sMin);
    double safety = 10 * (1 - scaled);
    return safety.clamp(0, 10);
  }

  Color _safetyToColor(double safety) {
    const minSafe = 7.0;
    const maxSafe = 8.0;
    double t = ((safety - minSafe) / (maxSafe - minSafe)).clamp(0, 1);

    const k = 10.0;
    const center = 0.5;
    t = 1 / (1 + exp(-k * (t - center)));

    final hue = t * 120.0;
    return HSVColor.fromAHSV(1.0, hue, 0.85, 0.85).toColor();
  }

  List<int> _dummyRecentArrests() {
    final rnd = Random();
    return List.generate(6, (_) => rnd.nextInt(30));
  }

  List<DropdownMenuItem<int>> _areaItems() {
    return List.generate(77, (i) => i + 1)
        .map((e) => DropdownMenuItem(value: e, child: Text("$e")))
        .toList();
  }

  // ===================== UI CARD ======================

  Widget _buildAreaPanel({
    required String title,
    required int area,
    required Color color,
    required bool loading,
    required String? error,
    double? severity,
    double? safety,
    Map<String, dynamic>? csv,
    required int? selectedYear,
    required int? selectedMonth,
    required void Function(int?) onYearChanged,
    required void Function(int?) onMonthChanged,
  }) {
    final arrests = _dummyRecentArrests();

    final years = CSVInsightsService.getYearsForCommunity(area);
    final months =
    selectedYear != null ? CSVInsightsService.getMonthsForCommunity(area, selectedYear) : [];

    return Card(
      elevation: 4,
      margin: const EdgeInsets.all(8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // TITLE ROW
            Row(
              children: [
                Expanded(
                  child: Text(
                    "$title — Area $area",
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                ),
                CircleAvatar(radius: 14, backgroundColor: color),
              ],
            ),

            const SizedBox(height: 12),

            // ================= HISTORICAL SELECTORS =================
            const Text("Historical Data", style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),

            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<int>(
                    value: selectedYear,
                    items: years
                        .map((y) => DropdownMenuItem(value: y, child: Text("$y")))
                        .toList(),
                    onChanged: onYearChanged,
                    decoration: const InputDecoration(
                      labelText: "Year",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: DropdownButtonFormField<int>(
                    value: selectedMonth,
                    items: months
                        .map((y) => DropdownMenuItem<int>(value: y, child: Text("$y")))

                        .toList(),
                    onChanged: onMonthChanged,
                    decoration: const InputDecoration(
                      labelText: "Month",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 14),

            // ================= API RESULTS =================
            if (loading)
              const LinearProgressIndicator()
            else if (error != null)
              Text("Error: $error", style: const TextStyle(color: Colors.red))
            else ...[
                Text("Severity: ${severity?.toStringAsFixed(3) ?? '—'}"),
                const SizedBox(height: 6),
                Text(
                  safety != null ? _safetyDescription(safety) : 'Loading...',
                  style: TextStyle(fontWeight: FontWeight.w700, color: color),
                ),
                const SizedBox(height: 12),
                const Text("Recent arrests:"),
                const SizedBox(height: 4),
                SizedBox(height: 60, child: _buildMiniBarChart(arrests, color)),
                const SizedBox(height: 12),

                // ================= CSV RESULTS =================
                if (csv != null) ...[
                  Text("Total Arrests: ${csv["Total_Arrests"]}"),
                  Text("Primary Crime: ${csv["Primary_Crime1"]}"),
                  Text("Hotspot: ${csv["Location1"]}"),
                  const SizedBox(height: 10),
                ],
              ],
          ],
        ),
      ),
    );
  }

  Widget _buildMiniBarChart(List<int> values, Color color) {
    final maxV = values.reduce(max).toDouble();
    return Row(
      children: values.map((v) {
        final h = maxV == 0 ? 0.1 : (v / maxV);
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: FractionallySizedBox(
              alignment: Alignment.bottomCenter,
              heightFactor: 0.6 * (0.3 + h),
              child: Container(
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  String _safetyDescription(double s) {
    if (s >= 8.1) return "Extremely Safe 💚";
    if (s >= 7.9) return "Very Safe ✅";
    if (s >= 7.8) return "Safe 🟢";
    if (s >= 7.6) return "Moderately Safe ⚠️";
    if (s >= 7.4) return "Slightly Unsafe 🔶";
    if (s >= 7.2) return "Unsafe 🔴";
    return "Very Unsafe 🚨";
  }

  // ===================== MAIN BUILD ======================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Aegis – Comparative Safety")),
      body: Column(
        children: [
          // COMMUNITY SELECTORS + COMPARE BUTTON
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<int>(
                    value: _areaA,
                    items: _areaItems(),
                    onChanged: (v) {
                      setState(() {
                        _areaA = v!;
                        final latest = CSVInsightsService.getLatestInsights(_areaA);
                        _csvYearA = latest?["Year"];
                        _csvMonthA = latest?["Month"];
                      });
                      _fetchBoth();
                    },
                    decoration: const InputDecoration(
                      labelText: "Community A",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: DropdownButtonFormField<int>(
                    value: _areaB,
                    items: _areaItems(),
                    onChanged: (v) {
                      setState(() {
                        _areaB = v!;
                        final latest = CSVInsightsService.getLatestInsights(_areaB);
                        _csvYearB = latest?["Year"];
                        _csvMonthB = latest?["Month"];
                      });
                      _fetchBoth();
                    },
                    decoration: const InputDecoration(
                      labelText: "Community B",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: _fetchBoth,
                  icon: const Icon(Icons.refresh),
                  label: const Text("Compare"),
                ),
              ],
            ),
          ),

          // Displays the real-time API inputs used
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: Row(
              children: [
                Text(
                  "Inputs — Month: $_month  Hour: $_hour  Year: $_year",
                  style: const TextStyle(fontSize: 12, color: Colors.black54),
                ),
              ],
            ),
          ),

          // MAIN PANELS
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: _buildAreaPanel(
                            title: "Left",
                            area: _areaA,
                            color: _colorA,
                            loading: _loadingA,
                            error: _errorA,
                            severity: _severityA,
                            safety: _safetyA,
                            csv: _csvA,
                            selectedYear: _csvYearA,
                            selectedMonth: _csvMonthA,
                            onYearChanged: (y) {
                              setState(() {
                                _csvYearA = y;
                                _csvMonthA = null;
                              });
                              _fetchCsvA();
                            },
                            onMonthChanged: (m) {
                              setState(() => _csvMonthA = m);
                              _fetchCsvA();
                            },
                          ),
                        ),
                        Expanded(
                          child: _buildAreaPanel(
                            title: "Right",
                            area: _areaB,
                            color: _colorB,
                            loading: _loadingB,
                            error: _errorB,
                            severity: _severityB,
                            safety: _safetyB,
                            csv: _csvB,
                            selectedYear: _csvYearB,
                            selectedMonth: _csvMonthB,
                            onYearChanged: (y) {
                              setState(() {
                                _csvYearB = y;
                                _csvMonthB = null;
                              });
                              _fetchCsvB();
                            },
                            onMonthChanged: (m) {
                              setState(() => _csvMonthB = m);
                              _fetchCsvB();
                            },
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

extension _ColorReadability on Color {
  Color darkenIfNeeded() {
    final luma = (0.299 * red + 0.587 * green + 0.114 * blue) / 255;
    return luma > 0.6 ? Colors.black87 : Colors.white;
  }
}
