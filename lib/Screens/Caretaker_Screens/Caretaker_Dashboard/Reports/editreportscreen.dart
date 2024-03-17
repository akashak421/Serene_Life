// ignore_for_file: use_key_in_widget_constructors, prefer_const_constructors_in_immutables, library_private_types_in_public_api, prefer_contains, prefer_const_constructors, use_build_context_synchronously, avoid_print

import 'dart:io';

import 'package:Serene_Life/Screens/Caretaker_Screens/caretakerhomescreen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../Minor screens/pageroute.dart';
import 'viewreportscreen.dart';
import 'package:Serene_Life/Screens/styles/fields.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

class EditReportScreen extends StatefulWidget {
  final Report report;

  EditReportScreen({required this.report});

  @override
  _EditReportScreenState createState() => _EditReportScreenState();
}

class _EditReportScreenState extends State<EditReportScreen> {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  String? _filePath;
  late String _fileName;
  late DatabaseReference dbRef;
  bool _isLoading = false;
  String? partnerPhoneNumber;
  late String newfileUrl;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.report.title);
    _descriptionController =
        TextEditingController(text: widget.report.description);
    _getUserProfile(); // Call _getUserProfile to fetch user profile
    _fileName = _getCleanFileName(widget.report.fileUrl);
    newfileUrl = widget.report.fileUrl;
  }

  // Fetch user profile to get phoneNumber
  Future<void> _getUserProfile() async {
    final User? user = FirebaseAuth.instance.currentUser;
    DocumentSnapshot userProfile = await FirebaseFirestore.instance
        .collection('Profiles')
        .doc(user!.phoneNumber)
        .get();
    setState(() {
      partnerPhoneNumber = userProfile['partnerPhoneNumber'];
      dbRef = FirebaseDatabase.instance
          .ref()
          .child(partnerPhoneNumber.toString())
          .child('Reports');
    });
  }

  String _getCleanFileName(String fileUrl) {
    String fileName = fileUrl.split('/').last.replaceAll('%20', ' ');
    fileName = fileName.replaceAll('%2F', '');
    final start = fileName.startsWith('reports') ? 'reports'.length : 0;
    final end = fileName.indexOf('?') >= 0
        ? fileName.indexOf('?')
        : fileName.indexOf('token');
    return fileName.substring(start, end);
  }

  Future<void> _selectFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null) {
      setState(() {
        _filePath = result.files.single.path;
        _fileName = result.files.single.name;
      });
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('No file selected')));
    }
  }

  Future<void> _clearFields() async {
    setState(() {
      _titleController.clear();
      _descriptionController.clear();
      _fileName = '';
      _filePath = null;
    });
  }

  Future<void> _updateReport() async {
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
                  color: Colors.blue, // Customize color if needed
                  backgroundColor:
                      Colors.grey[200], // Customize background color if needed
                ),
              ],
            ),
          ),
        );
      },
    );
    if (_filePath != null) {
      firebase_storage.TaskSnapshot task = await firebase_storage
          .FirebaseStorage.instance
          .ref('reports')
          .child(_fileName)
          .putFile(File(_filePath!));

      String downloadUrl = await task.ref.getDownloadURL();

      newfileUrl = downloadUrl;
    }

    try {
      await dbRef.child(widget.report.id).update({
        'title': _titleController.text,
        'description': _descriptionController.text,
        'fileUrl': newfileUrl,
      });

      Navigator.pop(context);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Report updated successfully')));

      Navigator.push(
        context,
        ScaleTransitionRoute(builder: (context) => ReportScreen()),
      );
    } catch (error) {
      Navigator.pop(context);
      print('Error updating report: $error');
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Failed to update report')));
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Report'),
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
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: EdgeInsets.all(16.0),
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
                  SizedBox(height: 50.0),
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
                  Text(_fileName.isEmpty
                      ? 'File: ${_getCleanFileName(widget.report.fileUrl)}'
                      : 'File: $_fileName'),
                  SizedBox(height: 40.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        onPressed: _selectFile,
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              Colors.blue, // Change button background color
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(50),
                          ),
                          padding: EdgeInsets.symmetric(
                              vertical: 16, horizontal: 30),
                        ),
                        child: Text(
                          'Select File',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: _clearFields,
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              Colors.red, // Change button background color
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(50),
                          ),
                          padding: EdgeInsets.symmetric(
                              vertical: 16, horizontal: 30),
                        ),
                        child: Text(
                          'Clear Fields',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 25.0),
                  Center(
                    child: ElevatedButton(
                      onPressed: _updateReport,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50),
                        ),
                        padding:
                            EdgeInsets.symmetric(vertical: 16, horizontal: 30),
                      ),
                      child: Text(
                        "Update Report",
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
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}
