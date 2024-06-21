import 'package:flutter/material.dart';
import 'package:screenbroz2/Screens/Login_Screen.dart';
import 'package:screenbroz2/Screens/serch-screen.dart';
import 'package:screenbroz2/Screens/splash_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Screenbrozz',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: SplashScreen(),
    );
  }
}
