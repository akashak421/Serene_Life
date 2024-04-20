// ignore_for_file: unused_local_variable, library_private_types_in_public_api, use_key_in_widget_constructors, prefer_const_constructors, use_build_context_synchronously, avoid_print

import 'package:Serene_Life/Screens/Elder_Screens/Homescreen.dart';
import 'package:Serene_Life/Screens/Elder_Screens/caretakerdetailscreen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../Minor screens/pageroute.dart';

class CaretakerListScreen extends StatefulWidget {
  @override
  _CaretakerListScreenState createState() => _CaretakerListScreenState();
}

class _CaretakerListScreenState extends State<CaretakerListScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final User? _user = FirebaseAuth.instance.currentUser;
  String? partnerPhoneNumber;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Caretakers'),
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
      body: FutureBuilder<DocumentSnapshot>(
        future: _firestore
            .collection('Profiles')
            .doc(_user!.phoneNumber.toString())
            .get(),
        builder: (context, userSnapshot) {
          if (userSnapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (userSnapshot.hasError) {
            return Center(child: Text('Failed to fetch user profile'));
          } else {
            String? status = userSnapshot.data!.get('assigned');
            if (status == 'true') {
              String? caretakerPhoneNumber =
                  userSnapshot.data!.get('partnerPhoneNumber');
              return FutureBuilder<DocumentSnapshot>(
                future: _firestore
                    .collection('Profiles')
                    .doc(caretakerPhoneNumber)
                    .get(),
                builder: (context, caretakerSnapshot) {
                  if (caretakerSnapshot.connectionState ==
                      ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (caretakerSnapshot.hasError) {
                    return Center(
                        child: Text('Failed to fetch caretaker details'));
                  } else {
                    Map<String, dynamic> caretakerData =
                        caretakerSnapshot.data!.data() as Map<String, dynamic>;
                    String phoneNumber = caretakerPhoneNumber.toString();
                    String name = caretakerData['name'];
                    String address = caretakerData['address'];
                    String email = caretakerData['email'];
                    bool isCaretaker = caretakerData['isCaretaker'] ?? false;
                    String gender = caretakerData['gender'];
                    String age = caretakerData['age'];
                    String imageUrl = caretakerData['imageUrl'];
                    String token = caretakerData['token'];
                    return SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            GestureDetector(
                              onTap: () {
                                showDialog(
                                  context: context,
                                  builder: (_) => AlertDialog(
                                    content: Image.network(
                                      imageUrl,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                );
                              },
                              child: Center(
                                child: CircleAvatar(
                                  radius: 70,
                                  backgroundImage: NetworkImage(imageUrl),
                                ),
                              ),
                            ),
                            SizedBox(height: 20),
                            Card(
                              elevation: 4,
                              margin: EdgeInsets.zero,
                              color: Colors.white,
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    ListTile(
                                      leading: Icon(Icons.person),
                                      title: Text(
                                        'Name',
                                        style: TextStyle(fontSize: 18),
                                      ),
                                      subtitle: Text(
                                        name,
                                        style: TextStyle(fontSize: 16),
                                      ),
                                    ),
                                    Divider(color: Colors.black),
                                    ListTile(
                                      leading: Icon(Icons.phone),
                                      title: Text(
                                        'Phone Number',
                                        style: TextStyle(fontSize: 18),
                                      ),
                                      subtitle: Text(
                                        phoneNumber,
                                        style: TextStyle(fontSize: 16),
                                      ),
                                    ),
                                    Divider(color: Colors.black),
                                    ListTile(
                                      leading: Icon(Icons.email),
                                      title: Text(
                                        'E-Mail',
                                        style: TextStyle(fontSize: 18),
                                      ),
                                      subtitle: Text(
                                        email,
                                        style: TextStyle(fontSize: 16),
                                      ),
                                    ),
                                    Divider(color: Colors.black),
                                    ListTile(
                                      leading: Icon(Icons.location_on),
                                      title: Text(
                                        'Address',
                                        style: TextStyle(fontSize: 18),
                                      ),
                                      subtitle: Text(
                                        address,
                                        style: TextStyle(fontSize: 16),
                                      ),
                                    ),
                                    Divider(color: Colors.black),
                                    ListTile(
                                      leading: Icon(Icons.calendar_month),
                                      title: Text(
                                        'Age',
                                        style: TextStyle(fontSize: 18),
                                      ),
                                      subtitle: Text(
                                        age,
                                        style: TextStyle(fontSize: 16),
                                      ),
                                    ),
                                    Divider(color: Colors.black),
                                    ListTile(
                                      leading: Icon(Icons.people),
                                      title: Text(
                                        'Gender',
                                        style: TextStyle(fontSize: 18),
                                      ),
                                      subtitle: Text(
                                        gender,
                                        style: TextStyle(fontSize: 16),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            Center(
                              child: ElevatedButton(
                                onPressed: () {
                                  _disconnect();
                                },
                                style: ElevatedButton.styleFrom(
                                  padding: EdgeInsets.symmetric(
                                      vertical: 12, horizontal: 24),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  backgroundColor: Colors.blue,
                                ),
                                child: Text(
                                  'Disconnect',
                                  style: TextStyle(
                                      fontSize: 16, color: Colors.white),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }
                },
              );
            } else {
              return FutureBuilder<QuerySnapshot>(
                future: _firestore
                    .collection('Profiles')
                    .where('isCaretaker', isEqualTo: true)
                    .get(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Failed to fetch caretakers'));
                  } else {
                    List<DocumentSnapshot> userDocs = snapshot.data!.docs;
                    List<Map<String, dynamic>> userDetails = [];
                    for (DocumentSnapshot doc in userDocs) {
                      String phoneNumber = doc.id;
                      String name = doc['name'];
                      String address = doc['address'];
                      String email = doc['email'];
                      bool isCaretaker = doc['isCaretaker'] ?? false;
                      String gender = doc['gender'];
                      String age = doc['age'];
                      String imageUrl = doc['imageUrl'];
                      String token = doc['token'];

                      Map<String, dynamic> user = {
                        'imageUrl': imageUrl,
                        'phoneNumber': phoneNumber,
                        'name': name,
                        'email': email,
                        'address': address,
                        'gender': gender,
                        'age': age,
                        'token': token,
                      };

                      userDetails.add(user);
                    }

                    return ListView.builder(
                      itemCount: userDetails.length,
                      itemBuilder: (context, index) {
                        Map<String, dynamic> user = userDetails[index];
                        String name = user['name'];
                        String email = user['email'];
                        String phoneNumber = user['phoneNumber'];

                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Card(
                            color: Colors.blue.shade100,
                            margin: EdgeInsets.symmetric(
                                horizontal: 14, vertical: 4),
                            child: ListTile(
                              title: Text(
                                name,
                                style: TextStyle(
                                  fontSize: 20,
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Email: $email',
                                    style: TextStyle(
                                      fontSize: 18,
                                    ),
                                  ),
                                  Text(
                                    'Phone Number: $phoneNumber',
                                    style: TextStyle(
                                      fontSize: 18,
                                    ),
                                  ),
                                ],
                              ),
                              onTap: () {
                                Navigator.of(context).push(
                                  ScaleTransitionRoute(
                                    builder: (context) =>
                                        CaretakerdetailsScreen(user: user),
                                  ),
                                );
                              },
                            ),
                          ),
                        );
                      },
                    );
                  }
                },
              );
            }
          }
        },
      ),
    );
  }
  _disconnect() async {
    String? partnerPhoneNumber;
DocumentSnapshot userProfile = await FirebaseFirestore.instance
        .collection('Profiles')
        .doc(_user!.phoneNumber)
        .get();
    partnerPhoneNumber = userProfile['partnerPhoneNumber'];

  // Show a confirmation dialog
  bool confirmDisconnect = await showDialog(
    context: context,
    builder: (_) => AlertDialog(
      title: Text('Disconnect Caretaker'),
      content: Text('Are you sure you want to disconnect from this caretaker?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false), // Cancel
          child: Text('Cancel'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, true), // Confirm
          child: Text('Disconnect'),
        ),
      ],
    ),
  );

  // If user confirms to disconnect
  if (confirmDisconnect == true) {
    try {
      // Update the current user's profile to remove caretaker details
      await _firestore
          .collection('Profiles')
          .doc(_user.phoneNumber.toString())
          .update({
        'assigned': 'false',
        'partnerPhoneNumber': FieldValue.delete(),
      });

      if (partnerPhoneNumber != null && partnerPhoneNumber.isNotEmpty) {
        await _firestore
            .collection('Profiles')
            .doc(partnerPhoneNumber)
            .update({
          'assigned': 'false',
          'partnerPhoneNumber': FieldValue.delete(),
        });
      }

      // Show a snackbar to indicate successful disconnection
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Disconnected caretaker successfully'),
      ));
    } catch (error) {
      print('Error disconnecting from caretaker: $error');
      // Show a snackbar to indicate error
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Failed to disconnect from caretaker'),
      ));
    }
  }
}

}
