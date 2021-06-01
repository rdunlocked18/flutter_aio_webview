import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_webview/utils/menu_options_enum.dart';
import 'package:share/share.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

class ContextMenu extends StatelessWidget {
  final Future<WebViewController> controller;
  final CookieManager cookieManager = CookieManager();

  ContextMenu(this.controller);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<WebViewController>(
      future: controller,
      builder:
          (BuildContext context, AsyncSnapshot<WebViewController> controller) {
        return PopupMenuButton<MenuOptions>(
          itemBuilder: (BuildContext context) => <PopupMenuItem<MenuOptions>>[
            PopupMenuItem(
              value: MenuOptions.sharePageUrl,
              child: Row(
                children: [
                  Icon(Icons.share),
                  SizedBox(
                    width: 10,
                  ),
                  Text('Share Page'),
                ],
              ),
              enabled: controller.hasData,
            ),
            PopupMenuItem(
              value: MenuOptions.rateApp,
              child: Row(
                children: [
                  Icon(Icons.star_border_rounded),
                  SizedBox(
                    width: 10,
                  ),
                  Text('Rate App'),
                ],
              ),
              enabled: controller.hasData,
            ),
          ],
          onSelected: (MenuOptions value) {
            switch (value) {
              case MenuOptions.sharePageUrl:
                sharePageUrl(controller.data, context);
                break;
              case MenuOptions.rateApp:
                rateApp();
                break;

              default:
                print("Cannot Launch Menu Option");
            }
          },
        );
      },
    );
  }

  void rateApp() {
    String appPackageName = "com.daftarirn.mahabhartiGlobal";
    try {
      launch("market://details?id=" + appPackageName);
    } on PlatformException catch (e) {
      print(e.stacktrace);
      launch("https://play.google.com/store/apps/details?id=" + appPackageName);
    } finally {
      launch("https://play.google.com/store/apps/details?id=" + appPackageName);
    }
  }

  sharePageUrl(WebViewController controller, BuildContext context) async {
    String currentUrl = await controller.currentUrl();

    Share.share('Check this Job Update $currentUrl');
  }
}
