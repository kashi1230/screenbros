import 'package:flutter/material.dart';
import 'package:screenbroz2/Screens/serch-screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login_screen.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? phone = prefs.getString('phone');
    String? password = prefs.getString('password');

    // Simulate a delay for splash screen
    await Future.delayed(Duration(seconds: 2));

    if (phone != null && password != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => SearchScreen()),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      backgroundColor: Color(0xFFFFFFFF),
      body: Center(
        child: Image.asset(
          'assets/images/log.png',
          width: 250,
          height: 250,
        ),
      ),
    );
  }
}
