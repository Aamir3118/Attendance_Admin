import 'dart:io';

import 'package:attendance_admin/widgets/widgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/services.dart' show ByteData, rootBundle;
import 'package:intl/intl.dart';
import 'package:open_file/open_file.dart';

import '../services/auth_service.dart';

class AddStudentsScreen extends StatefulWidget {
  const AddStudentsScreen({super.key});

  @override
  State<AddStudentsScreen> createState() => _AddStudentsScreenState();
}

class _AddStudentsScreenState extends State<AddStudentsScreen> {
  // String selectedCourse = '';
  // String selectedSemester = '';
  // String selectedDivision = '';
  // List<String> semesterList = ['Sem1', 'Sem2', 'Sem3'];
  // void _uploadFile() async {}
  List<Map<String, dynamic>> excelData = [];
  var isLoading = false;
  String? _selectedCourse;
  String? _selectedDiv;
  List<String> courseNames = [];
  List<String> divisionNames = [];
  DateTime? _selectedStartDate;
  DateTime? _selectedEndDate;
  @override
  void initState() {
    super.initState();
    _loadCourseNames();
    _loadDivisionNames();
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

  Future<void> _loadDivisionNames() async {
    try {
      QuerySnapshot divSnapshot =
          await FirebaseFirestore.instance.collection('divisions').get();
      setState(() {
        divisionNames =
            divSnapshot.docs.map((doc) => doc['div_name'] as String).toList();
      });
    } catch (e) {
      print(e.toString());
    }
  }

  Future<void> _readExcelData() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xls', 'xlsx'],
    );

    if (result != null &&
        result.files.isNotEmpty &&
        result.files.single.path != null) {
      try {
        String filePath = result.files.single.path!;
        final file = File(filePath);
        //OpenFile.open(filePath);
        if (file.existsSync() && file.lengthSync() > 0) {
          // final bytes = result.files.single.bytes!;
          // final excel = Excel.decodeBytes(bytes);
          // var sheet = excel.tables[excel.tables.keys.first];

          final bytes = file.readAsBytesSync();
          final excel = Excel.decodeBytes(bytes);
          var sheet = excel.tables[excel.tables.keys.first];
          List<Map<String, dynamic>> dataList = [];
          for (var key in excel.tables.keys) {
            print("Table Key: $key");
            var sheet = excel.tables[key];
            for (var tableRow in sheet!.rows) {
              print("Sheet Key: $key, Row: $tableRow");
            }
          }
          for (var tableRow in sheet!.rows) {
            print("Row: $tableRow");
            if (tableRow.isNotEmpty) {
              Map<String, dynamic> dataMap = {
                'RollNo': tableRow[0]?.value.toString(),
                'EnrollmentNo': formatEnrollmentNo(tableRow[1]?.value),
                'Name': tableRow[2]?.value.toString(),
              };
              dataList.add(dataMap);
            }
          }
          setState(() {
            excelData = dataList;
          });
        } else {
          print("File bytes length: ${result.files.single.bytes?.length}");
          print("File path: $filePath");
          print("File exists: ${file.existsSync()}");

          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text("Error"),
              content: Text("The selected Excel file is empty."),
            ),
          );
        }
      } catch (e) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text("Error"),
            content:
                Text("An error occurred while reading the Excel file: \n$e"),
          ),
        );
      }
    }
  }

  Future<void> _uploadData() async {
    String selectedCourse = _selectedCourse!;
    String selectedDiv = _selectedDiv!;
    DateTime startDate = _selectedStartDate!;
    DateTime endDate = _selectedEndDate!;

    CollectionReference studentsCollection =
        FirebaseFirestore.instance.collection("students");
    CollectionReference courseCollection =
        studentsCollection.doc(_selectedCourse).collection('divisions');
    CollectionReference divisionCollection =
        courseCollection.doc(_selectedDiv).collection('Enrollments');

    for (var rowData in excelData) {
      String enrollmentNo = rowData['EnrollmentNo'] ?? '';
      if (enrollmentNo.isNotEmpty) {
        // Check if a document with the same criteria exists
        QuerySnapshot existingStudent = await divisionCollection
            .where('EnrollmentNo', isEqualTo: enrollmentNo)
            .where('StartDate', isEqualTo: startDate)
            .where('EndDate', isEqualTo: endDate)
            .get();

        if (existingStudent.docs.isNotEmpty) {
          // Update the existing document
          DocumentReference studentDocRef =
              existingStudent.docs.first.reference;

          await studentDocRef.update({
            'RollNo': rowData['RollNo'] ?? '',
            'Name': rowData['Name'] ?? '',
          });
        } else {
          // Create a new student document using the enrollment number as the document ID
          DocumentReference studentDocRef =
              divisionCollection.doc(enrollmentNo);

          await studentDocRef.set({
            'RollNo': rowData['RollNo'] ?? '',
            'EnrollmentNo': enrollmentNo,
            'Name': rowData['Name'] ?? '',
            'StartDate': startDate,
            'EndDate': endDate,
          });
        }
      }
    }

    // //Create a student document using the enrollment number as the document ID
    // DocumentReference studentDocRef = studentsCollection.doc(enrollmentNo);

    // await studentDocRef.set({
    //   'RollNo': rowData['RollNo'] ?? '',
    //   'EnrollmentNo': enrollmentNo,
    //   'Name': rowData['Name'] ?? '',
    //   'StartDate': _selectedStartDate,
    //   'EndDate': _selectedEndDate,
    // });

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Success"),
        content: Text("Student data added successfully."),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'Add Students',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            DropdownButtonFormField<String>(
              value: null,
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
              onChanged: (selctedcourse) {
                setState(() {
                  _selectedCourse = selctedcourse;
                });
              },
            ),
            const SizedBox(
              height: 15,
            ),
            DropdownButtonFormField<String>(
              value: null,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              hint: const Text("Select Division"),
              items: divisionNames
                  .map(
                    (divName) => DropdownMenuItem<String>(
                      value: divName,
                      child: Text(divName),
                    ),
                  )
                  .toList(),
              onChanged: (selecteddiv) {
                setState(() {
                  _selectedDiv = selecteddiv;
                });
              },
            ),
            const SizedBox(
              height: 15,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    ElevatedButton(
                      onPressed: () => _selectStartDate(context),
                      child: Text("Select Start Date"),
                    ),
                    Text(_selectedStartDate != null
                        ? "Start Date: ${DateFormat('yyyy-MM-dd').format(_selectedStartDate!)}"
                        : ""),
                  ],
                ),
                Column(
                  children: [
                    ElevatedButton(
                      onPressed: () => _selectEndDate(context),
                      child: Text("Select End Date"),
                    ),
                    Text(_selectedEndDate != null
                        ? "End Date: ${DateFormat('yyyy-MM-dd').format(_selectedEndDate!)}"
                        : ""),
                  ],
                ),
              ],
            ),
            const SizedBox(
              height: 15,
            ),
            CustomWidgets.loginButton(
                context, _readExcelData, isLoading, "Select File"),
            const SizedBox(height: 10),
            CustomWidgets.loginButton(
                context, _uploadData, isLoading, "Upload Data"),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: excelData.length,
                itemBuilder: (context, index) {
                  var rowData = excelData[index];
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('RollNo: ${rowData['RollNo'] ?? ''}',
                          style: TextStyle(fontSize: 16)),
                      Text('EnrollmentNo: ${rowData['EnrollmentNo'] ?? ''}',
                          style: TextStyle(fontSize: 16)),
                      Text('Name: ${rowData['Name'] ?? ''}',
                          style: TextStyle(fontSize: 16)),
                      SizedBox(height: 10),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectStartDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedStartDate) {
      setState(() {
        _selectedStartDate = picked;
      });
    }
  }

  Future<void> _selectEndDate(BuildContext context) async {
    final DateTime? picked2 = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked2 != null && picked2 != _selectedEndDate) {
      setState(() {
        _selectedEndDate = picked2;
      });
    }
  }

  // Scaffold(
  //   appBar: AppBar(
  //     title: const Text("Upload Student Data"),
  //   ),
  //   body: Center(
  //     child: Padding(
  //       padding: const EdgeInsets.all(8.0),
  //       child: Column(
  //         mainAxisAlignment: MainAxisAlignment.center,
  //         children: <Widget>[
  //           DropdownSearch<String>(
  //             items: semesterList,
  //             onChanged: (value) {
  //               setState(() {
  //                 selectedSemester = value!;
  //               });
  //             },
  //             selectedItem: selectedSemester,
  //             dropdownBuilder: (context, selectedItem) {
  //               return Column(
  //                 crossAxisAlignment: CrossAxisAlignment.start,
  //                 children: [
  //                   InputDecorator(
  //                     decoration: InputDecoration(
  //                       hintText:
  //                           'Select Semester', // Hint text when no item is selected
  //                       labelText:
  //                           'Semester', // Label text when an item is selected
  //                     ),
  //                     isEmpty: selectedItem == null,
  //                     child: DropdownButtonHideUnderline(
  //                       child: Text(selectedItem ?? 'Select Semester'),
  //                     ),
  //                   ),
  //                   // Additional styling if needed
  //                   const SizedBox(height: 8),
  //                   const Divider(),
  //                 ],
  //               );
  //             },
  //           ),
  //           ElevatedButton(
  //             onPressed: () async {
  //               FilePickerResult? result =
  //                   await FilePicker.platform.pickFiles(
  //                 type: FileType.custom,
  //                 allowedExtensions: ['xls', 'xlsx'],
  //               );

  //               if (result != null &&
  //                   result.files.isNotEmpty &&
  //                   result.files.single.bytes != null) {
  //                 try {
  //                   final bytes = result.files.single.bytes!;
  //                   final excel = Excel.decodeBytes(bytes);

  //                   // Assuming your Excel file has a single sheet named 'Sheet1'.
  //                   final sheet = excel.tables['Sheet1'];
  //                   // CollectionReference courseRef = FirebaseFirestore.instance
  //                   //     .collection('students')
  //                   //     .doc()
  //                   //     .collection('enrollments');
  //                   print(
  //                       "File bytes length: ${result.files.single.bytes?.length}");
  //                   // Iterate through each row in the sheet and extract enrollment and name.
  //                   List<Map<String, String>> studentData = [];
  //                   for (var row in sheet!.rows) {
  //                     if (row.length >= 3) {
  //                       String rollno = row[0]?.value ?? '';
  //                       String enrollment = row[1]?.value ?? '';
  //                       String name = row[2]?.value ?? '';

  //                       // Print the extracted data to the console.
  //                       print(
  //                           'Roll No: $rollno, Enrollment: $enrollment, Name: $name');

  //                       // await courseRef.doc(enrollment).set({
  //                       //   'rollno': rollno,
  //                       //   'enrollment': enrollment,
  //                       //   'name': name,
  //                       // });
  //                     }
  //                   }

  //                   // for (var row in sheet!.rows) {
  //                   //   if (row[0] != null && row[1] != null && row[2] != null) {
  //                   //     String rollno =
  //                   //         row[0]?.value; // Assuming enrollment is in the first column.
  //                   //     String enrollment = row[1]?.value;
  //                   //     String name =
  //                   //         row[2]?.value; // Assuming name is in the second column.
  //                   //     await courseRef.doc(enrollment).set(
  //                   //         {'rollno': rollno, 'enrollment': enrollment, 'name': name});
  //                   //   }
  //                   // }

  //                   // Now, store the studentData in Firestore under the selected dropdown values.
  //                   // You'll need to replace 'yourFirestoreCollection' with your actual collection name.
  //                   // await FirebaseFirestore.instance
  //                   //     .collection('students')
  //                   //     .doc(selectedCourse)
  //                   //     .collection(selectedSemester)
  //                   //     .doc(selectedDivision)
  //                   //     .set({
  //                   //   'name': name, // Store name as a field within the document
  //                   //   'enrollment':
  //                   //       enrollment, // Store enrollment as a field within the document
  //                   // });

  //                   // Show success message to the user
  //                   showDialog(
  //                     context: context,
  //                     builder: (context) => AlertDialog(
  //                       title: Text("Success"),
  //                       content: Text("Data uploaded successfully!"),
  //                     ),
  //                   );
  //                 } catch (e) {
  //                   // Show error message to the user
  //                   showDialog(
  //                     context: context,
  //                     builder: (context) => AlertDialog(
  //                       title: Text("Error"),
  //                       content: Text(
  //                           "An error occurred while uploading the data: \n$e"),
  //                     ),
  //                   );
  //                 }
  //               }
  //             },
  //             child: const Text("Upload Excel File"),
  //           ),
  //         ],
  //       ),
  //     ),
  //   ),
  // );

  String formatEnrollmentNo(dynamic value) {
    if (value != null) {
      String stringValue = value.toString();
      //Remove non-numeric characters
      stringValue = stringValue.replaceAll(RegExp(r'[^0-9]'), '');
      return stringValue;
    }
    return '';
  }
}
