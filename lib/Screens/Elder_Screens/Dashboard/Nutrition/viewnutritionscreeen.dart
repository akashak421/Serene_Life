// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../Minor screens/pageroute.dart';
import '../../Homescreen.dart';

class Nutrition {
  final String foodName;
  final String category;
  final String quantity;
  final String calories;
  final String mealDescription;
  final String id;

  Nutrition({
    required this.foodName,
    required this.category,
    required this.quantity,
    required this.calories,
    required this.mealDescription,
    required this.id,
  });
}

class ViewNutritionScreen extends StatefulWidget {
  const ViewNutritionScreen({super.key});

  @override
  _ViewNutritionScreenState createState() => _ViewNutritionScreenState();
}

class _ViewNutritionScreenState extends State<ViewNutritionScreen> {
  late DatabaseReference dbRef;
  late Future<DataSnapshot> _fetchDataFuture;
  final User? user = FirebaseAuth.instance.currentUser;
  late Map<String, List<Nutrition>> groupedNutrition = {};

  Future<void> groupNutritionByCategory(List<Nutrition> nutritionList) async {
    groupedNutrition = {};
    for (var nutrition in nutritionList) {
      if (!groupedNutrition.containsKey(nutrition.category)) {
        groupedNutrition[nutrition.category] = [];
      }
      groupedNutrition[nutrition.category]!.add(nutrition);
    }
  }

  Future<DataSnapshot> fetchNutritionData() async {
    dbRef = FirebaseDatabase.instance
        .ref()
        .child(user!.phoneNumber.toString())
        .child('Nutrition');
    return dbRef.once().then((event) => event.snapshot);
  }

  @override
  void initState() {
    super.initState();
    _fetchDataFuture = fetchNutritionData().then((snapshot) {
      final nutritionList = (snapshot.value as Map<dynamic, dynamic>)
          .entries
          .map<Nutrition>((entry) => Nutrition(
                id: entry.key,
                foodName: entry.value['foodName'].toString(),
                category: entry.value['category'] ?? '',
                quantity: entry.value['quantity'] ?? '',
                calories: entry.value['calories'] ?? '',
                mealDescription: entry.value['mealDescription'] ?? '',
              ))
          .toList();
      groupNutritionByCategory(nutritionList);
      return snapshot;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('View Nutrition'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: IconButton(
              icon: const Icon(Icons.home),
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  ScaleTransitionRoute(
                      builder: (context) =>const HomeScreen()),
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
            return ListView.builder(
              itemCount: groupedNutrition.length,
              itemBuilder: (context, index) {
                final category = groupedNutrition.keys.toList()[index];
                final nutritionItems = groupedNutrition[category]!;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        category,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                    ),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: nutritionItems.length,
                      itemBuilder: (context, index) {
                        final nutrition = nutritionItems[index];

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
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: InkWell(
                              onTap: () {
                                // Navigate to edit screen
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      flex: 2,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            nutrition.foodName,
                                            style: const TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.blue,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            'Category: ${nutrition.category}',
                                            style: const TextStyle(
                                                fontSize: 16,
                                                color: Colors.black87),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            'Quantity: ${nutrition.quantity}',
                                            style: const TextStyle(
                                                fontSize: 16,
                                                color: Colors.black87),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            'Calories: ${nutrition.calories}',
                                            style: const TextStyle(
                                                fontSize: 16,
                                                color: Colors.black87),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            'Meal Description: ${nutrition.mealDescription}',
                                            style: const TextStyle(
                                                fontSize: 16,
                                                color: Colors.black87),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                );
              },
            );
          }
        },
      ),
    );
  }
}
