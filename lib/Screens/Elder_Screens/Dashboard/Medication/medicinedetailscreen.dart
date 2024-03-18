import 'viewmedicationscreen.dart';
import 'package:flutter/material.dart';

class MedicineDetailsScreen extends StatelessWidget {
  final Medicine medicine;

  MedicineDetailsScreen({required this.medicine});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Medicine Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          elevation: 4,
          margin: const EdgeInsets.all(8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20.0),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.blue.shade200, Colors.blue.shade50],
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDetailItem(
                    title: 'Name',
                    subtitle: medicine.name,
                    icon: Icons.medication,
                  ),
                  _buildDivider(),
                  _buildDetailItem(
                    title: 'Dosage',
                    subtitle: medicine.dosage,
                    icon: Icons.format_list_numbered,
                  ),
                  _buildDivider(),
                  _buildDetailItem(
                    title: 'Frequency',
                    subtitle: medicine.frequency,
                    icon: Icons.access_time,
                  ),
                  _buildDivider(),
                  _buildDetailItem(
                    title: 'Start Date',
                    subtitle: medicine.start_date,
                    icon: Icons.calendar_today,
                  ),
                  _buildDivider(),
                  _buildDetailItem(
                    title: 'End Date',
                    subtitle: medicine.end_date,
                    icon: Icons.calendar_today,
                  ),
                  _buildDivider(),
                  _buildDetailItem(
                    title: 'Instructions',
                    subtitle: medicine.instructions,
                    icon: Icons.format_align_justify,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailItem({
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    return ListTile(
      title: Text(
        title,
        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, fontFamily: 'Montserrat'),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(fontSize: 18, fontFamily: 'Roboto'),
      ),
      leading: Icon(
        icon,
        color: Colors.blue,
        size: 32,
      ),
    );
  }

  Widget _buildDivider() {
    return const Divider(
      color: Colors.black,
      thickness: 1.0,
      height: 24.0,
    );
  }
}
