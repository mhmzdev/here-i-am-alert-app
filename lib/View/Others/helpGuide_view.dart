import 'package:flutter/material.dart';

class HelpGuide extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Help Guide"),
      ),
      body: SafeArea(
        child: Container(
          padding: EdgeInsets.all(8.0),
          child: ListView(
            children: <Widget>[
              GuideContainer(
                guideNo: 1,
                title: "Add Contacts",
                imagePath: 'assets/phoneBook.png',
                guideDescription:
                    "Press 'PhoneBook' Button to open your in-app phone book. Then tap any contact that you want to add to your alert list.",
              ),
              GuideContainer(
                title: "Remove Contacts",
                guideNo: 2,
                imagePath: 'assets/remove.png',
                guideDescription:
                    "Tap any 'Contact' in the Alert list at your home screen to remove it from the list. Don't worry it will not be removed from your phone book.",
              ),
              GuideContainer(
                guideNo: 3,
                title: "Send Alert Button",
                imagePath: 'assets/sendAlertBtn.png',
                guideDescription:
                    "Press the 'Send Alert' Button to send your Location (address & google maps link) to all the contacts in your Alert List.",
              ),
              GuideContainer(
                guideNo: 4,
                title: "Shake to send Alert",
                imagePath: 'assets/shake.png',
                guideDescription:
                    "In case of serious emergency you can simply shake your device to send alert to all the contacts in your Alert List.",
              ),
              GuideContainer(
                guideNo: 5,
                title: "Sharing is Caring!",
                imagePath: 'assets/share.png',
                guideDescription:
                    "Share this app among other women to play your part in Women Protection!",
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class GuideContainer extends StatelessWidget {
  final String title;
  final String guideDescription;
  final int guideNo;
  final String imagePath;

  GuideContainer(
      {@required this.guideNo,
      @required this.title,
      @required this.imagePath,
      @required this.guideDescription});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: <Widget>[
          Text(
            "\n$guideNo. $title",
            style: Theme.of(context).textTheme.bodyText1,
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.03,
          ),
          Image.asset(
            imagePath,
            height: MediaQuery.of(context).size.height * 0.2,
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.03,
          ),
          Text(
            guideDescription,
            textAlign: TextAlign.justify,
            style:
                TextStyle(fontSize: MediaQuery.of(context).size.height * 0.020),
          ),
        ],
      ),
    );
  }
}
