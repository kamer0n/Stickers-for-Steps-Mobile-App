import 'package:flutter/material.dart';

import 'package:darkmodetoggle/screens/home.dart';
import 'package:darkmodetoggle/screens/signin.dart';
import 'package:darkmodetoggle/screens/signup.dart';

import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(MaterialApp(
    home: MyApp(),
  ));
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getPref();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Stack(
        children: [(_loginStatus == 1) ? Home() : SignIn()],
      ),
      theme: ThemeData.dark(),
      debugShowCheckedModeBanner: false,
      routes: <String, WidgetBuilder>{
        '/signin': (BuildContext context) => SignIn(),
        '/signup': (BuildContext context) => SignUp(),
        '/home': (BuildContext context) => Home(),
      },
    );
  }

  var _token = "";
  var _loginStatus = 0;
  getPref() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      _loginStatus = preferences.getInt('value') ?? 0;
      _token = preferences.getString('token') ?? "";
    });
  }
}
