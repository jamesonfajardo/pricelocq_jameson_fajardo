import 'dart:async';

import 'package:google_maps_flutter/google_maps_flutter.dart';

GoogleMap googleMapWidget({
  mapController,
  initialLatitude,
  initialLongitude,
  onMapCreated,
}) {
  Completer<GoogleMapController> mapController = Completer();
  return GoogleMap(
    myLocationEnabled: true,
    myLocationButtonEnabled: true,
    initialCameraPosition: CameraPosition(
      target: LatLng(initialLatitude, initialLongitude),
      zoom: 18,
    ),
    onMapCreated: (GoogleMapController controller) {
      mapController.complete(controller);

      onMapCreated();

      // setState(() {
      //   isMapLoaded = true;
      // });
    },
  );
}
