// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously, avoid_print, prefer_const_constructors, avoid_unnecessary_containers, sort_child_properties_last

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:flutter/material.dart';

import '../../../Minor screens/pageroute.dart';
import '../../caretakerhomescreen.dart';
import 'addreportscreen.dart';
import 'editreportscreen.dart';
import 'package:Serene_Life/Screens/Minor%20screens/webview.dart';

class Report {
  final String id;
  final String title;
  final String description;
  final String fileUrl;

  Report({
    required this.id,
    required this.title,
    required this.description,
    required this.fileUrl,
  });
}

class ReportScreen extends StatefulWidget {
  const ReportScreen({Key? key}) : super(key: key);

  @override
  _ReportScreenState createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  late DatabaseReference dbRef;
  late Future<DataSnapshot> _fetchDataFuture;
  final User? user = FirebaseAuth.instance.currentUser;
  String? partnerPhoneNumber;

  @override
  void initState() {
    super.initState();
    _fetchDataFuture = fetchdetails();
  }

  Future<DataSnapshot> fetchdetails() async {
    DocumentSnapshot userProfile = await FirebaseFirestore.instance
        .collection('Profiles')
        .doc(user!.phoneNumber)
        .get();
    partnerPhoneNumber = userProfile['partnerPhoneNumber'];
    dbRef = FirebaseDatabase.instance
        .ref()
        .child(partnerPhoneNumber!)
        .child('Reports');
    return dbRef.once().then((event) => event.snapshot);
  }
  Future<void> _previewReport(Report report) async {
    try {
      // Fetch all files from Firebase Storage
      firebase_storage.ListResult result = await firebase_storage
          .FirebaseStorage.instance
          .ref('reports')
          .listAll();

      // Iterate through each file in the result
      for (firebase_storage.Reference ref in result.items) {
        String downloadUrl = await ref.getDownloadURL();

        if (downloadUrl == report.fileUrl) {
          Navigator.pop(context);
          Navigator.of(context).push(ScaleTransitionRoute(
              builder: (context) => PdfViewPage(pdfUrl: downloadUrl)));
          return;
        }
      }

      print('Matching file not found for report: ${report.id}');
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('File not found')));
      Navigator.pop(context);
    } catch (e) {
      print('Error previewing report: $e');
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('View Reports'),
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
      body: FutureBuilder<DataSnapshot>(
        future: _fetchDataFuture,
        builder: (context, AsyncSnapshot<DataSnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.value == null) {
            return Center(child: Text('No data available'));
          } else {
            final Map<dynamic, dynamic>? reportsData =
                snapshot.data!.value as Map<dynamic, dynamic>?;

            if (reportsData == null) {
              return Center(child: Text('No report data available'));
            }

            List<Report> reports = [];

            reportsData.forEach((key, value) {
              String reportId = key.toString();
              Report report = Report(
                id: reportId,
                title: value['title'].toString(),
                description: value['description'].toString(),
                fileUrl: value['fileUrl'].toString(),
              );
              reports.add(report);
            });

            return ListView.builder(
              itemCount: reports.length,
              itemBuilder: (context, index) {
                Report report = reports[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: 8.0, horizontal: 16.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20.0),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.2),
                          spreadRadius: 2,
                          blurRadius: 5,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: InkWell(
                      onTap: ()
                        {
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
                                  'Processing',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                  ),
                                ),
                                SizedBox(height: 20),
                                LinearProgressIndicator(
                                  color: Colors.blue,
                                  backgroundColor: Colors.grey.shade300,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                    _previewReport(report);
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 3,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    report.title,
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blue,
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    'Description: ${report.description}',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey[800],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: IconButton(
                                icon: Icon(Icons.edit, color: Colors.blue),
                                onPressed: () {
                                  Navigator.of(context).push(ScaleTransitionRoute(
                                    builder: (context) =>
                                        EditReportScreen(report: report),
                                  ));
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            ScaleTransitionRoute(builder: (context) => AddReportScreen()),
          );
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.blue,
      ),
    );
  }
}
