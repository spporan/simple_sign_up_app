import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'HomePage.dart';
import 'PhoneAuth.dart';
import 'Widgets/SocialIcons.dart';
import 'CustomIcons.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as JSON;
import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

void main() => runApp(MaterialApp(
      home: MyApp(),
      debugShowCheckedModeBanner: false,
    ));

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => new _MyAppState();
}

class _MyAppState extends State<MyApp> {
  TextEditingController controller = TextEditingController();
  bool _isLoggedIn = false;
  Map userProfile;
  String code="+880";
  String number;
  GoogleSignIn _googleSignIn=GoogleSignIn(scopes: ['email']);
  GoogleSignInAccount _currentUser;
  FirebaseUser user;
  int authType=0;
  FirebaseAuth _auth = FirebaseAuth.instance;
  final facebookLogin = FacebookLogin();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {


    FirebaseAuth.instance.currentUser().then((user) => user != null
        ? setState(() {
          _isLoggedIn=true;
          authType=1;
          this.user=user;
    })
        : null);

    _googleSignIn.onCurrentUserChanged.listen((GoogleSignInAccount account) {
      setState(() {
        _currentUser = account;
      });
      if (_currentUser != null) {
        _isLoggedIn=true;
        authType=2;
      }
    });
    _googleSignIn.signInSilently();
    super.initState();
    // new Future.delayed(const Duration(seconds: 2));
  }

  _googleLogin()async{
    try{
        await _googleSignIn.signIn();
        setToast("Logged in");
        setState(() {
          _isLoggedIn= true;
        });
    }catch(err){
      print(err);

    }
  }
  _googleLogout(){
    _googleSignIn.signOut();
    setState(() {
     _isLoggedIn=false; 
    });
  }
  _loginWithFB() async {
    final result = await facebookLogin.logIn(['email']);

    switch (result.status) {
      case FacebookLoginStatus.loggedIn:
        final token = result.accessToken.token;
        final graphResponse = await http.get(
            'https://graph.facebook.com/v2.12/me?fields=name,picture.height(200),email&access_token=$token');
        final profile = JSON.jsonDecode(graphResponse.body);
        print(profile);
        setState(() {
          userProfile = profile;
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => HomePage(userProfile: userProfile,authType: 1)),
          );
          debugPrint('data: $userProfile');
          setToast("Login success :" + userProfile["name"]);
        });
        break;

      case FacebookLoginStatus.cancelledByUser:
        setState(() => _isLoggedIn = false);
        print('data: cancel By User');
        break;
      case FacebookLoginStatus.error:
        setState(() => _isLoggedIn = false);
        print('data: ${FacebookLoginStatus.error}');
        print(result.errorMessage);

        break;
    }
  }

  void setToast(String msg) {
    Fluttertoast.showToast(
        msg: msg,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIos: 1,
        backgroundColor: Colors.greenAccent,
        textColor: Colors.white,
        fontSize: 16.0);
  }
  Widget loginFormWidget() => Form(
      key: _formKey,
      child:  Container(
    width: double.infinity,
    height: ScreenUtil.getInstance().setHeight(275),
    decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.0),
        boxShadow: [
          BoxShadow(
              color: Colors.black12,
              offset: Offset(0.0, 15.0),
              blurRadius: 15.0),
          BoxShadow(
              color: Colors.black12,
              offset: Offset(0.0, -10.0),
              blurRadius: 10.0),
        ]),
    child: Padding(
      padding: EdgeInsets.only(left: 16.0, right: 16.0, top: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Text("Login",
              style: TextStyle(
                  fontSize: ScreenUtil.getInstance().setSp(45),
                  fontFamily: "Poppins-Bold",
                  letterSpacing: .6)),
          SizedBox(
            height: ScreenUtil.getInstance().setHeight(30),
          ),
          Row(
            children: <Widget>[
              CountryCodePicker(
                onChanged: (value) {
                  code=value.toString();
                  //setToast(value.toString());
                },
                initialSelection: '+880',
                favorite: ['+880', 'BD'],
                showCountryOnly: false,
                showOnlyCountryWhenClosed: false,
                alignLeft: false,
              ),
              Expanded(
                child: TextFormField(
                  validator: (value) {
                    if (value.isEmpty) {
                      return 'Please enter valid phone number';
                    }
                    return null;
                  },
                  keyboardType: TextInputType.phone,
                  controller: controller,
                  textAlign: TextAlign.center,
                  decoration: InputDecoration(
                      hintText: "Enter Your Phone Number",
                      hintStyle:
                      TextStyle(color: Colors.grey, fontSize: 12.0)),
                ),
              )
            ],
          ),
          SizedBox(
            height: ScreenUtil.getInstance().setHeight(35),
          ),
        ],
      ),
    ),
  ));
  Widget horizontalLine() => Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.0),
        child: Container(
          width: ScreenUtil.getInstance().setWidth(120),
          height: 1.0,
          color: Colors.black26.withOpacity(.2),
        ),
      );
  _logoutPhone(BuildContext context)async{
    _auth.signOut();
    setState(() {
      _isLoggedIn=false;
    });
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.instance = ScreenUtil.getInstance()..init(context);
    ScreenUtil.instance =
        ScreenUtil(width: 750, height: 1334, allowFontScaling: true);
    return new Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomPadding: true,
      body:
        Stack(
        fit: StackFit.expand,
        children: <Widget>[
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.only(top: 20.0),
                child: Image.asset("assets/image_01.png"),
              ),
              Expanded(
                child: Container(),
              ),
              Image.asset("assets/image_02.png")
            ],
          ),
      Center(
        child: _isLoggedIn
            ? Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children:authType==2? <Widget>[
            Container(
              height: 200.0,
              width: 200.0,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                image: DecorationImage(
                  fit: BoxFit.fill,
                  image:NetworkImage(_googleSignIn.currentUser.photoUrl),
                ),
              ),
            ),
            SizedBox(height: 8,),
            Text(_googleSignIn.currentUser.displayName),
            OutlineButton(
              child: Text("Logout"),
              onPressed: (){
                _googleLogout();
              },
            )
          ] : <Widget>[
            Text(user.phoneNumber),
            SizedBox(height: 8,),
            OutlineButton( child: Text("Logout",style:TextStyle(color: Colors.red),), onPressed: (){
              _logoutPhone(context);
            },)
          ],

        ):
          SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.only(left: 28.0, right: 28.0, top: 60.0),
              child: Column(
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Image.asset(
                        "assets/logo.png",
                        width: ScreenUtil.getInstance().setWidth(110),
                        height: ScreenUtil.getInstance().setHeight(110),
                      ),
                      Text("LOGO",
                          style: TextStyle(
                              fontFamily: "Poppins-Bold",
                              fontSize: ScreenUtil.getInstance().setSp(46),
                              letterSpacing: .6,
                              fontWeight: FontWeight.bold))
                    ],
                  ),
                  SizedBox(
                    height: ScreenUtil.getInstance().setHeight(180),
                  ),
                  loginFormWidget(),
                  SizedBox(height: ScreenUtil.getInstance().setHeight(40)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      InkWell(
                        child: Container(
                          width: ScreenUtil.getInstance().setWidth(330),
                          height: ScreenUtil.getInstance().setHeight(100),
                          decoration: BoxDecoration(
                              gradient: LinearGradient(colors: [
                                Color(0xFF17ead9),
                                Color(0xFF6078ea)
                              ]),
                              borderRadius: BorderRadius.circular(6.0),
                              boxShadow: [
                                BoxShadow(
                                    color: Color(0xFF6078ea).withOpacity(.3),
                                    offset: Offset(0.0, 8.0),
                                    blurRadius: 8.0)
                              ]),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () {
                                if(_formKey.currentState.validate()){
                                  number= controller.text.toString();
                                  String phoneNumber=code+number;
                                  PhoneAuth auth=PhoneAuth(phoneNo: phoneNumber);
                                  auth.verifyPhone(context);
                                  setToast(phoneNumber);
                                }

                              },
                              child: Center(
                                child: Text("CONTINUE",
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontFamily: "Poppins-Bold",
                                        fontSize: 18,
                                        letterSpacing: 1.0)),
                              ),
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                  SizedBox(
                    height: ScreenUtil.getInstance().setHeight(40),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      horizontalLine(),
                      Text("Social Login",
                          style: TextStyle(
                              fontSize: 16.0, fontFamily: "Poppins-Medium")),
                      horizontalLine()
                    ],
                  ),
                  SizedBox(
                    height: ScreenUtil.getInstance().setHeight(40),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      SocialIcon(
                        colors: [
                          Color(0xFF102397),
                          Color(0xFF187adf),
                          Color(0xFF00eaf8),
                        ],
                        iconData: CustomIcons.facebook,
                        onPressed: () {
                          _loginWithFB();
                        },
                      ),
                      SocialIcon(
                        colors: [
                          Color(0xFFff4f38),
                          Color(0xFFff355d),
                        ],
                        iconData: CustomIcons.googlePlus,
                        onPressed: () {
                          _googleLogin();
                         
                        },
                      ),
                    ],
                  ),
                  SizedBox(
                    height: ScreenUtil.getInstance().setHeight(30),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        "New User? ",
                        style: TextStyle(fontFamily: "Poppins-Medium"),
                      ),
                      InkWell(
                        onTap: () {},
                        child: Text("SignUp",
                            style: TextStyle(
                                color: Color(0xFF5d74e3),
                                fontFamily: "Poppins-Bold")),
                      )
                    ],
                  )
                ],
              ),
            ),
          )
      )],
      ),

    );
  }
}
