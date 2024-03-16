// ignore_for_file: library_private_types_in_public_api, prefer_final_fields, prefer_const_constructors, avoid_print

import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../Minor screens/pageroute.dart';
import '../../caretakerhomescreen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'viewmedicationscreen.dart';
import 'package:Serene_Life/Screens/styles/fields.dart';

class MedicationScreen extends StatefulWidget {
  const MedicationScreen({super.key});

  @override
  _MedicationScreenState createState() => _MedicationScreenState();
}

class _MedicationScreenState extends State<MedicationScreen> {
  DatabaseReference databaseReference = FirebaseDatabase.instance.ref();
  User? user = FirebaseAuth.instance.currentUser;
  TextEditingController _medicineNameController = TextEditingController();
  TextEditingController _dosageController = TextEditingController();
  TextEditingController _frequencyController = TextEditingController();
  TextEditingController _startDateController = TextEditingController();
  TextEditingController _endDateController = TextEditingController();
  TextEditingController _timesOfDayController = TextEditingController();
  TextEditingController _instructionsController = TextEditingController();
  String? phoneNumber;

  List<String> _frequencyOptions = ['Once', 'Two Times', 'Three Times', 'Four Times'];

  String _selectedFrequency = 'Once';
  List<String> _timesOfDayOptions = ['Morning','Night', 'Afternoon', 'Evening' ];
  List<String> _selectedTimes = [];

  @override
  void initState() {
    super.initState();
    _getUserProfile();
  }

  // Fetch phone number from user profile
  Future<void> _getUserProfile() async {
    final User? user = FirebaseAuth.instance.currentUser;
    DocumentSnapshot userProfile = await FirebaseFirestore.instance
        .collection('Profiles')
        .doc(user!.phoneNumber)
        .get();
    setState(() {
      phoneNumber = userProfile['partnerPhoneNumber'];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Medication"),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right:8.0),
            child: IconButton(
              icon: Icon(Icons.home),
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  ScaleTransitionRoute(builder: (context) => CaretakerHomeScreen()),
                );
              },
            ),
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(12.0),
        child: ListView(
          children: [
            CustomTextField(
              controller: _medicineNameController,
              label: 'Medicine Name',
            ),
            SizedBox(height: 15),
            CustomTextField(
              controller: _dosageController,
              label: 'Dosage',
              keyboardType: TextInputType.emailAddress,
            ),
            SizedBox(height: 15),
            buildFrequencyDropdown(),
            SizedBox(height: 15),
            buildDateFormField("Start Date", _startDateController),
            SizedBox(height: 15),
            buildDateFormField("End Date", _endDateController),
            SizedBox(height: 15),
            buildTimesOfDayDropdown(),
            SizedBox(height: 15),
            CustomTextField(
              controller: _instructionsController,
              label: 'Instructions',
            ),
            SizedBox(height: 15 ),
            Center(
              child: ElevatedButton(
                onPressed: _saveMedication,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xff8cccff),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 16, horizontal: 80),
                ),
                child: Text(
                  "Add",
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

 Widget buildFrequencyDropdown() {
  return Container(
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(15),
      border: Border.all(color: Colors.grey.shade300),
    ),
    padding: EdgeInsets.symmetric(horizontal: 16),
    child: DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: 'Frequency',
        border: InputBorder.none,
      ),
      value: _selectedFrequency,
      onChanged: (value) {
        setState(() {
          _selectedFrequency = value!;
          // Update the times of day options based on the selected frequency
          _selectedTimes.clear();
          for (int i = 0; i < _frequencyOptions.indexOf(_selectedFrequency) + 1; i++) {
            _selectedTimes.add(_timesOfDayOptions[i]);
          }
          _timesOfDayController.text = _selectedTimes.join(', ');
        });
      },
      items: _frequencyOptions.map((frequency) {
        return DropdownMenuItem<String>(
          value: frequency,
          child: Text(frequency),
        );
      }).toList(),
    ),
  );
}


  Widget buildTimesOfDayDropdown() {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        'Times of Day:',
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
      // SizedBox(height: 8),
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: _timesOfDayOptions.map((timeOfDay) {
          return CheckboxListTile(
            title: Text(timeOfDay),
            value: _selectedTimes.contains(timeOfDay),
            onChanged: (value) {
              setState(() {
                if (value != null && value) {
                  if (_selectedTimes.length < _frequencyOptions.indexOf(_selectedFrequency) + 1) {
                    _selectedTimes.add(timeOfDay);
                  }
                } else {
                  _selectedTimes.remove(timeOfDay);
                }
                _timesOfDayController.text = _selectedTimes.join(', ');
              });
            },
          );
        }).toList(),
      ),
    ],
  );
}


  Future<void> _selectDate(TextEditingController controller) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != DateTime.now()) {
      setState(() {
        controller.text = "${picked.year}-${picked.month}-${picked.day}";
      });
    }
  }

  void _saveMedication() {
  // Check if any of the fields are empty
  if (_medicineNameController.text.isEmpty ||
      _dosageController.text.isEmpty ||
      _startDateController.text.isEmpty ||
      _endDateController.text.isEmpty ||
      _selectedTimes.isEmpty ||
      _instructionsController.text.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Please fill in all the fields')),
    );
    return;
  }
  // Generate a relevant unique ID using timestamp and medication name
  String medicationId = DateTime.now().microsecond.toString();

  DatabaseReference userMedicationsRef = databaseReference.child(phoneNumber.toString()).child('Medications').child(medicationId);

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
                'Adding Medication',
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

  userMedicationsRef.set({
    'medicineName': _medicineNameController.text,
    'dosage': _dosageController.text,
    'frequency': _selectedFrequency,
    'startDate': _startDateController.text,
    'endDate': _endDateController.text,
    'timesOfDay': _timesOfDayController.text,
    'instructions': _instructionsController.text,
  }).then((_) {
    Navigator.pop(context);

    // Show a success message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Medication added successfully!')),
    );

     Navigator.pushReplacement(
          context,
          ScaleTransitionRoute(builder: (context) => ViewMedicineScreen()),
        );
  }).catchError((error) {
    // Close the dialog
    Navigator.pop(context);

    // Show an error message if something goes wrong
    print("Error saving medication: $error");
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Failed to save medication. Please try again.')),
    );
  });
}

  Widget buildDateFormField(String label, TextEditingController controller) {
    return GestureDetector(
      onTap: () => _selectDate(controller),
      child: AbsorbPointer(
        child: TextFormField(
          controller: controller,
          keyboardType: TextInputType.datetime,
          style: TextStyle(fontSize: 16),
          decoration: InputDecoration(
            labelText: label,
            labelStyle: TextStyle(fontSize: 16),
            hintText: "Select $label",
            hintStyle: TextStyle(fontSize: 14, color: Colors.grey),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide(color: Colors.blue),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _medicineNameController.dispose();
    _dosageController.dispose();
    _frequencyController.dispose();
    _startDateController.dispose();
    _endDateController.dispose();
    _timesOfDayController.dispose();
    _instructionsController.dispose();
    super.dispose();
  }
}
