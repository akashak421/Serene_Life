// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously, avoid_print, no_leading_underscores_for_local_identifiers, unused_local_variable

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';

import 'package:Serene_Life/Screens/Caretaker_Screens/Caretaker_Dashboard/PatientScreens/patientdetailscreen.dart';

import '../../../Minor screens/pageroute.dart';

class PatientScreen extends StatefulWidget {
  const PatientScreen({super.key});

  @override
  _PatientScreenState createState() => _PatientScreenState();
}

class _PatientScreenState extends State<PatientScreen> {
  final User? _user = FirebaseAuth.instance.currentUser;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Patient Details'),
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: _firestore
            .collection('Profiles')
            .doc(_user!.phoneNumber.toString())
            .get(),
        builder: (context, userSnapshot) {
          if (userSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (userSnapshot.hasError) {
            return const Center(child: Text('Failed to fetch user profile'));
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
                    return const Center(child: CircularProgressIndicator());
                  } else if (caretakerSnapshot.hasError) {
                    return const Center(
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
                            const SizedBox(height: 20),
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
                                      leading: const Icon(Icons.person),
                                      title: const Text(
                                        'Name',
                                        style: TextStyle(fontSize: 18),
                                      ),
                                      subtitle: Text(
                                        name,
                                        style: const TextStyle(fontSize: 16),
                                      ),
                                    ),
                                    const Divider(color: Colors.black),
                                    ListTile(
                                      leading: const Icon(Icons.phone),
                                      title: const Text(
                                        'Phone Number',
                                        style: TextStyle(fontSize: 18),
                                      ),
                                      subtitle: Text(
                                        phoneNumber,
                                        style: const TextStyle(fontSize: 16),
                                      ),
                                    ),
                                    const Divider(color: Colors.black),
                                    ListTile(
                                      leading: const Icon(Icons.email),
                                      title: const Text(
                                        'E-Mail',
                                        style: TextStyle(fontSize: 18),
                                      ),
                                      subtitle: Text(
                                        email,
                                        style: const TextStyle(fontSize: 16),
                                      ),
                                    ),
                                    const Divider(color: Colors.black),
                                    ListTile(
                                      leading: const Icon(Icons.location_on),
                                      title: const Text(
                                        'Address',
                                        style: TextStyle(fontSize: 18),
                                      ),
                                      subtitle: Text(
                                        address,
                                        style: const TextStyle(fontSize: 16),
                                      ),
                                    ),
                                    const Divider(color: Colors.black),
                                    ListTile(
                                      leading: const Icon(Icons.calendar_month),
                                      title: const Text(
                                        'Age',
                                        style: TextStyle(fontSize: 18),
                                      ),
                                      subtitle: Text(
                                        age,
                                        style: const TextStyle(fontSize: 16),
                                      ),
                                    ),
                                    const Divider(color: Colors.black),
                                    ListTile(
                                      leading: const Icon(Icons.people),
                                      title: const Text(
                                        'Gender',
                                        style: TextStyle(fontSize: 18),
                                      ),
                                      subtitle: Text(
                                        gender,
                                        style: const TextStyle(fontSize: 16),
                                      ),
                                    ),
                                  ],
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
              return StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection('Notifications')
                    .doc(_user.phoneNumber.toString())
                    .collection('Requests')
                    .snapshots(),
                builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (snapshot.data?.docs.isEmpty ?? true) {
                    return const Center(child: Text('No requests available'));
                  } else {
                    return ListView(
                      children: snapshot.data!.docs.map((DocumentSnapshot document) {
                        Map<String, dynamic> data =
                            document.data() as Map<String, dynamic>;
                        String senderName = data['senderName'];
                        return Card(
                          elevation: 4,
                          color: Colors.blue.shade100,
                          margin:
                              const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          child: ListTile(
                            title: Text(
                              "From $senderName",
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 18),
                            ),
                            subtitle: const Text(
                              "Requesting for care assistance",
                              style: TextStyle(fontSize: 16),
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(
                                    Icons.person,
                                    color: Colors.blueGrey,
                                    size: 35,
                                  ),
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      ScaleTransitionRoute(
                                        builder: (context) => PatientDetailsScreen(
                                          phoneNumber: data['senderPhoneNumber'],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.check,
                                    color: Colors.green,
                                    size: 35,
                                  ),
                                  onPressed: () {
                                    showDialog(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        title: const Text('Confirm'),
                                        content: const Text(
                                            'Are you sure you want to accept this request?'),
                                        actions: [
                                          TextButton(
                                            onPressed: () {
                                              String message="Accepted";
                                              _sendNotification(data,message);
                                              Navigator.of(context).pop();
                                            },
                                            child: const Text('Accept'),
                                          ),
                                          TextButton(
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                            },
                                            child: const Text('Cancel'),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.close,
                                    color: Colors.red,
                                    size: 35,
                                  ),
                                  onPressed: () {
                                    showDialog(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        title: const Text('Confirm'),
                                        content: const Text(
                                            'Are you sure you want to decline this request?'),
                                        actions: [
                                          TextButton(
                                            onPressed: () {
                                              String message="Declined";
                                              _sendNotification(data,message);
                                              Navigator.of(context).pop();
                                            },
                                            child: const Text('Decline'),
                                          ),
                                          TextButton(
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                            },
                                            child: const Text('Cancel'),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
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

  Future<void> _sendNotification(Map<String, dynamic>? data, String message) async {
    try {
      if (data == null) {
        print('Error sending notification: Data is null');
        return;
      }

      String? phoneNumber = _user!.phoneNumber;
      DocumentSnapshot<Map<String, dynamic>> snapshot = await _firestore
          .collection('Profiles')
          .doc(phoneNumber)
          .get();
      String? _name = snapshot.data()!['name'];
      String title = "Request $message";
      String body = "Your request has been $message by $_name ";

      // Check if 'sender_token' exists and is not null
      if (data.containsKey('senderToken') && data['senderToken'] != null) {
        String token = data['senderToken'];

        await http.post(
          Uri.parse('https://fcm.googleapis.com/fcm/send'),
          headers: <String, String>{
            'Content-type': 'application/json',
            'Authorization':
                'key=AAAAxXUtW5M:APA91bHiQ87fgwD9P-81RfRIcVopCvyBUlSb8Q8BWuROcliY7zx8dGtZr8Ol2a_vHybpAqKNMsxWjkUlYG0t1LiRYiQtTwLcr1-pV9yG8j-gUH-e0KPvv9XTssFnX_3FXJTw0j9fObAT',
          },
          body: jsonEncode(
            <String, dynamic>{
              'priority': 'high',
              'data': <String, dynamic>{
                'click_action': 'FLUTTER_NOTIFICATION_CLICK',
                'status': 'done',
                'body': body,
                'title': title,
              },
              "notification": <String, dynamic>{
                "title": title,
                "body": body,
                "android_channel_id": "YOUR_CHANNEL_ID",
              },
              "to": token,
            },
          ),
        );

        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Notification sent')));
        await FirebaseFirestore.instance
            .collection('Notifications')
            .doc(data['senderPhoneNumber'])
            .collection('Responses')
            .doc(phoneNumber)
            .set({
          'senderPhoneNumber': phoneNumber,
          'senderName': _name,
          'status': message,
          'body': body,
          'timestamp': FieldValue.serverTimestamp(),
        });
        if(message=="Accepted"){
          await FirebaseFirestore.instance
            .collection('Profiles')
            .doc(data['senderPhoneNumber'])
            .set({
              'partnerPhoneNumber' : phoneNumber,
              'assigned':'true',
            },SetOptions(merge: true),);

            await FirebaseFirestore.instance
            .collection('Profiles')
            .doc(phoneNumber)
            .set({
              'partnerPhoneNumber' : data['senderPhoneNumber'],
              'assigned':'true',
            },SetOptions(merge: true),);
        }

            await FirebaseFirestore.instance
            .collection('Notifications')
            .doc(phoneNumber)
            .collection('Requests')
            .doc(data['senderPhoneNumber'])
            .delete();

      } else {
        print('Error sending notification: Sender token is null or missing');
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to send notification')));
      }
    } catch (error) {
      print('Error sending notification: $error');
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to send notification')));
    }
  }
}
