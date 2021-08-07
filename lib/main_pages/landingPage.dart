import 'dart:convert';

import 'package:flutter/material.dart';
import 'dart:async';

// widgets
import '../widgets/dynamicAppBar.dart';
import '../widgets/radioTile.dart';

// controller
import '../controller/locationController.dart';
import '../controller/apiController.dart';

// external packages
import 'package:google_maps_flutter/google_maps_flutter.dart';

// env
import '../env.dart';

class LandingPage extends StatefulWidget {
  LandingPage({this.accessToken});

  final String? accessToken;

  @override
  _LandingPageState createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  // bappbar toggler
  bool isUserSearching = false;
  // geoloc var
  double myLatitude = 0;
  double myLongitude = 0;
  // googlemap var
  bool isMapLoaded = false;
  double destinationLat = 0;
  double destinationLon = 0;
  // api data var
  dynamic stationData;
  String? stationDataStatus;
  int? stationDataStatusCode;
  // radio btn var
  int? groupValue;

  void toggleSearch() {
    setState(() {
      if (!isUserSearching) {
        isUserSearching = true;
      } else {
        isUserSearching = false;
      }
    });
  }

  // ! GEOLOCATOR HANDLER
  void locationControllerInitialize() async {
    LocationController locationController =
        LocationController(context: context);
    var position = await locationController.initStateGetCurrentLocation();

    setState(() {
      myLatitude = position.latitude;
      myLongitude = position.longitude;
    });
  }

  // ! GOOGLE MAPS SCRIPT
  Completer<GoogleMapController> _controller = Completer();

  // ! SEAOIL STATIONS
  void getStationData() async {
    var response = await ApiController.getStationCoords(
      url: kStationEndpoint,
      accessKey: widget.accessToken,
    );

    setState(() {
      stationData = jsonDecode(response.body)['data'];
      stationDataStatus = jsonDecode(response.body)['status'];
      stationDataStatusCode = response.statusCode;
    });
  }

  @override
  void initState() {
    super.initState();
    print('init state activate');
    locationControllerInitialize();
    getStationData();
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      // disables resizing of window when keboard is present
      resizeToAvoidBottomInset: false,
      // toggle textfield
      // ! ================== APP BAR ==================
      appBar: dynamicAppBar(
        isUserSearching: isUserSearching,
        iconTapCallback: toggleSearch,
        textFieldCallback: (value) {
          print(value);
        },
      ),
      // ! ================== APP BODY ==================
      body: myLatitude == 0 || myLongitude == 0
          ? Center(child: Text('loading google map'))
          : SafeArea(
              child: GoogleMap(
                myLocationEnabled: true,
                myLocationButtonEnabled: true,
                initialCameraPosition: CameraPosition(
                  target: LatLng(myLatitude, myLongitude),
                  zoom: 18,
                ),
                onMapCreated: (GoogleMapController controller) {
                  _controller.complete(controller);

                  setState(() {
                    isMapLoaded = true;
                  });
                },
              ),
            ),
      // ! ================== BOTTOM SHEET ==================
      bottomSheet: Container(
        padding: EdgeInsets.symmetric(
          horizontal: 24,
          vertical: 8,
        ),
        height: screenHeight / (isUserSearching == false ? 3 : 1),
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // ! nearby stations
            Container(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Nearby Stations'),
                  TextButton(
                    // ! change map position
                    onPressed: destinationLat == 0 || destinationLat == 0
                        ? null
                        : () async {
                            final GoogleMapController controller =
                                await _controller.future;
                            controller.animateCamera(
                              CameraUpdate.newCameraPosition(
                                CameraPosition(
                                  target:
                                      LatLng(destinationLat, destinationLon),
                                  zoom: 18,
                                ),
                              ),
                            );
                          },
                    child: Text('Done'),
                  )
                ],
              ),
            ),
            // ! station data
            Expanded(
              child: SafeArea(
                child: ListView(
                  children: stationData == null || isMapLoaded == false
                      ? [Center(child: Text('loading Data'))]
                      : List.generate(
                          stationData.length,
                          (index) {
                            // return Text('${stationData[index]['id']}');
                            return RadioTile(
                              value: stationData[index]['id'],
                              groupValue: groupValue,
                              callback: (val) {
                                setState(() {
                                  groupValue = val;
                                  destinationLon =
                                      double.parse(stationData[index]['lng']);
                                  destinationLat =
                                      double.parse(stationData[index]['lat']);
                                });
                              },
                              branchName:
                                  'SEAOIL ${stationData[index]['area']} - ${stationData[index]['province']}',
                              myLatitude: myLatitude,
                              myLongitude: myLongitude,
                              destinationLatitude:
                                  double.parse(stationData[index]['lat']),
                              destinationLonitude:
                                  double.parse(stationData[index]['lng']),
                            );
                          },
                        ),
                ),
              ),
            )
          ],
        ),
        // bottom sheet style
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 5,
              blurRadius: 7,
              offset: Offset(0, 3), // changes position of shadow
            ),
          ],
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(25),
            topRight: Radius.circular(25),
          ),
        ),
      ),
    );
  }
}
