import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:geolocator/geolocator.dart';

import '../controller/locationController.dart';

void main() => runApp(Debug());

class Debug extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Google Maps Demo',
      home: MapSample(),
    );
  }
}

class MapSample extends StatefulWidget {
  @override
  State<MapSample> createState() => MapSampleState();
}

class MapSampleState extends State<MapSample> {
// ! GEOLOC
  double myLat = 0;
  double myLon = 0;

  void getLoc() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    setState(() {
      myLat = position.latitude;
      myLon = position.longitude;
    });
  }
// ! GEOLOC

// ! --------------------------

// ! GMAP
  Completer<GoogleMapController> _controller = Completer();

  Future<void> _goToTheLake() async {
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: LatLng(14.39764, 120.868896),
          zoom: 20,
        ),
      ),
    );
  }
// ! GMAP

// ! others

// ! others

  @override
  void initState() {
    super.initState();
    print('INIT STATE_____----------');
    getLoc();
  }

  @override
  Widget build(BuildContext context) {
    print('DISTANCE BETWEEN 2 POINTS');
    print(LocationController.distanceBetweenInKM(
      startLatitude: 14.46618,
      startLongitude: 121.0228717,
      endLatitude: 14.39764,
      endLongitude: 120.868896,
    ));

    print(myLat);
    print(myLon);
    return Scaffold(
      body: myLat == 0 || myLon == 0
          ? Center(child: Text('loading google map'))
          : SafeArea(
              child: GoogleMap(
                myLocationEnabled: true,
                myLocationButtonEnabled: true,
                zoomControlsEnabled: false,
                initialCameraPosition: CameraPosition(
                  target: LatLng(myLat, myLon),
                  zoom: 18,
                ),
                onMapCreated: (GoogleMapController controller) {
                  _controller.complete(controller);
                },
              ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _goToTheLake,
        label: Text('To the lake!'),
        icon: Icon(Icons.directions_boat),
      ),
    );
  }
}
