import 'dart:convert';

import 'package:flutter/material.dart';
import 'dart:async';

// widgets
import '../widgets/dynamicAppBar.dart';
import '../widgets/summaryCard.dart';
import '../widgets/radioTile.dart';

// controller
import '../controller/locationController.dart';
import '../controller/apiController.dart';

// external packages
import 'package:google_maps_flutter/google_maps_flutter.dart';

// util
import '../util/snackbarManager.dart';

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
  dynamic stationData; // for debugging purposes only
  dynamic stationMap = []; // ! single source of truth
  String? apiStatusMessage;
  // search related variables
  dynamic foundStations = [];
  int? selectedStationId;
  int? selectedStationIndex;
  String? textfieldValue = '';
  bool showStationSummary = false;
  // radio btn var
  int? groupValue;

  // ! GOOGLE MAPS SCRIPT ---------
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
            double.parse(stationMap[index]['branchLat']),
            double.parse(stationMap[index]['branchLon']),
          ),
          zoom: 19,
        ),
      ),
    );
  }

  // change map location on search select
  changeMapLocationOnSearch({index, updatedValue}) async {
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

  // return to your location
  backToMyLocation() async {
    // update map position
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: LatLng(
            myLatitude,
            myLongitude,
          ),
          zoom: 19,
        ),
      ),
    );
  }

  // reset search related variabled
  resetSearch() {
    setState(() {
      groupValue = -9999;
      showStationSummary = false;
      selectedStationId = null;
      selectedStationIndex = null;
      textfieldValue = '';
    });
  }
  // ! GOOGLE MAPS SCRIPT ---------

  // ! search station ------------
  void searchStation(keyword) {
    var results = [];
    if (keyword.isEmpty) {
      results = stationMap;
    } else {
      results = stationMap
          .where((station) =>
              station["address"].toLowerCase().contains(keyword.toLowerCase())
                  ? true
                  : false)
          .toList();
    }

    // print(results);

    setState(() {
      foundStations = results;
    });
  }
  // ! search station ------------

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
    List<Map<String, dynamic>> sortedMap = [];

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
          'index': index,
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
      foundStations = sortedMap;
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

// todo
    // print(selectedStationId);
    // print(stationData[selectedStationIndex]);
    // print('selectedStationId: $selectedStationId');
    // print('selectedStationIndex: $selectedStationIndex');
    // print('textfieldValue: $textfieldValue');
    // print('showStationSummary: $showStationSummary');
// todo

    return Scaffold(
      // disables resizing of window when keboard is present
      resizeToAvoidBottomInset: false,
      // toggle textfield
      // ! ================== APP BAR ==================
      appBar: dynamicAppBar(
        isUserSearching: isUserSearching,
        iconTapCallback: () {
          setState(() {
            if (!isUserSearching) {
              isUserSearching = true;
              // resetSearch();
            } else {
              isUserSearching = false;
              if (selectedStationIndex != null && textfieldValue != '') {
                showStationSummary = true;
                changeMapLocationOnSearch(
                  index: selectedStationIndex,
                  updatedValue: selectedStationId,
                );
              } else {
                textfieldValue = '';
                searchStation('');
              }
            }
          });
        },
        textFieldCallback: (value) {
          searchStation(value);
          setState(() {
            textfieldValue = value;
          });
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
                  !showStationSummary
                      ? Text('Nearby Stations')
                      : TextButton(
                          onPressed: () {
                            backToMyLocation();
                            resetSearch();
                            searchStation('');
                          },
                          child: Text('Back to list'),
                        ),
                  TextButton(
                    // ! change map position
                    onPressed: !showStationSummary
                        ? null
                        : () {
                            snackbarManager(context,
                                'There was no instruction on what to do with the Done button');
                          },
                    child: Text('Done'),
                  )
                ],
              ),
            ),
            // ! station data
            showStationSummary
                ? Expanded(
                    child: SummaryCard(
                      branchName:
                          'SEOIL ${stationData[selectedStationIndex]['province']} - ${stationData[selectedStationIndex]['city']}',
                      address: stationData[selectedStationIndex]['address'],
                      distanceBetween: LocationController.distanceBetweenInKM(
                        startLatitude: myLatitude,
                        startLongitude: myLongitude,
                        endLatitude: double.parse(
                            stationData[selectedStationIndex]['lat']),
                        endLongitude: double.parse(
                            stationData[selectedStationIndex]['lng']),
                      ),
                    ),
                  )
                : Expanded(
                    child: SafeArea(
                      child: stationMap.isEmpty || isMapLoaded == false
                          ? Center(
                              child: Text(apiStatusMessage ?? 'Loading Data'))
                          : foundStations.length > 0
                              ? ListView(
                                  children: List.generate(
                                    foundStations.length,
                                    (index) {
                                      return RadioTile(
                                        value: foundStations[index]['id'],
                                        groupValue: groupValue,
                                        tileCallback: () {
                                          changeMapLocation(
                                            index: index,
                                            updatedValue: foundStations[index]
                                                ['id'],
                                          );
                                          if (textfieldValue != '') {
                                            setState(() {
                                              selectedStationId =
                                                  foundStations[index]['id'];
                                              selectedStationIndex =
                                                  foundStations[index]['index'];
                                            });
                                          }
                                        },
                                        radioCallback: (radioValue) {
                                          changeMapLocation(
                                            index: index,
                                            updatedValue: radioValue,
                                          );
                                          if (textfieldValue != '') {
                                            setState(() {
                                              selectedStationId =
                                                  foundStations[index]['id'];
                                              selectedStationIndex =
                                                  foundStations[index]['index'];
                                            });
                                          }
                                        },
                                        branchName:
                                            'SEAOIL ${foundStations[index]['province']} - ${foundStations[index]['city']}',
                                        distanceBetween:
                                            '${foundStations[index]['distanceFromMe'].toInt()}',
                                      );
                                    },
                                  ),
                                )
                              : Center(
                                  child: Text('No Results Found'),
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
              color:
                  Colors.grey.withOpacity(isUserSearching == false ? 0.5 : 0),
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
