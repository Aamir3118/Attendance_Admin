import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../widgets/widgets.dart';

class CourseEdit extends StatefulWidget {
  const CourseEdit(
      {super.key, required this.courseName, required this.courseId});
  final String courseName;
  final String courseId;

  @override
  State<CourseEdit> createState() => _CourseEditState();
}

class _CourseEditState extends State<CourseEdit> {
  bool isLoading = false;
  final TextEditingController courseController = TextEditingController();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    courseController.text = widget.courseName;
  }

  final _formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Edit Course",
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
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
                controller: courseController,

                //initialValue: widget.courseName,
                // onChanged: (value) {
                //   value = courseController.text;
                // },
                decoration: decoration(
                  "",
                  context,
                  false,
                  courseController,
                  Icons.book,
                ),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter course';
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
              onTap: _updatecourse,
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
                        : Text(
                            "Update Course",
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

  Future<void> _updatecourse() async {
    FocusManager.instance.primaryFocus?.unfocus();
    if (_formKey.currentState!.validate()) {
      setState(() {
        isLoading = true;
      });
      try {
        final String newCourse = courseController.text;
        print(newCourse);
        print("Updating course: ${newCourse}");
        print("courseId: ${widget.courseId}");
        final FirebaseFirestore firestore = FirebaseFirestore.instance;
        final CollectionReference _course =
            FirebaseFirestore.instance.collection("courses");
        final DocumentReference courseDocRef = _course.doc(widget.courseId);
        final CollectionReference studentsCollection =
            firestore.collection("students");

        //update course_name in courses collection
        await courseDocRef.update({
          "course_name": courseController.text,
        });
        QuerySnapshot studQuery = await studentsCollection
            .where("course_name", isEqualTo: widget.courseName)
            .get();
        for (QueryDocumentSnapshot studentDoc in studQuery.docs) {
          await studentDoc.reference.update({"course_name": newCourse});
        }
        // DocumentSnapshot oldStudentDocSnapshot = await firestore
        //     .collection("students")
        //     .where("course_name", isEqualTo: widget.courseName)
        //     .get() as DocumentSnapshot<Object?>;
        //         final DocumentReference courseDocRef2 = oldStudentDocSnapshot.doc(widget.courseId);

        // oldStudentDocSnapshot.update();
        // final DocumentReference newStudentDocRef =
        //     firestore.collection("students").doc(courseController.text);
        // DocumentSnapshot oldStudentDocSnapshot = (await firestore
        //     .collection("students")
        //     .doc(widget.courseName)
        //     .collection("divisions")
        //     .doc("A")
        //     .collection("start_year")
        //     .doc("2023")
        //     .collection("enrollments")
        //     .get()) as DocumentSnapshot<Object?>;
        // if (oldStudentDocSnapshot.exists) {
        //   await newStudentDocRef.set(oldStudentDocSnapshot.data());
        // } else {
        //   print("Not exists");
        // }
        // await firestore.collection("students").doc(widget.courseName).delete();
        // // QuerySnapshot studentSnapshot = await FirebaseFirestore.instance
        // //     .collection('students')

        // //     .where(FieldPath.documentId, isEqualTo: widget.courseName)
        // //     .get();
        // // //Update the student documents
        // // for (QueryDocumentSnapshot studentDoc in studentSnapshot.docs) {
        // //   await studentDoc.reference.update(newCourse as Map<Object, Object?>);
        // // }

        // final CollectionReference subjectsCollection =
        //     firestore.collection('subjects');

        // // Retrieve all documents in the "subjects" collection
        // QuerySnapshot subjectsQuery = await subjectsCollection.get();

        // for (QueryDocumentSnapshot docSnapshot in subjectsQuery.docs) {
        //   // Print the document ID
        //   print("Document ID: ${docSnapshot.id}");
        // }

        setState(() {
          isLoading = false;
          //widget.courseName = _courseController.text;
        });
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text("Success"),
            content: Text("Course edited added successfully."),
          ),
        );
      } catch (e) {}
    }
  }
}
