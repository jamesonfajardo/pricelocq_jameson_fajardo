import 'dart:convert';

import 'package:flutter/material.dart';
import 'dart:async';

// APP DATA
import '../APPDATA.dart';
import 'package:provider/provider.dart';

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
  // LandingPage({this.accessToken});

  // final String? accessToken;

  @override
  _LandingPageState createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  // appbar toggler
  bool isUserSearching = false; // used to toggle elements dependent on search
  // geoloc var
  double myLatitude = 0;
  double myLongitude = 0;
  // googlemap var
  bool isMapLoaded = false; // used to render elements after google map loads
  // api data var
  dynamic stationData; // raw api data
  dynamic stationMap = []; // used for rendering sorted data
  String? apiStatusMessage; // used for error handling
  // search related variables
  dynamic foundStations = []; // used for rendering search results
  int? selectedStationId; // used to fetch station specific info
  int? selectedStationIndex; // used to fetch station specific info
  String? textfieldValue = ''; // used to fetch station specific info
  bool showStationSummary = false; // render station summary based on T or F
  // radio btn var
  int? groupValue;

  // ! GOOGLE MAPS SCRIPT START ---------
  Completer<GoogleMapController> _controller = Completer();

  // change map location
  changeMapLocation({jsonBody, index, updatedValue}) async {
    setState(() {
      groupValue = updatedValue;
    });
    // update map position
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: LatLng(
            double.parse(jsonBody[index]['lat']),
            double.parse(jsonBody[index]['lng']),
          ),
          zoom: 19,
        ),
      ),
    );
  }

  // return to my location
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
  // ! GOOGLE MAPS SCRIPT END ---------

  // ! SEARCH RELATED FUNCTIONS START ------------
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

    setState(() {
      foundStations = results;
    });
  }

  // reset search related variables
  resetSearch() {
    setState(() {
      groupValue = -9999;
      showStationSummary = false;
      selectedStationId = null;
      selectedStationIndex = null;
      textfieldValue = '';
    });
  }
  // ! SEARCH RELATED FUNCTIONS END ------------

  // ! FETCH AND PROCESS API DATA START ------------
  void initializeLandingPageData() async {
    // geolocator
    LocationController locationController =
        LocationController(context: context);
    var position = await locationController.initStateGetCurrentLocation();

    // sea oil
    var response = await ApiController.getStationCoords(
      url: kStationEndpoint,
      accessKey: Provider.of<APPDATA>(context, listen: false).accessToken,
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
          'lat': stationData[index]['lat'],
          'lng': stationData[index]['lng'],
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
  // ! FETCH AND PROCESS API DATA END ------------

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
      // ! ================== APP BAR ==================
      appBar: dynamicAppBar(
        isUserSearching: isUserSearching,
        iconTapCallback: () {
          setState(() {
            // toggle textfield
            if (!isUserSearching) {
              isUserSearching = true;
            } else {
              isUserSearching = false;
              if (selectedStationIndex != null && textfieldValue != '') {
                showStationSummary = true;
                /*
                ** if textfield is not empty, and a result is selected,
                ** move to the said location on pressing close search btn
                */
                changeMapLocation(
                  jsonBody: stationData,
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // ! bottomsheet header
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
            // ! station data / bottomsheet body
            // show the station complete info in this widget
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
                // show sorted station data
                : Expanded(
                    // use safe area to avoid OS interfaces like notch, etc.
                    child: SafeArea(
                      child: stationMap.isEmpty || isMapLoaded == false
                          ? Center(
                              // render when app is still loading
                              child: Text(apiStatusMessage ?? 'Loading Data'),
                            )
                          : foundStations.length > 0
                              // render sorted data
                              ? ListView(
                                  children: List.generate(
                                    foundStations.length,
                                    (index) {
                                      return RadioTile(
                                        value: foundStations[index]['id'],
                                        groupValue: groupValue,
                                        tileCallback: () {
                                          changeMapLocation(
                                            jsonBody: stationMap,
                                            index: index,
                                            updatedValue: foundStations[index]
                                                ['id'],
                                          );
                                          if (textfieldValue != '') {
                                            // assign particular values when clicked
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
                                            jsonBody: stationMap,
                                            index: index,
                                            updatedValue: radioValue,
                                          );
                                          if (textfieldValue != '') {
                                            // assign particular values when clicked
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
                                  // render when search has no results
                                  child: Text('No Results Found'),
                                ),
                    ),
                  )
          ],
        ),
        // ! BOTTOMSHEET STYLE
        padding: EdgeInsets.symmetric(
          horizontal: 24,
          vertical: 8,
        ),
        // if user is searching, make the bottomsheet fullscreen
        height: screenHeight / (isUserSearching == false ? 3 : 1),
        width: double.infinity,
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
