// ignore_for_file: library_private_types_in_public_api, avoid_print, prefer_const_constructors_in_immutables

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import '../../../styles/fields.dart';
import '../../caretakerhomescreen.dart';
import 'viewexercisescreen.dart';

class EditExerciseScreen extends StatefulWidget {
  final Exercise exercise;

  EditExerciseScreen({super.key, required this.exercise});

  @override
  _EditExerciseScreenState createState() => _EditExerciseScreenState();
}

class _EditExerciseScreenState extends State<EditExerciseScreen> {
  late TextEditingController _exerciseNameController;
  late TextEditingController _durationController;
  late TextEditingController _instructionsController;
  final DatabaseReference _databaseReference = FirebaseDatabase.instance.ref();
  late String? phoneNumber;

  @override
  void initState() {
    super.initState();
    _exerciseNameController = TextEditingController(text: widget.exercise.name);
    _durationController = TextEditingController(text: widget.exercise.duration);
    _instructionsController =
        TextEditingController(text: widget.exercise.instructions);
    _getUserProfile();
  }

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
        title: const Text('Edit Exercise'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: IconButton(
              icon: const Icon(Icons.home),
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const CaretakerHomeScreen()),
                );
              },
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomTextField(
              controller: _exerciseNameController,
              label: 'Exercise Name',
            ),
            const SizedBox(height: 20),
            CustomTextField(
              controller: _durationController,
              label: 'Durations',
            ),
            const SizedBox(height: 20),
            CustomTextField(
              controller: _instructionsController,
              label: 'Instructions',
            ),
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: _updateExercise,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xff8cccff),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50),
                  ),
                  padding:
                      const EdgeInsets.symmetric(vertical: 16, horizontal: 80),
                ),
                child: const Text(
                  "Update",
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

  void _updateExercise() {
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
    String exerciseId = widget.exercise.id;
    String exerciseName = _exerciseNameController.text;
    String duration = _durationController.text;
    String instructions = _instructionsController.text;
    _databaseReference
        .child(phoneNumber.toString())
        .child('Exercises')
        .child(exerciseId)
        .update({
      'exerciseName': exerciseName,
      'duration': duration,
      'instructions': instructions,
    }).then((_) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Medication updated successfully!'),
      ));
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const ViewExerciseScreen()),
      );
    }).catchError((error) {
      Navigator.pop(context);
      print("Error updating exercise: $error");
      // Handle error updating exercise
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
