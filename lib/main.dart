import 'package:darkmodetoggle/backend/collection.dart';
import 'package:darkmodetoggle/backend/databasehandler.dart';
import 'package:flutter/material.dart';

import 'package:darkmodetoggle/screens/stickers_screen.dart';
import 'package:darkmodetoggle/screens/signin.dart';
import 'package:darkmodetoggle/screens/signup.dart';
import 'package:darkmodetoggle/screens/home.dart';

import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(MaterialApp(
    home: MyApp(),
  ));
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    _buildDB();
    getPref();
  }

  _buildDB() async {
    await DatabaseHandler().initializeDB();
    await fetchCollections();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Stack(
        children: [(_loginStatus == 1) ? Home('Home') : SignIn()],
      ),
      theme: ThemeData.dark(),
      debugShowCheckedModeBanner: false,
      routes: <String, WidgetBuilder>{
        '/signin': (BuildContext context) => SignIn(),
        '/signup': (BuildContext context) => SignUp(),
        '/stickerscreen': (BuildContext context) => StickerScreen(),
        '/friendsscreen': (BuildContext context) => Home('Friends'),
        '/home': (BuildContext context) => Home('Home'),
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
