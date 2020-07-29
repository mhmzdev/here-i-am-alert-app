import 'package:fancy_on_boarding/fancy_on_boarding.dart';
import 'package:flutter/material.dart';

class AboutApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final _pages = <PageModel>[
      PageModel(
        title: Text(
          "Here I Am - App",
          style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: MediaQuery.of(context).size.height * 0.03),
        ),
        color: Colors.grey[900],
        // color: Color(0xffbe3a5a),
        heroAssetPath: 'assets/intro.png',
        iconAssetPath: 'assets/female.png',
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Text(
            "She is a Woman, a Mother, a Daughter, a Wife and a Sister. It's our firm duty to protect women of our society.\n\n Hence, we have developed this app to send alert to our loved ones in case of emergency, harassment etc.",
            textAlign: TextAlign.center,
          ),
        ),
      ),
      PageModel(
          title: Text(
            "Shake to Alert",
            style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: MediaQuery.of(context).size.height * 0.03),
          ),
          color: Colors.grey[800],
          heroAssetPath: 'assets/shake.png',
          iconAssetPath: 'assets/female.png',
          body: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Text(
              "Shake your Device to Alert your loved ones in no time and be safe!",
              textAlign: TextAlign.center,
            ),
          )),
      PageModel(
          title: Text(
            "Sharing is Caring",
            style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: MediaQuery.of(context).size.height * 0.03),
          ),
          color: Colors.grey[700],
          heroAssetPath: 'assets/share.png',
          iconAssetPath: 'assets/female.png',
          body: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Text(
              "Share the app with other females around you for betterment of our society!",
              textAlign: TextAlign.center,
            ),
          )),
    ];
    return Scaffold(
      body: FancyOnBoarding(
        doneButtonText: "Next",
        doneButtonTextStyle: TextStyle(
            fontSize: MediaQuery.of(context).size.height * 0.02,
            fontWeight: FontWeight.bold),
        onSkipButtonPressed: () => Navigator.pop(context),
        pageList: _pages,
        onDoneButtonPressed: () => Navigator.pop(context),
      ),
    );
  }
}
