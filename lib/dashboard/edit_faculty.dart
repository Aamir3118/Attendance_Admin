import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_admin/firebase_admin.dart' as admin;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class EditFaculty extends StatefulWidget {
  final String facultyTitle;
  const EditFaculty({super.key, required this.facultyTitle});

  @override
  State<EditFaculty> createState() => _EditFacultyState();
}

class _EditFacultyState extends State<EditFaculty> {
  FirebaseAuth auth = FirebaseAuth.instance;

  // App? adminApp;
  // @override
  // void initState() {
  //   super.initState();
  //   // Initialize Firebase Admin SDK in the initState method
  //   adminApp = FirebaseAdmin.instance.initializeApp(
  //     AppOptions(
  //       credential: FirebaseAdmin.instance.certFromPath('/service_app.json'),
  //       projectId: 'attendance-app-14fb8',
  //     ),
  //     'adminapp',
  //   );
  // }

  Future<void> _deleteFacultyUser(String userId, String email) async {
    try {
      // Delete the user account from Firebase Authentication
      //await FirebaseAuth.instance.currentUser?.delete();

      // Delete the Firestore document
      await FirebaseFirestore.instance
          .collection('faculties')
          .doc(userId)
          .delete();
      final response = await http.delete(
        Uri.parse('https://attendence-firebase.vercel.app/api/$userId'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );
      print(
          'User account with email $email and ID $userId deleted successfully.');
    } catch (e) {
      print('Error deleting user and document: $e');
    }
  }

  List<QueryDocumentSnapshot> facultyList = []; // Store the faculty data

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          widget.facultyTitle,
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
              FirebaseFirestore.instance.collection('faculties').snapshots(),
          builder: (context, AsyncSnapshot<QuerySnapshot> streamSnapshot) {
            if (streamSnapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
            facultyList = streamSnapshot.data!.docs;
            if (facultyList.isEmpty) {
              return const Center(
                child: Text('No data'),
              );
            }
            //final facultyList = streamSnapshot.data!.docs;
            return ListView.builder(
                itemCount: facultyList.length,
                itemBuilder: (ctx, index) {
                  return Dismissible(
                    direction: DismissDirection.endToStart,
                    key: Key(facultyList[index].id),
                    background: Container(
                      alignment: AlignmentDirectional.centerEnd,
                      color: Colors.red,
                      child: Icon(
                        Icons.delete,
                        color: Colors.white,
                      ),
                    ),
                    child: ListTile(
                      title: Text(
                        facultyList[index]['username'],
                      ),
                      subtitle: Text(facultyList[index]['email']),
                    ),
                    confirmDismiss: (direction) async {
                      return await showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              title: Text("Delete?"),
                              content: Text(
                                  "Do you want to delete ${facultyList[index]['username']}?"),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(ctx).pop(false);
                                  },
                                  child: Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () {
                                    final email = facultyList[index]['email'];

                                    Navigator.of(ctx).pop(true);
                                  },
                                  child: Text('Ok'),
                                ),
                              ],
                            );
                          });
                    },
                    onDismissed: (direction) async {
                      if (direction == DismissDirection.endToStart) {
                        // Delete the entire document using the document ID
                        try {
                          // Delete the user account when the faculty entry is dismissed
                          await _deleteFacultyUser(facultyList[index].id,
                              facultyList[index]['email']);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Faculty deleted successfully.'),
                            ),
                          ); // Now, update the faculty list after the deletion is complete
                          setState(() {
                            facultyList.removeAt(index);
                          });
                        } catch (e) {
                          print(e);
                        }
                      }
                    },
                  );
                });
          },
        ),
      ),
    );
  }
}
