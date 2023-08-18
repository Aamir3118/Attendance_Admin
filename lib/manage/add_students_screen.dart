import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/services.dart' show ByteData, rootBundle;
import 'package:intl/intl.dart';
import 'package:open_file/open_file.dart';

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

  // Future<void> _readExcelData() async {
  //   // Load the Excel file from assets
  //   ByteData data = await rootBundle.load('assets/student.xlsx');
  //   var bytes = data.buffer.asUint8List();

  //   // Parse the Excel file
  //   var excel = Excel.decodeBytes(bytes);

  //   // Assuming the first sheet is the one you want to read from
  //   var sheet = excel.tables[excel.tables.keys.first];
  //   List<Map<String, dynamic>> dataList = [];

  //   for (var tableRow in sheet!.rows) {
  //     print(formatEnrollmentNo(tableRow[1]?.value));
  //     if (tableRow.isNotEmpty) {
  //       Map<String, dynamic> dataMap = {
  //         'RollNo': tableRow[0]?.value.toString(),
  //         'EnrollmentNo': formatEnrollmentNo(tableRow[1]?.value),
  //         'Name': tableRow[2]?.value.toString(),
  //       };
  //       dataList.add(dataMap);
  //     }
  //   }
  //   setState(() {
  //     // Store Excel data in the state variable
  //     excelData = dataList;
  //   });
  // }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Excel Data Reader'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: _readExcelData,
              child: Text('Read Excel Data'),
            ),
            SizedBox(height: 20),
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
  }

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
