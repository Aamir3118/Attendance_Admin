import 'package:attendance_admin/edits/course_edit.dart';
import 'package:attendance_admin/loadData.dart';
import 'package:attendance_admin/subjects_list.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:attendance_admin/loadData.dart';
import 'package:flutter/material.dart';

class EditCourse extends StatefulWidget {
  final String courses;
  const EditCourse({super.key, required this.courses});

  @override
  State<EditCourse> createState() => _EditCourseState();
}

class _EditCourseState extends State<EditCourse> {
  List<QueryDocumentSnapshot> coursesList = [];
  List<String> subjectNames = [];

  Future<String?> _fetchCourseId(String courseName) async {
    try {
      QuerySnapshot courseSnapshot = await FirebaseFirestore.instance
          .collection('courses')
          .where('course_name', isEqualTo: courseName)
          .get();

      if (courseSnapshot.docs.isNotEmpty) {
        return courseSnapshot.docs.first.id;
      }
    } catch (e) {
      print("Error fetching courseId: $e");
    }
    return null;
  }

  Future<void> _deleteCourse(String courseId, String courseName) async {
    try {
      // Delete the user account from Firebase Authentication
      // await FirebaseAuth.instance.currentUser?.delete();

      // Delete the Firestore document
      QuerySnapshot subjectsSnapshot = await FirebaseFirestore.instance
          .collection('courses')
          .doc(courseId)
          .collection('subjects')
          .get();
      for (QueryDocumentSnapshot subjectDoc in subjectsSnapshot.docs) {
        await subjectDoc.reference.delete();
      }
      // await FirebaseFirestore.instance
      //     .collection('courses')
      //     .doc(courseId)
      //     .collection('subjects')
      //     .doc(courseName)
      //     .delete();
      await FirebaseFirestore.instance
          .collection('courses')
          .doc(courseId)
          .delete();

      final CollectionReference studentsCollection =
          FirebaseFirestore.instance.collection("students");

      // Query for students where course_name is equal to the old course name
      QuerySnapshot studentsQuery = await studentsCollection
          .where("course_name", isEqualTo: courseName)
          .get();

      // Iterate through the students and update their course_name
      for (QueryDocumentSnapshot studentDoc in studentsQuery.docs) {
        // delete the course_name field in each student document
        //await studentDoc.reference.collection("enrollments").doc()
        // Delete the enrollments subcollection for the student document
        await studentDoc.reference
            .collection("enrollments")
            .get()
            .then((enrollmentsQuery) {
          for (QueryDocumentSnapshot enrollmentDoc in enrollmentsQuery.docs) {
            enrollmentDoc.reference.delete();
          }
        });
        await studentDoc.reference.delete();
      }

      // DocumentReference courseRef =
      //     FirebaseFirestore.instance.collection('courses').doc(courseName);
      // DocumentSnapshot courseSnapshot = await courseRef.get();
      // if (!courseSnapshot.exists) {
      //   return;
      // }
      //String courseId=courseSnapshot.id;
      // QuerySnapshot studentSnapshot = await FirebaseFirestore.instance
      //     .collection('students')
      //     .where(FieldPath.documentId, isEqualTo: courseName)
      //     .get();
      // //Delete the student documents
      // for (QueryDocumentSnapshot studentDoc in studentSnapshot.docs) {
      //   await studentDoc.reference.delete();
      // }
      // await courseRef.collection('divisions').get().then((querySnapshot) {
      //   querySnapshot.docs.forEach((divisionDoc) async {
      //     await divisionDoc.reference
      //         .collection('enrollments')
      //         .get()
      //         .then((enrollmentsQuerySnapshot) {
      //       enrollmentsQuerySnapshot.docs.forEach((enrollmentDoc) async {
      //         await enrollmentDoc.reference.delete();
      //       });
      //     });
      //     await divisionDoc.reference.delete();
      //   });
      // });
      // await FirebaseFirestore.instance
      //     .collection('subjects')
      //     .doc(courseId)
      //     .collection(courseName)
      //     .get()
      //     .then((querySnapshot) {
      //   querySnapshot.docs.forEach((doc) {
      //     doc.reference.delete();
      //   });
      // });

      print('$courseName deleted successfully.');
    } catch (e) {
      print('Error deleting user and document: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          widget.courses,
          style: const TextStyle(
            color: Colors.white,
          ),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.only(
          top: 10,
        ),
        child: StreamBuilder(
          stream: FirebaseFirestore.instance.collection('courses').snapshots(),
          builder: (context, AsyncSnapshot<QuerySnapshot> streamSnapshot) {
            if (streamSnapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
            coursesList = streamSnapshot.data!.docs;

            if (coursesList.isEmpty) {
              return const Center(
                child: Text('No data'),
              );
            }

            return ListView.builder(
                itemCount: coursesList.length,
                itemBuilder: (ctx, index) {
                  //int courseId =_fetchCourseId(coursesList[index]['course_name']) as int;
                  final courseName = coursesList[index]['course_name'];

                  return FutureBuilder<String?>(
                      future: fetchCourseId(courseName),
                      builder: (context, courseIdSnapshot) {
                        if (courseIdSnapshot.connectionState ==
                            ConnectionState.waiting) {
                          return ListTile(
                            title: Text(courseName),
                            subtitle: Text(""),
                          );
                        }
                        if (courseIdSnapshot.hasError ||
                            courseIdSnapshot.data == null) {
                          return ListTile(
                            title: Text(courseName),
                            subtitle: Text(''),
                          );
                        }

                        final courseId = courseIdSnapshot.data!;
                        return FutureBuilder<QuerySnapshot>(
                            future: FirebaseFirestore.instance
                                .collection('courses')
                                .doc(courseId)
                                .collection('subjects')
                                .get(),
                            builder: (context, subjectSnapshot) {
                              if (subjectSnapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return ListTile(
                                  title: Text(courseName),
                                  subtitle: Text(''),
                                );
                              }
                              final subjectCount =
                                  subjectSnapshot.data!.docs.length;
                              return Dismissible(
                                direction: DismissDirection.endToStart,
                                key: Key(coursesList[index].id),
                                background: Container(
                                  alignment: AlignmentDirectional.centerEnd,
                                  color: Colors.red,
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: ListTile(
                                    onTap: () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (context) => SubjectsList(
                                            courseName: courseName,
                                            subjectCount: subjectCount,
                                            courseId: courseId,
                                          ),
                                        ),
                                      );
                                    },
                                    title: Text(courseName),
                                    subtitle: Text('Subjects: $subjectCount'),
                                    trailing: IconButton(
                                      icon: Icon(
                                        Icons.edit,
                                      ),
                                      color:
                                          const Color.fromRGBO(21, 101, 192, 1),
                                      onPressed: () {
                                        Navigator.of(context).push(
                                          MaterialPageRoute(
                                              builder: (context) => CourseEdit(
                                                  courseName: courseName,
                                                  courseId: courseId)),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                                confirmDismiss: (direction) async {
                                  return await showDialog(
                                      context: context,
                                      builder: (context) {
                                        return AlertDialog(
                                          title: Text("Delete?"),
                                          content: Text(
                                              "Do you want to delete ${coursesList[index]['course_name']}?"),
                                          actions: [
                                            TextButton(
                                              onPressed: () {
                                                Navigator.of(ctx).pop(false);
                                              },
                                              child: Text('Cancel'),
                                            ),
                                            TextButton(
                                              onPressed: () {
                                                Navigator.of(ctx).pop(true);
                                              },
                                              child: Text('Ok'),
                                            ),
                                          ],
                                        );
                                      });
                                },
                                onDismissed: (direction) {
                                  if (direction ==
                                      DismissDirection.endToStart) {
                                    // Delete the entire document using the document ID
                                    _deleteCourse(coursesList[index].id,
                                        coursesList[index]['course_name']);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                            'Course deleted successfully.'),
                                      ),
                                    );
                                    //updating facultyList after deletion
                                    setState(() {
                                      coursesList.removeAt(index);
                                    });
                                  }
                                },
                              );
                            });
                      });
                  // ListTile(
                  //     title: Text(
                  //       coursesList[index]['course_name'],
                  //     ),
                  //     subtitle: Text(""));
                });
          },
        ),
      ),
    );
  }
}
