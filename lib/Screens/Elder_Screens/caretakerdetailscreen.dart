// ignore_for_file: unused_local_variable, library_private_types_in_public_api, use_key_in_widget_constructors, prefer_const_constructors, prefer_const_constructors_in_immutables, avoid_print, use_build_context_synchronously, no_leading_underscores_for_local_identifiers, sort_child_properties_last, non_constant_identifier_names

import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'Homescreen.dart';

class CaretakerdetailsScreen extends StatefulWidget {
  final Map<String, dynamic> user;
  CaretakerdetailsScreen({required this.user});

  @override
  _CaretakerdetailsScreenState createState() => _CaretakerdetailsScreenState();
}

class _CaretakerdetailsScreenState extends State<CaretakerdetailsScreen> {
  final User? _user = FirebaseAuth.instance.currentUser;
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();
  }

  Future<void> _sendNotificationToCaretaker() async {
    try {
      String? phoneNumber = _user!.phoneNumber;
      String name = widget.user['name'];
      DocumentSnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore
          .instance
          .collection('Profiles')
          .doc(phoneNumber)
          .get();
      String? _name = snapshot.data()!['name'];
      String? sender_token = snapshot.data()!['token'];
      String title = "Hello $name";
      String body = "You have been requested for care assistance to $_name ";
      String token = widget.user['token'];

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
          .showSnackBar(SnackBar(content: Text('Notification sent')));
      await FirebaseFirestore.instance
          .collection('Notifications')
          .doc(widget.user['phoneNumber']) // Recipient phone number
          .collection('Requests') // Collection for sender requests
          .doc(phoneNumber) // Sender phone number as document ID
          .set({
        'recipientPhoneNumber': widget.user['phoneNumber'],
        'senderPhoneNumber': phoneNumber,
        'senderName': _name,
        'title': title,
        'body': body,
        'senderToken': sender_token,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (error) {
      print('Error sending notification: $error');
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Failed to send notification')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Caretaker Details'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: IconButton(
              icon: Icon(Icons.home),
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => HomeScreen()),
                );
              },
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
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
                        widget.user['imageUrl'],
                        fit: BoxFit.cover,
                      ),
                    ),
                  );
                },
                child: Center(
                  child: CircleAvatar(
                    radius: 70,
                    backgroundImage: NetworkImage(widget.user['imageUrl']),
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
                          widget.user['name'],
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
                          widget.user['phoneNumber'],
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
                          widget.user['email'],
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
                          widget.user['address'],
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
                          widget.user['age'],
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
                          widget.user['gender'],
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    _sendNotificationToCaretaker();
                  },
                  child: Text(
                    'Request',
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    backgroundColor: Colors.blue,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
