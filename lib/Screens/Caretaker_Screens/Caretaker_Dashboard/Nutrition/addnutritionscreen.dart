// ignore_for_file: avoid_print, library_private_types_in_public_api, non_constant_identifier_names

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../Minor screens/pageroute.dart';
import '../../caretakerhomescreen.dart';
import 'package:Serene_Life/Screens/styles/fields.dart';


class AddNutritionScreen extends StatefulWidget {
  const AddNutritionScreen({super.key});

  @override
  _AddNutritionScreenState createState() => _AddNutritionScreenState();
}

class _AddNutritionScreenState extends State<AddNutritionScreen> {
  final DatabaseReference _databaseReference = FirebaseDatabase.instance.ref();
  User? user = FirebaseAuth.instance.currentUser;
  final TextEditingController _foodNameController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _caloriesController = TextEditingController();
  final TextEditingController _mealDescriptionController = TextEditingController();
  String? phoneNumber;
  String? _selectedCategory;
  String? _selectedCalories;

  final List<String> categories = ["Breakfast", "Lunch", "Dinner", "Snack"];
  final List<String> calories = ["200", "200", "300", "400", "500"];


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
        title: const Text("Add Nutrition"),
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
              controller: _foodNameController,
              label: 'Food Name',
            ),
            const SizedBox(height: 20),
             DropdownButtonFormField<String>(
              value: _selectedCategory,
              onChanged: (String? value) {
                setState(() {
                  _selectedCategory = value;
                });
              },
              items: categories.map((String category) {
                return DropdownMenuItem<String>(
                  value: category,
                  child: Text(category, style: const TextStyle(fontWeight: FontWeight.normal)), // Remove bold styling
                );
              }).toList(),
              decoration: InputDecoration(
                labelText: 'Category',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)), // Add border radius
              ),
            ),
            const SizedBox(height: 20),
            DropdownButtonFormField<String>(
              value: _selectedCalories,
              onChanged: (String? value) {
                setState(() {
                  _selectedCalories = value;
                });
              },
              items: calories.map((String calorie) {
                return DropdownMenuItem<String>(
                  value: calorie,
                  child: Text(calorie, style: const TextStyle(fontWeight: FontWeight.normal)), // Remove bold styling
                );
              }).toList(),
              decoration: InputDecoration(
                labelText: 'Calories',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)), // Add border radius
              ),
            ),
            const SizedBox(height: 20),
            CustomTextField(
              controller: _quantityController,
              label: 'Quantity',
            ),
            const SizedBox(height: 20),
            CustomTextField(
              controller: _mealDescriptionController,
              label: 'Meal Description',
            ),
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: _saveNutrition,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue, // Set button background color
                  foregroundColor: Colors.white, // Set text color
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 80),
                ),
                child: const Text(
                  "Add",
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
    );
  }

  void _saveNutrition() {
    // Check if any of the fields are empty
    if (_foodNameController.text.isEmpty ||
        _categoryController.text.isEmpty ||
        _quantityController.text.isEmpty ||
        _caloriesController.text.isEmpty ||
        _mealDescriptionController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all the fields')),
      );
      return;
    }
    String nutritionId = DateTime.now().microsecond.toString();
    DatabaseReference userNutritionRef = _databaseReference.child(phoneNumber!.toString()).child('Nutrition').child(nutritionId);

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
                  'Adding Nutrition',
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

    userNutritionRef.set({
      'foodName': _foodNameController.text,
      'category': _categoryController.text,
      'quantity': _quantityController.text,
      'calories': _caloriesController.text,
      'mealDescription': _mealDescriptionController.text,
    }).then((_) {
      Navigator.pop(context);

      // Show a success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nutrition added successfully!')),
      );

      // Navigator.pushReplacement(
      //   context,
      //   ScaleTransitionRoute(builder: (context) => const ViewNutritionScreen()),
      // );
    }).catchError((error) {
      // Close the dialog
      Navigator.pop(context);

      // Show an error message if something goes wrong
      print("Error saving nutrition: $error");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to save nutrition. Please try again.')),
      );
    });
  }

  @override
  void dispose() {
    _foodNameController.dispose();
    _categoryController.dispose();
    _quantityController.dispose();
    _caloriesController.dispose();
    _mealDescriptionController.dispose();
    super.dispose();
  }
}
