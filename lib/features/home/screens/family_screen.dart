import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class FamilyScreen extends StatefulWidget {
  const FamilyScreen({super.key});

  @override
  State<FamilyScreen> createState() => _FamilyScreenState();
}

class _FamilyScreenState extends State<FamilyScreen> {
  final List<Map<String, dynamic>> familyMembers = [
    {
      "name": "Sarah Johnson",
      "relation": "Spouse",
      "phone": "+1 (555) 123-4567",
      "status": "Safe",
      "location": "Millennium Park, Chicago",
      "time": "5 min ago",
      "emergency": true,
    },
    {
      "name": "Mike Johnson",
      "relation": "Son",
      "phone": "+1 (555) 987-6543",
      "status": "Safe",
      "location": "University of Chicago",
      "time": "1 hr ago",
      "emergency": false,
    },
    {
      "name": "Emma Johnson",
      "relation": "Daughter",
      "phone": "+1 (555) 456-7890",
      "status": "Caution",
      "location": "Lincoln Park High School",
      "time": "2 hr ago",
      "emergency": false,
    },
  ];

  final TextEditingController nameController = TextEditingController();
  final TextEditingController relationController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  String status = "Safe";
  bool emergency = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text(
            "Family Tracking",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          backgroundColor: AppColors.primary,
          elevation: 4, // subtle shadow for depth
          centerTitle: true,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(
              bottom: Radius.circular(20), // soft curved bottom
            ),
          ),
          flexibleSpace: ClipRRect(
            borderRadius: const BorderRadius.vertical(
              bottom: Radius.circular(20),
            ),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10), // subtle glass effect
              child: Container(
                color: AppColors.primary.withOpacity(0.8), // slightly translucent
              ),
            ),
          ),

        ),

      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    _statCard("Safe", familyMembers.where((m) => m["status"] == "Safe").length.toString(), Colors.green, Icons.shield_outlined),
                    _statCard("Caution", familyMembers.where((m) => m["status"] != "Safe").length.toString(), Colors.orange, Icons.warning_amber_outlined),
                    _statCard("Total Members", familyMembers.length.toString(), AppColors.primary, Icons.group_outlined),
                    _statCard("Emergency Contacts", familyMembers.where((m) => m["emergency"] == true).length.toString(), Colors.pink, Icons.phone_in_talk_outlined),
                  ],
                ),
                const SizedBox(height: 24),
                Text("Family Members", style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 12),
                Column(
                  children: familyMembers.map((m) => _familyCard(m)).toList(),
                ),
                const SizedBox(height: 80), // Extra space so last card isn't covered by FAB
              ],
            ),
          ),

          // FAB positioned above content
          Positioned(
            bottom: 16,
            right: 16,
            child: FloatingActionButton.extended(
              onPressed: () => _showAddMemberSheet(context),
              backgroundColor: AppColors.primary,
              icon: const Icon(Icons.person_add_alt_1, color: Colors.white),
              label: const Text("Add Member", style: TextStyle(color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _statCard(String label, String count, Color color, IconData icon) {
    return Container(
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.2),
            blurRadius: 6,
            offset: const Offset(2, 2),
          )
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 6),
          Text(
            count,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 13, color: Colors.black87),
          ),
        ],
      ),
    );
  }

  Widget _familyCard(Map<String, dynamic> member) {
    final isSafe = member["status"] == "Safe";
    final statusColor = isSafe ? Colors.green : Colors.orange;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: const Offset(2, 2),
          )
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: AppColors.primary.withOpacity(0.8),
              child: Text(
                member["name"].toString()[0],
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        member["name"],
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      if (member["emergency"] == true)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.pink.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            "Emergency",
                            style: TextStyle(color: Colors.pink, fontSize: 12),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(member["relation"], style: const TextStyle(color: Colors.black54)),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(Icons.phone, size: 16, color: Colors.grey.shade600),
                      const SizedBox(width: 6),
                      Text(member["phone"]),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(member["status"], style: TextStyle(color: statusColor, fontWeight: FontWeight.w600)),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          member["location"],
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(color: Colors.black87),
                        ),
                      ),
                    ],
                  ),
                  Text(member["time"], style: const TextStyle(color: Colors.black54, fontSize: 12)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddMemberSheet(BuildContext context) {
    nameController.clear();
    relationController.clear();
    phoneController.clear();
    locationController.clear();
    status = "Safe";
    emergency = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(left: 16, right: 16, top: 24, bottom: MediaQuery.of(context).viewInsets.bottom + 16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Add Family Member", style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 16),
              TextField(controller: nameController, decoration: const InputDecoration(labelText: "Name")),
              const SizedBox(height: 12),
              TextField(controller: relationController, decoration: const InputDecoration(labelText: "Relation")),
              const SizedBox(height: 12),
              TextField(controller: phoneController, decoration: const InputDecoration(labelText: "Phone")),
              const SizedBox(height: 12),
              TextField(controller: locationController, decoration: const InputDecoration(labelText: "Location")),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: status,
                items: ["Safe", "Caution"].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                onChanged: (val) => setState(() => status = val!),
                decoration: const InputDecoration(labelText: "Status"),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Text("Emergency"),
                  Switch(value: emergency, onChanged: (val) => setState(() => emergency = val)),
                ],
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      familyMembers.add({
                        "name": nameController.text,
                        "relation": relationController.text,
                        "phone": phoneController.text,
                        "status": status,
                        "location": locationController.text,
                        "time": "Just now",
                        "emergency": emergency,
                      });
                    });
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text("Add Member"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
