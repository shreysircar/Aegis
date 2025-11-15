import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../../core/widgets/chicago_map.dart'; // keeps types consistent with your app

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  // UI state
  int _areaA = 1;
  int _areaB = 2;

  // Date/time inputs (default to now)
  late int _month;
  late int _hour;
  late int _year;

  // API state
  bool _loadingA = false;
  bool _loadingB = false;
  String? _errorA;
  String? _errorB;

  double? _severityA;
  double? _safetyA;
  Color _colorA = Colors.grey.shade400;

  double? _severityB;
  double? _safetyB;
  Color _colorB = Colors.grey.shade400;

  final String apiUrl = 'https://aegis-api-sszj.onrender.com/predict';

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _month = now.month;
    _hour = now.hour;
    _year = now.year;

    // initial fetch
    _fetchBoth();
  }

  Future<void> _fetchBoth() async {
    await Future.wait([_fetchForA(), _fetchForB()]);
  }

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

  Future<double> _fetchSeverity(int communityArea, int month, int hour, int year) async {
    final body = json.encode({
      "Community_Area": communityArea,
      "Month": month,
      "Hour": hour,
      "Year": year,
    });

    final resp = await http.post(
      Uri.parse(apiUrl),
      headers: {'Content-Type': 'application/json'},
      body: body,
    ).timeout(const Duration(seconds: 10));

    if (resp.statusCode == 200) {
      final data = json.decode(resp.body);
      final severity = (data['severity_score'] is num)
          ? (data['severity_score'] as num).toDouble()
          : double.tryParse('${data['severity_score']}') ?? 0.0;
      return severity;
    } else {
      throw Exception('API ${resp.statusCode}: ${resp.body}');
    }
  }

  // The same conversion used in chicago_map.dart
  double _severityToSafety(double sev) {
    const double sMin = 0.7;
    const double sMax = 33.5167;
    double safety;
    if (sMax > sMin) {
      final scaled = (sev - sMin) / (sMax - sMin);
      safety = 10.0 * (1.0 - scaled);
    } else {
      safety = 10.0 - sev;
    }
    return safety.clamp(0.0, 10.0);
  }

  // Same color mapping (rescale focused for tight 7..8 range)
  Color _safetyToColor(double safety) {
    const double minSafe = 7.0;
    const double maxSafe = 8.0;
    double t = ((safety - minSafe) / (maxSafe - minSafe)).clamp(0.0, 1.0);
    const double k = 10.0;
    const double center = 0.5;
    t = 1 / (1 + exp(-k * (t - center)));
    final hue = t * 120.0;
    final hsv = HSVColor.fromAHSV(1.0, hue, 0.85, 0.85);
    return hsv.toColor();
  }

  // Safety description same style as location_screen (tight range)
  String _safetyDescription(double safety) {
    if (safety >= 8.1) return "Extremely Safe 💚";
    if (safety >= 7.9) return "Very Safe ✅";
    if (safety >= 7.8) return "Safe 🟢";
    if (safety >= 7.6) return "Moderately Safe ⚠️";
    if (safety >= 7.4) return "Slightly Unsafe 🔶";
    if (safety >= 7.2) return "Unsafe 🔴";
    return "Very Unsafe 🚨";
  }

  // Dummy arrests trend generator — replace with real data integration later
  List<int> _dummyRecentArrests() {
    final rnd = Random();
    return List.generate(6, (_) => rnd.nextInt(30));
  }

  Widget _buildMiniBarChart(List<int> values, Color color) {
    if (values.isEmpty) return const SizedBox.shrink();
    final maxV = values.reduce(max).toDouble();
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: values.map((v) {
        final heightFactor = maxV == 0 ? 0.0 : (v / maxV);
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: FractionallySizedBox(
              alignment: Alignment.bottomCenter,
              heightFactor: 0.6 * (0.3 + heightFactor), // visual scale
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

  Widget _buildAreaPanel({
    required String title,
    required int area,
    required bool loading,
    required String? error,
    double? severity,
    double? safety,
    required Color color,
  }) {
    final arrests = _dummyRecentArrests();
    return Card(
      elevation: 4,
      margin: const EdgeInsets.all(8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    '$title — Area $area',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                ),
                CircleAvatar(
                  radius: 14,
                  backgroundColor: color,
                ),
                const SizedBox(width: 8),
                Chip(
                  backgroundColor: color.withOpacity(0.12),
                  label: Text(
                    safety != null ? 'Safety ${safety.toStringAsFixed(2)}' : 'Safety —',
                    style: TextStyle(color: color.darkenIfNeeded()),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            if (loading)
              const LinearProgressIndicator()
            else if (error != null)
              Text('Error: $error', style: const TextStyle(color: Colors.red))
            else
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    severity != null ? 'Severity: ${severity.toStringAsFixed(3)}' : 'Severity —',
                    style: const TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    safety != null ? _safetyDescription(safety) : 'Loading safety...',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: color),
                  ),
                  const SizedBox(height: 12),
                  const Text('Recent arrests (dummy):', style: TextStyle(fontSize: 13)),
                  const SizedBox(height: 8),
                  SizedBox(height: 60, child: _buildMiniBarChart(arrests, color)),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Icon(Icons.local_police, size: 16),
                      const SizedBox(width: 8),
                      Expanded(child: Text('Most common crime: Burglary (dummy)')),
                    ],
                  ),
                ],
              ),

            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  // UI helpers for dropdowns
  List<DropdownMenuItem<int>> _areaItems() {
    return List.generate(77, (i) => i + 1)
        .map((v) => DropdownMenuItem<int>(value: v, child: Text('$v')))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Aegis — Comparative Safety'),
      ),
      body: Container(
        // slightly tinted background so heatmap area feels less empty
        color: Colors.grey.shade50,
        child: Column(
          children: [
            // inputs row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Row(
                children: [
                  // Area A
                  Expanded(
                    child: InputDecorator(
                      decoration: const InputDecoration(labelText: 'Community A', border: OutlineInputBorder()),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<int>(
                          value: _areaA,
                          items: _areaItems(),
                          onChanged: (v) => setState(() => _areaA = v ?? _areaA),
                          isExpanded: true,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Area B
                  Expanded(
                    child: InputDecorator(
                      decoration: const InputDecoration(labelText: 'Community B', border: OutlineInputBorder()),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<int>(
                          value: _areaB,
                          items: _areaItems(),
                          onChanged: (v) => setState(() => _areaB = v ?? _areaB),
                          isExpanded: true,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: () async {
                      await _fetchBoth();
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('Compare'),
                  ),
                ],
              ),
            ),

            // time used info
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              child: Row(
                children: [
                  Text('Inputs used — Month: $_month   Hour: $_hour   Year: $_year',
                      style: const TextStyle(fontSize: 12, color: Colors.black54)),
                  const Spacer(),
                  Text('Data: API ${apiUrl.split('/predict').first}/predict', style: const TextStyle(fontSize: 12, color: Colors.black45)),
                ],
              ),
            ),

            // panels
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: Column(
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: _buildAreaPanel(
                              title: 'Left',
                              area: _areaA,
                              loading: _loadingA,
                              error: _errorA,
                              severity: _severityA,
                              safety: _safetyA,
                              color: _colorA,
                            ),
                          ),
                          Expanded(
                            child: _buildAreaPanel(
                              title: 'Right',
                              area: _areaB,
                              loading: _loadingB,
                              error: _errorB,
                              severity: _severityB,
                              safety: _safetyB,
                              color: _colorB,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      // Comparative insight card (dummy data)
                      Card(
                        elevation: 3,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Community Insights', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Expanded(child: Text('Did you know? In 2024, 65% of crimes in area $_areaA occurred after 8 PM. (dummy)')),
                                  const SizedBox(width: 8),
                                ],
                              ),
                              const SizedBox(height: 10),
                              const Text('Quick comparison', style: TextStyle(fontWeight: FontWeight.w600)),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Expanded(child: _smallStat('Safety A', _safetyA?.toStringAsFixed(2) ?? '—', _colorA)),
                                  const SizedBox(width: 8),
                                  Expanded(child: _smallStat('Safety B', _safetyB?.toStringAsFixed(2) ?? '—', _colorB)),
                                  const SizedBox(width: 8),
                                  Expanded(child: _smallStat('Severity A', _severityA?.toStringAsFixed(3) ?? '—', _colorA)),
                                  const SizedBox(width: 8),
                                  Expanded(child: _smallStat('Severity B', _severityB?.toStringAsFixed(3) ?? '—', _colorB)),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _smallStat(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: color.withOpacity(0.08),
      ),
      child: Column(
        children: [
          Text(label, style: const TextStyle(fontSize: 12)),
          const SizedBox(height: 6),
          Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: color)),
        ],
      ),
    );
  }
}

/// small extension to ensure chip text is readable on light backgrounds
extension _ColorReadability on Color {
  Color darkenIfNeeded() {
    // quick contrast check: if light, return Colors.black87 else white
    final luma = (0.299 * red + 0.587 * green + 0.114 * blue) / 255;
    return luma > 0.6 ? Colors.black87 : Colors.white;
  }
}
