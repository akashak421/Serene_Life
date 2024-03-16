// ignore_for_file: avoid_print, library_private_types_in_public_api, non_constant_identifier_names

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../Minor screens/pageroute.dart';
import '../../caretakerhomescreen.dart';
// import 'view_exercise_screen.dart';
import 'package:Serene_Life/Screens/styles/fields.dart';

class AddExerciseScreen extends StatefulWidget {
  const AddExerciseScreen({super.key});

  @override
  _AddExerciseScreenState createState() => _AddExerciseScreenState();
}

class _AddExerciseScreenState extends State<AddExerciseScreen> {
  final DatabaseReference _databaseReference = FirebaseDatabase.instance.ref();
  User? user = FirebaseAuth.instance.currentUser;
  final TextEditingController _exerciseNameController = TextEditingController();
  final TextEditingController _durationController = TextEditingController();
  final TextEditingController _instructionsController = TextEditingController();
  String? phoneNumber;

  @override
  void initState() {
    super.initState();
    _fetchPhoneNumber();
  }

  void _fetchPhoneNumber() async {
    try {
      if (user != null) {
        final userProfile = await FirebaseFirestore.instance
            .collection('Profiles')
            .doc(user!.phoneNumber)
            .get();
          phoneNumber = userProfile['partnerPhoneNumber'];
      }
    } catch (e) {
      print('Error fetching phone number: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Exercise"),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: IconButton(
              icon: const Icon(Icons.home),
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  ScaleTransitionRoute(builder: (context) => const CaretakerHomeScreen()),
                );
              },
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: ListView(
          children: [
            CustomTextField(
              controller: _exerciseNameController,
              label: 'Exercise Name',
            ),
            const SizedBox(height: 15),
            CustomTextField(
              controller: _durationController,
              label: 'Duration (minutes)',
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 15),
            CustomTextField(
              controller: _instructionsController,
              label: 'Instructions',
            ),
            const SizedBox(height: 15),
            Center(
              child: ElevatedButton(
                onPressed: _saveExercise,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xff8cccff),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 80),
                ),
                child: const Text(
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

  void _saveExercise() {
    // Check if any of the fields are empty
    if (_exerciseNameController.text.isEmpty ||
        _durationController.text.isEmpty ||
        _instructionsController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all the fields')),
      );
      return;
    }
    String ExerciseId = DateTime.now().microsecond.toString();
    DatabaseReference userExercisesRef = _databaseReference.child(phoneNumber!.toString()).child('Exercises').child(ExerciseId);

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
                  'Adding Exercise',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
                const SizedBox(height: 20),
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

    userExercisesRef.set({
      'exerciseName': _exerciseNameController.text,
      'duration': _durationController.text,
      'instructions': _instructionsController.text,
    }).then((_) {
      Navigator.pop(context);


      // Show a success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Exercise added successfully!')),
      );

      // Navigator.pushReplacement(
      //   context,
      //   // ScaleTransitionRoute(builder: (context) => ViewExerciseScreen()),
      // );
    }).catchError((error) {
      // Close the dialog
      Navigator.pop(context);

      // Show an error message if something goes wrong
      print("Error saving exercise: $error");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to save exercise. Please try again.')),
      );
    });
  }

  @override
  void dispose() {
    _exerciseNameController.dispose();
    _durationController.dispose();
    _instructionsController.dispose();
    super.dispose();
  }
}
