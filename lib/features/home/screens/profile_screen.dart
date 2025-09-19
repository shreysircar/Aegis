import 'package:flutter/material.dart';
import '../../../../core/widgets/stats_card.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Your Stats")),
      body: GridView.count(
        crossAxisCount: 2,
        padding: const EdgeInsets.all(12),
        children: const [
          StatsCard(title: "Safe zone exits", value: "2 times", color: Colors.redAccent),
          StatsCard(title: "Most visited", value: "Tennis Ground", color: Colors.purple),
          StatsCard(title: "Health alerts", value: "1", color: Colors.orange),
          StatsCard(title: "Emergency contact", value: "Neela", color: Colors.teal),
          StatsCard(title: "Favourites", value: "5 places", color: Colors.pink),
          StatsCard(title: "Timeline", value: "Jan", color: Colors.blue),
        ],
      ),
    );
  }
}
