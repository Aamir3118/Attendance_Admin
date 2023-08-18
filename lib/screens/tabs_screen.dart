import 'package:attendance_admin/manage/add_faculty_screen.dart';
import 'package:attendance_admin/screens/admin_dashboard_screen.dart';
import 'package:attendance_admin/screens/manage_screen.dart';
import 'package:attendance_admin/screens/signin_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class TabsScreen extends StatefulWidget {
  const TabsScreen({super.key});

  @override
  State<TabsScreen> createState() => _TabsScreenState();
}

class _TabsScreenState extends State<TabsScreen> {
  FirebaseAuth user = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          centerTitle: true,
          title: const Text(
            'Admin Home',
            style: TextStyle(color: Colors.white),
          ),
          actions: <Widget>[
            IconButton(
              onPressed: () async {
                try {
                  await user.signOut();
                  // Navigator.of(context).push(
                  //   MaterialPageRoute(builder: (context) => SignInScreen()),
                  // );
                } catch (e) {
                  e.toString();
                }
              },
              icon: const Icon(Icons.exit_to_app, color: Colors.white),
            ),
          ],
          bottom: TabBar(
            tabs: <Widget>[
              Tab(
                text: 'Dashboard',
              ),
              Tab(
                text: 'Manage',
              ),
            ],
            labelColor: Colors.white,
            indicatorColor: Colors.white,
            unselectedLabelColor: Colors.blueGrey[50],
          ),
        ),
        body: const TabBarView(
          children: <Widget>[
            AdminDashboardScreen(),
            ManageScreen(),
          ],
        ),
      ),
    );
  }
}
