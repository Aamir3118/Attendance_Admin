import 'package:attendance_admin/widgets/widgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../widgets/widgets.dart';

class AddCoursesScreen extends StatefulWidget {
  const AddCoursesScreen({super.key});

  @override
  State<AddCoursesScreen> createState() => _AddCoursesScreenState();
}

class _AddCoursesScreenState extends State<AddCoursesScreen> {
  final _courseController = TextEditingController();
  var isLoading = false;
  final formKey = GlobalKey<FormState>();
  @override
  void dispose() {
    _courseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Add Course"),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: formKey,
            child: Column(
              children: [
                textFormField(_courseController, 'Enter Course Name', false,
                    TextInputType.name, (value) {
                  if (value!.isEmpty) {
                    return "Please enter course name";
                  }
                  return null;
                }, context, Icons.school),
                SizedBox(height: 16),
                CustomWidgets.loginButton(
                    context, _saveCourse, isLoading, "Save Data"),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _saveCourse() async {
    try {
      FocusManager.instance.primaryFocus?.unfocus();
      if (formKey.currentState!.validate()) {
        setState(() {
          isLoading = true;
        });
        String? adminUid = AuthService().getCurrentUserUID();
        String courseName =
            _courseController.text.trim(); // Get the entered course name
        // Normalize the entered course name to lowercase
        // String courseNameLower = courseName.toLowerCase();
        // String courseNameUpper = courseName.toUpperCase();
        // Check if a course with the same normalized name exists
        QuerySnapshot querySnapshot = await FirebaseFirestore.instance
            .collection('courses')
            .where('course_name', isEqualTo: courseName)
            .get();

        // Store the course data in the courses collection
        //FirebaseAuth auth = FirebaseAuth.instance;
        if (querySnapshot.docs.isNotEmpty) {
          // A course with the same name exists, show an alert
          setState(() {
            isLoading = false;
          });

          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text("Course Already Added"),
              content: Text("The course '$courseName' is already added."),
            ),
          );
        } else {
          String courseDocumentId =
              FirebaseFirestore.instance.collection('courses').doc().id;
          DocumentReference newCourseDocRef = FirebaseFirestore.instance
              .collection('courses')
              .doc(courseDocumentId);

          // Store the course data in the courses collection
          await newCourseDocRef.set({
            'course_name': courseName,
            'senderid': adminUid,
            'courseId': courseDocumentId,
          });

          setState(() {
            isLoading = false;
          });

          // Show a success message to the user
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text("Success"),
              content: Text("Course '$courseName' added successfully."),
            ),
          );
        }
      }
    } catch (e) {
      print(e.toString());
    }
  }
}
