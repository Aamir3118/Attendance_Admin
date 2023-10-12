import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import '../widgets/widgets.dart';

class AddDivisionScreen extends StatefulWidget {
  const AddDivisionScreen({super.key});

  @override
  State<AddDivisionScreen> createState() => _AddDivisionScreenState();
}

class _AddDivisionScreenState extends State<AddDivisionScreen> {
  final _divController = TextEditingController();
  var isLoading = false;
  final formKey = GlobalKey<FormState>();
  @override
  void dispose() {
    _divController.dispose();
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
          title: const Text("Add Division"),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: formKey,
            child: Column(
              children: [
                textFormField(
                    _divController, 'Enter Division', false, TextInputType.name,
                    (value) {
                  if (value!.isEmpty) {
                    return "Please enter division";
                  }
                  return null;
                }, context, Icons.category),
                SizedBox(height: 16),
                CustomWidgets.loginButton(
                    context, _saveDivision, isLoading, "Save Data"),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _saveDivision() async {
    try {
      FocusManager.instance.primaryFocus?.unfocus();
      if (formKey.currentState!.validate()) {
        setState(() {
          isLoading = true;
        });
        String? adminUid = AuthService().getCurrentUserUID();
        String divName = _divController.text
            .trim()
            .toUpperCase(); // Get the entered course name
        // Normalize the entered course name to lowercase
        // String courseNameLower = courseName.toLowerCase();
        // String courseNameUpper = courseName.toUpperCase();
        // Check if a course with the same normalized name exists
        QuerySnapshot querySnapshot = await FirebaseFirestore.instance
            .collection('divisions')
            .where('div_name', isEqualTo: divName)
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
              title: Text("Division Already Added"),
              content: Text("The division '$divName' is already added."),
            ),
          );
        } else {
          String divDocumentId =
              FirebaseFirestore.instance.collection('divisons').doc().id;
          DocumentReference newDivDocRef = FirebaseFirestore.instance
              .collection('divisions')
              .doc(divDocumentId);

          // Store the course data in the courses collection
          await newDivDocRef.set({
            'div_name': divName,
            'senderid': adminUid,
            'divisionId': divDocumentId,
          });

          setState(() {
            isLoading = false;
          });

          // Show a success message to the user
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text("Success"),
              content: Text("Division '$divName' added successfully."),
            ),
          );
        }
      }
    } catch (e) {
      print(e.toString());
    }
  }
}
