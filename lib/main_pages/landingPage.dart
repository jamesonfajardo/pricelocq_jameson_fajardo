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
  // appbar toggler
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
  dynamic stationMap = [];
  String? apiStatusMessage;
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

  // ! GOOGLE MAPS SCRIPT
  Completer<GoogleMapController> _controller = Completer();

  // change map location
  changeMapLocation({index, updatedValue}) async {
    setState(() {
      groupValue = updatedValue;
    });
    // update map position
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: LatLng(
            double.parse(stationData[index]['lat']),
            double.parse(stationData[index]['lng']),
          ),
          zoom: 19,
        ),
      ),
    );
  }

  // ! COMBINED METHODS
  void initializeLandingPageData() async {
    // geolocator
    LocationController locationController =
        LocationController(context: context);
    var position = await locationController.initStateGetCurrentLocation();

    // sea oil
    var response = await ApiController.getStationCoords(
      url: kStationEndpoint,
      accessKey: widget.accessToken,
      /*
      ** try to deliberately send an invalid accessToken to see how the
      ** app respond to failed api requests
      ** replace widget.accessToken with an invalid token to test
      */
    );

    // create sorted map
    var sortedMap = [];

    /*
    ** if status code is an error type, don't generate anything
    ** if the script doesn't generate anything, it will ping the
    ** app that there's an error and show the appropriate error message
    */
    if (response.statusCode == 200) {
      stationData = jsonDecode(response.body)['data'];

      List.generate(stationData.length, (index) {
        sortedMap.add({
          'id': stationData[index]['id'],
          'area': stationData[index]['area'],
          'city': stationData[index]['city'],
          'province': stationData[index]['province'],
          'address': stationData[index]['address'],
          'branchLat': stationData[index]['lat'],
          'branchLon': stationData[index]['lng'],
          'distanceFromMe': LocationController.distanceBetweenInKM(
            startLatitude: position.latitude,
            startLongitude: position.longitude,
            endLatitude: double.parse(stationData[index]['lat']),
            endLongitude: double.parse(stationData[index]['lng']),
          ),
        });
      });

      sortedMap
          .sort((a, b) => a["distanceFromMe"].compareTo(b["distanceFromMe"]));
    }

    setState(() {
      // geolocator
      myLatitude = position.latitude;
      myLongitude = position.longitude;

      // seaoil - set api status
      if (response.statusCode != 200)
        apiStatusMessage = 'Error fetching station data';

      // complete map data
      stationMap = sortedMap;
    });
  }

  @override
  void initState() {
    super.initState();
    initializeLandingPageData();
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
                  zoom: 19,
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
        // if user is searching, make the bottomsheet fullscreen
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
                        : () => print('test'),
                    child: Text('Done'),
                  )
                ],
              ),
            ),
            // ! station data
            Expanded(
              child: SafeArea(
                child: stationMap.isEmpty || isMapLoaded == false
                    ? Center(child: Text(apiStatusMessage ?? 'Loading Data'))
                    : ListView(
                        children: List.generate(
                          stationMap.length,
                          (index) {
                            return RadioTile(
                              value: stationMap[index]['id'],
                              groupValue: groupValue,
                              tileCallback: () {
                                changeMapLocation(
                                  index: index,
                                  updatedValue: stationMap[index]['id'],
                                );
                              },
                              radioCallback: (radioValue) {
                                changeMapLocation(
                                  index: index,
                                  updatedValue: radioValue,
                                );
                              },
                              branchName:
                                  'SEAOIL ${stationMap[index]['province']} - ${stationMap[index]['city']}',
                              distanceBetween:
                                  '${stationMap[index]['distanceFromMe'].toInt()}',
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
