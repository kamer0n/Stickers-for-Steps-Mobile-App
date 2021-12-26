import 'package:darkmodetoggle/backend/collection.dart';
import 'package:darkmodetoggle/backend/databasehandler.dart';
import 'package:darkmodetoggle/screens/nav.dart';
import 'package:flutter/material.dart';

import 'package:darkmodetoggle/screens/stickers_screen.dart';
import 'package:darkmodetoggle/screens/signin.dart';
import 'package:darkmodetoggle/screens/signup.dart';

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
        children: [(_loginStatus == 1) ? Nav('Home') : SignIn()],
      ),
      theme: ThemeData.dark(),
      debugShowCheckedModeBanner: false,
      routes: <String, WidgetBuilder>{
        '/signin': (BuildContext context) => SignIn(),
        '/signup': (BuildContext context) => SignUp(),
        '/stickerscreen': (BuildContext context) => StickerScreen(),
        '/friendsscreen': (BuildContext context) => Nav('Friends'),
        '/home': (BuildContext context) => Nav('Home'),
        '/leaderboard': (BuildContext context) => Nav('Leaderboard'),
      },
    );
  }

  var _loginStatus = 0;
  getPref() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      _loginStatus = preferences.getInt('value') ?? 0;
    });
  }
}
