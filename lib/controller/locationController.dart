import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:io';
import '../util/dialogManager.dart';

class LocationController {
  LocationController({this.context});
  final BuildContext? context;

  Future initStateGetCurrentLocation() async {
    LocationPermission locationPermission = await Geolocator.checkPermission();

    // check if location service is disabled or denied
    if (!await Geolocator.isLocationServiceEnabled() ||
        locationPermission == LocationPermission.deniedForever) {
      // show alert dialog
      /*
      ** dialogManager can also hold the lat lon values
      ** upon navigator.pop
      */
      return DialogManager(this.context).showAlert(
        isCupertino: Platform.isAndroid ? false : true,
        title: 'Location is disabled',
        message: 'Please enable your location services then press Retry',
        additionalActions: [
          // open location settings
          TextButton(
            onPressed: () => Geolocator.openLocationSettings(),
            child: Text("Enable"),
          ),
          // recheck location permission
          TextButton(
            onPressed: () async {
              /*
              ** if location permission is enabled
              ** fetch lat and lon then close the dialogbox
              */
              if (await Geolocator.isLocationServiceEnabled()) {
                var position = await Geolocator.getCurrentPosition(
                    desiredAccuracy: LocationAccuracy.high);

                Navigator.pop(this.context!, position);
              }
            },
            child: Text("Retry"),
          ),
        ],
      );
    } else {
      var position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);

      // return lat lon values
      return position;
    }
  }

  static double distanceBetweenInKM({
    startLatitude,
    startLongitude,
    endLatitude,
    endLongitude,
  }) {
    double distanceInMeters = Geolocator.distanceBetween(
      startLatitude,
      startLongitude,
      endLatitude,
      endLongitude,
    );
    return (distanceInMeters / 1000);
  }
}
