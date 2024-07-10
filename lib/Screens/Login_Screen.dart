import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:screenbroz2/Screens/serch-screen.dart';
import 'package:screenbroz2/Widgets/TextBuilder.dart';
import 'package:screenbroz2/Widgets/common_widgets.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _obscureText = true;
  TextEditingController userName = TextEditingController();
  TextEditingController userPassword = TextEditingController();
  final _formPageKey = GlobalKey<FormState>();
  final _pageKey = GlobalKey<ScaffoldState>();
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _togglePassword() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  Future<void> _loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? phone = prefs.getString('phone');
    String? password = prefs.getString('password');

    if (phone != null && password != null) {
      userName.text = phone;
      userPassword.text = password;
    }
  }

  Future<void> _saveUserData(String phone, String password) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('phone', phone);
    await prefs.setString('password', password);
  }

  Future<void> login(BuildContext context) async {
    setState(() {
      isLoading = true;
    });
    final response = await http.post(
      Uri.parse('https://www.screenbros.in/employeeapi/employee_login.php'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'phone': userName.text.trim(),
        'password': userPassword.text.trim(),
      }),
    );
    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      print(response.body);
      if (data['status'] == 'success') {
        await _saveUserData(userName.text.trim(), userPassword.text.trim());
        Navigator.pop(context);
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => SearchScreen()),
              (route) => false,
        );
        print(response.body);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.blueAccent,
              content: TextBuilder(text:data['message'],fontWeight: FontWeight.bold,color: Colors.white,)),
        );
      }
    } else {
      throw Exception('Failed to load data');
    }
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _pageKey,
      body: Form(
        key: _formPageKey,
        child: SingleChildScrollView(
          child: Container(
            height: MediaQuery.of(context).size.height,
            child: Stack(
              children: <Widget>[
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Expanded(
                        flex: 3,
                        child: const SizedBox(),
                      ),
                      TextBuilder(
                        text: "Welcome",
                        color: Colors.black,
                        fontSize: 28,
                        fontWeight: FontWeight.w400,
                      ),
                      const SizedBox(height: 50),
                      _emailPasswordWidget(),
                      const SizedBox(height: 20),
                      // Wrap login button with Stack
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          loginButton(
                            ontap: () {
                              // Set isLoading to true before making the request
                              setState(() {
                                isLoading = true;
                              });
                              login(context);
                            },
                            width: MediaQuery.of(context).size.width,
                            text: "Login",
                            height: 50.0,
                          ),
                          // Show circular progress indicator based on isLoading flag
                          if (isLoading)
                            CircularProgressIndicator(color: Colors.white,),
                        ],
                      ),
                      const SizedBox(height: 20),
                      _divider(),
                      Expanded(
                        flex: 2,
                        child: const SizedBox(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _divider() {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: <Widget>[
          const SizedBox(width: 20),
        ],
      ),
    );
  }

  Widget _emailField() {
    return TextFormField(
      key: Key("Phone"),
      controller: userName,
      validator: (value) => (value!.isEmpty) ? "Please Enter Phone Number" : null,
      style: GoogleFonts.lato(fontSize: 20.0),
      decoration: InputDecoration(
        prefixIcon: Icon(Icons.person),
        labelText: "Phone Number",
        border: OutlineInputBorder(),
      ),
    );
  }

  Widget _passwordField() {
    return TextFormField(
      key: Key("userPassword"),
      controller: userPassword,
      obscureText: _obscureText,
      validator: (value) => (value!.isEmpty) ? "Please Enter Password" : null,
      style: GoogleFonts.lato(fontSize: 20.0),
      decoration: InputDecoration(
        prefixIcon: Icon(Icons.lock),
        labelText: "Password",
        border: OutlineInputBorder(),
      ),
    );
  }

  Widget _emailPasswordWidget() {
    return Column(
      children: <Widget>[
        _emailField(),
        const SizedBox(height: 10),
        _passwordField(),
        TextButton(
          onPressed: _togglePassword,
          child: TextBuilder(text: _obscureText ? "Show" : "Hide"),
        ),
      ],
    );
  }
}
