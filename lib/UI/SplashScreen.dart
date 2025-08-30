import 'dart:async';

import 'package:flutter/material.dart';
import 'package:scapture/Database/Database.dart';
import 'package:scapture/UI/LandingScreen.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Database _database = Database();

  @override
  void initState() {
    super.initState();
    Timer(Duration(seconds: 3), () {
      _database.isLogin();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFEFBF04),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              margin: EdgeInsets.symmetric(horizontal: 40),
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2), // light black shadow
                    blurRadius: 10,
                    offset: Offset(2, 4), // horizontal and vertical offset
                  ),
                ],
              ),
              child: Image.asset("assets/images/applogo.png"),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 40,vertical: 20),
              child: Column(
                children: [
                  Text(
                    "Thy throne, O God, is for ever and ever: the scepter of thy kingdom is a right scepter."
                  ),
                  Row(
                children: [
                  Spacer(),
                  Text("Psalm 45:6",style: TextStyle(fontWeight: FontWeight.bold),),
                  SizedBox(width: 30,)
                ],
              )
                ],
              ),
            ),
            
          ],
        ),
      ),
    );
  }
}
