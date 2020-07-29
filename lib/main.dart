import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:here_i_am/View/Others/helpGuide_view.dart';
import 'package:here_i_am/View/Others/intro_view.dart';
import 'package:here_i_am/View/homeScreen_view.dart';
import 'package:here_i_am/View/loginScreen_view.dart';

void main() {
  runApp(MyApp());
}

final myTheme = ThemeData(
    primarySwatch: Colors.red,
    buttonColor: Color(0xffbe3a5a),
    primaryColor: Color(0xffbe3a5a),
    brightness: Brightness.dark,
    backgroundColor: Color(0xff0b0c0e),
    accentColor: Color(0xffbe3a5a),
    fontFamily: "Montserrat",
    iconTheme: IconThemeData(color: Color(0xffa8a9b1)),
    accentIconTheme: IconThemeData(color: Color(0xffa8a9b1)),
    dividerColor: Color(0xffbe3a5a),
    textTheme: TextTheme(
        headline1: TextStyle(fontSize: 30, fontFamily: 'Montserrat'),
        headline2: TextStyle(
            fontSize: 32, fontFamily: 'MontRegular', color: Color(0xffbe3a5a)),
        button: TextStyle(letterSpacing: 1.5)));

class MyApp extends StatelessWidget {
  Future authCheck() async {
    FirebaseUser _user = await FirebaseAuth.instance.currentUser();
    return _user;
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);

    return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: myTheme,
        routes: {
          '/aboutApp': (context) => AboutApp(),
          '/helpGuide': (context) => HelpGuide()
        },
        home: FutureBuilder(
          future: authCheck(),
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (snapshot.data == null) {
              return LoginScreen();
            } else {
              return HomeScreen(
                user: snapshot.data,
                maxSlide: MediaQuery.of(context).size.width * 0.85,
              );
            }
          },
        ));
  }
}
