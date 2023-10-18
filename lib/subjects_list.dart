import 'package:attendance_admin/edits/subject_edit.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class SubjectsList extends StatefulWidget {
  final String courseName;
  int? subjectCount;
  final String courseId;
  SubjectsList({
    super.key,
    required this.courseName,
    required this.subjectCount,
    required this.courseId,
  });

  @override
  State<SubjectsList> createState() => _SubjectsListState();
}

class _SubjectsListState extends State<SubjectsList> {
  List<QueryDocumentSnapshot> subjectsList = [];

  Future<void> _deleteSubject(String id, String name) async {
    // QuerySnapshot subjectsSnapshot = await FirebaseFirestore.instance
    //       .collection('courses')
    //       .doc(widget.courseId)
    //       .collection('subjects')
    //       .get();
    //   for (QueryDocumentSnapshot subjectDoc in subjectsSnapshot.docs) {
    //     await subjectDoc.reference.delete();
    //   }
    CollectionReference subjectsCollection = FirebaseFirestore.instance
        .collection('courses')
        .doc(widget.courseId)
        .collection('subjects');

    QuerySnapshot subjectsSnapshot =
        await subjectsCollection.where("subject_name", isEqualTo: name).get();

    if (subjectsSnapshot.docs.isNotEmpty) {
      await subjectsSnapshot.docs.first.reference.delete();
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
          if (subjectsName.contains(name)) {
            subjectsName.remove(name);
            await facultiesCollection
                .doc(facultyDoc.id)
                .update({'subjects': subjectsName});
          }
        }
        //dynamic subjectsArray = facultyDoc.data()['subjects'];
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          widget.courseName,
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: widget.subjectCount == 0
          ? const Center(
              child: Text("There are no subjects in this course!!!"),
            )
          : StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection("courses")
                  .doc(widget.courseId)
                  .collection("subjects")
                  .snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                return ListView.builder(
                  itemCount: widget.subjectCount,
                  itemBuilder: (context, index) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                    subjectsList = snapshot.data!.docs;
                    if (subjectsList.isEmpty) {
                      // Handle the case where data is null
                      return const Center(
                        child: Text("No Data found"),
                      );
                    }

                    return Dismissible(
                      direction: DismissDirection.endToStart,
                      key: Key(subjectsList[index].id),
                      background: Container(
                        alignment: AlignmentDirectional.centerEnd,
                        color: Colors.red,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ListTile(
                          title: Text(
                            subjectsList[index]['subject_name'],
                          ),
                          trailing: IconButton(
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                    builder: (context) => SubjectEdit(
                                        subId: subjectsList[index].id,
                                        subName: subjectsList[index]
                                            ['subject_name'],
                                        courseId: widget.courseId)),
                              );
                            },
                            icon: Icon(Icons.edit),
                            color: const Color.fromRGBO(21, 101, 192, 1),
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
                                    "Do you want to delete ${subjectsList[index]['subject_name']}?"),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop(false);
                                    },
                                    child: Text('Cancel'),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop(true);
                                    },
                                    child: Text('Ok'),
                                  ),
                                ],
                              );
                            });
                      },
                      onDismissed: (direction) {
                        if (direction == DismissDirection.endToStart) {
                          // Delete the entire document using the document ID
                          _deleteSubject(subjectsList[index].id,
                              subjectsList[index]['subject_name']);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Subject deleted successfully.'),
                            ),
                          );
                          //updating facultyList after deletion
                          setState(() {
                            subjectsList.removeAt(index);
                            widget.subjectCount = (widget.subjectCount! - 1);
                          });
                        }
                      },
                    );
                  },
                );
              },
            ),
    );
  }
}
