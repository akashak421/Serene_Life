// ignore_for_file: unused_local_variable, library_private_types_in_public_api, use_key_in_widget_constructors, prefer_const_constructors, avoid_web_libraries_in_flutter, prefer_const_constructors_in_immutables

// import 'dart:js';
import 'package:Serene_Life/Screens/Elder_Screens/notification.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:Serene_Life/Screens/Elder_Screens/Homescreen.dart';
import 'package:Serene_Life/Screens/authentication/registration.dart';
import 'package:Serene_Life/Screens/Minor%20screens/splashscreen.dart';
import 'package:Serene_Life/firebase_options.dart';
import 'Screens/Caretaker_Screens/caretakerhomescreen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final NotificationHandler notificationHandler = NotificationHandler();
  await notificationHandler.initializeNotifications();
  await notificationHandler.configureFirebaseMessaging();
  runApp(MyApp());
}


class MyApp extends StatelessWidget {
  MyApp({Key? key}) : super(key: key);

  void initializeApp() async {
    final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
    await _firebaseMessaging.requestPermission();
    String _fcmToken = (await _firebaseMessaging.getToken())!;
    final User? _user = FirebaseAuth.instance.currentUser;
    await FirebaseFirestore.instance
        .collection('Profiles')
        .doc(_user!.phoneNumber.toString())
        .set(
      {
        'token': _fcmToken,
      },
      SetOptions(merge: true),
    );
    print(_fcmToken);
    final NotificationHandler notificationHandler = NotificationHandler();
    await notificationHandler.initializeNotifications();
    await notificationHandler.configureFirebaseMessaging();
    // await MedicationReminder.cancel();

  }

  @override
  Widget build(BuildContext context) {
    initializeApp(); // Call initialization when MyApp widget is created
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: AuthenticationWrapper(),
    );
  }
}


class AuthenticationWrapper extends StatelessWidget {
  const AuthenticationWrapper({Key? key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return SplashScreen();
        } else if (snapshot.hasData) {
          final User? user = snapshot.data;
          if (user != null) {
            return FutureBuilder<DocumentSnapshot>(
              future: FirebaseFirestore.instance.collection('Profiles').doc(user.phoneNumber).get(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                } else if (snapshot.hasData) {
                  final Map<String, dynamic>? profileData = snapshot.data!.data() as Map<String, dynamic>?;
                  if (profileData != null) {
                    final bool? isCaretaker = profileData['isCaretaker'] as bool?;
                    if (isCaretaker != null) {
                      if (isCaretaker) {
                        return const CaretakerHomeScreen();
                      } else {
                        return const HomeScreen();
                      }
                    } else {
                      return const RegisterScreen();
                    }
                  } else {
                    return const RegisterScreen();
                  }
                } else {
                  return const RegisterScreen();
                }
              },
            );
          } else {
            return const RegisterScreen();
          }
        } else {
          return const RegisterScreen();
        }
      },
    );
  }
}
