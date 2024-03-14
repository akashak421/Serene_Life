// ignore_for_file: library_private_types_in_public_api
import 'package:Serene_Life/Screens/Caretaker_Screens/caretakerhomescreen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

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
  const ViewExerciseScreen({super.key});

  @override
  _ViewExerciseScreenState createState() => _ViewExerciseScreenState();
}

class _ViewExerciseScreenState extends State<ViewExerciseScreen> {
  late DatabaseReference dbRef;
  late Future<DataSnapshot>  _fetchDataFuture;
  final User? user = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    _fetchDataFuture = fetchdetails();
  }

  Future<DataSnapshot> fetchdetails() async {
      dbRef = FirebaseDatabase.instance.ref().child(user!.phoneNumber.toString()).child('Exercises');
    return dbRef.once().then((event) => event.snapshot);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('View Exercises'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right:8.0),
            child: IconButton(
              icon: const Icon(Icons.home),
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const CaretakerHomeScreen()),
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
            final Map<dynamic, dynamic>? exercisesData = snapshot.data!.value as Map<dynamic, dynamic>?;

            if (exercisesData == null) {
              return const Center(child: Text('No exercise data available'));
            }

            List<Exercise> exercises = [];

            exercisesData.forEach((key, value) {
              String exerciseId = key.toString();
              Exercise exercise = Exercise(
                id :exerciseId,
                name: value['exerciseName'].toString(),
                duration:value['duration']?? '',
                instructions : value['instructions'] ?? '',
              );
              exercises.add(exercise);
            });

            return ListView.builder(
              itemCount: exercises.length,
              itemBuilder: (context, index) {
                Exercise exercise = exercises[index];

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6.0), // Add vertical padding between cards
                  child: Card(
                    elevation: 4,
                    color: Colors.blue.shade100,
                    margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    child: ListTile(
                      title: Text(
                        exercise.name,
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Duration : ${exercise.duration}',
                            style: const TextStyle(fontSize: 18),
                          ),
                          Text(
                            'Instruction : ${exercise.instructions}',
                            style: const TextStyle(fontSize: 18),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
