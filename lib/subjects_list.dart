import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class SubjectsList extends StatefulWidget {
  final String courseName;
  final int subjectCount;
  final String courseId;
  const SubjectsList({
    super.key,
    required this.courseName,
    required this.subjectCount,
    required this.courseId,
  });

  @override
  State<SubjectsList> createState() => _SubjectsListState();
}

class _SubjectsListState extends State<SubjectsList> {
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
                    final subjectsList = snapshot.data?.docs;
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                    if (!snapshot.hasData) {
                      // Handle the case where data is null
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                    return ListTile(
                      title: Text(
                        subjectsList![index]['subject_name'],
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}
