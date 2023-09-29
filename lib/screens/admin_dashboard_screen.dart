import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  //List<String> dashboardItemList = ["Faculty", "Admin", "Course", "Subject"];
  List<Map<String, dynamic>> dashboardItemList = [
    {"title": "Faculty", "collection": "faculties"},
    {"title": "Admin", "collection": "Admin"},
    {"title": "Course", "collection": "courses"},
    {"title": "Subject", "collection": "subjects"},
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GridView(
        padding: const EdgeInsets.all(12.0),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 4 / 3,
          crossAxisSpacing: 20,
          mainAxisSpacing: 20,
        ),
        children: dashboardItemList
            .where((itemData) => _collectionExists(itemData['collection']))
            .map(
              (itemData) => FutureBuilder<int>(
                future: _getCollectionItemCount(itemData['collection']),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                        child:
                            CircularProgressIndicator()); // Show loading indicator while fetching data
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else {
                    final itemCount = snapshot.data ?? 0;
                    return Container(
                      padding: EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        gradient: LinearGradient(
                          colors: [
                            Colors.blue.shade50.withOpacity(0.7),
                            Colors.blue.shade50
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            itemData['title'],
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          SizedBox(height: 10),
                          Text(
                            itemCount.toString(), // Display the item count
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 30,
                                color: Colors.black54,
                                fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    );
                  }
                },
              ),
            )
            .toList(),
      ),
    );
  }

  bool _collectionExists(String collectionName) {
    // Check if the collection exists in Firestore
    // You can use Firebase's `collection(collectionName).get()` and check for errors
    // If it exists, return true; otherwise, return false

    return true;
  }

  Future<int> _getCollectionItemCount(String collectionName) async {
    try {
      if (collectionName == 'courses') {
        QuerySnapshot snapshot =
            await FirebaseFirestore.instance.collection(collectionName).get();
        return snapshot.docs.length;
      } else if (collectionName == 'subjects') {
        // Assuming you want the total count of subjects across all courses
        QuerySnapshot courseSnapshot =
            await FirebaseFirestore.instance.collection('courses').get();
        int totalCount = 0;

        for (QueryDocumentSnapshot courseDoc in courseSnapshot.docs) {
          String courseId = courseDoc.id;
          String courseName = courseDoc['course_name'];

          QuerySnapshot subjectSnapshot = await FirebaseFirestore.instance
              .collection(collectionName)
              .doc(courseId)
              .collection(courseName)
              .get();

          totalCount += subjectSnapshot.docs.length;
        }

        return totalCount;
      } else {
        QuerySnapshot snapshot =
            await FirebaseFirestore.instance.collection(collectionName).get();
        return snapshot.docs.length;
      }
    } catch (error) {
      print('Error fetching collection count: $error');
      return 0;
    }
  }

  // Future<int> _getCollectionItemCount(String collectionName) async {
  //   try {
  //     if (collectionName == 'courses') {
  //       QuerySnapshot snapshot =
  //           await FirebaseFirestore.instance.collection(collectionName).get();
  //       int totalCount = 1;

  //       for (QueryDocumentSnapshot courseDoc in snapshot.docs) {
  //         String courseId = courseDoc.id;
  //         print("Id: $courseId");
  //         QuerySnapshot courseSubjectsSnapshot = await FirebaseFirestore
  //             .instance
  //             .collection('subjects')
  //             .doc(courseId)
  //             .collection("MCA")
  //             .get();
  //         totalCount += courseSubjectsSnapshot.docs.length;
  //       }

  //       return totalCount;
  //     } else {
  //       QuerySnapshot snapshot =
  //           await FirebaseFirestore.instance.collection(collectionName).get();
  //       return snapshot.docs.length;
  //     }
  //   } catch (error) {
  //     print('Error fetching collection count: $error');
  //     return 0;
  //   }
  // }

  // Future<int> _getCollectionItemCount(String collectionName) async {
  //   try {
  //     QuerySnapshot snapshot =
  //         await FirebaseFirestore.instance.collection(collectionName).get();
  //     return snapshot.docs.length;
  //   } catch (error) {
  //     print('Error fetching collection count: $error');
  //     return 0;
  //   }
  // }
}
