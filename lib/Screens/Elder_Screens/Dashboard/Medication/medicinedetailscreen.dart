// ignore_for_file: use_key_in_widget_constructors, prefer_const_constructors, prefer_const_constructors_in_immutables

import 'viewmedicationscreen.dart';
import 'package:flutter/material.dart';

class MedicineDetailsScreen extends StatelessWidget {
  final Medicine medicine;

  MedicineDetailsScreen({required this.medicine});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Medicine Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          elevation: 4,
          margin: EdgeInsets.all(8),
          color: Colors.blue.shade100,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ListTile(
                  title: Text(
                    'Name',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    medicine.name,
                    style: TextStyle(fontSize: 16),
                  ),
                  leading: Icon(Icons.medication),
                ),
                Divider(color: Colors.black,),
                ListTile(
                  title: Text(
                    'Dosage',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    medicine.dosage,
                    style: TextStyle(fontSize: 16),
                  ),
                  leading: Icon(Icons.format_list_numbered),
                ),
                Divider(color: Colors.black,),
                ListTile(
                  title: Text(
                    'Frequency',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    medicine.frequency,
                    style: TextStyle(fontSize: 16),
                  ),
                  leading: Icon(Icons.access_time),
                ),
                Divider(color: Colors.black,),
                ListTile(
                  title: Text(
                    'Start Date',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    medicine.start_date,
                    style: TextStyle(fontSize: 16),
                  ),
                  leading: Icon(Icons.calendar_month_outlined),
                ),
                Divider(color: Colors.black,),
                ListTile(
                  title: Text(
                    'End Date',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    medicine.end_date,
                    style: TextStyle(fontSize: 16),
                  ),
                  leading: Icon(Icons.calendar_month_outlined),
                ),
                Divider(color: Colors.black,),
                 ListTile(
                  title: Text(
                    'Instructions',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    medicine.instructions,
                    style: TextStyle(fontSize: 16),
                  ),
                  leading: Icon(Icons.format_align_justify),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}