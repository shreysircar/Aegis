import 'dart:math';
import 'package:flutter/material.dart';
import '../../../core/widgets/chicago_map.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  Community? _selected;

  void _onCommunityTap(Community c) {
    setState(() => _selected = c);

    // generate dummy severity/safety for modal
    final dummySeverity = (Random().nextDouble() * 33.5).clamp(0.7, 33.5);
    final dummySafety = _severityToSafety(dummySeverity);
    final dummyColor = _safetyToColor(dummySafety);

    // show modal bottom sheet
    showModalBottomSheet(
      context: context,
      builder: (ctx) => _buildDetailsSheet(c, dummySeverity, dummySafety, dummyColor),
    );
  }

  Widget _buildDetailsSheet(Community c, double severity, double safety, Color color) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Wrap(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Community ${c.areaNumber}',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Chip(
                label: Text('Safety: ${safety.toStringAsFixed(2)} / 10'),
                backgroundColor: color.withOpacity(0.15),
                avatar: Icon(Icons.shield, color: color),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'Severity Score: ${severity.toStringAsFixed(3)}',
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 8),
          Text(
            _safetyDescription(safety),
            style: TextStyle(color: color, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 12),
          // Dummy info section (later replace with API data)
          const Text(
            'Dummy info about this community goes here. '
                'This could include crime stats, safety tips, or other relevant details.',
            style: TextStyle(fontSize: 14),
          ),
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ),
        ],
      ),
    );
  }

  // --- Helpers for dummy data coloring ---
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
    double t = (safety / 10.0).clamp(0.0, 1.0);
    const double k = 20.0;
    const double center = 0.75;
    t = 1 / (1 + exp(-k * (t - center)));
    final hue = t * 120.0;
    final hsv = HSVColor.fromAHSV(1.0, hue, 0.85, 0.85);
    return hsv.toColor();
  }

  String _safetyDescription(double safety) {
    if (safety >= 8) return "Very Safe ✅";
    if (safety >= 7.8) return "Safe 🟢";
    if (safety >= 7.5) return "Moderate ⚠️";
    if (safety >= 6.5) return "Unsafe 🔶";
    return "Very Unsafe 🔴";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Aegis — Search Map'),
      ),
      body: Column(
        children: [
          Container(
            height: 48,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            alignment: Alignment.centerLeft,
            child: const Text(
              'Heatzone Legend: Green (Safe) → Red (Unsafe)',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: ChicagoMap(
              svgAssetPath: 'assets/images/chicago_communities.svg',
              apiUrl: 'https://aegis-api-sszj.onrender.com/predict',
              month: 7,
              hour: 20,
              year: 2022,
              onCommunityTap: _onCommunityTap,
            ),
          ),
        ],
      ),
    );
  }
}
