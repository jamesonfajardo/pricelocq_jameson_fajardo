import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// main pages
import '../main_pages/landingPage.dart';

// env constants
import '../env.dart';

// widgets
import '../widgets/customTextField.dart';
import '../widgets/countryCode.dart';
import '../widgets/primaryButton.dart';

// controller
import '../controller/apiController.dart';
import 'dart:convert';

// util
import '../util/snackbarManager.dart';

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  ApiController apiController = ApiController();
  String? mobileNo;
  String? password;
  bool isBtnDisabled = true;

  void primaryButtonAvailability() {
    if (mobileNo == null ||
        password == null ||
        mobileNo == '' ||
        password == '') {
      isBtnDisabled = true;
    } else {
      isBtnDisabled = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // expanded to push the button downwards
            Expanded(
              flex: 1,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // mobile number
                  CustomTextField(
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    callback: (value) {
                      setState(() {
                        mobileNo = value;
                        /*
                        ** if mobile number and password is supplied
                        ** activate the 'Continue' button
                        ** else, disable it
                        */
                        primaryButtonAvailability();
                      });
                    },
                    labelText: 'Mobile No.',
                    hintText: '9123456789',
                    /* 
                    ** CountryCode = custom widget for showing country flag
                    ** and country prefix number
                    */
                    prefixIcon: CountryCode(
                      countryCode: '+63',
                      flagImage: Image.asset(
                        'icons/flags/png/ph.png',
                        package: 'country_icons',
                      ),
                    ),
                  ),
                  // password
                  CustomTextField(
                    callback: (value) {
                      setState(() {
                        password = value;
                        /*
                        ** if mobile number and password is supplied
                        ** activate the 'Continue' button
                        ** else, disable it
                        */
                        primaryButtonAvailability();
                      });
                    },
                    labelText: 'Password',
                    hintText: 'Password',
                    prefixIcon: Icon(
                      Icons.lock,
                      color: Colors.lightGreen,
                    ),
                    obscureText: true,
                  )
                ],
              ),
            ),

            // "Continue" button
            PrimaryButton(
              disableButton: isBtnDisabled,
              label: 'Continue',
              // ! POST
              // post data to endpoint
              callback: () async {
                var postData = await apiController.login(
                  url: kLoginEndpoint,
                  body: {"mobile": '0$mobileNo', "password": password},
                );
                var jsonBody = jsonDecode(postData.body);
                var statusCode = postData.statusCode;

                // if request succeeded
                if (statusCode == 200) {
                  // if login status is failed
                  if (jsonBody['status'] == 'failed') {
                    // snackbarManager = custom code for showing snackbars
                    snackbarManager(context, jsonBody['data']['message']);
                  } else if (jsonBody['status'] == 'success') {
                    // if login status is successful
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => LandingPage(
                          // pass the access token to the next page
                          accessToken: jsonBody['data']['accessToken'],
                        ),
                      ),
                    );
                  } else {
                    // if login status is neither fail nor success
                    // snackbarManager = custom code for showing snackbars
                    snackbarManager(context, 'Unknow error occured');
                  }
                } else {
                  // if request failed
                  // snackbarManager = custom code for showing snackbars
                  snackbarManager(context, 'Login failed, please try again');
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
