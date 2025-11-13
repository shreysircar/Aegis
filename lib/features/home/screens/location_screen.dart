import 'package:flutter/material.dart';
import '../../../core/widgets/chicago_map.dart';

class LocationScreen extends StatefulWidget {
  const LocationScreen({Key? key}) : super(key: key);

  @override
  State<LocationScreen> createState() => _LocationScreenState();
}

class _LocationScreenState extends State<LocationScreen> {
  Community? _selected;
  int _month = 7;
  int _hour = 20;
  int _year = 2022;

  void _onCommunityTap(Community c) {
    setState(() => _selected = c);
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey[100],
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => _buildDetailsSheet(c),
    );
  }

  Widget _buildDetailsSheet(Community c) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Wrap(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Community ${c.areaNumber}',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Chip(
                label: Text(
                  c.safety != null
                      ? 'Safety: ${c.safety!.toStringAsFixed(2)} / 10'
                      : 'Loading...',
                ),
                backgroundColor: c.color.withOpacity(0.15),
                avatar: Icon(Icons.shield, color: c.color),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            c.severity != null
                ? 'Severity Score: ${c.severity!.toStringAsFixed(3)}'
                : 'Fetching severity...',
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 8),
          if (c.safety != null)
            Text(
              _safetyDescription(c.safety!),
              style: TextStyle(
                color: c.color,
                fontWeight: FontWeight.w600,
              ),
            ),
          const SizedBox(height: 20),
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton.icon(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.close),
              label: const Text('Close'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent.shade100,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _safetyDescription(double safety) {
    if (safety >= 8.1) return "Extremely Safe 💚";
    if (safety >= 7.9) return "Very Safe ✅";
    if (safety >= 7.8) return "Safe 🟢";
    if (safety >= 7.6) return "Moderately Safe ⚠️";
    if (safety >= 7.4) return "Slightly Unsafe 🔶";
    if (safety >= 7.2) return "Unsafe 🔴";
    return "Very Unsafe 🚨";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Aegis — Heatzones'),
        elevation: 2,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFF8F9FA),
              Color(0xFFF0F0F0),
              Color(0xFFECECEC),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            // --- Header text ---
            Container(
              height: 50,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              alignment: Alignment.centerLeft,
              child: const Text(
                'Heatzone Mapping: 🟢 Safe → 🔴 Unsafe',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                  letterSpacing: 0.2,
                ),
              ),
            ),

            // --- Control row card ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: Card(
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                shadowColor: Colors.black26,
                child: Padding(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  child: Row(
                    children: [
                      // Month Dropdown
                      Expanded(
                        child: InputDecorator(
                          decoration: const InputDecoration(
                            labelText: 'Month',
                            border: OutlineInputBorder(
                              borderRadius:
                              BorderRadius.all(Radius.circular(10)),
                            ),
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<int>(
                              value: _month,
                              isExpanded: true,
                              items: List.generate(12, (i) => i + 1)
                                  .map((m) => DropdownMenuItem(
                                  value: m, child: Text('$m')))
                                  .toList(),
                              onChanged: (val) =>
                                  setState(() => _month = val ?? _month),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),

                      // Hour Slider
                      Expanded(
                        flex: 2,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Hour',
                                style: TextStyle(
                                    fontWeight: FontWeight.w600, fontSize: 13)),
                            SliderTheme(
                              data: SliderTheme.of(context).copyWith(
                                activeTrackColor: Colors.redAccent,
                                thumbColor: Colors.redAccent,
                                overlayColor:
                                Colors.redAccent.withOpacity(0.2),
                              ),
                              child: Slider(
                                value: _hour.toDouble(),
                                min: 0,
                                max: 23,
                                divisions: 23,
                                label: '$_hour',
                                onChanged: (val) =>
                                    setState(() => _hour = val.toInt()),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),

                      // Year Dropdown
                      Expanded(
                        child: InputDecorator(
                          decoration: const InputDecoration(
                            labelText: 'Year',
                            border: OutlineInputBorder(
                              borderRadius:
                              BorderRadius.all(Radius.circular(10)),
                            ),
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<int>(
                              value: _year,
                              isExpanded: true,
                              items: List.generate(
                                  DateTime.now().year + 10 - 2013 + 1,
                                      (i) => 2013 + i)
                                  .map((y) => DropdownMenuItem(
                                  value: y, child: Text('$y')))
                                  .toList(),
                              onChanged: (val) =>
                                  setState(() => _year = val ?? _year),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // --- Map background container ---
            Expanded(
              child: Container(
                margin: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12.withOpacity(0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                clipBehavior: Clip.antiAlias,
                child: ChicagoMap(
                  svgAssetPath: 'assets/images/chicago_communities.svg',
                  apiUrl: 'https://aegis-api-sszj.onrender.com/predict',
                  month: _month,
                  hour: _hour,
                  year: _year,
                  onCommunityTap: _onCommunityTap,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
