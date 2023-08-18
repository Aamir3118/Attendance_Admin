import 'package:flutter/material.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  List<String> dashboardItemList = ["Faculty", "Admin", "Course", "Subject"];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GridView(
        padding: const EdgeInsets.all(25.0),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 4 / 3,
            crossAxisSpacing: 20,
            mainAxisSpacing: 20),
        children: dashboardItemList
            .map((itemData) => Container(
                  padding: EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    gradient: LinearGradient(colors: [
                      Colors.blue.shade50.withOpacity(0.7),
                      Colors.blue.shade50
                    ], begin: Alignment.topCenter, end: Alignment.bottomCenter),
                  ),
                  child: Text(
                    itemData,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                  ),
                ))
            .toList(),
      ),
    );
  }
}
