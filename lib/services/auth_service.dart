import 'package:attendance_admin/screens/signin_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  FirebaseAuth auth = FirebaseAuth.instance;
  Future<void> signInWithEmailAndPassword(String email, String password) async {
    UserCredential authResult = await auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<void> signInWithFacultyEmailAndPassword(
      String email, String password) async {
    UserCredential authResult = await auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<void> createFacultyWithEmailAndPassword(
      String email, String password) async {
    UserCredential authResult2 = await auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  String? getCurrentUserUID() {
    User? user = auth.currentUser;
    return user?.uid;
  }
  // User? user = authResult.user;
  // DocumentSnapshot adminDoc = await FirebaseFirestore.instance
  //     .collection('Admin')
  //     .doc(user!.uid)
  //     .get();
  // if (adminDoc.id == user.uid) {
  //   //print(adminDoc.data()!['email']);
  //   //await storeFacultyData(user.uid, email, password);
  //   print('User exists in the Admin collection.');
  //   return;
  // } else {
  //   await auth.signOut();
  //   SignInScreen();
  //   print('User is not a faculty member.');

  //   //throw FirebaseAuthException(message: 'User is not a faculty member.', code: '');
  // }
  // Future<void> storeFacultyData(
  //     String userId, String email, String password) async {
  //   await FirebaseFirestore.instance.collection('Admin').doc(userId).set(
  //     {
  //       'email': email,
  //       'password': password,
  //     },
  //   );
  // }
}
