// ignore_for_file: body_might_complete_normally_catch_error, use_key_in_widget_constructors, library_private_types_in_public_api, prefer_final_fields, prefer_const_constructors, unnecessary_string_interpolations, prefer_const_literals_to_create_immutables, avoid_print, use_build_context_synchronously

import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../Minor screens/pageroute.dart';
import '../../caretakerhomescreen.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_database/firebase_database.dart';

import '../../../styles/fields.dart';
import 'viewreportscreen.dart';

class AddReportScreen extends StatefulWidget {
  @override
  _AddReportScreenState createState() => _AddReportScreenState();
}

class _AddReportScreenState extends State<AddReportScreen> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController _titleController = TextEditingController();
  TextEditingController _descriptionController = TextEditingController();
  String? _filePath;
  String _fileName = '';
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String? partnerPhoneNumber;

  void _uploadReport() async {
    if (_formKey.currentState!.validate()) {
      if (_filePath == null) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Please select a file')));
        return;
      }

      try {
        final User? user = _auth.currentUser;
        if (user != null) {
          // Fetch partner's phone number from Firestore
          DocumentSnapshot userProfile = await FirebaseFirestore.instance
              .collection('Profiles')
              .doc(user.phoneNumber)
              .get();
          partnerPhoneNumber = userProfile['partnerPhoneNumber'];
        }

        Reference storageRef =
            FirebaseStorage.instance.ref().child('reports').child('$_fileName');
        UploadTask uploadTask = storageRef.putFile(File(_filePath!));

        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return Dialog(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Uploading Report',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                    SizedBox(height: 20),
                    LinearProgressIndicator(
                      color: Colors.white,
                      backgroundColor: Color(0xff8cccff),
                    ),
                  ],
                ),
              ),
            );
          },
        );

        uploadTask.whenComplete(() async {
          String downloadURL = await storageRef.getDownloadURL();
          String reportId = DateTime.now().microsecond.toString();
          DatabaseReference dbRef = FirebaseDatabase.instance
              .ref()
              .child(partnerPhoneNumber.toString())
              .child('Reports')
              .child(reportId);
          dbRef.set({
            'title': _titleController.text,
            'description': _descriptionController.text,
            'fileUrl': downloadURL,
            'timestamp': DateTime.now().toString()
          }).then((_) {
            _formKey.currentState!.reset();
            _filePath = null;
            setState(() {
              _fileName = '';
            });
            _titleController.clear();
            _descriptionController.clear();

            Navigator.pop(context); // Close the progress dialog
            ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Report uploaded successfully')));

            // Navigate to ReportScreen
            Navigator.push(
              context,
              ScaleTransitionRoute(builder: (context) => ReportScreen()),
            );
          }).catchError((error) {
            Navigator.pop(context); // Close the progress dialog
            ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Failed to upload report')));
          });
        }).catchError((error) {
          Navigator.pop(context); // Close the progress dialog
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text('Failed to upload file')));
        });
      } catch (e) {
        print(e.toString());
        Navigator.pop(context); // Close the progress dialog
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('An error occurred. Please try again.')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Report'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: IconButton(
              icon: Icon(Icons.home),
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  ScaleTransitionRoute(
                      builder: (context) => CaretakerHomeScreen()),
                );
              },
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomTextField(
                controller: _titleController,
                label: 'Title',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Enter the title')));
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.0),
              CustomTextField(
                controller: _descriptionController,
                label: 'Description',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Enter the description')));
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.0),
              Text(_fileName.isEmpty ? '' : _fileName),
              SizedBox(height: 16.0),
              Center(
                child: ElevatedButton(
                  onPressed: () async {
                    FilePickerResult? result =
                        await FilePicker.platform.pickFiles();
                    if (result != null) {
                      setState(() {
                        _filePath = result.files.single.path!;
                        _fileName = result.files.single.name;
                      });
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('No file selected')));
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                  ),
                  child: Text(
                    "Select Files",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                      fontSize: 18,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 25.0),
              Center(
                child: ElevatedButton(
                  onPressed: _uploadReport,
                  style: ElevatedButton.styleFrom(
                    backgroundColor:Colors.blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 16, horizontal: 30),
                  ),
                  child: Text(
                    "Upload Report",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                      fontSize: 18,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
