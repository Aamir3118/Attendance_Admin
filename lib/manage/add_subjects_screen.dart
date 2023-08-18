import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import '../widgets/widgets.dart';

class AddSubjectsScreen extends StatefulWidget {
  const AddSubjectsScreen({super.key});

  @override
  State<AddSubjectsScreen> createState() => _AddSubjectsScreenState();
}

class _AddSubjectsScreenState extends State<AddSubjectsScreen> {
  String? _selectedCourse;

  final _subjectController = TextEditingController();
  var isLoading = false;
  final formKey = GlobalKey<FormState>();
  List<String> courseNames = [];

  @override
  void initState() {
    super.initState();
    _loadCourseNames();
  }

  Future<void> _loadCourseNames() async {
    try {
      QuerySnapshot courseSnapshot =
          await FirebaseFirestore.instance.collection('courses').get();
      setState(() {
        courseNames = courseSnapshot.docs
            .map((doc) => doc['course_name'] as String)
            .toList();
      });
    } catch (e) {
      print(e.toString());
    }
  }

  @override
  void dispose() {
    _subjectController.dispose();
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
          title: const Text("Add Subject"),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: formKey,
            child: Column(
              children: [
                DropdownButtonFormField<String>(
                  value: null,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  hint: Text("Select Course"),
                  items: courseNames
                      .map(
                        (courseName) => DropdownMenuItem<String>(
                          value: courseName,
                          child: Text(courseName),
                        ),
                      )
                      .toList(),
                  onChanged: (selctedcourse) {
                    setState(() {
                      _selectedCourse = selctedcourse;
                    });
                  },
                ),
                const SizedBox(
                  height: 20,
                ),
                textFormField(_subjectController, 'Enter Subject', false,
                    TextInputType.name, (value) {
                  if (value!.isEmpty) {
                    return "Please enter subject";
                  }
                  return null;
                }, context, Icons.book),
                SizedBox(height: 16),
                CustomWidgets.loginButton(
                    context, _saveSubject, isLoading, "Save Data"),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _saveSubject() async {
    try {
      FocusManager.instance.primaryFocus?.unfocus();
      if (formKey.currentState!.validate()) {
        setState(() {
          isLoading = true;
        });
        String? adminUid = AuthService().getCurrentUserUID();
        String subjectName = _subjectController.text.trim().toUpperCase();
        String? selectedCourse = _selectedCourse;

        if (selectedCourse == null) {
          setState(() {
            isLoading = false;
          });
          return;
        }
        String? selectedCourseId;
        QuerySnapshot courseQuerySnapshot = await FirebaseFirestore.instance
            .collection("courses")
            .where('course_name', isEqualTo: selectedCourse)
            .get();
        //String subCollectionPath = 'courses/$selectedCourse/subjects';
        if (courseQuerySnapshot.docs.isNotEmpty) {
          selectedCourseId = courseQuerySnapshot.docs[0].id;
        } else {
          setState(() {
            isLoading = false;
          });

          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text("Course Not Found"),
              content:
                  Text("The selected course '$selectedCourse' was not found."),
            ),
          );
          return;
        }
        CollectionReference subCollectionRef = FirebaseFirestore.instance
            .collection("subjects")
            .doc(selectedCourseId)
            .collection(selectedCourse);
        QuerySnapshot querySnapshot = await subCollectionRef
            .where('subject_name', isEqualTo: subjectName)
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
              title: Text("Subject Already Added"),
              content: Text("The subject '$subjectName' is already added."),
            ),
          );
        } else {
          String subjectDocumentId = subCollectionRef.doc().id;
          DocumentReference newSubjectDocRef =
              subCollectionRef.doc(subjectDocumentId);

          // Store the course data in the courses collection
          await newSubjectDocRef.set({
            'subject_name': subjectName,
            'senderid': adminUid,
            'subjectId': subjectDocumentId,
          });

          setState(() {
            isLoading = false;
          });

          // Show a success message to the user
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text("Success"),
              content: Text("Subject '$subjectName' added successfully."),
            ),
          );
        }
      }
    } catch (e) {
      print(e.toString());
    }
  }
}
