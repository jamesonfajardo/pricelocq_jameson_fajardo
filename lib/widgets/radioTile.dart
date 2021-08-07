import 'package:flutter/material.dart';

class RadioTile extends StatelessWidget {
  RadioTile({
    this.value,
    this.groupValue,
    this.radioCallback,
    this.tileCallback,
    this.branchName,
    this.distanceBetween,
    // this.myLatitude,
    // this.myLongitude,
    // this.destinationLatitude,
    // this.destinationLonitude,
  });

  final String? distanceBetween;
  final int? value;
  final int? groupValue;
  final ValueChanged? radioCallback;
  final void Function()? tileCallback;
  final String? branchName;

  // final double? myLatitude;
  // final double? myLongitude;
  // final double? destinationLatitude;
  // final double? destinationLonitude;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: tileCallback ?? () => print('object'),
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        title: Column(
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
              '$distanceBetween km away from you',
              style: TextStyle(
                fontSize: 10,
              ),
            ),
          ],
        ),
        trailing: Radio(
          value: value ?? -2,
          groupValue: groupValue ?? -1,
          onChanged: radioCallback ?? (val) => print('callback goes here'),
        ),
      ),
    );
  }
}
