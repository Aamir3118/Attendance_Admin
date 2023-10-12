import 'package:cloud_firestore/cloud_firestore.dart';

Future<List<String>> loadCourseNames() async {
  try {
    QuerySnapshot courseSnapshot =
        await FirebaseFirestore.instance.collection('courses').get();
    return courseSnapshot.docs
        .map((doc) => doc['course_name'] as String)
        .toList();
  } catch (e) {
    print(e.toString());
    return [];
  }
}

Future<String?> fetchCourseId(String courseName) async {
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
