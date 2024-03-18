// ignore_for_file: non_constant_identifier_names, library_private_types_in_public_api, prefer_const_constructors, avoid_unnecessary_containers, sort_child_properties_last

import 'package:Serene_Life/Screens/Elder_Screens/Homescreen.dart';
import '../../../Minor screens/pageroute.dart';
import 'editmedicationscreen.dart';
import 'addmedicationscreen.dart';
import 'medicinedetailscreen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class Medicine {
  final String name;
  final String frequency;
  final String dosage;
  final String start_date;
  final String end_date;
  final String times_of_day;
  final String instructions;
  final String id;

  Medicine({
    required this.name,
    required this.frequency,
    required this.dosage,
    required this.start_date,
    required this.end_date,
    required this.times_of_day,
    required this.instructions,
    required this.id,
  });
}

class ViewMedicineScreen extends StatefulWidget {
  const ViewMedicineScreen({super.key});

  @override
  _ViewMedicineScreenState createState() => _ViewMedicineScreenState();
}

class _ViewMedicineScreenState extends State<ViewMedicineScreen> {
  late DatabaseReference dbRef;
  late Future<DataSnapshot> _fetchDataFuture;

  @override
  void initState() {
    super.initState();
    final User? user = FirebaseAuth.instance.currentUser;
    dbRef = FirebaseDatabase.instance.ref().child(user!.phoneNumber!).child('Medications');
    _fetchDataFuture = dbRef.once().then((event) => event.snapshot);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('View Medicines'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right:8.0),
            child: IconButton(
              icon: Icon(Icons.home),
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  ScaleTransitionRoute(builder: (context) => HomeScreen()),
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
            final Map<dynamic, dynamic>? medicinesData = snapshot.data!.value as Map<dynamic, dynamic>?;

            if (medicinesData == null) {
              return Center(child: Text('No medicine data available'));
            }

            List<Medicine> medicines = [];

            medicinesData.forEach((key, value) {
              String medicineId = key.toString(); // Assuming key is the medicine ID
              Medicine medicine = Medicine(
                id :medicineId,
                name: value['medicineName'].toString(),
                frequency: value['frequency'] ?? '',
                dosage: value['dosage'] ?? '',
                start_date: value['startDate'] ?? '',
                end_date : value['endDate'] ?? '',
                times_of_day : value['timesOfDay'] ?? '',
                instructions : value['instructions'] ?? '',
              );
              medicines.add(medicine);
            });

            return ListView.builder(
              itemCount: medicines.length,
              itemBuilder: (context, index) {
                Medicine medicine = medicines[index];

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
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                MedicineDetailsScreen(medicine: medicine),
                          ),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 2,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    medicine.name,
                                    style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.blue),
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    'Dosage: ${medicine.dosage}',
                                    style: TextStyle(
                                        fontSize: 16, color: Colors.grey[800]),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    'Frequency: ${medicine.frequency}',
                                    style: TextStyle(
                                        fontSize: 16, color: Colors.grey[800]),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    'From: ${medicine.start_date}',
                                    style: TextStyle(
                                        fontSize: 16, color: Colors.grey[800]),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    'To: ${medicine.end_date}',
                                    style: TextStyle(
                                        fontSize: 16, color: Colors.grey[800]),
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: Padding(
                                padding: const EdgeInsets.only(left: 16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    IconButton(
                                      icon:
                                          Icon(Icons.edit, color: Colors.blue),
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                EditMedicineScreen(
                                                    medicine: medicine),
                                          ),
                                        );
                                      },
                                    ),
                                  ],
                                ),
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
            ScaleTransitionRoute(builder: (context) => MedicationScreen()),
          );
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.blue,
      ),
    );
  }
}
