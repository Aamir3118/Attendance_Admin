import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../edits/div_edit.dart';

class EditDivision extends StatefulWidget {
  final String divisions;
  const EditDivision({super.key, required this.divisions});

  @override
  State<EditDivision> createState() => _EditDivisionState();
}

class _EditDivisionState extends State<EditDivision> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          widget.divisions,
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
          stream:
              FirebaseFirestore.instance.collection('divisions').snapshots(),
          builder: (context, AsyncSnapshot<QuerySnapshot> streamSnapshot) {
            if (streamSnapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
            if (streamSnapshot.data!.docs.length < 1) {
              return const Center(
                child: Text('No data'),
              );
            }
            final divList = streamSnapshot.data!.docs;
            return ListView.builder(
                itemCount: divList.length,
                itemBuilder: (ctx, index) {
                  return Dismissible(
                    direction: DismissDirection.endToStart,
                    key: Key(divList[index].id),
                    background: Container(
                      alignment: AlignmentDirectional.centerEnd,
                      color: Colors.red,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ListTile(
                        trailing: IconButton(
                          icon: Icon(
                            Icons.edit,
                          ),
                          color: const Color.fromRGBO(21, 101, 192, 1),
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                  builder: (context) => DivEdit(
                                        divName: divList[index]['div_name'],
                                        divId: divList[index].id,
                                      )),
                            );
                          },
                        ),
                        title: Text(
                          divList[index]['div_name'],
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
                                  "Do you want to delete ${divList[index]['div_name']}?"),
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
                      if (direction == DismissDirection.endToStart) {
                        // Delete the entire document using the document ID
                        _deleteDiv(
                          divList[index]['div_name'],
                          divList[index].id,
                        );
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Division deleted successfully.'),
                          ),
                        );
                        //updating facultyList after deletion
                        setState(() {
                          divList.removeAt(index);
                        });
                      }
                    },
                  );
                });
          },
        ),
      ),
    );
  }

  Future<void> _deleteDiv(String divName, String divId) async {
    try {
      // Delete the user account from Firebase Authentication
      // await FirebaseAuth.instance.currentUser?.delete();

      // Delete the Firestore document
      await FirebaseFirestore.instance
          .collection('divisions')
          .doc(divId)
          .delete();

      final CollectionReference studentsCollection =
          FirebaseFirestore.instance.collection("students");

      // Query for students where course_name is equal to the old course name
      QuerySnapshot studentsQuery =
          await studentsCollection.where("div_name", isEqualTo: divName).get();

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

      print('$divName deleted successfully.');
    } catch (e) {
      print('Error deleting user and document: $e');
    }
  }
}
