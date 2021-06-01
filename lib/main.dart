import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webview/screens/splash_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  void initializeFlutterFire() async {
    try {
      await Firebase.initializeApp();
      print("Configured to firebase");
    } catch (e) {
      print(e.toString());
    }
  }

  @override
  void initState() {
    initializeFlutterFire();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Mahabharti.in',
        theme: ThemeData(
          primarySwatch: Colors.orange,
        ),
        home: SplashScreen());
  }
}
