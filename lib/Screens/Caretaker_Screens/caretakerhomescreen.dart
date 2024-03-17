// ignore_for_file: library_prefixes, use_build_context_synchronously, avoid_print

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:Serene_Life/Screens/authentication/registration.dart' as RegistrationScreen;
import 'package:Serene_Life/Screens/Caretaker_Screens/Caretaker_Dashboard/PatientScreens/patientscreen.dart';
import 'package:Serene_Life/Screens/Caretaker_Screens/Caretaker_Dashboard/Reports/viewreportscreen.dart';
import 'package:Serene_Life/Screens/Elder_Screens/profilescreen.dart';
import '../Minor screens/pageroute.dart';
import 'Caretaker_Dashboard/Excercises/viewexercisescreen.dart';
import 'Caretaker_Dashboard/Medication/viewmedicationscreen.dart';

class CaretakerHomeScreen extends StatefulWidget {
  const CaretakerHomeScreen({super.key});

  @override
  State<CaretakerHomeScreen> createState() => _CaretakerHomeScreenState();
}

class _CaretakerHomeScreenState extends State<CaretakerHomeScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Serene Life"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await logoutAndNavigateToRegistration(context);
            },
          ),
        ],
      ),
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          const SizedBox(height: 30),
          Container(
            color: Theme.of(context).primaryColor,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              decoration: const BoxDecoration(
                color: Colors.white,
              ),
              child: GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 40,
                mainAxisSpacing: 40,
                children: [
                  itemDashboard('Medication', Icons.medication, Colors.deepOrange),
                  itemDashboard('Patient', Icons.person, Colors.green),
                  itemDashboard('Reports', Icons.description, Colors.purple),
                  itemDashboard('Nutrition', Icons.local_dining, Colors.indigo),
                  itemDashboard('Exercises', Icons.spa, Colors.teal),
                ],
              ),
            ),
          ),
          const SizedBox(height: 60),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  ScaleTransitionRoute(
                    builder: (context) => const ProfileScreen(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(50),
                ),
                padding: const EdgeInsets.symmetric(vertical: 14,),
                elevation: 5,
                shadowColor: Colors.grey.withOpacity(1.0),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.person_add,
                    color: Colors.white,
                  ),
                  SizedBox(width: 10),
                  Text(
                    "Create Profile",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Future<void> logoutAndNavigateToRegistration(BuildContext context) async {
    try {
      await _auth.signOut();
      Navigator.of(context).pushReplacement(
        ScaleTransitionRoute(
          builder: (context) => const RegistrationScreen.RegisterScreen(),
        ),
      );
    } catch (e) {
      print("Error during logout: $e");
    }
  }

  Widget itemDashboard(String title, IconData iconData, Color background) {
    return InkWell(
      onTap: () {
        _navigateToScreen(title);
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              offset: const Offset(0, 3),
              blurRadius: 6,
              color: Colors.black.withOpacity(0.1),
            ),
          ],
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              background.withOpacity(0.7),
              background.withOpacity(0.5),
            ],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    offset: const Offset(0, 3),
                    blurRadius: 6,
                    color: Colors.black.withOpacity(0.1),
                  ),
                ],
              ),
              child: Icon(
                iconData,
                color: background,
                size: 35,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              title.toUpperCase(),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToScreen(String title) {
    late Widget screen;
    switch (title) {
      case 'Patient':
        screen = const PatientScreen();
        break;
      case 'Medication':
        screen = const ViewMedicineScreen();
        break;
      case 'Reports':
        screen = const ReportScreen();
        break;
      case 'Exercises':
        screen = const ViewExerciseScreen();
        break;
      default:
        // Default case
        return;
    }
    Navigator.of(context).push(ScaleTransitionRoute(builder: (context) => screen));
  }
}
