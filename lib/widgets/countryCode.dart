// CountryCode = a row of flag and phone number prefix
// for example: phFlag +63

import 'package:flutter/material.dart';

class CountryCode extends StatelessWidget {
  CountryCode({
    this.flagImage,
    this.countryCode,
  });

  final Widget? flagImage;
  final String? countryCode;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(width: 16),
        Container(
          width: 25,
          child: flagImage ??
              Image.asset('icons/flags/png/ph.png', package: 'country_icons'),
        ),
        SizedBox(width: 8),
        Text(countryCode ?? '+63'),
        SizedBox(width: 8),
      ],
    );
  }
}
