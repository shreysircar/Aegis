import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class GuideScreen extends StatefulWidget {
  const GuideScreen({super.key});

  @override
  State<GuideScreen> createState() => _GuideScreenState();
}

class _GuideScreenState extends State<GuideScreen> {
  final TextEditingController _searchController = TextEditingController();

  // 🔹 Static example route (Downtown → Lincoln Park)
  final LatLng start = LatLng(41.8781, -87.6298); // Downtown Chicago
  final LatLng end = LatLng(41.9214, -87.6513);   // Lincoln Park
  final List<LatLng> route = [
    LatLng(41.8781, -87.6298),
    LatLng(41.8900, -87.6350),
    LatLng(41.9050, -87.6400),
    LatLng(41.9214, -87.6513),
  ];

  // 🔹 Static route description
  final List<Map<String, String>> routeSteps = [
    {"step": "Start at Downtown", "risk": "Medium Risk"},
    {"step": "Pass through River North", "risk": "Low Risk"},
    {"step": "Move via Old Town", "risk": "Low Risk"},
    {"step": "Reach Lincoln Park", "risk": "Safe"},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Map
          FlutterMap(
            options: MapOptions(
              initialCenter: start,
              initialZoom: 13.0,
            ),
            children: [
              TileLayer(
                urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
                userAgentPackageName: "com.example.aegis",
              ),

              // 🔹 Draw route polyline
              PolylineLayer(
                polylines: [
                  Polyline(
                    points: route,
                    color: Colors.green,
                    strokeWidth: 5,
                  ),
                ],
              ),

              // 🔹 Markers for start and end
              MarkerLayer(
                markers: [
                  Marker(
                    point: start,
                    width: 40,
                    height: 40,
                    child: const Icon(Icons.location_on, color: Colors.red, size: 32),
                  ),
                  Marker(
                    point: end,
                    width: 40,
                    height: 40,
                    child: const Icon(Icons.flag, color: Colors.green, size: 32),
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
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: "Enter destination in Chicago",
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.search, color: Colors.black54),
                    onPressed: () {
                      // For now, static destination only
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Static demo: Route to Lincoln Park")),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),

          // 🔹 Bottom Route Info
          Positioned(
            bottom: 80, // above navbar
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 6,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text("Safest Route to Lincoln Park",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 150,
                    child: ListView.builder(
                      itemCount: routeSteps.length,
                      itemBuilder: (context, index) {
                        final step = routeSteps[index];
                        return ListTile(
                          leading: const Icon(Icons.directions, color: Colors.green),
                          title: Text(step["step"]!),
                          subtitle: Text(step["risk"]!),
                        );
                      },
                    ),
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
