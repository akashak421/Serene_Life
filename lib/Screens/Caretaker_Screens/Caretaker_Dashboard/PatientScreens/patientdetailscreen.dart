// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PatientDetailsScreen extends StatefulWidget {
  final String phoneNumber;

  const PatientDetailsScreen({super.key, required this.phoneNumber});

  @override
  _PatientDetailsScreenState createState() => _PatientDetailsScreenState();
}

class _PatientDetailsScreenState extends State<PatientDetailsScreen> {
  late Future<DocumentSnapshot> _patientProfileFuture;

  @override
  void initState() {
    super.initState();
    _patientProfileFuture = _fetchPatientProfile();
  }

  Future<DocumentSnapshot> _fetchPatientProfile() async {
    return await FirebaseFirestore.instance
        .collection('Profiles')
        .doc(widget.phoneNumber)
        .get();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Patient Details'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: FutureBuilder(
          future: _patientProfileFuture,
          builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else {
              if (snapshot.data == null || !snapshot.data!.exists) {
                return const Center(child: Text('Patient details not found'));
              } else {
                Map<String, dynamic> patientData =
                    snapshot.data!.data() as Map<String, dynamic>;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (_) => AlertDialog(
                            content: Image.network(
                              patientData['imageUrl'],
                              fit: BoxFit.cover,
                            ),
                          ),
                        );
                      },
                      child: Center(
                        child: CircleAvatar(
                          radius: 70,
                          backgroundImage:
                              NetworkImage(patientData['imageUrl']),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Card(
                      elevation: 4,
                      margin: EdgeInsets.zero,
                      color: Colors.white,
                      child: Padding(
                  padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ListTile(
                            leading: const Icon(Icons.person),
                            title: const Text(
                              'Name',
                              style: TextStyle(fontSize: 18),
                            ),
                            subtitle: Text(
                              patientData['name'],
                              style: const TextStyle(fontSize: 16),
                            ),
                          ),
                          const Divider(color: Colors.black),
                          ListTile(
                            leading: const Icon(Icons.phone),
                            title: const Text(
                              'Phone Number',
                              style: TextStyle(fontSize: 18),
                            ),
                            subtitle: Text(
                              widget.phoneNumber,
                              style: const TextStyle(fontSize: 16),
                            ),
                          ),
                          const Divider(color: Colors.black),
                          ListTile(
                            leading: const Icon(Icons.email),
                            title: const Text(
                              'E-Mail',
                              style: TextStyle(fontSize: 18),
                            ),
                            subtitle: Text(
                              patientData['email'],
                              style: const TextStyle(fontSize: 16),
                            ),
                          ),
                          const Divider(color: Colors.black),
                          ListTile(
                            leading: const Icon(Icons.location_on),
                            title: const Text(
                              'Address',
                              style: TextStyle(fontSize: 18),
                            ),
                            subtitle: Text(
                              patientData['address'],
                              style: const TextStyle(fontSize: 16),
                            ),
                          ),
                          const Divider(color: Colors.black),
                          ListTile(
                            leading: const Icon(Icons.calendar_month),
                            title: const Text(
                              'Age',
                              style: TextStyle(fontSize: 18),
                            ),
                            subtitle: Text(
                              patientData['age'],
                              style: const TextStyle(fontSize: 16),
                            ),
                          ),
                          const Divider(color: Colors.black),
                          ListTile(
                            leading: const Icon(Icons.people),
                            title: const Text(
                              'Gender',
                              style: TextStyle(fontSize: 18),
                            ),
                            subtitle: Text(
                              patientData['gender'],
                              style: const TextStyle(fontSize: 16),
                            ),
                          ),
                        ],
                      ),
                      ),
                    ),
                  ],
                );
              }
            }
          },
        ),
      ),
    );
  }
}
