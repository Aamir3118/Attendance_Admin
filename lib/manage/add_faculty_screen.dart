import 'package:attendance_admin/screens/tabs_screen.dart';
import 'package:attendance_admin/widgets/widgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../screens/manage_screen.dart';
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

  var isLoading = false;

  FirebaseAuth user = FirebaseAuth.instance;
  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _usernameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Handle the back button press here, if needed
        // Return true to allow popping, or false to prevent it.
        Navigator.of(context)
            .push(MaterialPageRoute(builder: (context) => TabsScreen()));
        // Navigator.of(context).pop();
        return true;
      },
      child: GestureDetector(
        onTap: () {
          FocusManager.instance.primaryFocus?.unfocus();
        },
        child: Scaffold(
          appBar: AppBar(
            centerTitle: true,
            title: const Text(
              "Add Faculty",
              style: TextStyle(color: Colors.white),
            ),
            leading: IconButton(
              icon: Icon(
                Icons.arrow_back,
                color: Colors.white,
              ), // Use an icon for the back button
              onPressed: () {
                // Handle the appbar back button press
                Navigator.of(context)
                    .pop(); // Navigate back to the previous screen
              },
            ),
          ),
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16),
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
                    const SizedBox(
                      height: 15,
                    ),
                    CustomWidgets.loginButton(
                        context, addFaculty, isLoading, "Add Faculty")
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> addFaculty() async {
    FocusManager.instance.primaryFocus?.unfocus();
    if (_formKey.currentState!.validate()) {
      setState(() {
        isLoading = true;
      });

      String email = _emailController.text;
      String password = _passwordController.text;
      String username = _usernameController.text;

      try {
        // Use AuthService to create faculty account
        await authService.createFacultyWithEmailAndPassword(email, password);

        // Get the currently logged-in admin's UID
        String? adminUid = AuthService().getCurrentUserUID();

        // Store the faculty data in the faculties collection
        //String? courseId = await _fetchCourseId(selectedCourseName);

        Map<String, dynamic> facultyData = {
          'email': email,
          'password': password,
          'username': username,
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
            title: const Text("Success"),
            content: const Text("faculty added successfully."),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.popUntil(
                      context, ModalRoute.withName('/addFaculty'));
                },
                child: const Text('Ok'),
              ),
            ],
          ),
        );
      } on FirebaseAuthException catch (error) {
        var errorMessage = "Authentication failed!";
        if (error.code == 'wrong-password') {
          errorMessage = 'Invalid password.';
        } else if (error.code == 'email-already-in-use') {
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
          title: const Text('An Error Occurred!'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(ctx).pop();
              },
              child: const Text('Ok'),
            ),
          ],
        ),
      );
    }
  }
}
