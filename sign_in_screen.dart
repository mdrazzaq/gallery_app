import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:wallpaper_app/config/config.dart';

class SignInScreen extends StatefulWidget {
  @override
  _SignInScreenState createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final Firestore _db = Firestore.instance;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: Stack(
          children: [
            Image(
              image: AssetImage('assets/bg.jpg'),
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              fit: BoxFit.cover,
            ),
            Container(
              margin: EdgeInsets.only(top: 100),
              width: MediaQuery.of(context).size.width,
              child: Image(
                image: AssetImage('assets/logo_circle.png'),
                height: 200,
                width: 200,
              ),
            ),
            Positioned(
              bottom: 40,
              left: 0,
              right: 0,
              child: Container(
                width: MediaQuery.of(context).size.width,
                margin: EdgeInsets.symmetric(horizontal: 20,vertical: 10),
                child: InkWell(
                  onTap: _signIn,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 20,vertical: 25),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          primaryColor,secondaryColor
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Text(
                      'Google Sign-In',
                      style: TextStyle(fontSize: 20),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  void _signIn() async{
    try{
      final GoogleSignInAccount googleUser = await _googleSignIn.signIn();
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      final AuthCredential credential = GoogleAuthProvider.getCredential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final FirebaseUser user = (await _auth.signInWithCredential(credential)).user;
      print("signed in " + user.displayName);
      _db.collection('users').document(user.uid).setData({
        'displayName': user.displayName,
        'email': user.email,
        'uId': user.uid,
        'photoUrl': user.photoUrl,
        'lastSignIn': DateTime.now()
      });
    }catch(e){
      print(e.message);
    }

  }
}
