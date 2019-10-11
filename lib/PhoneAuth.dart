import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'HomePage.dart';
class PhoneAuth {
  Color myColor = Color(0xff00bfa5);
  PhoneAuth({this.phoneNo});
  String phoneNo;
  String smsOTP;
  String verificationId;
  String errorMessage = '';

  FirebaseAuth _auth = FirebaseAuth.instance;
  final _formKey = GlobalKey<FormState>();

    Future<void>  verifyPhone(BuildContext context) async {
    final PhoneCodeSent smsOTPSent = (String verId, [int forceCodeResend]) {
      this.verificationId = verId;
      openAlertBox(context).then((value) {
        print('sign in');
      });
    };


    try {
      await _auth.verifyPhoneNumber(
          phoneNumber: this.phoneNo,
          codeAutoRetrievalTimeout: (String verId) {
            this.verificationId = verId;
          },
          codeSent:
          smsOTPSent,
          timeout: const Duration(seconds: 20),
          verificationCompleted: (AuthCredential phoneAuthCredential) {
            print(phoneAuthCredential);
          },
          verificationFailed: (AuthException exceptio) {
            print('${exceptio.message}');
          });
    } catch (e) {
      handleError(context,e);
    }
  }


  openAlertBox(BuildContext context) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(32.0))),
            contentPadding: EdgeInsets.only(top: 10.0),
            content: Container(
              width: 300.0,
              child:Form(
                  key: _formKey,
                  child:Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text(
                            "OTP Verify",
                            style: TextStyle(fontSize: 24.0),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 5.0,
                      ),
                      Divider(
                        color: Colors.grey,
                        height: 4.0,
                      ),
                      Padding(

                        padding: EdgeInsets.only(left: 30.0, right: 30.0),
                        child: TextFormField(
                          validator: (value) {
                            if (value.isEmpty) {
                              return 'Please enter valid OTP';
                            }
                            return null;
                          },
                          keyboardType: TextInputType.phone,
                          decoration: InputDecoration(
                            hintText: "Enter OTP Code",
                            border: InputBorder.none,
                          ),
                          onChanged: (value) {
                            this.smsOTP = value;
                          },
                        ),

                      ),
                      (errorMessage != ''
                          ? Text(
                        errorMessage,
                        style: TextStyle(color: Colors.red),
                      )
                          : Container()),
                      InkWell(
                        splashColor: Colors.blueAccent,
                        onTap: (){
                          if(_formKey.currentState.validate()){
                            _auth.currentUser().then((user) {
                              if (user != null) {
                                Navigator.of(context).pop();
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(builder: (context) => HomePage(authType: 2,user:user)),

                                );
                              } else {
                                signIn(context);
                              }
                            });
                          }
                        },
                        child: Container(
                          padding: EdgeInsets.only(top: 20.0, bottom: 20.0),
                          decoration: BoxDecoration(
                            color: myColor,
                            borderRadius: BorderRadius.only(
                                bottomLeft: Radius.circular(16.0),
                                bottomRight: Radius.circular(16.0)),
                          ),
                          child: Text(
                            "Verify",
                            style: TextStyle(color: Colors.white),
                            textAlign: TextAlign.center,
                          ),

                        ),
                      ),
                    ],
                  )
              ),
            ),
          );
        });
  }

 signIn(BuildContext context) async {
    try {
      final AuthCredential credential =  PhoneAuthProvider.getCredential (
        verificationId: verificationId,
        smsCode: smsOTP,
      );
      FirebaseUser user=(await _auth.signInWithCredential(credential)).user;
        Navigator.of(context).pop();
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomePage(authType: 2,user: user)),
        );



    } catch (e) {
      handleError(context,e);
    }
  }
  handleError(BuildContext context,PlatformException error) {
    print(error);
    switch (error.code) {
      case 'ERROR_INVALID_VERIFICATION_CODE':
        FocusScope.of(context).requestFocus(new FocusNode());
          errorMessage = 'Invalid Code';
        Navigator.of(context).pop();
        openAlertBox(context).then((value) {
          print('sign in');
        });
        break;
      default:
          errorMessage = error.message;
        break;
    }
  }


}