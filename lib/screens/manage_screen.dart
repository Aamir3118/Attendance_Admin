import 'package:attendance_admin/manage/add_division_screen.dart';
import 'package:attendance_admin/manage/add_faculty_screen.dart';
import 'package:attendance_admin/manage/add_students_screen.dart';
import 'package:attendance_admin/manage/add_subjects_screen.dart';
import 'package:flutter/material.dart';

import '../manage/add_courses_screen.dart';

class ManageScreen extends StatefulWidget {
  const ManageScreen({super.key});

  @override
  State<ManageScreen> createState() => _ManageScreenState();
}

class _ManageScreenState extends State<ManageScreen> {
  List<String> manageList = [
    'Add Faculty',
    'Add Students',
    'Add Course',
    'Add Subjects',
    'Add Division'
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.builder(
          itemCount: manageList.length,
          itemBuilder: (context, index) {
            return ListTile(
              leading: Icon(
                Icons.add_circle_outline,
                color: Theme.of(context).primaryColor,
              ),
              title: Text(
                manageList[index],
              ),
              onTap: () {
                _onListItemTapped(index);
                //Navigator.of(context).push(MaterialPageRoute(builder: ((context) => ));
              },
            );
          }),
    );
  }

  void _onListItemTapped(int index) {
    switch (index) {
      case 0:
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => AddFacultyScreen()));
        break;
      case 1:
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => AddStudentsScreen()));
        break;
      case 2:
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => AddCoursesScreen()));
        break;
      case 3:
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => AddSubjectsScreen()));
        break;
      case 4:
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => AddDivisionScreen()));
        break;
    }
  }
}
