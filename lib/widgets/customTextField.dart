// CustomTextField = created to accomodate the textfield design

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// const
import '../const/colors.dart';
import '../const/fonts.dart';

class CustomTextField extends StatelessWidget {
  CustomTextField({
    this.labelText,
    this.hintText,
    this.prefixIcon,
    this.callback,
    this.obscureText,
    this.keyboardType,
    this.inputFormatters,
  });

  final String? labelText;
  final String? hintText;
  final Widget? prefixIcon;
  final ValueChanged? callback;
  final bool? obscureText;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // container will hold the elements making up the widget
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8,
          ),
          // the widget is divided in to 2 parts,
          // the labelText and the textfield itself
          // so we use column
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                labelText ?? 'labelText',
                style: TextStyle(
                  color: kDarkBlue,
                  fontWeight: FontWeight.w800,
                ),
              ),
              SizedBox(height: 8), // sizedBox = spacer
              TextField(
                keyboardType: keyboardType,
                inputFormatters: inputFormatters,
                maxLength: 10,
                obscureText: obscureText ?? false,
                style: kDefaultFontSize,
                onChanged: callback,
                decoration: InputDecoration(
                  counter: SizedBox.shrink(),
                  prefixIcon: prefixIcon ?? Icon(Icons.add),
                  hintText: hintText ?? 'hintText',
                  fillColor: kLightBlue,
                  hintStyle: TextStyle(
                    color: kPlaceholder,
                  ),
                  border: OutlineInputBorder(
                    borderSide: BorderSide.none,
                    borderRadius: BorderRadius.all(
                      Radius.circular(12),
                    ),
                  ),
                  filled: true,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
