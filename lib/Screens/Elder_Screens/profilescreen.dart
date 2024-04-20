// ignore_for_file: avoid_print, library_prefixes, use_build_context_synchronously

import 'dart:io';

import 'package:Serene_Life/Screens/authentication/registration.dart'
    as RegistrationScreen;
import 'package:Serene_Life/Screens/styles/fields.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../Minor screens/pageroute.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  String? _selectedGender;
  XFile? _image;
  String? imageUrl;
  bool isSavingProfile = false;
  User? user = FirebaseAuth.instance.currentUser;
  final _formKey = GlobalKey<FormState>();


@override
void initState() {
  super.initState();
  // Fetch user profile data when the widget is first initialized
  fetchUserProfileData();
}

void fetchUserProfileData() {
  if (user != null) {
    FirebaseFirestore.instance
        .collection('Profiles')
        .doc(user!.phoneNumber)
        .get()
        .then((DocumentSnapshot snapshot) {
      if (snapshot.exists) {
        Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
        setState(() {
          _nameController.text = data['name'] ?? '';
          _emailController.text = data['email'] ?? '';
          _addressController.text = data['address'] ?? '';
          _ageController.text = data['age'] ?? '';
        });
      }
    }).catchError((error) {
      print('Error fetching user profile data: $error');
    });
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Serene Life",
          style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () async {
              await logoutAndNavigateToRegistration(context);
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  'User Profile',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                GestureDetector(
                  onTap: () {
                    _pickImage(ImageSource.gallery);
                  },
                  child: Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      _image != null
                          ? CircleAvatar(
                              radius: 70,
                              backgroundColor: Colors.blue,
                              child: ClipOval(
                                child: Image.file(
                                  File(_image!.path),
                                  width: 200,
                                  height: 200,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            )
                          : const CircleAvatar(
                              radius: 70,
                              backgroundColor: Colors.blue,
                              child: Icon(
                                Icons.camera_alt,
                                size: 70,
                                color: Colors.white,
                              ),
                            ),
                      GestureDetector(
                        onTap: () {
                          _pickImage(ImageSource.camera);
                        },
                        child: const CircleAvatar(
                          radius: 25,
                          backgroundColor: Colors.white,
                          child: Icon(
                            Icons.camera_alt,
                            size: 25,
                            color: Colors.blue,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                CustomTextField(
                  label: 'Name',
                  controller: _nameController,
                  keyboardType: TextInputType.text,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 18),
                CustomTextField(
                  label: 'Email',
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    } else if (!value.contains('@')) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 18),
                CustomTextField(
                  label: 'Address',
                  controller: _addressController,
                  keyboardType: TextInputType.text,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your address';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 18),
                CustomTextField(
                  label: 'Age',
                  controller: _ageController,
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your age';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 18),
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    labelText: 'Gender',
                    labelStyle: const TextStyle(fontSize: 16),
                    hintText: 'Select Gender',
                    hintStyle:
                        const TextStyle(fontSize: 14, color: Colors.grey),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: const BorderSide(color: Colors.blue),
                    ),
                  ),
                  value: _selectedGender,
                  onChanged: (String? value) {
                    setState(() {
                      _selectedGender = value;
                    });
                  },
                  items: <String>['Male', 'Female', 'Other']
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  validator: (value) {
                    if (value == null) {
                      return 'Please select your gender';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      if (_image != null) {
                        saveProfileDetails();
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Please select an image.'),
                          ),
                        );
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50),
                    ),
                    padding: const EdgeInsets.symmetric(
                        vertical: 14, horizontal: 60),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (isSavingProfile)
                        const SizedBox(
                          width: 20,
                          height: 40,
                          child: LinearProgressIndicator(
                            color: Colors.white,
                            backgroundColor: Color(0xff8cccff),
                          ),
                        ),
                      if (isSavingProfile) const SizedBox(width: 10),
                      Text(
                        isSavingProfile ? 'Saving...' : 'Submit',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.5,
                          fontSize: 18,
                        ),
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
  }

  Future<void> logoutAndNavigateToRegistration(BuildContext context) async {
    try {
      await _auth.signOut();
      Navigator.of(context).pushReplacement(
        ScaleTransitionRoute(
          builder: (context) => const RegistrationScreen.RegisterScreen(),
        ),
      );
    } catch (e) {
      print("Error during logout: $e");
    }
  }

  void saveProfileDetails() async {
    setState(() {
      isSavingProfile = true;
    });
    String name = _nameController.text;
    String email = _emailController.text;
    String address = _addressController.text;
    String age = _ageController.text;
    String gender = _selectedGender ?? '';
    String? phoneNumber;
    String? fcmToken;

    try {
      phoneNumber = user!.phoneNumber;
      fcmToken = await FirebaseMessaging.instance.getToken(); // Fetch FCM token
    } catch (e) {
      print('Invalid phone number format');
      return;
    }

    if (imageUrl == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select an image.'),
        ),
      );
      setState(() {
        isSavingProfile = false;
      });
      return;
    }

    if (fcmToken == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to retrieve FCM token.'),
        ),
      );
      setState(() {
        isSavingProfile = false;
      });
      return;
    }

    await FirebaseFirestore.instance
        .collection('Profiles')
        .doc(phoneNumber)
        .set(
      {
        'name': name,
        'email': email,
        'address': address,
        'age': age,
        'gender': gender,
        'imageUrl': imageUrl!,
        'token': fcmToken,
      },
      SetOptions(merge: true),
    ).then((value) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile saved successfully!'),
        ),
      );
      setState(() {
        isSavingProfile = false;
        _nameController.text = '';
        _emailController.text = '';
        _addressController.text = '';
        _ageController.text = '';
        _selectedGender = null;
        _image = null;
      });
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to save profile. Please try again.'),
        ),
      );
      setState(() {
        isSavingProfile = false;
      });
    });
  }

  Future<void> _pickImage(ImageSource source) async {
    final XFile? pickedImage = await ImagePicker().pickImage(source: source);

    if (pickedImage != null) {
      setState(() {
        _image = pickedImage;
      });

      Reference ref = FirebaseStorage.instance
          .ref()
          .child('profile_images')
          .child('${user!.uid}.jpg');
      UploadTask uploadTask = ref.putFile(File(_image!.path));

      uploadTask.then((res) {
        res.ref.getDownloadURL().then((downloadUrl) {
          setState(() {
            imageUrl = downloadUrl;
          });
        });
      }).catchError((err) {
        print("Failed to upload image: $err");
      });
    }
  }
}
