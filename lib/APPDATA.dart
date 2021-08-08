// repository of app state
// state management used: provider

import 'package:flutter/material.dart';

class APPDATA extends ChangeNotifier {
  String debugString = 'debug string from within provider';

  // Login Page
  String? mobileNo;
  String? password;
  bool isLoginBtnDisabled = true;
  String? accessToken;

  void update(property, value) {
    switch (property) {
      case 'debugString':
        debugString = value;
        break;
      case 'mobileNo':
        mobileNo = value;
        break;
      case 'password':
        password = value;
        break;
      case 'isLoginBtnDisabled':
        isLoginBtnDisabled = value;
        break;
      case 'accessToken':
        accessToken = value;
        break;
    }
    notifyListeners();
  }
}
