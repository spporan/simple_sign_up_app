import 'package:flutter/material.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:flutter_login_page_ui/main.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
class HomePage extends StatelessWidget{

  Map userProfile;
  int authType;
  FirebaseUser user;
  FirebaseAuth _auth = FirebaseAuth.instance;
  GoogleSignIn _googleSignIn=GoogleSignIn(scopes: ['email']);
  HomePage({
    this.userProfile,
    this.authType,
    this.user
});

  _logoutFb(BuildContext context) {
    FacebookLogin().logOut();
    Navigator.pop(context);

  }



  _logoutPhone(BuildContext context)async{
    _auth.signOut();
    Navigator.pop(context);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => MyApp(),
      ));
  }



  @override
  Widget build(BuildContext context) {
   
    return Scaffold(
      appBar: AppBar(
        title:Text( "Logged In"),
      
      ),
      body: Stack(
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
              child:authType==1 ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Container(
                    height: 200.0,
                    width: 200.0,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(
                        fit: BoxFit.fill,
                        image: NetworkImage(
                          userProfile['picture']['data']['url'],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 8,),
                  Text(userProfile["name"]),
                  OutlineButton( child: Text("Logout"), onPressed: (){
                    _logoutFb(context);
                  },)
                ],

              ) :
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(user.phoneNumber),
                  SizedBox(height: 8,),
                  OutlineButton( child: Text("Logout",style:TextStyle(color: Colors.red),), onPressed: (){
                    _logoutPhone(context);
                  },)
                ],

              )
          ),
        ],
      )
    );
  }

}