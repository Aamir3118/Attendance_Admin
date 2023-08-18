import 'package:attendance_admin/widgets/widgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../services/auth_service.dart';

class AddFacultyScreen extends StatefulWidget {
  const AddFacultyScreen({super.key});

  @override
  State<AddFacultyScreen> createState() => _AddFacultyScreenState();
}

class _AddFacultyScreenState extends State<AddFacultyScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final AuthService authService = AuthService();
  List<dynamic> _selectedSubjects = [];
  List<dynamic> _selectedDepartments = [];
  var isLoading = false;
  String? _selectedCourse;
  String? _selectedSubject;
  // Provide options for subjects and departments
  List<dynamic> _subjects = ['Mathematics', 'Physics', 'Chemistry', 'Biology'];
  List<String> courseNames = [];
  List<String> subjectNames = [];
  @override
  void initState() {
    super.initState();
    _loadCourseNames();
  }

  FirebaseAuth user = FirebaseAuth.instance;
  // Future<void> _loadCourseNames() async {
  //   try {
  //     QuerySnapshot courseSnapshot =
  //         await FirebaseFirestore.instance.collection('courses').get();
  //     setState(() {
  //       courseNames = courseSnapshot.docs
  //           .map((doc) => doc['course_name'] as String)
  //           .toList();
  //     });
  //   } catch (e) {
  //     print(e.toString());
  //   }
  // }
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
        actions: <Widget>[
          IconButton(
            onPressed: () async {
              try {
                await user.signOut();
              } catch (e) {
                e.toString();
              }
            },
            icon: const Icon(Icons.exit_to_app, color: Colors.white),
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                textFormField(_usernameController, "Enter Username", false,
                    TextInputType.name, (value) {
                  if (value!.isEmpty) {
                    return 'Please enter username';
                  } else if (value.length <= 5) {
                    return "Username length should greater than 5";
                  }
                  // You can add more email validation checks here
                  return null;
                }, context, Icons.person_outline),
                const SizedBox(
                  height: 10,
                ),
                textFormField(_emailController, "Enter Email", false,
                    TextInputType.emailAddress, (value) {
                  if (value!.isEmpty) {
                    return 'Please enter an email';
                  }
                  // You can add more email validation checks here
                  return null;
                }, context, Icons.email_outlined),
                const SizedBox(
                  height: 10,
                ),
                // TextFormField(
                //   controller: _emailController,
                //   keyboardType: TextInputType.emailAddress,
                //   decoration: InputDecoration(labelText: 'Email'),
                //   validator: (value) {
                //     if (value!.isEmpty) {
                //       return 'Please enter an email';
                //     }
                //     // You can add more email validation checks here
                //     return null;
                //   },
                // ),
                PasswordField(
                    controller: _passwordController,
                    hint: "Enter Password",
                    inputType: TextInputType.text,
                    validation: (value) {
                      if (value!.isEmpty) {
                        return 'Please enter a password';
                      }
                      // You can add more email validation checks here
                      return null;
                    },
                    context: context),
                // SizedBox(height: 20),
                // MultiSelect(
                //   autovalidate: false,
                //   titleText: 'Select Subjects',
                //   dataSource: _subjects,
                //   textField: 'display',
                //   valueField: 'value',
                //   filterable: true,
                //   onSaved: (selectedValues) {
                //     setState(() {
                //       _selectedSubjects = selectedValues;
                //     });
                //   },
                // ),
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

                      // String? courseId = await _fetchCourseId(selectedcourse!);

                      // if (courseId != null) {
                      //   _loadSubjectsName(courseId, selectedcourse);
                      //   setState(() {
                      //     _selectedCourse = selectedcourse;
                      //     _selectedSubject = null;
                      //   });
                      // } else {
                      //   print(
                      //       "Course ID not found for selected course: $_selectedCourse");
                      // }
                    },
                  ),
                const SizedBox(
                  height: 15,
                ),

                if (_selectedCourse != null && _selectedSubject != null)
                  loginButton(_selectedCourse!, _selectedSubject!)
              ],
            ),
          ),
        ),
      ),
    );
  }

  InkWell loginButton(String selectedCourse, String selectedSubject) {
    return InkWell(
      onTap: () {
        submitForm(selectedCourse, selectedSubject);
      },
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: Theme.of(context).primaryColor),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Center(
            child: isLoading
                ? const CircularProgressIndicator(
                    color: Colors.white,
                  )
                : const Text(
                    "Submit",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  Future<void> submitForm(
      String selectedCourseName, String selectedSubjectName) async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        isLoading = true;
      });

      String email = _emailController.text;
      String password = _passwordController.text;
      String username = _usernameController.text;
      String courseName = selectedCourseName;
      String subjectName = selectedSubjectName;

      try {
        // Use AuthService to create faculty account
        await authService.createFacultyWithEmailAndPassword(email, password);

        // Get the currently logged-in admin's UID
        String? adminUid = AuthService().getCurrentUserUID();

        // Store the faculty data in the faculties collection
        String? courseId = await _fetchCourseId(selectedCourseName);

        if (courseId != null) {
          Map<String, dynamic> facultyData = {
            'email': email,
            'password': password,
            'username': username,
            'course': courseName,
            'subject': subjectName,
          };
          FirebaseAuth auth = FirebaseAuth.instance;
          await FirebaseFirestore.instance
              .collection('faculties')
              .doc(auth.currentUser!.uid)
              .set(facultyData);

          setState(() {
            isLoading = false;
          });

          // Show a success message to the user
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text("Success"),
              content: Text("faculty added successfully."),
            ),
          );
        }
      } on FirebaseAuthException catch (error) {
        var errorMessage = "Failed";
        if (error.code == 'wrong-password') {
          errorMessage = 'Invalid password.';
        } else if (error.code == 'email-already-exists') {
          errorMessage = 'This email address is already in use.';
        } else if (error.code == 'invalid-email') {
          errorMessage = 'This is not a valid email address.';
        } else if (error.code == 'user-not-found') {
          errorMessage = 'Could not find a user with that email.';
        }

        _showErrorDialog(errorMessage);
        setState(() {
          isLoading = false;
        });
      } catch (err) {
        const errorMessage = 'Error creating faculty account!';

        _showErrorDialog(errorMessage);

        setState(() {
          isLoading = false;
        });
        // Handle any errors that occurred during account creation
        print('Error creating faculty account: $err');
        // Show an error message or handle the error as needed.
      }
    }
  }

  void _showErrorDialog(String message) {
    if (mounted) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text('An Error Occurred!'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(ctx).pop();
              },
              child: Text('Ok'),
            ),
          ],
        ),
      );
    }
  }
}
