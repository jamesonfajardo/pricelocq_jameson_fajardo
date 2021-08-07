import 'package:flutter/material.dart';

void snackbarManager(context, text) {
  final snackBar = SnackBar(
    content: Text(text),
    backgroundColor: Colors.pink,
    // behavior: SnackBarBehavior.floating,
    // margin: EdgeInsets.all(16),
    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
  );
  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}
