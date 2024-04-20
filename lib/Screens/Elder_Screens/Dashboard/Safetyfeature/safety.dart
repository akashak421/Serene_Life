import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:url_launcher/url_launcher.dart';

class SafetyfeatureScreen extends StatefulWidget {
  @override
  _SafetyfeatureScreenState createState() => _SafetyfeatureScreenState();
}

class _SafetyfeatureScreenState extends State<SafetyfeatureScreen> {
  String _locationMessage = '';
  final User? user = FirebaseAuth.instance.currentUser;
  late String phoneNumber;

  @override
  void initState() {
    super.initState();
    fetchdetails();
  }

  void fetchdetails() async {
    DocumentSnapshot userProfile = await FirebaseFirestore.instance
        .collection('Profiles')
        .doc(user!.phoneNumber)
        .get();
    phoneNumber = userProfile['partnerPhoneNumber'];
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Emergency Assistance'),
      ),
      body: Center(
        child: ElevatedButton.icon(
          onPressed: _shareLocationAndAlert,
          icon: Icon(Icons.announcement, size: 50),
          label: Text('Emergency'),
          style: ElevatedButton.styleFrom(
            padding: EdgeInsets.symmetric(vertical: 20, horizontal: 40),
          ),
        ),
      ),
    );
  }

  void _shareLocationAndAlert() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission != LocationPermission.denied) {
        getLocation();
      } else {
        setState(() {
          _locationMessage = 'Location permission denied.';
        });
      }
    } else {
      getLocation();
    }
  }

  void makePhoneCall() async {
    try {
      await FlutterPhoneDirectCaller.callNumber('8012750403');
    } catch (e) {
      setState(() {
        print(e);
      });
    }
  }

  Future launchMaps(double latitude, double longitude) async {
    String googleMapsUrl = 'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude';
    final Uri url = Uri.parse(googleMapsUrl);

    try {
      await launchUrl(url);
      makePhoneCall();
    } catch(e) {
      setState(() {
        _locationMessage = 'Could not launch maps-$e';
      });
    }
  }

  void getLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      setState(() {
        _locationMessage =
            'Latitude: ${position.latitude}, Longitude: ${position.longitude}';
      });

      await launchMaps(position.latitude, position.longitude);
    } catch (e) {
      setState(() {
        _locationMessage = 'Could not fetch location: $e';
      });
    }
  }
}
