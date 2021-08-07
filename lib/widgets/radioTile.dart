import 'package:flutter/material.dart';
import '../controller/locationController.dart';

class RadioTile extends StatelessWidget {
  RadioTile({
    this.value,
    this.groupValue,
    this.callback,
    this.branchName,
    this.myLatitude,
    this.myLongitude,
    this.destinationLatitude,
    this.destinationLonitude,
  });

  final int? value;
  final int? groupValue;
  final ValueChanged? callback;
  final String? branchName;

  final double? myLatitude;
  final double? myLongitude;
  final double? destinationLatitude;
  final double? destinationLonitude;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              branchName ?? 'branchName',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 4),
            Text(
              '${LocationController.distanceBetweenInKM(
                startLatitude: myLatitude,
                startLongitude: myLongitude,
                endLatitude: destinationLatitude,
                endLongitude: destinationLonitude,
              ).toStringAsFixed(1)} km',
              style: TextStyle(
                fontSize: 10,
              ),
            ),
          ],
        ),
        Radio(
          value: value ?? -2,
          groupValue: groupValue ?? -1,
          onChanged: callback ?? (val) => print('callback goes here'),
        ),
      ],
    );
  }
}
