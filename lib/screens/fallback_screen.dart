import 'dart:async';

import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webview/components/no_connection_widget.dart';
import 'package:flutter_webview/screens/main_webview_screen.dart';
import 'package:flutter_webview/screens/splash_screen.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';

class FallbackScreen extends StatefulWidget {
  @override
  _FallbackScreenState createState() => _FallbackScreenState();
}

class _FallbackScreenState extends State<FallbackScreen> {
  final RoundedLoadingButtonController _btnController =
      RoundedLoadingButtonController();
  Future<void> _checkNetworkStatus() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.mobile ||
        connectivityResult == ConnectivityResult.wifi) {
      _btnController.success();
      Navigator.pushAndRemoveUntil<dynamic>(
        context,
        MaterialPageRoute<dynamic>(builder: (context) => MainWebviewScreen()),
        (route) => false,
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => SplashScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
          color: Colors.white,
          child: Column(
            children: [
              NoConnectionWidget(),
              SizedBox(
                  height: 50,
                  width: 200,
                  child: RoundedLoadingButton(
                    animateOnTap: true,
                    color: Colors.orange,
                    child:
                        Text('Retry!', style: TextStyle(color: Colors.white)),
                    controller: _btnController,
                    onPressed: _checkNetworkStatus,
                  ))
            ],
          )),
    );
  }
}
