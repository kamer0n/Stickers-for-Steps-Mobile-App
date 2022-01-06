import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import 'package:darkmodetoggle/apis/api.dart';

TextEditingController _textFieldController = TextEditingController();

Future<void> addFriendDialog(BuildContext context, {UniqueKey? key}) async {
  return showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('Enter username'),
        content: TextField(
          controller: _textFieldController,
          decoration: const InputDecoration(hintText: "Username"),
        ),
        actions: <Widget>[
          TextButton(
            child: const Text('CANCEL'),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          TextButton(
            child: const Text('OK'),
            onPressed: () async {
              addFriendPost(_textFieldController.text);
              Navigator.pop(context);
            },
          ),
        ],
      );
    },
  );
}

Future<void> addFriendPost(String user) async {
  SharedPreferences preferences = await SharedPreferences.getInstance();
  String url = (addfriendurl + user + '/');
  await http
      .post(Uri.parse(url), headers: {"authorization": "TOKEN " + (preferences.getString('token') ?? defaultToken)});
}
