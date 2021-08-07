// PrimaryButton = the button for proceeding with major events

import 'package:flutter/material.dart';
import '../const/fonts.dart';

class PrimaryButton extends StatelessWidget {
  PrimaryButton({
    this.label,
    this.callback,
    this.disableButton,
  });

  final String? label;
  final VoidCallback? callback;
  final bool? disableButton;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.all(16),
      child: TextButton(
        onPressed:
            disableButton == true ? null : callback ?? () => print('callback'),
        child: Text(
          label ?? 'Button Label Goes Here',
          style: kDefaultFontSize.copyWith(
            color: Colors.white,
          ),
        ),
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            disableButton == true ? Color(0xffededed) : Color(0xff7539bd),
            disableButton == true ? Color(0xffededed) : Color(0xff5626ae),
          ],
        ),
      ),
    );
  }
}
