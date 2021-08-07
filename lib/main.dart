import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pricelocq/main_pages/debug.dart';

// main pages
import 'main_pages/login.dart';
import 'main_pages/landingPage.dart';
import 'main_pages/debug.dart';

// const
import 'const/colors.dart';
import 'const/fonts.dart';

void main() {
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    systemNavigationBarColor: kViolet, // navigation bar color
    statusBarColor: kViolet, // status bar color
  ));
  runApp(PriceLocq());
}

class PriceLocq extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      // set app defaults
      theme: ThemeData(
        textTheme: TextTheme(
          bodyText2: kDefaultFontSize,
        ),
      ),
      /*
      ** page routes
      ** mostly used for showing pages that do not need
      ** data from the previous page
      ** or when using a state management package like provider
      ** can also be used for debugging specific pages
      */
      routes: {
        '/': (context) => Login(),
        '/landing-page': (context) => LandingPage(),
        '/debug': (context) => Debug(),
      },
      initialRoute: '/',
    );
  }
}
