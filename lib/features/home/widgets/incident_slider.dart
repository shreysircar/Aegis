import 'package:flutter/material.dart';
import '../models/incident_model.dart';
import 'incident_card.dart';

class IncidentSlider extends StatelessWidget {
  final List<Incident> incidents;

  const IncidentSlider({super.key, required this.incidents});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 120,
      child: PageView.builder(
        controller: PageController(viewportFraction: 0.85),
        itemCount: incidents.length,
        itemBuilder: (context, index) {
          return IncidentCard(incident: incidents[index]);
        },
      ),
    );
  }
}
