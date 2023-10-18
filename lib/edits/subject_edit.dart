import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../widgets/widgets.dart';

class SubjectEdit extends StatefulWidget {
  final String subName;
  final String subId;
  final String courseId;
  const SubjectEdit(
      {super.key,
      required this.subId,
      required this.subName,
      required this.courseId});

  @override
  State<SubjectEdit> createState() => _SubjectEditState();
}

class _SubjectEditState extends State<SubjectEdit> {
  bool isLoading = false;
  final TextEditingController subController = TextEditingController();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    subController.text = widget.subName;
  }

  final _formKey = GlobalKey<FormState>();

  Future<void> _updateSubject() async {
    FocusManager.instance.primaryFocus?.unfocus();
    if (_formKey.currentState!.validate()) {
      setState(() {
        isLoading = true;
      });
      try {
        String newSub = subController.text;

        CollectionReference subjectsCollection = FirebaseFirestore.instance
            .collection('courses')
            .doc(widget.courseId)
            .collection('subjects');

        QuerySnapshot subjectsSnapshot = await subjectsCollection
            .where("subject_name", isEqualTo: widget.subName)
            .get();

        if (subjectsSnapshot.docs.isNotEmpty) {
          await subjectsSnapshot.docs.first.reference
              .update({"subject_name": newSub});
        }
        // for (QueryDocumentSnapshot subjectDoc in subjectsSnapshot.docs) {
        //   // Delete each subject document within the subjects subcollection
        //   await subjectDoc.reference.delete();
        // }
        CollectionReference facultiesCollection =
            FirebaseFirestore.instance.collection("faculties");
        QuerySnapshot facultiesQuery = await facultiesCollection.get();
        for (QueryDocumentSnapshot facultyDoc in facultiesQuery.docs) {
          if (facultyDoc.exists) {
            Map<String, dynamic>? facultyData =
                facultyDoc.data() as Map<String, dynamic>?;
            if (facultyData != null) {
              List<dynamic> subjectsArray = facultyData['subjects'];
              List<String> subjectsName = List<String>.from(subjectsArray);
              if (subjectsName.contains(widget.subName)) {
                //replacing the old with new one
                int index = subjectsName.indexOf(widget.subName);
                subjectsName[index] = newSub;
                await facultiesCollection
                    .doc(facultyDoc.id)
                    .update({'subjects': subjectsName});
              }
            }
            //dynamic subjectsArray = facultyDoc.data()['subjects'];
          }
        }
        setState(() {
          isLoading = false;
        });
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text("Success"),
            content: Text("Subject edited successfully."),
          ),
        );
      } catch (e) {
        print(e);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Edit Subject",
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: <Widget>[
            // textFormField(courseController, "", false, TextInputType.name,
            //     (value) {
            //   if (value!.isEmpty) {
            //     return 'Please enter course';
            //   }
            //   return null;
            // }, context, Icons.book),
            Form(
              key: _formKey,
              child: TextFormField(
                controller: subController,

                //initialValue: widget.courseName,
                // onChanged: (value) {
                //   value = courseController.text;
                // },
                decoration: decoration(
                  "",
                  context,
                  false,
                  subController,
                  Icons.subject,
                ),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter subject';
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            // CustomWidgets.loginButton(
            //     context, _updatecourse, isLoading, "Update Course"),
            InkWell(
              onTap: _updateSubject,
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.blue,
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Center(
                    child: isLoading
                        ? const CircularProgressIndicator(
                            color: Colors.white,
                          )
                        : const Text(
                            "Update Subject",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                            ),
                          ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
