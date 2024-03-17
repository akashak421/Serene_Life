// ignore_for_file: use_key_in_widget_constructors, prefer_const_constructors_in_immutables, library_private_types_in_public_api, prefer_final_fields, prefer_const_constructors, avoid_print

import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../Minor screens/pageroute.dart';
import '../../caretakerhomescreen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:Serene_Life/Screens/styles/fields.dart';
import 'viewmedicationscreen.dart';

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
  late String? phoneNumber;

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
    _timesOfDayController = TextEditingController();
    medicationId = widget.medicine.id;
    _selectedFrequency = widget.medicine.frequency;
    _selectedTimes = widget.medicine.times_of_day.split(', ');
    _getUserProfile(); // Call _getUserProfile to fetch user profile
  }

  // Fetch user profile to get phoneNumber
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
        title: Text('Edit Medicine'),
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
                    backgroundColor: Colors.blue, // Set button background color
                    foregroundColor: Colors.white, // Set text color
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 16, horizontal: 80),
                  ),
                  child: Text(
                    "Update",
                    style: TextStyle(
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
            _selectedTimes.clear();
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
            bool isChecked = _selectedTimes.contains(timeOfDay);
            int selectedFrequencyIndex =
                _frequencyOptions.indexOf(_selectedFrequency);
            int timeOfDayIndex = _timesOfDayOptions.indexOf(timeOfDay);
            int maxAllowedSelections = selectedFrequencyIndex + 1;
            bool isEnabled = timeOfDayIndex <= maxAllowedSelections - 1;
            return CheckboxListTile(
              title: Text(timeOfDay),
              value: isChecked,
              onChanged: isEnabled
                  ? (value) {
                      setState(() {
                        if (value != null && value) {
                          _selectedTimes.add(timeOfDay);
                        } else {
                          _selectedTimes.remove(timeOfDay);
                        }
                        _timesOfDayController.text = _selectedTimes.join(', ');
                      });
                    }
                  : null, // Disable checkbox if the time of day exceeds the maximum allowed selections
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
                const Text(
                  'Updating..',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
                const SizedBox(height: 20),
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
