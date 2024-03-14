// ignore_for_file: prefer_const_constructors, prefer_interpolation_to_compose_strings, non_constant_identifier_names

import 'package:Serene_Life/Screens/authentication/otpscreen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:Serene_Life/Screens/Elder_Screens/Homescreen.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  TextEditingController phoneController = TextEditingController();
  double screenHeight = 0;
  double screenWidth = 0;
  double bottom = 0;
  String countrydial = "+91";
  Color blue = const Color(0xff8cccff);
  bool isSendingOtp = false;
  bool isCaretaker = false; // Added radio button state

  @override
  Widget build(BuildContext context) {
    screenHeight = MediaQuery.of(context).size.height;
    screenWidth = MediaQuery.of(context).size.width;
    bottom = MediaQuery.of(context).viewInsets.bottom;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Serene Life",
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: SizedBox(
          height: screenHeight,
          width: screenWidth,
          child: Stack(
            children: [
              Align(
                child: Padding(
                  padding: const EdgeInsets.only(top: 60),
                  child: Column(
                    children: [
                      Image.asset(
                        'assets/elder-removebg-preview.png',
                        height: 250,
                        width: 250,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        "Phone Number",
                        style: TextStyle(
                          color: Color.fromARGB(255, 8, 0, 0),
                          fontWeight: FontWeight.bold,
                          fontSize: screenWidth / 15,
                        ),
                      ),
                      Text(
                        "Verification",
                        style: TextStyle(
                          color: Color.fromARGB(255, 8, 0, 0),
                          fontWeight: FontWeight.bold,
                          fontSize: screenWidth / 15,
                        ),
                      ),
                      SizedBox(height: 25),
                      Text(
                        "Enter the number to get verified",
                        style: TextStyle(
                          color: Color.fromARGB(255, 10, 0, 0),
                          fontWeight: FontWeight.normal,
                          fontSize: screenWidth / 27,
                        ),
                      ),
                      SizedBox(height: 45),
                      Container(
                        margin: EdgeInsets.only(left: 20, right: 20),
                        child: IntlPhoneField(
                          controller: phoneController,
                          showCountryFlag: false,
                          showDropdownIcon: false,
                          initialCountryCode: 'IN',
                          initialValue: countrydial,
                          onCountryChanged: (country) {
                            setState(() {
                              countrydial = "+" + country.dialCode;
                            });
                          },
                          decoration: InputDecoration(
                            hintText: "Enter phone number",
                            hintStyle: TextStyle(
                              color: Colors.grey,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                      Row(
                        children: [
                          Radio(
                            value: true,
                            groupValue: isCaretaker,
                            onChanged: (value) {
                              setState(() {
                                isCaretaker = value as bool;
                              });
                            },
                          ),
                          Text('Caretaker'),
                          SizedBox(width: 20),
                          Radio(
                            value: false,
                            groupValue: isCaretaker,
                            onChanged: (value) {
                              setState(() {
                                isCaretaker = value as bool;
                              });
                            },
                          ),
                          Text('Not a Caretaker'),
                        ],
                      ),
                      GestureDetector(
                        onTap: () {
                          if (phoneController.text.isEmpty) {
                            showSnackBarText("Phone number is still empty");
                          } else {
                            // Set loading state
                            setState(() {
                              isSendingOtp = true;
                            });

                            // Perform the action
                            verifyPhone(countrydial + phoneController.text);
                          }
                        },
                        child: Container(
                          height: 50,
                          width: screenWidth / 1.5,
                          margin: EdgeInsets.only(bottom: screenHeight / 10),
                          decoration: BoxDecoration(
                            color: blue,
                            borderRadius: BorderRadius.circular(50),
                          ),
                          child: Center(
                            child: isSendingOtp
                                ? CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white),
                                  )
                                : Text(
                                    "Send OTP",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 1.5,
                                      fontSize: 18,
                                    ),
                                  ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> verifyPhone(String number) async {
    try {
      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: number,
        timeout: const Duration(seconds: 61),
        verificationCompleted: (PhoneAuthCredential credential) {
          showSnackBarText("Successfully Logged in");
        },
        verificationFailed: (FirebaseAuthException e) {
          showSnackBarText(e.toString());
          setState(() {
            isSendingOtp = false;
          });
        },
        codeSent: (String verificationId, int? ResendToken) {
          showSnackBarText("OTP sent");
          // Reset loading state
          setState(() {
            isSendingOtp = false;
          });

          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => OTPScreen(
                verificationId: verificationId,
                phoneNumber: countrydial + phoneController.text,
                isCaretaker: isCaretaker,
                onVerificationComplete: () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (context) => HomeScreen(),
                    ),
                  );
                },
              ),
            ),
          );
        },
        codeAutoRetrievalTimeout: (String verificationId) {},
      );
    } catch (e) {
      showSnackBarText(e.toString());
      setState(() {
        isSendingOtp = false;
      });
    }
  }
  void showSnackBarText(String text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(text),
      ),
    );
  }
}
