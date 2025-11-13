import 'package:flutter/material.dart';
import '../../../core/widgets/chicago_map.dart';

class LocationScreen extends StatefulWidget {
  const LocationScreen({Key? key}) : super(key: key);

  @override
  State<LocationScreen> createState() => _LocationScreenState();
}

class _LocationScreenState extends State<LocationScreen> {
  Community? _selected;

  void _onCommunityTap(Community c) {
    setState(() => _selected = c);
    // show bottom sheet with details
    showModalBottomSheet(
      context: context,
      builder: (ctx) => _buildDetailsSheet(c),
    );
  }

  Widget _buildDetailsSheet(Community c) {
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
          const SizedBox(height: 10),
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
                fontWeight: FontWeight.w500,
              ),
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

  /// Give a short human-readable label based on safety value
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
        title: const Text('Aegis — Heatzones'),
      ),
      body: Column(
        children: [
          Container(
            height: 48,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            alignment: Alignment.centerLeft,
            child: const Text(
              'Heatzone Color Mapping: Green (Safe) → Red (Unsafe)',
              style: TextStyle(fontWeight: FontWeight.w600),
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
