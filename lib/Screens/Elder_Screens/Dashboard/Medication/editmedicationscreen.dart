// ignore_for_file: use_key_in_widget_constructors, prefer_const_constructors_in_immutables, library_private_types_in_public_api, prefer_final_fields, prefer_const_constructors, avoid_print

import 'package:Serene_Life/Screens/Elder_Screens/Homescreen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:Serene_Life/Screens/styles/fields.dart';
import 'package:Serene_Life/Screens/Elder_Screens/Dashboard/Medication/viewmedicationscreen.dart';

import '../../../Minor screens/pageroute.dart';

class EditMedicineScreen extends StatefulWidget {
  final Medicine medicine;

  EditMedicineScreen({required this.medicine});

  @override
  _EditMedicineScreenState createState() => _EditMedicineScreenState();
}

class _EditMedicineScreenState extends State<EditMedicineScreen> {
  late TextEditingController _medicineNameController;
  late TextEditingController _dosageController;
  late TextEditingController _startDateController;
  late TextEditingController _endDateController;
  late TextEditingController _timesOfDayController;
  late TextEditingController _instructionsController;
  User? user = FirebaseAuth.instance.currentUser;
  final DatabaseReference _databaseReference = FirebaseDatabase.instance.ref();

  late String medicationId;

  List<String> _frequencyOptions = [
    'Once',
    'Twice',
    'Three Times',
    'Four Times'
  ];
  String _selectedFrequency = 'Once';
  List<String> _timesOfDayOptions = [
    'Morning',
    'Afternoon',
    'Evening',
    'Night'
  ];
  List<String> _selectedTimes = [];

  @override
  void initState() {
    super.initState();
    _medicineNameController = TextEditingController(text: widget.medicine.name);
    _dosageController = TextEditingController(text: widget.medicine.dosage);
    _startDateController =
        TextEditingController(text: widget.medicine.start_date);
    _endDateController = TextEditingController(text: widget.medicine.end_date);
    _instructionsController =
        TextEditingController(text: widget.medicine.instructions);
    medicationId = widget.medicine.id;
    _selectedFrequency = widget.medicine.frequency;
    _selectedTimes = widget.medicine.times_of_day.split(', ');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Medicine'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
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
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomTextField(
                controller: _medicineNameController,
                label: 'Medicine Name',
              ),
              SizedBox(height: 20),
              CustomTextField(
                controller: _dosageController,
                label: 'Dosage',
              ),
              SizedBox(height: 20),
              buildFrequencyDropdown(),
              SizedBox(height: 18),
              buildDateFormField("Start Date", _startDateController),
              SizedBox(height: 20),
              buildDateFormField("End Date", _endDateController),
              SizedBox(height: 20),
              buildTimesOfDayDropdown(),
              SizedBox(height: 16),
              CustomTextField(
                controller: _instructionsController,
                label: 'Instructions',
              ),
              SizedBox(height: 16),
              Center(
                child: ElevatedButton(
                  onPressed: _updateMedicine,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue, // Background color
                    foregroundColor: Colors.white, // Text color
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 16, horizontal: 80),
                  ),
                  child: Text(
                    "Update",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
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
            // Clear the selected times of day
            _selectedTimes.clear();
            // Update the selected times of day based on the selected frequency
            int selectedIndex = _frequencyOptions.indexOf(_selectedFrequency);
            for (int i = 0; i <= selectedIndex; i++) {
              _selectedTimes.add(_timesOfDayOptions[i]);
            }
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
        SizedBox(height: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: _timesOfDayOptions.map((timeOfDay) {
            return CheckboxListTile(
              title: Text(timeOfDay),
              value: _selectedTimes.contains(timeOfDay),
              onChanged: (value) {
                setState(() {
                  if (value != null && value) {
                    if (_selectedTimes.length <
                        _frequencyOptions.indexOf(_selectedFrequency) + 1) {
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

  void _updateMedicine() {
    String? phoneNumber;
    try {
      phoneNumber = user!.phoneNumber;
    } catch (e) {
      // Handle the case where the phone number is not a valid integer
      print('Invalid phone number format');
      return;
    }

    DatabaseReference userMedicationsRef = _databaseReference
        .child(phoneNumber.toString())
        .child('Medications')
        .child(medicationId);

    String updatedMedicineName = _medicineNameController.text;
    String updatedDosage = _dosageController.text;
    String updatedFrequency = _selectedFrequency;
    String updatedStartDate = _startDateController.text;
    String updatedEndDate = _endDateController.text;
    String updatedTimesOfDay = _selectedTimes.join(', ');
    String updatedInstructions = _instructionsController.text;

    // Construct the updated medicine object
    Map<String, dynamic> updatedData = {
      'medicineName': updatedMedicineName,
      'dosage': updatedDosage,
      'frequency': updatedFrequency,
      'startDate': updatedStartDate,
      'endDate': updatedEndDate,
      'timesOfDay': updatedTimesOfDay,
      'instructions': updatedInstructions,
    };

    // Update the medicine data in the database
    userMedicationsRef.update(updatedData).then((_) {
      // Clear the text controllers after saving
      _medicineNameController.clear();
      _dosageController.clear();
      // _selectedFrequency.clear();
      _startDateController.clear();
      _endDateController.clear();
      _selectedTimes.clear();
      _instructionsController.clear();

      // Show a success message
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Medication updated successfully!'),
      ));
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update medication: $error')),
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
    _startDateController.dispose();
    _endDateController.dispose();
    _instructionsController.dispose();
    super.dispose();
  }
}
