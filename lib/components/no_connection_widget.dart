import 'package:flutter/material.dart';

class NoConnectionWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 200),
            SizedBox(
                width: 250, height: 250, child: Image.asset("assets/logo.jpg")),
            Text(
              "Please Connect to Internet \nTo Start Using the App",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(width: 100, height: 100),
          ],
        ),
      ),
    );
  }
}
