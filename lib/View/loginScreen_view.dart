import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:here_i_am/CustomWidgets/rippleEffect.dart';
import 'package:here_i_am/View/homeScreen_view.dart';
import 'package:here_i_am/animations/bottomAnimation.dart';
import 'package:toast/toast.dart';

final _controllerCode = TextEditingController();
final _controllerPhone = TextEditingController();

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool validate = false;
  bool codeValidate = false;
  String _verificationId;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String validateCode(String code) {
    if (!(code.length == 6) && code.isNotEmpty) {
      return "Invalid Code length";
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;

    return GestureDetector(
      onTap: () {
        FocusScopeNode currentFocus = FocusScope.of(context);
        if (!currentFocus.hasPrimaryFocus) {
          currentFocus.unfocus();
        }
      },
      child: Scaffold(
        resizeToAvoidBottomPadding: false,
        body: SafeArea(
          child: Stack(
            children: <Widget>[
              ripple(height, width),
              HereIAmImage(),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  SizedBox(height: height * 0.3),
                  PhoneTextField(),
                  SizedBox(
                    height: height * 0.02,
                  ),
                  OTPDescription(),
                  SizedBox(
                    height: height * 0.02,
                  ),
                  loginBtn(height, width, context)
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget loginBtn(double height, double width, BuildContext context) {
    return SizedBox(
      height: height * 0.06,
      width: width * 0.5,
      child: RaisedButton(
          shape: StadiumBorder(),
          onPressed: () async {
            setState(() {
              _controllerPhone.text.isEmpty
                  ? validate = true
                  : validate = false;
            });
            final phoneNumber = "+92" + _controllerPhone.text.trim();
            _verifyPhoneNumber(phoneNumber);
            _controllerPhone.clear();
          },
          child: WidgetAnimator(Text("Login",
              style: TextStyle(
                fontSize: height * 0.02,
              )))),
    );
  }

  Widget ripple(double height, double width) {
    return Positioned(
        top: height * 0.15,
        right: width / 12,
        child: RippleAnimation(
          size: height * 0.07,
        ));
  }

  verificationCompleted() {
    return (AuthCredential credential) async {
      await _auth.signInWithCredential(credential).then((AuthResult value) {
        if (value.user != null) {
          Navigator.pop(context);
          Navigator.push(
              context,
              new MaterialPageRoute(
                  builder: (context) => HomeScreen(
                        user: value.user,
                        maxSlide: MediaQuery.of(context).size.width * 0.85,
                      )));
        }
      });
    };
  }

  verificationFailed() {
    return (AuthException exception) {
      Toast.show('Verification Failed: ${exception.code}', context,
          backgroundColor: Colors.red,
          duration: 3,
          backgroundRadius: 5,
          gravity: Toast.BOTTOM);
    };
  }

  codeSent() {
    return (String verificationID, [int forceResendingToken]) {
      double height = MediaQuery.of(context).size.height;
      double width = MediaQuery.of(context).size.width;

      showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              title: Text('Enter 6-Digit Code'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  SizedBox(
                    height: height * 0.1,
                    width: width,
                    child: TextField(
                      style: TextStyle(fontSize: height * 0.02),
                      controller: _controllerCode,
                      keyboardType: TextInputType.number,
                      maxLength: 6,
                      cursorColor: Colors.white,
                      decoration: InputDecoration(
                        errorText: validateCode(_controllerCode.text),
                        hintText: 'Enter Code',
                        hintStyle: TextStyle(fontSize: height * 0.015),
                        enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.white),
                            borderRadius: BorderRadius.circular(12.0)),
                        focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.white),
                            borderRadius: BorderRadius.circular(12.0)),
                        errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.0),
                            borderSide: BorderSide(color: Colors.red)),
                        focusedErrorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.0),
                            borderSide: BorderSide(color: Colors.red)),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: height * 0.01,
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Icon(
                        Icons.info,
                        color: Color(0xffbe3a5a),
                        size: height * 0.03,
                      ),
                      SizedBox(
                        width: width * 0.02,
                      ),
                      Text(
                        'Wait for Automatic Detection!',
                        style: TextStyle(
                            fontFamily: 'Montserrat', fontSize: height * 0.017),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: height * 0.01,
                  ),
                  Container(
                    height: height * 0.06,
                    width: width,
                    child: FlatButton(
                      padding: EdgeInsets.symmetric(horizontal: width * .05),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5)),
                      child: Text(
                        "Confirm",
                      ),
                      textColor: Colors.white,
                      color: Color(0xffbe3a5a),
                      onPressed: () async {
                        setState(() {
                          _controllerCode.text.isEmpty
                              ? codeValidate = true
                              : codeValidate = false;
                        });
                        _auth.currentUser().then((user) {
                          if (user != null) {
                            Navigator.pop(context);
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => HomeScreen(
                                          user: user,
                                          maxSlide: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.85,
                                        )));
                          } else {
                            _verifyCode();
                          }
                        });
                        _controllerCode.clear();
                      },
                    ),
                  )
                ],
              ),
            );
          });
      _verificationId = verificationID;
    };
  }

  codeAutoRetrievalTimeout() {
    return (String verificationID) {
      _verificationId = verificationID;
    };
  }

  Future<void> _verifyPhoneNumber(String phone) async {
    _auth.verifyPhoneNumber(
      phoneNumber: phone,
      timeout: const Duration(seconds: 60),
      verificationCompleted: verificationCompleted(),
      verificationFailed: verificationFailed(),
      codeSent: codeSent(),
      codeAutoRetrievalTimeout: codeAutoRetrievalTimeout(),
    );
  }

  Future<void> _verifyCode() async {
    final AuthCredential credential = PhoneAuthProvider.getCredential(
        verificationId: _verificationId, smsCode: _controllerCode.text);
    final FirebaseUser user =
        (await _auth.signInWithCredential(credential)).user;
    final FirebaseUser currentUser = await _auth.currentUser();
    assert(user.uid == currentUser.uid);
    if (user != null) {
      Navigator.pop(context);
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => HomeScreen(
                    user: user,
                    maxSlide: MediaQuery.of(context).size.width * 0.85,
                  )));
    }
  }
}

class HereIAmImage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    return Positioned(
      top: height * 0.2,
      right: width / 6,
      child: Image.asset(
        "assets/hereIam1.png",
        height: height * 0.25,
      ),
    );
  }
}

class PhoneTextField extends StatelessWidget {
  String validatePhone(String phone) {
    if (!(phone.length == 10) && phone.isNotEmpty) {
      return "Invalid Phone Number length";
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
// top: height * 0.45,
    return Container(
      padding: EdgeInsets.symmetric(horizontal: width * 0.04),
      width: width,
      height: height * 0.1,
      child: TextField(
          controller: _controllerPhone,
          style: TextStyle(color: Colors.white, fontSize: height * 0.023),
          keyboardType: TextInputType.phone,
          autofocus: false,
          cursorColor: Colors.white,
          maxLength: 10,
          decoration: InputDecoration(
              errorText: validatePhone(_controllerPhone.text),
              counterStyle: TextStyle(color: Colors.white),
              prefixIcon: WidgetAnimator(
                Icon(
                  Icons.phone,
                  color: Colors.white,
                  size: height * 0.03,
                ),
              ),
              prefix: Text(
                '+92',
                style: TextStyle(fontSize: height * 0.023),
              ),
              prefixStyle: TextStyle(color: Colors.white),
              labelText: 'Phone Number',
              labelStyle: TextStyle(color: Colors.white),
              hintStyle: TextStyle(color: Colors.white54),
              enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                  borderRadius: BorderRadius.circular(32)),
              errorBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.red),
                  borderRadius: BorderRadius.circular(32)),
              focusedErrorBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.red),
                  borderRadius: BorderRadius.circular(32)),
              focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                  borderRadius: BorderRadius.circular(32)))),
    );
  }
}

class OTPDescription extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Icon(
          Icons.info,
          color: Color(0xffbe3a5a),
          size: height * 0.03,
        ),
        SizedBox(
          width: width * 0.02,
        ),
        RichText(
            text: TextSpan(children: [
          TextSpan(text: 'We will send'),
          TextSpan(
            text: ' One Time Password',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          TextSpan(text: ' on \nthis mobile number')
        ])),
      ],
    );
  }
}
