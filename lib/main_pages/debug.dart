import 'package:flutter/material.dart';

class Debug extends StatefulWidget {
  const Debug({Key? key}) : super(key: key);

  @override
  _DebugState createState() => _DebugState();
}

class _DebugState extends State<Debug> {
  List<Map<String, dynamic>> stationMap = [
    {
      'id': '226',
      'area': 'LUZON',
      'city': 'PARANAQUE',
      'province': 'METRO MANILA',
      'address':
          'Lot 4964-1-2-A-4-2 DR.A. SANTOS AVENUE, SAN ISIDRO, PARANAQUE CITY',
      'branchLat': '14.45525448',
      'branchLon': '121.0417243',
      'distanceFromMe': '2.366846533874309'
    },
    {
      'id': '7',
      'area': 'NCR',
      'city': 'PARANAQUE CITY',
      'province': 'METRO MANILA',
      'address':
          '8451 Dr. A. Santos Avenue Brgy. San Antonio, Sucat, Paranaque City',
      'branchLat': '14.455111',
      'branchLon': '121.04173',
      'distanceFromMe': '2.375633931453743'
    },
    {
      'id': '241',
      'area': 'METRO MANILA',
      'city': 'PARANAQUE',
      'province': 'METRO MANILA',
      'address': 'WEST SERVICE ROAD SAN DIONISIO MERVILLE PARANAQUE CITY',
      'branchLat': '14.49472425',
      'branchLon': '121.0423936',
      'distanceFromMe': '3.807507021293104'
    },
    {
      'id': 34,
      'area': 'NCR',
      'city': 'TAGUIG CITY',
      'province': 'METRO MANILA',
      'address': 'Cuasay corner MRT Avenue, Taguig City',
      'branchLat': '14.512974',
      'branchLon': '121.054882',
      'distanceFromMe': '6.244440930352944'
    },
  ];

  List<Map<String, dynamic>> foundStations = [];

  void searchStation(keyword) {
    List<Map<String, dynamic>> results = [];
    if (keyword.isEmpty) {
      results = stationMap;
    } else {
      results = stationMap
          .where((station) =>
              station["address"].toLowerCase().contains(keyword.toLowerCase()))
          .toList();
    }

    setState(() {
      foundStations = results;
    });
  }

  @override
  void initState() {
    super.initState();
    foundStations = stationMap;
  }

  @override
  Widget build(BuildContext context) {
    // ! ====================
    // searchStation('sucat');
    // print(stationMap[0]['address']);
    // print(stationMap);
    print(foundStations);
    // ! ====================
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            TextField(
              onChanged: (value) => searchStation(value),
              decoration: InputDecoration(
                  labelText: 'Search', suffixIcon: Icon(Icons.search)),
            ),
            Expanded(
              child: foundStations.length > 0
                  ? ListView.builder(
                      itemCount: foundStations.length,
                      itemBuilder: (context, index) {
                        return Card(
                          child: Text(
                              '$index. ${foundStations[index]['address']}'),
                        );
                      },
                    )
                  : Text('no results found'),
            ),
          ],
        ),
      ),
    );
  }
}

// Card(
//   child: Text('$index. ${foundStations[index]['address']}'),
// )
