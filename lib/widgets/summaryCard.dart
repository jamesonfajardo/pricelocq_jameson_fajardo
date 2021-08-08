import 'package:flutter/material.dart';

class SummaryCard extends StatelessWidget {
  SummaryCard({
    this.address,
    this.branchName,
    this.distanceBetween,
    // this.myLatitude,
    // this.myLongitude,
    // this.destinationLatitude,
    // this.destinationLonitude,
  });

  final String? address;
  final double? distanceBetween;
  final String? branchName;

  // final double? myLatitude;
  // final double? myLongitude;
  // final double? destinationLatitude;
  // final double? destinationLonitude;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            branchName ?? 'branchName',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 4),
          Container(
            child: Text(
              address ?? 'address goes here',
              style: TextStyle(
                fontSize: 12,
              ),
            ),
          ),
          SizedBox(height: 32),
          Text(
            '${distanceBetween!.toInt()} km away',
            style: TextStyle(
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
