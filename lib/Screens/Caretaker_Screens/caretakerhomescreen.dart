// ignore_for_file: library_prefixes, prefer_const_constructors, use_build_context_synchronously, avoid_print

// import 'package:Serene_Life/Screens/Patient/notification.dart';
import 'package:Serene_Life/Screens/Caretaker_Screens/Caretaker_Dashboard/PatientScreens/patientscreen.dart';
import 'package:Serene_Life/Screens/Caretaker_Screens/Caretaker_Dashboard/Reports/viewreportscreen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:Serene_Life/Screens/authentication/registration.dart' as RegistrationScreen;
import 'package:Serene_Life/Screens/Elder_Screens/profilescreen.dart';
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
        title: Text("Serene Life"),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
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
                  itemDashboard('Patient', Icons.person_2, Colors.green),
                  itemDashboard('Reports', Icons.description, Colors.purple),
                  itemDashboard('Nutrition', Icons.local_dining, Colors.indigo),
                  itemDashboard('Exercises', Icons.spa, Colors.teal),
                ],
              ),
            ),
          ),
          const SizedBox(height: 60),
          Center(
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (context) => ProfileScreen(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xff8cccff),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(50),
                ),
                padding: EdgeInsets.symmetric(vertical: 16, horizontal: 24),
              ),
              child: Text(
                "Create Profile",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                  fontSize: 18,
                ),
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
        MaterialPageRoute(
          builder: (context) => RegistrationScreen.RegisterScreen(),
        ),
      );
    } catch (e) {
      print("Error during logout: $e");
    }
  }

  itemDashboard(String title, IconData iconData, Color background) => GestureDetector(
    onTap: () {
      if (title == 'Patient') {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => PatientScreen(),
          ),
        );
      }
      if (title == 'Medication') {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => ViewMedicineScreen(),
          ),
        );
      }
      if (title == 'Reports') {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => ReportScreen(),
          ),
        );
      }
      if (title == 'Exercises') {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => ViewExerciseScreen(),
          ),
        );
      }
    },
    child: Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            offset: const Offset(0, 5),
            color: Theme.of(context).primaryColor.withOpacity(.2),
            spreadRadius: 3,
            blurRadius: 5,
          )
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: background,
              shape: BoxShape.circle,
            ),
            child: Icon(
              iconData,
              color: Colors.white,
              size: 35,
            ),
          ),
          const SizedBox(height: 8),
          Text(title.toUpperCase(), style: Theme.of(context).textTheme.titleMedium),
        ],
      ),
    ),
  );
}