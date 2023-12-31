import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../widgets/widgets.dart';

class DivEdit extends StatefulWidget {
  final String divName;
  final String divId;
  const DivEdit({super.key, required this.divName, required this.divId});

  @override
  State<DivEdit> createState() => _DivEditState();
}

class _DivEditState extends State<DivEdit> {
  bool isLoading = false;
  final TextEditingController divController = TextEditingController();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    divController.text = widget.divName;
  }

  final _formKey = GlobalKey<FormState>();

  Future<void> _updateDivision() async {
    FocusManager.instance.primaryFocus?.unfocus();
    if (_formKey.currentState!.validate()) {
      setState(() {
        isLoading = true;
      });
      try {
        final String newCourse = divController.text;

        final CollectionReference _div =
            FirebaseFirestore.instance.collection("divisions");
        final DocumentReference divDocRef = _div.doc(widget.divId);
        final CollectionReference studentsCollection =
            FirebaseFirestore.instance.collection("students");

        //update course_name in courses collection
        await divDocRef.update({
          "div_name": divController.text,
        });
        QuerySnapshot studQuery = await studentsCollection
            .where("div_name", isEqualTo: widget.divName)
            .get();
        for (QueryDocumentSnapshot studentDoc in studQuery.docs) {
          await studentDoc.reference.update({"div_name": newCourse});
        }
        setState(() {
          isLoading = false;
        });
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text("Success"),
            content: Text("Division edited successfully."),
          ),
        );
      } catch (e) {}
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Edit Division",
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: <Widget>[
            // textFormField(courseController, "", false, TextInputType.name,
            //     (value) {
            //   if (value!.isEmpty) {
            //     return 'Please enter course';
            //   }
            //   return null;
            // }, context, Icons.book),
            Form(
              key: _formKey,
              child: TextFormField(
                controller: divController,

                //initialValue: widget.courseName,
                // onChanged: (value) {
                //   value = courseController.text;
                // },
                decoration: decoration(
                  "",
                  context,
                  false,
                  divController,
                  Icons.book,
                ),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter division';
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            // CustomWidgets.loginButton(
            //     context, _updatecourse, isLoading, "Update Course"),
            InkWell(
              onTap: _updateDivision,
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.blue,
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Center(
                    child: isLoading
                        ? const CircularProgressIndicator(
                            color: Colors.white,
                          )
                        : Text(
                            "Update Division",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                            ),
                          ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
