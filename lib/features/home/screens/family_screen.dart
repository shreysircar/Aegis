// family_screen.dart
import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../../core/widgets/chicago_map.dart'; // keeps types consistent with your app

class FamilyScreen extends StatefulWidget {
  const FamilyScreen({Key? key}) : super(key: key);

  @override
  State<FamilyScreen> createState() => _FamilyScreenState();
}

class _AreaRow {
  final int area;
  final double severity;
  final double safety;
  final Color color;

  _AreaRow({
    required this.area,
    required this.severity,
    required this.safety,
    required this.color,
  });
}

class _FamilyScreenState extends State<FamilyScreen> {
  int _month = 7;
  int _hour = 20;
  int _year = 2022;

  final String apiUrl = 'https://aegis-api-sszj.onrender.com/predict';

  bool _loading = false;
  String? _error;
  List<_AreaRow> _rows = [];

  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _month = now.month;
    _hour = now.hour;
    _year = now.year;
    _refreshLeaderboard();
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }

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

  Future<double> _fetchSeverity(int communityArea, int month, int hour, int year) async {
    final body = json.encode({
      "Community_Area": communityArea,
      "Month": month,
      "Hour": hour,
      "Year": year,
    });

    final resp = await http
        .post(Uri.parse(apiUrl), headers: {'Content-Type': 'application/json'}, body: body)
        .timeout(const Duration(seconds: 10));

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

  Future<void> _buildLeaderboard() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final List<_AreaRow> tmp = [];

      for (int area = 1; area <= 77; area++) {
        try {
          final sev = await _fetchSeverity(area, _month, _hour, _year);
          final safety = _severityToSafety(sev);
          final color = _safetyToColor(safety);
          tmp.add(_AreaRow(area: area, severity: sev, safety: safety, color: color));
        } catch (e) {
          debugPrint('Failed fetching area $area: $e');
        }
        await Future.delayed(const Duration(milliseconds: 80));
      }

      tmp.sort((a, b) => b.safety.compareTo(a.safety));

      setState(() {
        _rows = tmp;
      });
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _refreshLeaderboard() async {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      _buildLeaderboard();
    });
  }

  // ---------------------------------------------------------------------------
  // FIXED SAFETY SCORE WIDGET (NO MORE 4px OVERFLOW)
  // ---------------------------------------------------------------------------

  Widget _buildRow(int idx, _AreaRow r) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      leading: CircleAvatar(
        radius: 20,
        backgroundColor: r.color,
        child: Text(
          '${idx + 1}',
          style: TextStyle(
            color: r.color.darkenIfNeeded(),
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      title: Text(
        'Community ${r.area}',
        style: const TextStyle(fontWeight: FontWeight.w700),
      ),
      subtitle: Text('Severity: ${r.severity.toStringAsFixed(3)}'),

      // 🔥 FIX APPLIED HERE
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4), // reduced vertical padding
        decoration: BoxDecoration(
          color: r.color.withOpacity(0.12),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: r.color.withOpacity(0.22)),
        ),

        // prevents overflow forever
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${r.safety.toStringAsFixed(2)} / 10',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: r.color,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                _safetyLabel(r.safety),
                style: TextStyle(
                  fontSize: 11,
                  color: r.color.darkenIfNeeded(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _safetyLabel(double safety) {
    if (safety >= 8.1) return "Extremely Safe";
    if (safety >= 7.9) return "Very Safe";
    if (safety >= 7.8) return "Safe";
    if (safety >= 7.6) return "Moderately Safe";
    if (safety >= 7.4) return "Slightly Unsafe";
    if (safety >= 7.2) return "Unsafe";
    return "Very Unsafe";
  }

  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Aegis — Leaderboard'),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFF8F9FA),
              Color(0xFFF3F4F6),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),

        child: SingleChildScrollView(
          child: Column(
            children: [
              // Controls
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    child: Row(
                      children: [
                        Expanded(
                          child: InputDecorator(
                            decoration: const InputDecoration(
                              labelText: 'Month',
                              border: OutlineInputBorder(),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<int>(
                                value: _month,
                                isExpanded: true,
                                items: List.generate(12, (i) => i + 1)
                                    .map((m) => DropdownMenuItem(value: m, child: Text('$m')))
                                    .toList(),
                                onChanged: (val) {
                                  setState(() => _month = val ?? _month);
                                  _refreshLeaderboard();
                                },
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(width: 8),

                        Expanded(
                          flex: 2,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Hour', style: TextStyle(fontWeight: FontWeight.w600)),
                              Slider(
                                value: _hour.toDouble(),
                                min: 0,
                                max: 23,
                                divisions: 23,
                                label: '$_hour',
                                onChanged: (val) {
                                  setState(() => _hour = val.toInt());
                                  _refreshLeaderboard();
                                },
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(width: 8),

                        Expanded(
                          child: InputDecorator(
                            decoration: const InputDecoration(
                              labelText: 'Year',
                              border: OutlineInputBorder(),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<int>(
                                value: _year,
                                isExpanded: true,
                                items: List.generate(DateTime.now().year + 10 - 2013 + 1,
                                        (i) => 2013 + i)
                                    .map((y) => DropdownMenuItem(value: y, child: Text('$y')))
                                    .toList(),
                                onChanged: (val) {
                                  setState(() => _year = val ?? _year);
                                  _refreshLeaderboard();
                                },
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(width: 8),

                        IconButton(
                          onPressed: _buildLeaderboard,
                          icon: const Icon(Icons.refresh),
                          tooltip: 'Refresh leaderboard',
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Showing leaderboard for Month: $_month  Hour: $_hour  Year: $_year',
                        style: const TextStyle(fontSize: 13, color: Colors.black54),
                      ),
                    ),
                    if (_loading)
                      const SizedBox(
                          height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2))
                    else
                      Text('${_rows.length} areas', style: const TextStyle(color: Colors.black54)),
                  ],
                ),
              ),

              SizedBox(
                height: 600,
                child: RefreshIndicator(
                  onRefresh: _buildLeaderboard,
                  child: _loading && _rows.isEmpty
                      ? const Center(child: CircularProgressIndicator())
                      : _error != null
                      ? ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: Text(
                          'Error: $_error',
                          style: const TextStyle(color: Colors.red),
                        ),
                      )
                    ],
                  )
                      : ListView.separated(
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemCount: _rows.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, index) =>
                        _buildRow(index, _rows[index]),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

extension _ColorReadability on Color {
  Color darkenIfNeeded() {
    final luma = (0.299 * red + 0.587 * green + 0.114 * blue) / 255;
    return luma > 0.6 ? Colors.black87 : Colors.black;
  }
}
