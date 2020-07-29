import 'dart:io';
import 'dart:math' as math;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_shake_plugin/flutter_shake_plugin.dart';
import 'package:geocoder/geocoder.dart';
import 'package:here_i_am/CustomWidgets/rippleEffect.dart';
import 'package:here_i_am/Model/uploadContacts.dart';
import 'package:here_i_am/View/Others/intro_view.dart';
import 'package:here_i_am/View/phoneBook_view.dart';
import 'package:here_i_am/animations/bottomAnimation.dart';
import 'package:location/location.dart';
import 'package:sms_maintained/sms.dart';
import 'package:toast/toast.dart';

class HomeScreen extends StatefulWidget {
  final double maxSlide;
  final FirebaseUser user;
  HomeScreen({this.maxSlide, this.user});

  static HomeScreenState of(BuildContext context) =>
      context.findAncestorStateOfType<HomeScreenState>();

  @override
  HomeScreenState createState() => new HomeScreenState();
}

class HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  AnimationController animationController;
  bool _canBeDragged = false;
  bool contactAvail = false;

  FlutterShakePlugin _shakePlugin;

  callBack(boolVar) {
    setState(() {
      contactAvail = boolVar;
    });
  }

  initialContacts() {
    var db =
        FirebaseDatabase.instance.reference().child(widget.user.phoneNumber);
    db.once().then((DataSnapshot snapshot) {
      if (snapshot.value == null) {
        setState(() {
          contactAvail = false;
        });
      } else {
        setState(() {
          contactAvail = true;
        });
      }
    });
  }

  @override
  void initState() {
    initialContacts();
    super.initState();
    animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 250),
    );

    _shakePlugin = FlutterShakePlugin(
        onPhoneShaken: () {
          print('Shaking Phone Working');
          sendAlertSMS();
        },
        shakeThresholdGravity: 30)
      ..startListening();
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
    _shakePlugin.stopListening();
  }

  void toggle() => animationController.isDismissed
      ? animationController.forward()
      : animationController.reverse();

  void sendSMS(String number, String msgText) {
    SmsMessage msg = new SmsMessage(number, msgText);
    final SmsSender sender = new SmsSender();
    msg.onStateChanged.listen((state) {
      if (state == SmsMessageState.Sending) {
        return Toast.show('Sending Alert...', context,
            duration: 1, backgroundColor: Colors.blue, backgroundRadius: 5);
      } else if (state == SmsMessageState.Sent) {
        return Toast.show('Alert Sent Successfully!', context,
            duration: 3, backgroundColor: Colors.green, backgroundRadius: 5);
      } else if (state == SmsMessageState.Fail) {
        return Toast.show(
            'Failure! Check your credits & Network Signals!', context,
            duration: 5, backgroundColor: Colors.red, backgroundRadius: 5);
      } else {
        return Toast.show('Failed to send SMS. Try Again!', context,
            duration: 5, backgroundColor: Colors.red, backgroundRadius: 5);
      }
    });
    sender.sendSms(msg);
  }

  sendAlertSMS() async {
    List<String> recipients = [];
    var db =
        FirebaseDatabase.instance.reference().child(widget.user.phoneNumber);

    LocationData myLocation;
    String error;
    Location location = new Location();
    try {
      myLocation = await location.getLocation();
      var currentLocation = myLocation;
      setState(() {
        db.once().then((DataSnapshot snapshot) async {
          Map<dynamic, dynamic> values = snapshot.value;

          if (snapshot.value == null) {
            return Toast.show('No Contacts Found!', context,
                backgroundColor: Colors.red,
                backgroundRadius: 5,
                duration: 3,
                gravity: Toast.CENTER);
          } else {
            values.forEach((key, values) {
              recipients.add(values["phone"]);
            });

            var coordinates = Coordinates(
                currentLocation.latitude, currentLocation.longitude);
            var addresses =
                await Geocoder.local.findAddressesFromCoordinates(coordinates);
            var first = addresses.first;
            String link =
                "http://maps.google.com/?q=${currentLocation.latitude},${currentLocation.longitude}";
            for (int i = 0; i < recipients.length; i++) {
              sendSMS(recipients[i], "Help Me!\n${first.addressLine}\n$link");
            }
          }
        });
      });
    } on PlatformException catch (e) {
      if (e.code == 'PERMISSION_DENIED') {
        error = 'Please grant permission';
        print('Error due to Denied: $error');
      }
      if (e.code == 'PERMISSION_DENIED_NEVER_ASK') {
        error = 'Permission denied- please enable it from app settings';
        print("Error due to not Asking: $error");
      }
      myLocation = null;
    }
  }

  Future<bool> _onWillPop() async {
    return (await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            title: new Text(
              "Exit Application",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            content: new Text("Are You Sure?"),
            actions: <Widget>[
              FlatButton(
                shape: StadiumBorder(),
                color: Colors.white,
                child: new Text(
                  "Yes",
                  style: TextStyle(fontFamily: "2", color: Colors.red),
                ),
                onPressed: () {
                  exit(0);
                },
              ),
              FlatButton(
                shape: StadiumBorder(),
                color: Colors.white,
                child: new Text(
                  "No",
                  style: TextStyle(fontFamily: "2", color: Colors.blue),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        )) ??
        false;
  }

  final FirebaseDatabase database = new FirebaseDatabase();

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: GestureDetector(
        onHorizontalDragStart: _onDragStart,
        onHorizontalDragUpdate: _onDragUpdate,
        onHorizontalDragEnd: _onDragEnd,
        behavior: HitTestBehavior.translucent,
        child: AnimatedBuilder(
          animation: animationController,
          builder: (context, _) {
            return Material(
              child: SafeArea(
                child: Stack(
                  children: <Widget>[
                    Transform.translate(
                      offset: Offset(
                          widget.maxSlide * (animationController.value - 1), 0),
                      child: Transform(
                        transform: Matrix4.identity()
                          ..setEntry(3, 2, 0.001)
                          ..rotateY(
                              math.pi / 2 * (1 - animationController.value)),
                        alignment: Alignment.centerRight,
                        child: MyDrawer(),
                      ),
                    ),
                    Transform.translate(
                      offset: Offset(
                          widget.maxSlide * animationController.value, 0),
                      child: Transform(
                          transform: Matrix4.identity()
                            ..setEntry(3, 2, 0.001)
                            ..rotateY(-math.pi * animationController.value / 2),
                          alignment: Alignment.centerLeft,
                          child: homeScreenWidget(
                              MediaQuery.of(context).size.height,
                              MediaQuery.of(context).size.width)),
                    ),
                    Positioned(
                      top: 4.0 + MediaQuery.of(context).padding.top,
                      left: 4.0 + animationController.value * widget.maxSlide,
                      child: IconButton(
                        icon: Icon(Icons.menu),
                        onPressed: toggle,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget homeScreenWidget(double height, double width) {
    DatabaseReference contactRef =
        database.reference().child(widget.user.phoneNumber);

    return SafeArea(
      child: Container(
        padding: EdgeInsets.all(8.0),
        color: Colors.grey[900],
        child: Stack(
          children: <Widget>[
            Ripples(),
            AppImage(),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  SizedBox(height: height * 0.2),
                  addContactsText(context),
                  SizedBox(height: height * 0.03),
                  contactAvail
                      ? Container(
                          width: width * 0.7,
                          height: height * 0.25,
                          child: FirebaseAnimatedList(
                              scrollDirection: Axis.vertical,
                              query: contactRef,
                              itemBuilder: (BuildContext context,
                                  DataSnapshot snapshot,
                                  Animation<double> animation,
                                  int index) {
                                return WidgetAnimator(
                                    contactTile(snapshot, index, contactRef));
                              }))
                      : Text('Add Contact(s) from Phone book.',
                          style: TextStyle(color: Colors.lightGreen)),
                  SizedBox(
                    height: height * 0.012,
                  ),
                  contactAvail ? RemoveInstruction() : Container(),
                  SizedBox(height: height * 0.03),
                  phoneBookBtn(height, width),
                  SizedBox(height: height * 0.03),
                  sendAlertBtn(height, width),
                  SizedBox(height: height * 0.03),
                  contactAvail ? ShakeToAlert() : Container()
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget addContactsText(BuildContext context) {
    return Text(
      "Add Contacts to be Informed",
      style: TextStyle(
          fontFamily: 'Montserrat',
          color: Colors.white,
          fontSize: MediaQuery.of(context).size.height * 0.022),
    );
  }

  Widget sendAlertBtn(double height, double width) {
    return SizedBox(
      width: width * 0.7,
      height: height * 0.06,
      child: RaisedButton(
        shape: StadiumBorder(),
        onPressed: () {
          sendAlertSMS();
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            WidgetAnimator(
              Icon(
                Icons.warning,
                size: height * 0.03,
              ),
            ),
            SizedBox(
              width: width * 0.05,
            ),
            Text(
              "Sent Alert",
              style: TextStyle(fontSize: height * 0.023),
            ),
          ],
        ),
      ),
    );
  }

  Widget phoneBookBtn(double height, double width) {
    return SizedBox(
      width: width * 0.7,
      height: height * 0.06,
      child: RaisedButton(
        shape: StadiumBorder(),
        onPressed: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => PhoneBook(
                        user: widget.user,
                        callback: callBack,
                        contactAvailable: contactAvail,
                      )));
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            WidgetAnimator(
              Icon(
                Icons.contacts,
                size: height * 0.03,
              ),
            ),
            SizedBox(
              width: width * 0.05,
            ),
            Text(
              "PhoneBook",
              style: TextStyle(fontSize: height * 0.023),
            ),
          ],
        ),
      ),
    );
  }

  Widget contactTile(DataSnapshot res, int index, DatabaseReference reference) {
    final double width = MediaQuery.of(context).size.width;
    final double height = MediaQuery.of(context).size.height;
    index++;
    UploadContact uploadContact = UploadContact.fromSnapshot(res);
    return Container(
      padding: EdgeInsets.symmetric(vertical: height * 0.005),
      width: width,
      child: FlatButton(
        padding: EdgeInsets.symmetric(
            horizontal: width * 0.01, vertical: height * 0.005),
        shape: StadiumBorder(),
        color: Colors.white.withOpacity(0.5),
        onPressed: () {
          reference.child(uploadContact.key).remove();
          Toast.show("Contact Removed!", context,
              backgroundColor: Colors.red, duration: 3, backgroundRadius: 5);
          var db = FirebaseDatabase.instance
              .reference()
              .child(widget.user.phoneNumber);
          db.once().then((DataSnapshot snapshot) {
            if (snapshot.value == null) {
              setState(() {
                contactAvail = false;
              });
            }
          });
        },
        child: Row(
          children: <Widget>[
            CircleAvatar(
              radius: height * 0.03,
              backgroundColor: Colors.white,
              child: Icon(Icons.person,
                  color: Color(0xffbe3a5a), size: height * 0.045),
            ),
            SizedBox(width: width * 0.025),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  uploadContact.name,
                  style: TextStyle(fontFamily: "2", color: Colors.white),
                ),
                SizedBox(height: height * 0.01),
                Text("Contact " + index.toString(),
                    style: TextStyle(color: Colors.white54, fontFamily: "3")),
              ],
            )
          ],
        ),
      ),
    );
  }

  void _onDragStart(DragStartDetails details) {
    bool isDragOpenFromLeft = animationController.isDismissed;
    bool isDragCloseFromRight = animationController.isCompleted;
    _canBeDragged = isDragOpenFromLeft || isDragCloseFromRight;
  }

  void _onDragUpdate(DragUpdateDetails details) {
    if (_canBeDragged) {
      double delta = details.primaryDelta / widget.maxSlide;
      animationController.value += delta;
    }
  }

  void _onDragEnd(DragEndDetails details) {
    double _kMinFlingVelocity = 365.0;

    if (animationController.isDismissed || animationController.isCompleted) {
      return;
    }
    if (details.velocity.pixelsPerSecond.dx.abs() >= _kMinFlingVelocity) {
      double visualVelocity = details.velocity.pixelsPerSecond.dx /
          MediaQuery.of(context).size.width;

      animationController.fling(velocity: visualVelocity);
    } else if (animationController.value < 0.5) {
      animationController.reverse();
    } else {
      animationController.forward();
    }
  }
}

class MyDrawer extends StatelessWidget {
  Widget drawerRipples(double height, double width) {
    return Positioned(
      right: width * 0.125,
      child: Align(
        alignment: Alignment.topCenter,
        child: RippleAnimation(
          size: height * 0.05,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;

    return SizedBox(
      width: width * 0.85,
      height: double.infinity,
      child: Material(
        color: Colors.grey[900],
        child: SafeArea(
          child: Theme(
            data: ThemeData(brightness: Brightness.dark),
            child: Stack(
              children: <Widget>[
                drawerRipples(height, width),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    SizedBox(height: height * 0.03),
                    Image.asset('assets/hereIam1.png', height: height * 0.2),
                    SizedBox(height: height * 0.1),
                    Card(
                      child: ListTile(
                        leading: Icon(Icons.help),
                        title: Text('Help Guide'),
                        onTap: () => Navigator.pushNamed(context, '/helpGuide'),
                      ),
                    ),
                    Card(
                      child: ListTile(
                        leading: Icon(Icons.info),
                        title: Text('About App'),
                        onTap: () => Navigator.pushNamed(context, '/aboutApp'),
                      ),
                    ),
                    SizedBox(height: height * 0.1),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Text(
                          "'The one being Protected is always precious than the one who is Protecting.'\n\n~Women Safety",
                          textAlign: TextAlign.center),
                    ),
                  ],
                ),
                AppVersion()
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class AppImage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Positioned(
        right: MediaQuery.of(context).size.width / 5,
        top: MediaQuery.of(context).size.height * 0.07,
        child: Image.asset('assets/hereIam1.png',
            height: MediaQuery.of(context).size.height * 0.2));
  }
}

class RemoveInstruction extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    final double height = MediaQuery.of(context).size.height;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Icon(Icons.delete, color: Colors.red, size: height * 0.025),
        SizedBox(width: width * 0.01),
        Text(
          'Tap a Contact to Remove',
          style: TextStyle(fontFamily: 'Montserrat', color: Colors.red),
        )
      ],
    );
  }
}

class PhoneBookBtn extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;

    return SizedBox(
      width: width * 0.7,
      height: height * 0.06,
      child: RaisedButton(
        shape: StadiumBorder(),
        onPressed: () {
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => PhoneBook()));
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(
              Icons.contacts,
              size: height * 0.03,
            ),
            SizedBox(
              width: width * 0.05,
            ),
            Text(
              "PhoneBook",
              style: TextStyle(fontSize: height * 0.023),
            ),
          ],
        ),
      ),
    );
  }
}

class ShakeToAlert extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Text(
        'In Case of critical situation Shake your Phone\nto send Alert!',
        style: TextStyle(fontFamily: 'Montserrat', color: Color(0xffa8a9b1)),
        textAlign: TextAlign.center);
  }
}

class Ripples extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Positioned(
      right: MediaQuery.of(context).size.width * 0.16,
      top: MediaQuery.of(context).size.height * 0.04,
      child: RippleAnimation(
        size: MediaQuery.of(context).size.height * 0.05,
      ),
    );
  }
}

class AppVersion extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    return Align(
        alignment: Alignment.bottomCenter,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              'Here I Am',
              style: TextStyle(fontFamily: "s", fontWeight: FontWeight.bold),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  "Version: \n",
                  style: TextStyle(fontSize: height * 0.015),
                ),
                Text(
                  "1.0.0\n",
                  style: TextStyle(fontSize: height * 0.015),
                )
              ],
            )
          ],
        ));
  }
}
