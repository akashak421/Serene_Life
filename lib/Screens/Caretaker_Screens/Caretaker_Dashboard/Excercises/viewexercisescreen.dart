// ignore_for_file: library_private_types_in_public_api

import '../../../Minor screens/pageroute.dart';
import 'addexercises.dart';
import 'package:Serene_Life/Screens/Caretaker_Screens/caretakerhomescreen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'editexercisescreen.dart';

class Exercise {
  final String name;
  final String duration;
  final String instructions;
  final String id;

  Exercise({
    required this.name,
    required this.duration,
    required this.instructions,
    required this.id,
  });
}

class ViewExerciseScreen extends StatefulWidget {
  const ViewExerciseScreen({Key? key}) : super(key: key);

  @override
  _ViewExerciseScreenState createState() => _ViewExerciseScreenState();
}

class _ViewExerciseScreenState extends State<ViewExerciseScreen> {
  late DatabaseReference dbRef;
  late Future<DataSnapshot> _fetchDataFuture;
  final User? user = FirebaseAuth.instance.currentUser;
  String? partnerPhoneNumber;

  @override
  void initState() {
    super.initState();
    _fetchDataFuture = fetchdetails();
  }

  Future<DataSnapshot> fetchdetails() async {
    DocumentSnapshot userProfile = await FirebaseFirestore.instance
        .collection('Profiles')
        .doc(user!.phoneNumber)
        .get();
    partnerPhoneNumber = userProfile['partnerPhoneNumber'];
    dbRef = FirebaseDatabase.instance
        .ref()
        .child(partnerPhoneNumber!)
        .child('Exercises');
    return dbRef.once().then((event) => event.snapshot);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('View Exercises'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: IconButton(
              icon: const Icon(Icons.home),
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  ScaleTransitionRoute(
                      builder: (context) => const CaretakerHomeScreen()),
                );
              },
            ),
          ),
        ],
      ),
      body: FutureBuilder<DataSnapshot>(
        future: _fetchDataFuture,
        builder: (context, AsyncSnapshot<DataSnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.value == null) {
            return const Center(child: Text('No data available'));
          } else {
            final Map<dynamic, dynamic>? exercisesData =
                snapshot.data!.value as Map<dynamic, dynamic>?;

            if (exercisesData == null) {
              return const Center(child: Text('No exercise data available'));
            }

            List<Exercise> exercises = [];

            exercisesData.forEach((key, value) {
              String exerciseId = key.toString();
              Exercise exercise = Exercise(
                id: exerciseId,
                name: value['exerciseName'].toString(),
                duration: value['duration'] ?? '',
                instructions: value['instructions'] ?? '',
              );
              exercises.add(exercise);
            });

            return ListView.builder(
              itemCount: exercises.length,
              itemBuilder: (context, index) {
                Exercise exercise = exercises[index];

                return Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: 8.0, horizontal: 16.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20.0),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.2),
                          spreadRadius: 2,
                          blurRadius: 5,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: InkWell(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 2,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    exercise.name,
                                    style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.blue),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Duration: ${exercise.duration} mins',
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Instructions: ${exercise.instructions}',
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: Padding(
                                padding: const EdgeInsets.only(left: 16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    IconButton(
                                      icon:
                                          Icon(Icons.edit, color: Colors.blue),
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          ScaleTransitionRoute(
                                            builder: (context) =>
                                                EditExerciseScreen(
                                                    exercise: exercise),
                                          ),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            ScaleTransitionRoute(
                builder: (context) => const AddExerciseScreen()),
          );
        },
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add),
      ),
    );
  }
}
