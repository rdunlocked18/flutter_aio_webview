import 'dart:io';
import 'dart:async';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:rate_my_app/rate_my_app.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../components/no_connection_widget.dart';
import '../../components/context_menu.dart';
import '../../components/navigation_component.dart';
import '../../utils/push_notifications_manager.dart';

class MainWebviewScreen extends StatefulWidget {
  final String title;

  MainWebviewScreen({Key key, this.title}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _MainWebviewScreenState();
  }
}

JavascriptChannel snackbarJavascriptChannel(BuildContext context) {
  return JavascriptChannel(
    name: 'SnackbarJSChannel',
    onMessageReceived: (JavascriptMessage message) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(message.message),
      ));
    },
  );
}

class _MainWebviewScreenState extends State<MainWebviewScreen> {
  String connectionStatus = 'Unknown';
  WebViewController webViewController;
  final Completer<WebViewController> _controller =
      Completer<WebViewController>();
  bool isLoading = true;
  bool isConnected = true;
  final Connectivity _connectivity = Connectivity();
  StreamSubscription<ConnectivityResult> _connectivitySubscription;
  RateMyApp rateMyApp = RateMyApp(
    preferencesPrefix: 'rateMyApp_',
    minDays: 5,
    minLaunches: 7,
    remindDays: 2,
    remindLaunches: 5,
    // appStoreIdentifier: '',
    googlePlayIdentifier: 'com.daftarirn.mahabhartiGlobal',
  );

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

  void initRateMyApp() {
    rateMyApp.init().then((_) {
      if (rateMyApp.shouldOpenDialog) {
        rateMyApp.showRateDialog(
          context,
          title: 'Rate this app', // The dialog title.
          message:
              'If you like this app, please take a little bit of your time to review it !\nIt really helps us and it shouldn\'t take you more than one minute.', // The dialog message.
          rateButton: 'RATE', // The dialog "rate" button text.
          noButton: 'NO THANKS', // The dialog "no" button text.
          laterButton: 'MAYBE LATER', // The dialog "later" button text.
          listener: (button) {
            switch (button) {
              case RateMyAppDialogButton.rate:
                break;
              case RateMyAppDialogButton.later:
                break;
              case RateMyAppDialogButton.no:
                break;
            }
            return true;
          },
          ignoreNativeDialog: Platform.isAndroid,
          dialogStyle: const DialogStyle(),
          onDismissed: () =>
              rateMyApp.callEvent(RateMyAppEventType.laterButtonPressed),
        );

        rateMyApp.showStarRateDialog(
          context,
          title: 'Rate this app', // The dialog title.
          message:
              'You like this app ? Then take a little bit of your time to leave a rating :',
          actionsBuilder: (context, stars) {
            return [
              TextButton(
                child: Text('OK'),
                onPressed: () async {
                  print('Thanks for the ' +
                      (stars == null ? '0' : stars.round().toString()) +
                      ' star(s) !');
                  await rateMyApp
                      .callEvent(RateMyAppEventType.rateButtonPressed);
                  Navigator.pop<RateMyAppDialogButton>(
                      context, RateMyAppDialogButton.rate);
                },
              ),
            ];
          },
          ignoreNativeDialog: Platform.isAndroid,
          dialogStyle: const DialogStyle(
            titleAlign: TextAlign.center,
            messageAlign: TextAlign.center,
            messagePadding: EdgeInsets.only(bottom: 20),
          ),
          starRatingOptions: const StarRatingOptions(),
          onDismissed: () =>
              rateMyApp.callEvent(RateMyAppEventType.laterButtonPressed),
        );
      }
    });
  }

  @override
  void initState() {
    FirebaseMessaging.onBackgroundMessage(
        PushNotificationsHandler.firebaseMessagingBackgroundHandler);
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      print("onMessage: $message");
    });
    _connectivitySubscription =
        _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
    super.initState();
    if (Platform.isAndroid) WebView.platform = SurfaceAndroidWebView();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => _exitApp(context),
      child: Scaffold(
        appBar: AppBar(
          brightness: Brightness.dark,
          title: Text('MahaBharti'),
          actions: <Widget>[
            NavigationControls(_controller.future),
            ContextMenu(_controller.future)
          ],
        ),
        body: Builder(
          builder: (BuildContext context) {
            return Container(
              color: Colors.white,
              child: Stack(children: [
                isConnected
                    ? WebView(
                        onPageFinished: (finish) {
                          setState(() {
                            isLoading = false;
                          });
                        },
                        initialUrl: 'https://mahabharti.in/global',
                        javascriptMode: JavascriptMode.unrestricted,
                        onWebViewCreated: (WebViewController controller) {
                          webViewController = controller;
                          _controller.complete(webViewController);
                        },
                        javascriptChannels: <JavascriptChannel>[
                          snackbarJavascriptChannel(context),
                        ].toSet(),
                        onPageStarted: (url) {
                          initConnectivity();
                          handleShare(url);
                        },
                      )
                    : Column(
                        children: [
                          NoConnectionWidget(),
                          CircularProgressIndicator(),
                        ],
                      ),
                isLoading
                    ? Center(
                        child: CircularProgressIndicator(),
                      )
                    : Stack(),
              ]),
            );
          },
        ),
      ),
    );
  }

  // ignore: missing_return
  Future<bool> _exitApp(BuildContext context) async {
    if (await webViewController.canGoBack()) {
      print("onwill goback");
      webViewController.goBack();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("You are already on Home Page"),
          backgroundColor: Colors.black,
          action: SnackBarAction(
            label: "Exit App",
            onPressed: () => exit(0),
          ),
        ),
      );
      return Future.value(false);
    }
  }

  Future<void> handleShare(String url) async {
    if (url.contains("facebook")) {
      await launch(url);
      return NavigationDecision.prevent;
    } else if (url.contains("telegram")) {
      await launch(url);
      return NavigationDecision.prevent;
    } else if (url.contains("whatsapp")) {
      await launch(url);
      return NavigationDecision.prevent;
    } else if (url.contains("twitter")) {
      await launch(url);
      return NavigationDecision.prevent;
    }
  }

  @override
  void dispose() {
    _connectivitySubscription.cancel();
    super.dispose();
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
