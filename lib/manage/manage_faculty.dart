import 'package:attendance_admin/widgets/widgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ManageFaculty extends StatefulWidget {
  const ManageFaculty({super.key});

  @override
  State<ManageFaculty> createState() => _ManageFacultyState();
}

class _ManageFacultyState extends State<ManageFaculty> {
  String? _selectedCourse;
  String? _selectedSubject;
  String? _selectedFaculty;
  List<String> courseNames = [];
  List<String> subjectNames = [];
  List<String> facultyNames = [];
  List<String> facultyEmails = [];
  var isLoading = false;
  @override
  void initState() {
    super.initState();
    _loadCourseNames();
    _loadFacultyDetails();
  }

  Future<void> _loadCourseNames() async {
    try {
      QuerySnapshot courseSnapshot =
          await FirebaseFirestore.instance.collection('courses').get();
      setState(() {
        courseNames = courseSnapshot.docs
            .map((doc) => doc['course_name'] as String)
            .toList();
      });
    } catch (e) {
      print(e.toString());
    }
  }

  Future<void> _loadFacultyDetails() async {
    try {
      QuerySnapshot facultySnapshot =
          await FirebaseFirestore.instance.collection('faculties').get();
      setState(() {
        // facultyNames = facultySnapshot.docs
        //     .map((doc) => doc['username'] as String)
        //     .toList();
        facultyEmails =
            facultySnapshot.docs.map((doc) => doc['email'] as String).toList();
      });
    } catch (e) {
      print(e.toString());
    }
  }

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

  Future<String?> _fetchFacultyId(String facultyEmail) async {
    try {
      QuerySnapshot facultySnapshot = await FirebaseFirestore.instance
          .collection('faculties')
          .where('email', isEqualTo: facultyEmail)
          .get();

      if (facultySnapshot.docs.isNotEmpty) {
        return facultySnapshot.docs.first.id;
      }
    } catch (e) {
      print("Error fetching facultyId: $e");
    }
    return null;
  }

  Future<void> _loadSubjectsName(String courseId, String courseName) async {
    print(courseId);
    print(courseName);
    try {
      QuerySnapshot subjectSnapshot = await FirebaseFirestore.instance
          .collection('subjects')
          .doc(courseId)
          .collection(courseName)
          .get();

      setState(() {
        subjectNames = subjectSnapshot.docs
            .map((doc) => doc['subject_name'] as String)
            .toList();
      });
      print(subjectNames);
    } catch (e) {
      print(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          "Manage Faculty",
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            //mainAxisAlignment: MainAxisAlignment.center,
            children: [
              DropdownButtonFormField<String>(
                value: _selectedFaculty,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                hint: const Text("Select Faculty email"),
                items: facultyEmails
                    .map(
                      (facultyEmail) => DropdownMenuItem<String>(
                        value: facultyEmail,
                        child: Text(facultyEmail),
                      ),
                    )
                    .toList(),
                onChanged: (selectedfaculty) async {
                  String? facultyId = await _fetchFacultyId(selectedfaculty!);

                  if (facultyId != null) {
                    _loadFacultyDetails();
                    setState(() {
                      _selectedFaculty = selectedfaculty;
                    });
                  } else {
                    print("Faculty ID not found: $_selectedFaculty");
                  }
                },
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: _selectedCourse,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                hint: Text("Select Course"),
                items: courseNames
                    .map(
                      (courseName) => DropdownMenuItem<String>(
                        value: courseName,
                        child: Text(courseName),
                      ),
                    )
                    .toList(),
                onChanged: (selectedcourse) async {
                  String? courseId = await _fetchCourseId(selectedcourse!);

                  if (courseId != null) {
                    _loadSubjectsName(courseId, selectedcourse);
                    setState(() {
                      _selectedCourse = selectedcourse;
                      _selectedSubject = null;
                    });
                  } else {
                    print(
                        "Course ID not found for selected course: $_selectedCourse");
                  }
                },
              ),
              // _buildCheckboxListTile(
              //   label: "Select Course",
              //   values: courseNames,
              //   selectedValue: _selectedCourse,
              //   onChanged: (selectedcourse) async {
              //     String? courseId = await _fetchCourseId(selectedcourse!);

              //     if (courseId != null) {
              //       _loadSubjectsName(courseId, selectedcourse);
              //       setState(() {
              //         _selectedCourse = selectedcourse;
              //         _selectedSubject = null;
              //       });
              //     } else {
              //       print(
              //           "Course ID not found for selected course: $_selectedCourse");
              //     }
              //   },
              // ),
              const SizedBox(height: 10),
              if (_selectedCourse != null)
                DropdownButtonFormField<String>(
                  value: _selectedSubject,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  hint: Text("Select Subject"),
                  items: subjectNames
                      .map(
                        (subject) => DropdownMenuItem<String>(
                          value: subject,
                          child: Text(subject),
                        ),
                      )
                      .toList(),
                  onChanged: (selectedSub) async {
                    setState(() {
                      _selectedSubject = selectedSub;
                    });
                  },
                ),
              const SizedBox(height: 20),
              if (_selectedFaculty != null &&
                  _selectedCourse != null &&
                  _selectedSubject != null)
                CustomWidgets.loginButton(context, saveData, isLoading, "Save")
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _updateFacultyCoursesAndSubjects(
    String facultyEmail,
    List<String> selectedCourses,
    List<String> selectedSubjects,
  ) async {
    try {
      // Get the faculty document reference based on the email
      QuerySnapshot facultySnapshot = await FirebaseFirestore.instance
          .collection('faculties')
          .where('email', isEqualTo: facultyEmail)
          .get();

      if (facultySnapshot.docs.isNotEmpty) {
        // Assuming there's only one faculty with a given email
        DocumentReference facultyDocRef = facultySnapshot.docs.first.reference;

        // Get the current courses and subjects for the faculty
        Map<String, dynamic>? facultyData =
            facultySnapshot.docs.first.data() as Map<String, dynamic>?;

        // Ensure that the selected courses and subjects are not already present
        if (facultyData != null) {
          List<String> currentCourses =
              List<String>.from(facultyData['courses'] ?? []);
          List<String> currentSubjects =
              List<String>.from(facultyData['subjects'] ?? []);

          // Add selected courses and subjects if not already present
          for (String selectedCourse in selectedCourses) {
            if (!currentCourses.contains(selectedCourse)) {
              currentCourses.add(selectedCourse);
            }
          }

          for (String selectedSubject in selectedSubjects) {
            if (!currentSubjects.contains(selectedSubject)) {
              currentSubjects.add(selectedSubject);
            }
          }

          // Update the faculty document with the new courses and subjects
          await facultyDocRef.update({
            'courses': currentCourses,
            'subjects': currentSubjects,
          });
        }
      }
    } catch (e) {
      print("Error updating faculty data: $e");
    }
  }

  void saveData() async {
    setState(() {
      isLoading = true;
    });
    try {
      await _updateFacultyCoursesAndSubjects(
        _selectedFaculty!,
        [_selectedCourse!],
        [_selectedSubject!],
      );

      // Refresh faculty details if needed
      _loadFacultyDetails();
      setState(() {
        _selectedCourse = null;
        _selectedSubject = null;
        isLoading = false;
      });

      showSuccessDialog();
    } catch (error) {
      setState(() {
        isLoading = false;
      });
      showErrorDialog('An error occurred: $error');
    }
  }

  void showSuccessDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Success'),
        content: Text('Courses and subjects updated successfully.'),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  void showErrorDialog(String errorMessage) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Error'),
        content: Text(errorMessage),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('OK'),
          ),
        ],
      ),
    );
  }
}
