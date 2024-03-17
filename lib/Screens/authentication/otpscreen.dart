// ignore_for_file: must_be_immutable, library_private_types_in_public_api, use_build_context_synchronously, prefer_const_constructors, non_constant_identifier_names, avoid_print
import 'dart:async';

import 'package:Serene_Life/Screens/Caretaker_Screens/caretakerhomescreen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:Serene_Life/Screens/Elder_Screens/Homescreen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

import '../Minor screens/pageroute.dart';

class OTPScreen extends StatefulWidget {
  String verificationId;
  bool isCaretaker;
  final String phoneNumber;
  final Null Function() onVerificationComplete;

  OTPScreen({
    super.key,
    required this.verificationId,
    required this.phoneNumber,
    required this.onVerificationComplete,
    required this.isCaretaker,
  });

  @override
  _OTPScreenState createState() => _OTPScreenState();
}

class _OTPScreenState extends State<OTPScreen> {
  String otppin = "";
  int resendTimeout = 60;
  bool isResendEnabled = false;
  bool isResendingOTP = false;
  bool isVerifyingOTP = false;
  bool isSubmitClicked = false;
  late Timer _resendTimer;
  late String _fcmToken;
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  @override
  void initState() {
    super.initState();
    enableResendButton();
    _getFCMToken();
  }

  Future<void> _getFCMToken() async {
    _fcmToken = (await _firebaseMessaging.getToken())!;
    await _firebaseMessaging.requestPermission();
    print(_fcmToken);
  }

  Future<void> saveUserDetails(String phoneNumber) async {
    // Save user details including the FCM token
    await FirebaseFirestore.instance
        .collection('Profiles')
        .doc(phoneNumber)
        .set(
      {
        'isCaretaker': widget.isCaretaker,
        'token': _fcmToken,
        'assigned': 'false',
      },
      SetOptions(merge: true),
    );
  }

  Future<Map<String, dynamic>> fetchUserDetails(String phoneNumber) async {
    DocumentSnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore
        .instance
        .collection('Profiles')
        .doc(phoneNumber)
        .get();

    return snapshot.data()!;
  }

  Future<bool> checkIfNewUser(String phoneNumber) async {
    DocumentSnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore
        .instance
        .collection('Profiles')
        .doc(phoneNumber)
        .get();

    return !snapshot.exists;
  }

  Future<void> verifyOTP() async {
    setState(() {
      isVerifyingOTP =
          true; // Set isVerifyingOTP to true when verifying OTP starts
    });
    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: widget.verificationId,
        smsCode: otppin,
      );
      await FirebaseAuth.instance.signInWithCredential(credential);

      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        bool isNewUser = await checkIfNewUser(user.phoneNumber!);

        if (isNewUser) {
          await saveUserDetails(user.phoneNumber!);
          if (widget.isCaretaker) {
            Navigator.of(context).pushReplacement(
              ScaleTransitionRoute(
                builder: (context) => CaretakerHomeScreen(),
              ),
            );
          } else {
            Navigator.of(context).pushReplacement(
              ScaleTransitionRoute(
                builder: (context) => HomeScreen(),
              ),
            );
          }
        } else {
          Map<String, dynamic> userDetails =
              await fetchUserDetails(user.phoneNumber!);
          bool isCaretaker = userDetails['isCaretaker'];
          await FirebaseFirestore.instance
              .collection('Profiles')
              .doc(user.phoneNumber)
              .set(
            {
              'token': _fcmToken,
              'assigned': 'false',
            },
            SetOptions(merge: true),
          );
          if (isCaretaker) {
            Navigator.of(context).pushReplacement(
              ScaleTransitionRoute(
                builder: (context) => CaretakerHomeScreen(),
              ),
            );
          } else {
            Navigator.of(context).pushReplacement(
              ScaleTransitionRoute(
                builder: (context) => HomeScreen(),
              ),
            );
          }
        }
      }
    } catch (e) {
      showSnackBarText("OTP verification failed. Please try again.");
    } finally {
      setState(() {
        isVerifyingOTP =
            false; // Reset isVerifyingOTP after OTP verification completes
      });
    }
  }

  void enableResendButton() {
    if (mounted) {
      setState(() {
        isResendEnabled = false;
      });

      _resendTimer = Timer.periodic(Duration(seconds: 1), (timer) {
        if (mounted) {
          if (resendTimeout > 0) {
            setState(() {
              resendTimeout -= 1;
            });
          } else {
            _resendTimer.cancel(); // Cancel the timer
            if (mounted) {
              setState(() {
                isResendEnabled = true; // Enable resend button after timeout
              });
            }
          }
        } else {
          _resendTimer
              .cancel(); // Cancel the timer if the widget is not mounted
        }
      });
    }
  }

  @override
  void dispose() {
    _resendTimer.cancel();
    super.dispose();
  }

  void resendOTP() async {
    setState(() {
      isResendingOTP = true; // Set flag to indicate resend OTP in progress
    });

    try {
      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: widget.phoneNumber,
        timeout: const Duration(seconds: 60),
        verificationCompleted: (PhoneAuthCredential credential) {
          // Auto verification
          showSnackBarText("Auto-verification completed");
        },
        verificationFailed: (FirebaseAuthException e) {
          showSnackBarText("Auto-verification failed. Please try again.");
        },
        codeSent: (String verificationId, int? ResendToken) {
          showSnackBarText("OTP resent");
          // Update verification ID
          setState(() {
            widget.verificationId = verificationId;
            otppin = ""; // Clear previous OTP
            resendTimeout = 60; // Reset the timeout
            isResendEnabled = false; // Disable resend button
          });
          enableResendButton(); // Enable resend button after timeout
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          // Auto-retrieval timeout
          showSnackBarText("Timeout. Please try again.");
        },
      );
    } catch (e) {
      showSnackBarText("Error resending OTP. Please try again.");
    } finally {
      setState(() {
        isResendingOTP = false; // Reset the resend OTP progress flag
      });
    }
  }

  Color blue = const Color(0xff8cccff);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Serene Life",
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/elder-removebg-preview.png',
                    height: 200,
                    width: 200,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "OTP Verification",
                    style: TextStyle(
                      fontFamily:
                          'Montserrat', // Specify the desired font family
                      color: Color.fromARGB(255, 8, 0, 0),
                      fontWeight: FontWeight.bold,
                      fontSize: MediaQuery.of(context).size.width / 12,
                    ),
                  ),
                  Text(
                    "Enter the code sent to ${widget.phoneNumber}",
                    style: TextStyle(
                      fontFamily:
                          'Montserrat', // Specify the desired font family
                      color: Color.fromARGB(255, 10, 0, 0),
                      fontWeight: FontWeight.bold,
                      fontSize: MediaQuery.of(context).size.width / 25,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: MediaQuery.of(context).size.width / 12),
              child: PinCodeTextField(
                appContext: context,
                length: 6,
                onChanged: (value) {
                  setState(() {
                    otppin = value;
                  });
                },
                pinTheme: PinTheme(
                  activeColor: blue,
                  selectedColor: blue,
                  inactiveColor: Colors.black26,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Resend OTP in ",
                  style: TextStyle(fontSize: 16),
                ),
                Text(
                  "${resendTimeout}s",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: (isResendEnabled && !isResendingOTP)
                  ? () {
                      setState(() {
                        isResendingOTP = true;
                      });
                      resendOTP();
                    }
                  : null,
              child: Container(
                decoration: BoxDecoration(
                  color: isResendEnabled && !isResendingOTP
                      ? Colors.blue // Adjust color as needed
                      : Colors.grey,
                  borderRadius: BorderRadius.circular(50),
                ),
                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 25),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (isResendingOTP)
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      ),
                    SizedBox(width: isResendingOTP ? 10 : 0),
                    Text(
                      "Resend",
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
            const SizedBox(height: 40),
            GestureDetector(
              onTap: (isVerifyingOTP || resendTimeout <= 0)
                  ? null
                  : () {
                      if (otppin.length == 6) {
                        setState(() {
                          isSubmitClicked = true;
                        });
                        verifyOTP();
                      } else {
                        showSnackBarText("Enter OTP correctly");
                      }
                    },
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.blue, // Adjust color as needed
                  borderRadius: BorderRadius.circular(50),
                ),
                padding: EdgeInsets.symmetric(vertical: 13, horizontal: 50),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (isVerifyingOTP)
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      ),
                    SizedBox(width: isVerifyingOTP ? 10 : 0),
                    Text(
                      "Submit OTP",
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
          ],
        ),
      ),
    );
  }

  void showSnackBarText(String text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(text),
      ),
    );
  }
}
