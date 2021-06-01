import 'dart:async';

import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_webview/screens/fallback_screen.dart';
import 'package:flutter_webview/screens/main_webview_screen.dart';

import 'package:splash_screen_view/SplashScreenView.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  String connectionStatus = 'Unknown';
  bool isConnected = false;
  final Connectivity _connectivity = Connectivity();
  StreamSubscription<ConnectivityResult> _connectivitySubscription;

  @override
  void initState() {
    super.initState();
    initConnectivity();
    _connectivitySubscription =
        _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
  }

  @override
  void dispose() {
    _connectivitySubscription.cancel();
    super.dispose();
  }

  Future<void> initConnectivity() async {
    ConnectivityResult result = ConnectivityResult.none;
    try {
      result = await _connectivity.checkConnectivity();
    } on PlatformException catch (e) {
      print(e.toString());
    }
    if (!mounted) {
      return Future.value(null);
    }

    return _updateConnectionStatus(result);
  }

  @override
  Widget build(BuildContext context) {
    return isConnected
        ? SplashScreenView(
            home: MainWebviewScreen(),
            duration: 3000,
            imageSize: 100,
            imageSrc: "assets/logo.jpg",
            text: "Loading...",
            textType: TextType.TyperAnimatedText,
            textStyle: TextStyle(
              fontSize: 20.0,
            ),
            backgroundColor: Colors.white,
          )
        : SplashScreenView(
            home: FallbackScreen(),
            duration: 3000,
            imageSize: 100,
            imageSrc: "assets/logo.jpg",
            text: "Please Check Your Connection",
            textType: TextType.TyperAnimatedText,
            textStyle: TextStyle(
              fontSize: 20.0,
            ),
            backgroundColor: Colors.white,
          );
  }

  Future<void> _updateConnectionStatus(ConnectivityResult result) async {
    switch (result) {
      case ConnectivityResult.wifi:
        setState(() {
          isConnected = true;
        });
        break;
      case ConnectivityResult.mobile:
        setState(() {
          isConnected = true;
        });
        break;
      case ConnectivityResult.none:
        setState(() {
          connectionStatus = result.toString();
          isConnected = false;
          print(result);
        });
        break;
      default:
        setState(() => connectionStatus = 'Failed to get connectivity.');
        break;
    }
  }
}
