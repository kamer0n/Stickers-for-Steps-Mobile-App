import 'dart:convert';

import 'package:darkmodetoggle/apis/api.dart';
import 'package:darkmodetoggle/backend/collection.dart';
import 'package:darkmodetoggle/backend/databasehandler.dart';
import 'package:darkmodetoggle/screens/nav.dart';
import 'package:flutter/material.dart';

import 'package:darkmodetoggle/screens/stickers_screen.dart';
import 'package:darkmodetoggle/screens/signin.dart';
import 'package:darkmodetoggle/screens/signup.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';

import 'package:http/http.dart' as http;

void main() {
  runApp(const MaterialApp(
    home: MyApp(),
  ));
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final StreamChatClient client = StreamChatClient(
    '5ceytf5njkme',
    //logLevel: Level.INFO,
  );

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
      builder: (context, child) {
        return StreamChat(
          streamChatThemeData: StreamChatThemeData(
            colorTheme: ColorTheme.dark(),
            messageListViewTheme: MessageListViewThemeData(backgroundColor: Colors.grey[900]),
            otherMessageTheme: MessageThemeData(messageBackgroundColor: Colors.grey[800]),
            messageInputTheme: MessageInputThemeData(
                inputBackgroundColor: Colors.grey[900],
                activeBorderGradient: const LinearGradient(
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                  colors: [
                    Colors.white,
                    Colors.white,
                  ],
                ),
                idleBorderGradient: const LinearGradient(
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                  colors: [
                    Colors.white,
                    Colors.white,
                  ],
                ),
                sendButtonIdleColor: Colors.grey[700]),
          ),
          client: client,
          child: child,
        );
      },
      home: Stack(
        children: [launchScreen()],
      ),
      theme: ThemeData.dark(),
      debugShowCheckedModeBanner: false,
      routes: <String, WidgetBuilder>{
        '/signin': (BuildContext context) => const SignIn(),
        '/signup': (BuildContext context) => const SignUp(),
        '/stickerscreen': (BuildContext context) => const StickerScreen(),
        '/friendsscreen': (BuildContext context) => Nav('Friends'),
        '/home': (BuildContext context) => Nav('Home'),
        '/leaderboard': (BuildContext context) => Nav('Leaderboard'),
      },
    );
  }

  Widget launchScreen() {
    if (_loginStatus == 1) {
      getClient();
      return Nav('Home');
    } else {
      return const SignIn();
    }
  }

  var _loginStatus = 0;
  getPref() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      _loginStatus = preferences.getInt('value') ?? 0;
      print(_loginStatus);
      if (_loginStatus == 1) {
        getClient();
      }
    });
  }

  getClient() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String? chatToken = preferences.getString("chatToken");
    if (chatToken == null) {
      final response = await http.post(Uri.parse(chatTokenUrl),
          headers: {
            "Accept": "application/json",
            "Content-Type": "application/x-www-form-urlencoded",
            "authorization": ("TOKEN " + (preferences.getString('token') ?? defaultToken))
          },
          encoding: Encoding.getByName("utf-8"));
      if (response.statusCode == 200) {
        Map<String, dynamic> resposne = jsonDecode(response.body);
        preferences.setString("chatToken", resposne["chatToken"]);
        chatToken = resposne["chatToken"];
      }
    }
  }
}
