import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

// 🔹 Import our model & widgets
import '../models/incident_model.dart';
import '../widgets/incident_slider.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final MapController _mapController = MapController();
  final TextEditingController _searchController = TextEditingController();

  // Simulated places
  final Map<String, LatLng> _places = {
    'Central Park': LatLng(40.785091, -73.968285),
    'Times Square': LatLng(40.758896, -73.985130),
  };

  // 🔹 Incident list (dynamic cards)
  final List<Incident> _incidents = [
    Incident(title: "Theft at Central Park", riskLevel: "Risk Level: High", risk: RiskLevel.high),
    Incident(title: "Assault at Times Square", riskLevel: "Risk Level: Low", risk: RiskLevel.low),
    Incident(title: "Robbery at 5th Avenue", riskLevel: "Risk Level: Medium", risk: RiskLevel.medium),
  ];

  void _goToPlace(String placeName) {
    final query = placeName.trim().toLowerCase();

    final match = _places.entries.firstWhere(
          (entry) => entry.key.toLowerCase().contains(query),
      orElse: () => MapEntry('', LatLng(0, 0)),
    );

    if (match.key.isNotEmpty) {
      _mapController.move(match.value, 14.0);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Place not found")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Map
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: LatLng(40.785091, -73.968285),
              initialZoom: 12.0,
            ),
            children: [
              TileLayer(
                urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
                userAgentPackageName: 'com.example.aegis',
              ),
              CircleLayer(
                circles: [
                  CircleMarker(
                    point: LatLng(40.785091, -73.968285),
                    radius: 120,
                    color: Colors.red.withOpacity(0.3),
                    borderStrokeWidth: 2,
                    borderColor: Colors.red,
                  ),
                  CircleMarker(
                    point: LatLng(40.758896, -73.985130),
                    radius: 120,
                    color: Colors.blue.withOpacity(0.3),
                    borderStrokeWidth: 2,
                    borderColor: Colors.blue,
                  ),
                ],
              ),
            ],
          ),

          // Search Bar
          Positioned(
            top: 50,
            left: 16,
            right: 16,
            child: Material(
              elevation: 4,
              borderRadius: BorderRadius.circular(12),
              child: Autocomplete<String>(
                optionsBuilder: (TextEditingValue value) {
                  if (value.text.isEmpty) {
                    return const Iterable<String>.empty();
                  }
                  return _places.keys.where(
                        (place) => place.toLowerCase().contains(value.text.toLowerCase()),
                  );
                },
                onSelected: (String selection) {
                  _searchController.text = selection;
                  _goToPlace(selection);
                },
                fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
                  controller.text = _searchController.text;
                  return TextField(
                    controller: controller,
                    focusNode: focusNode,
                    decoration: InputDecoration(
                      hintText: "Search places",
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      suffixIcon: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.search, color: Colors.black54),
                            onPressed: () => _goToPlace(controller.text),
                          ),
                          IconButton(
                            icon: const Icon(Icons.tune, color: Colors.black54),
                            onPressed: () {
                              // TODO: filter action
                            },
                          ),
                        ],
                      ),
                    ),
                    onSubmitted: (value) => _goToPlace(value),
                  );
                },
              ),
            ),
          ),

          // Bottom Section: FAB + Slider
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 80), // space above nav bar
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // FAB
                  Align(
                    alignment: Alignment.centerRight,
                    child: Padding(
                      padding: const EdgeInsets.only(right: 20, bottom: 16),
                      child: FloatingActionButton(
                        backgroundColor: Colors.red,
                        onPressed: () {
                          // TODO: action
                        },
                        child: const Icon(Icons.add, color: Colors.white),
                      ),
                    ),
                  ),

                  // Incident Slider
                  SizedBox(
                    height: 120,
                    child: IncidentSlider(incidents: _incidents),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
