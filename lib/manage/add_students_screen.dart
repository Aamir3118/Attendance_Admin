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
  var isLoadingFile = false;
  var isLoadingUpload = false;
  final _formKey = GlobalKey<FormState>();
  String? selectedExcelFileName;
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
    printStudents();
  }

  Future<void> printStudents() async {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    final CollectionReference studentsCollection =
        firestore.collection("students");

    // Define your query criteria
    final String selectedCourse = "course 5";
    final String selectedDiv = "A";
    final int startYear = 2023;
    final int endYear = 2025;

    // Query for the student document based on your criteria
    QuerySnapshot studentsQuery = await studentsCollection
        .where('course_name', isEqualTo: selectedCourse)
        .where('div_name', isEqualTo: selectedDiv)
        .where('start_year', isEqualTo: startYear)
        .where('end_year', isEqualTo: endYear)
        .get();

    if (studentsQuery.docs.isNotEmpty) {
      // Student document found, now retrieve data from the enrollments subcollection
      final DocumentReference studentDocRef =
          studentsQuery.docs.first.reference;
      final CollectionReference enrollmentsCollection =
          studentDocRef.collection('enrollments');

      QuerySnapshot enrollmentsQuery = await enrollmentsCollection.get();
      if (enrollmentsQuery.docs.isNotEmpty) {
        // Data found, iterate through the documents and print them
        for (QueryDocumentSnapshot enrollmentDoc in enrollmentsQuery.docs) {
          print("Enrollment No: ${enrollmentDoc['EnrollmentNo']}");
          print("Roll No: ${enrollmentDoc['RollNo']}");
          print("Name: ${enrollmentDoc['Name']}");
        }
      } else {
        // No data found in enrollments collection
        print("No student data found.");
      }
    } else {
      // No student document matching the criteria found
      print("No student document found.");
    }
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
    setState(() {
      isLoadingFile = true;
    });
    if (result != null &&
        result.files.isNotEmpty &&
        result.files.single.path != null) {
      setState(() {
        isLoadingFile = false;
      });
      try {
        selectedExcelFileName = result.files.first.name;
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
          setState(() {
            isLoadingFile = false;
          });
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
        setState(() {
          isLoadingFile = false;
        });
      }
    }
  }

  Future<void> _uploadData() async {
    FocusManager.instance.primaryFocus!.unfocus();
    if (_formKey.currentState?.validate() == false ||
        selectedExcelFileName == null) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text("Error"),
          content: Text("Please select an Excel file before uploading data."),
        ),
      );
      return;
    }
    if (_selectedStartDate != null &&
        _selectedEndDate != null &&
        _selectedStartDate!.isAfter(_selectedEndDate!)) {
      // Display an error message and prevent data upload
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text("Error"),
          content: Text("Start year cannot be greater than the end year."),
        ),
      );
      setState(() {
        isLoadingUpload = false;
      });
      return;
    }
    if (_selectedStartDate != null &&
        _selectedEndDate != null &&
        _selectedEndDate!.isBefore(_selectedStartDate!)) {
      // Display an error message and prevent data upload
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text("Error"),
          content: Text("End year cannot be smaller than the start year."),
        ),
      );
      setState(() {
        isLoadingUpload = false;
      });
      return;
    }
    setState(() {
      isLoadingUpload = true;
    });
    String selectedCourse = _selectedCourse!;
    String selectedDiv = _selectedDiv!;
    DateTime startDate = _selectedStartDate!;
    DateTime endDate = _selectedEndDate!;

    Map<String, dynamic> documentData = {
      'div_name': selectedDiv,
      'course_name': selectedCourse,
      'start_year': startDate.year,
      'end_year': endDate.year,
    };
    CollectionReference studentsCollection =
        FirebaseFirestore.instance.collection("students");
    //DocumentReference newDocumentRef =
    // await studentsCollection.add(documentData);

    Query existingDocQuery = studentsCollection
        .where('div_name', isEqualTo: selectedDiv)
        .where('course_name', isEqualTo: selectedCourse)
        .where('start_year', isEqualTo: startDate.year)
        .where('end_year', isEqualTo: endDate.year);

    QuerySnapshot existingDocs = await existingDocQuery.get();

    if (existingDocs.docs.isNotEmpty) {
      // Document with the same criteria exists, update it
      DocumentReference existingDocumentRef = existingDocs.docs.first.reference;

      // Update the document
      await existingDocumentRef.update(documentData);
      CollectionReference enrollmentsCollection =
          existingDocumentRef.collection('enrollments');
      for (var rowData in excelData) {
        String enrollmentNo = rowData['EnrollmentNo'] ?? '';
        if (enrollmentNo.isNotEmpty) {
          // Check if a document with the same criteria exists
          QuerySnapshot existingStudent = await enrollmentsCollection
              .where('EnrollmentNo', isEqualTo: enrollmentNo)
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
                enrollmentsCollection.doc(enrollmentNo);

            await studentDocRef.set({
              'RollNo': rowData['RollNo'] ?? '',
              'EnrollmentNo': enrollmentNo,
              'Name': rowData['Name'] ?? '',
              'StartYear': startDate,
              'EndYear': endDate,
              'ExcelFileName': selectedExcelFileName,
            });
          }
        }
      }
    } else {
      // Document with the same criteria does not exist, create a new document
      //await studentsCollection.add(documentData);
      // Document with the same criteria doesn't exist, create a new one
      // Create the main document
      DocumentReference newDocumentRef =
          await studentsCollection.add(documentData);
      // Update the documentData with the newly created document's ID
      documentData['docId'] = newDocumentRef.id;
      // Create the enrollments subcollection
      CollectionReference enrollmentsCollection =
          newDocumentRef.collection('enrollments');
      for (var rowData in excelData) {
        String enrollmentNo = rowData['EnrollmentNo'] ?? '';
        if (enrollmentNo.isNotEmpty) {
          // Create a new student document using the enrollment number as the document ID
          DocumentReference studentDocRef =
              enrollmentsCollection.doc(enrollmentNo);

          await studentDocRef.set({
            'RollNo': rowData['RollNo'] ?? '',
            'EnrollmentNo': enrollmentNo,
            'Name': rowData['Name'] ?? '',
            'StartYear': startDate,
            'EndYear': endDate,
            'ExcelFileName': selectedExcelFileName,
          });
        }
      }
    }

    // Update or create the enrollments subcollection
    // CollectionReference enrollmentsCollection =
    //     existingDocs.docs.first.reference.collection('enrollments');
    // for (var rowData in excelData) {
    //   String enrollmentNo = rowData['EnrollmentNo'] ?? '';
    //   if (enrollmentNo.isNotEmpty) {
    //     // Check if a document with the same criteria exists
    //     // QuerySnapshot existingStudent = await divisionCollection
    //     //     .where('EnrollmentNo', isEqualTo: enrollmentNo)
    //     //     .where('StartDate', isEqualTo: startDate)
    //     //     .where('EndDate', isEqualTo: endDate)
    //     //     .where('ExcelFileName', isEqualTo: selectedExcelFileName)
    //     //     .get();
    //     QuerySnapshot existingStudent = await enrollmentsCollection
    //         .where('EnrollmentNo', isEqualTo: enrollmentNo)
    //         //.where('ExcelFileName', isEqualTo: selectedExcelFileName)
    //         .get();
    //     if (existingStudent.docs.isNotEmpty) {
    //       //Update the existing document
    //       DocumentReference studentDocRef =
    //           existingStudent.docs.first.reference;

    //       await studentDocRef.update({
    //         'RollNo': rowData['RollNo'] ?? '',
    //         'Name': rowData['Name'] ?? '',
    //       });
    //     } else {
    //       // Create a new student document using the enrollment number as the document ID
    //       DocumentReference studentDocRef =
    //           enrollmentsCollection.doc(enrollmentNo);

    //       await studentDocRef.set({
    //         'RollNo': rowData['RollNo'] ?? '',
    //         'EnrollmentNo': enrollmentNo,
    //         'Name': rowData['Name'] ?? '',
    //         'StartYear': startDate,
    //         'EndYear': endDate,
    //         'ExcelFileName': selectedExcelFileName,
    //       });
    //     }
    //   }
    // }

    setState(() {
      isLoadingUpload = false;
    });
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
    double spacing = 16.0;
    if (MediaQuery.of(context).size.width > 600) {
      spacing = 32.0;
    }
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'Add Students',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              //mainAxisAlignment: MainAxisAlignment.center,
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
                  validator: (val) {
                    if (val == null) {
                      return "Please select a course";
                    }
                    return null;
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
                  validator: (val) {
                    if (val == null) {
                      return "Please select a Division";
                    }
                    return null;
                  },
                ),
                const SizedBox(
                  height: 15,
                ),

                // ElevatedButton(
                //   onPressed: () => _selectStartDate(context),
                //   child: Text("Select Start Date"),
                // ),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        children: [
                          DropdownButtonFormField<int>(
                            value: _selectedStartDate?.year,
                            items: List.generate(101, (index) {
                              final year = DateTime.now().year - 50 + index;
                              return DropdownMenuItem<int>(
                                  value: year, child: Text(year.toString()));
                            }),
                            onChanged: (selectedYear) {
                              setState(() {
                                _selectedStartDate = DateTime(selectedYear!);
                              });
                            },
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              hintText: "Select Start Year",
                            ),
                            validator: (val) {
                              if (val == null) {
                                return "Please select start year";
                              }

                              return null;
                            },
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Text(_selectedStartDate != null
                              ? "Start Year: ${DateFormat('yyyy').format(_selectedStartDate!)}"
                              : ""),
                        ],
                      ),
                    ),
                    SizedBox(
                      width: spacing,
                    ),
                    Expanded(
                      child: Column(
                        children: [
                          DropdownButtonFormField<int>(
                            value: _selectedEndDate?.year,
                            items: List.generate(101, (index) {
                              final year = DateTime.now().year - 50 + index;
                              return DropdownMenuItem<int>(
                                  value: year, child: Text(year.toString()));
                            }),
                            onChanged: (selectedYear) {
                              setState(() {
                                _selectedEndDate = DateTime(selectedYear!);
                              });
                            },
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              hintText: "Select End Year",
                            ),
                            validator: (val) {
                              if (val == null) {
                                return "Please select end year";
                              }

                              return null;
                            },
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Text(_selectedEndDate != null
                              ? "End Year: ${DateFormat('yyyy').format(_selectedEndDate!)}"
                              : ""),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(
                  height: 15,
                ),
                selectedExcelFileName == null
                    ? Text("")
                    : Text(selectedExcelFileName!),
                const SizedBox(
                  height: 15,
                ),
                CustomWidgets.loginButton(
                    context, _readExcelData, isLoadingFile, "Select File"),
                const SizedBox(height: 10),
                CustomWidgets.loginButton(
                    context, _uploadData, isLoadingUpload, "Upload Data"),
                const SizedBox(height: 20),
                // Expanded(
                //   child: ListView.builder(
                //     itemCount: excelData.length,
                //     itemBuilder: (context, index) {
                //       var rowData = excelData[index];
                //       return Column(
                //         crossAxisAlignment: CrossAxisAlignment.start,
                //         children: [
                //           Text('RollNo: ${rowData['RollNo'] ?? ''}',
                //               style: TextStyle(fontSize: 16)),
                //           Text('EnrollmentNo: ${rowData['EnrollmentNo'] ?? ''}',
                //               style: TextStyle(fontSize: 16)),
                //           Text('Name: ${rowData['Name'] ?? ''}',
                //               style: TextStyle(fontSize: 16)),
                //           SizedBox(height: 10),
                //         ],
                //       );
                //     },
                //   ),
                // ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _selectStartDate(BuildContext context) async {
    DateTime currentDate = DateTime.now();
    int selectedYear = currentDate.year;
    // final DateTime? picked = await showDatePicker(
    //   context: context,
    //   initialDate: DateTime.now(),
    //   firstDate: DateTime(2000),
    //   lastDate: DateTime(2101),
    // );
    final DateTime? pickedDate = await showDialog<DateTime>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Select Start Year"),
            content: YearPicker(
                firstDate: DateTime(2000),
                lastDate: DateTime(2101),
                initialDate: DateTime(selectedYear),
                selectedDate: _selectedStartDate ?? DateTime(selectedYear),
                onChanged: (DateTime year) {
                  Navigator.of(context).pop(year);
                }),
          );
        });
    if (pickedDate != null) {
      setState(() {
        _selectedStartDate = pickedDate;
      });
    }
  }

  Future<void> _selectEndDate(BuildContext context) async {
    DateTime currentDate = DateTime.now();
    int selectedYear = currentDate.year;
    // final DateTime? picked = await showDatePicker(
    //   context: context,
    //   initialDate: DateTime.now(),
    //   firstDate: DateTime(2000),
    //   lastDate: DateTime(2101),
    // );
    final DateTime? pickedDate = await showDialog<DateTime>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Select End Year"),
            content: YearPicker(
                firstDate: DateTime(2000),
                lastDate: DateTime(2101),
                initialDate: DateTime(selectedYear),
                selectedDate: _selectedStartDate ?? DateTime(selectedYear),
                onChanged: (DateTime year) {
                  Navigator.of(context).pop(year);
                }),
          );
        });
    if (pickedDate != null) {
      setState(() {
        _selectedEndDate = pickedDate;
      });
    }
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
