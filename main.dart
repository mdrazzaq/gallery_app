import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:wallpaper_app/config/config.dart';
import 'package:wallpaper_app/screen/home_page_screen.dart';
import 'package:wallpaper_app/screen/sign_in_screen.dart';

void main(){
  runApp(App());
}

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: primaryColor,
      ),
      home: MainPage(),
    );
  }
}

class MainPage extends StatefulWidget {

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  @override
  void initState() {
    _firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) async {
        print("onMessage: $message");
        String title = message["notification"]["title"] ?? "";
        String body = message["notification"]["body"] ?? "";

        print(title);
        print(body);

        _showDialog(
            title: title,
            body: body
        );
      },
      onLaunch: (Map<String, dynamic> message) async {
        print("onLaunch: $message");
        String title = message["notification"]["title"] ?? "";
        String body = message["notification"]["body"] ?? "";

        print(title);
        print(body);

        _showDialog(
            title: title,
            body: body
        );
      },
      onResume: (Map<String, dynamic> message) async {
        print("onResume: $message");
        String title = message["notification"]["title"] ?? "";
        String body = message["notification"]["body"] ?? "";

        print(title);
        print(body);

        _showDialog(
            title: title,
            body: body
        );
      },
    );
    _firebaseMessaging.subscribeToTopic("promotion");
    super.initState();
  }
  void _showDialog({String title, String body}) {
    showDialog(
        context: context,
        builder: (ctx) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
            title: Text(title),
            content: Text(body),
            actions: <Widget>[
              RaisedButton(
                onPressed: () {
                  Navigator.of(ctx).pop();
                },
                child: Text("Dismiss"),
              )
            ],
          );
        }
    );
  }
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: _auth.onAuthStateChanged,
      builder: (ctx, AsyncSnapshot<FirebaseUser>snapshot){
        if(snapshot.hasData){
          FirebaseUser user = snapshot.data;
          if(user !=null){
            return HomePageScreen();
          }else{
            return SignInScreen();
          }
        }
        return SignInScreen();
      },
    );
  }
}

