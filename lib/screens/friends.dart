import 'package:darkmodetoggle/apis/api.dart';
import 'package:darkmodetoggle/backend/friends.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:darkmodetoggle/backend/sticker.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'package:http/http.dart' as http;

class FriendScreen extends StatefulWidget {
  @override
  _FriendScreenState createState() => _FriendScreenState();
}

class _FriendScreenState extends State<FriendScreen> {
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.black54,
        body: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child:
              /* WebView(
            javascriptMode: JavascriptMode.unrestricted,
            initialUrl: 'http://188.166.153.138',
            onPageFinished: (value) {
              setState(() {
                isLoading = true;
              });
            },
          ), */
              SingleChildScrollView(
                  child: FutureBuilder<List<Friend>>(
            future: fetchFriends(http.Client()),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                print(snapshot.error);
                return const Center(
                  child: Text('An error has occurred!'),
                );
              } else if (snapshot.hasData) {
                return FriendsList(Friends: snapshot.data!);
              } else {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
            },
          )),
          /* (!isLoading)
              ? const Center(
                  child: CircularProgressIndicator(
                    backgroundColor: Colors.green,
                  ),
                )
              : Container() */
        ),
        floatingActionButton: new FloatingActionButton(
          splashColor: Colors.blue,
          onPressed: () {
            _displayTextInputDialog(context, key: UniqueKey());
          },
          tooltip: 'Increment',
          child: new Icon(Icons.add),
        ));
  }
}

TextEditingController _textFieldController = TextEditingController();

Future<void> _displayTextInputDialog(BuildContext context, {UniqueKey? key}) async {
  return showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text('Enter username'),
        content: TextField(
          controller: _textFieldController,
          decoration: InputDecoration(hintText: "Username"),
        ),
        actions: <Widget>[
          TextButton(
            child: Text('CANCEL'),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          TextButton(
            child: Text('OK'),
            onPressed: () async {
              SharedPreferences preferences = await SharedPreferences.getInstance();
              print(_textFieldController.text);
              print(preferences.getString('token'));
              print(addfriendurl);
              String url = (addfriendurl + _textFieldController.text + '/');
              print(url);
              var jeff = await http.post(Uri.parse(url),
                  headers: {"authorization": "TOKEN " + (preferences.getString('token') ?? defaultToken)});
              print(jeff.body);
              Navigator.pop(context);
            },
          ),
        ],
      );
    },
  );
}
