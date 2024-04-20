// import 'package:flutter/material.dart';
// import 'package:location/location.dart';
// import 'package:url_launcher/url_launcher.dart';

// class LocationShareScreen extends StatefulWidget {
//   @override
//   _LocationShareScreenState createState() => _LocationShareScreenState();
// }

// class _LocationShareScreenState extends State<LocationShareScreen> {
//   LocationData? _currentLocation;
//   Location location = Location();

//   @override
//   void initState() {
//     super.initState();
//     _getLocation();
//   }

//   Future<void> _getLocation() async {
//     try {
//       final LocationData locationData = await location.getLocation();
//       setState(() {
//         _currentLocation = locationData;
//       });
//     } catch (e) {
//       print('Error getting location: $e');
//     }
//   }

//   Future<void> _shareLocation() async {
//     if (_currentLocation != null) {
//       final String latitude = _currentLocation!.latitude.toString();
//       final String longitude = _currentLocation!.longitude.toString();
//       final Uri url = Uri.parse('https://www.google.com/maps?q=$latitude,$longitude');
//       if (await canLaunchUrl(url)) {
//         await launchUrl(url);
//       } else {
//         print('Could not launch $url');
//       }
//     } else {
//       print('Location data not available');
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Location Share'),
//       ),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             if (_currentLocation != null)
//               Text('Latitude: ${_currentLocation!.latitude}, Longitude: ${_currentLocation!.longitude}'),
//             SizedBox(height: 20),
//             ElevatedButton(
//               onPressed: _shareLocation,
//               child: Text('Share Location'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';

class LocationView extends StatefulWidget {
  @override
  _LocationViewState createState() => _LocationViewState();
}

class _LocationViewState extends State<LocationView> {
  String _locationMessage = '';

  void fetchLocation() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      // If permission is denied, request permission again
      permission = await Geolocator.requestPermission();
      if (permission != LocationPermission.denied) {
        // If permission is granted after requesting, fetch location
        getLocation();
      } else {
        setState(() {
          _locationMessage = 'Location permission denied.';
        });
      }
    } else {
      // If permission is already granted, fetch location
      getLocation();
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

      // Launch maps with the obtained coordinates
      launchMaps(position.latitude, position.longitude);
    } catch (e) {
      setState(() {
        _locationMessage = 'Could not fetch location: $e';
      });
    }
  }

  void launchMaps(double latitude, double longitude) async {
    String googleMapsUrl = 'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude';
    final Uri url = Uri.parse(googleMapsUrl);

    try {
      await launchUrl(url);
    } catch(e) {
      setState(() {
        _locationMessage = 'Could not launch maps-$e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Location Demo'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: () {
                fetchLocation();
              },
              child: Text('Fetch Location'),
            ),
            SizedBox(height: 20),
            Text(_locationMessage),
          ],
        ),
      ),
    );
  }
}
