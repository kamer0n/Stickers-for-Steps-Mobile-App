import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import 'api.dart';

TextEditingController _textFieldController = TextEditingController();

Future<void> displayTextInputDialog(BuildContext context, {UniqueKey? key}) async {
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
              String url = (addfriendurl + _textFieldController.text + '/');
              await http.post(Uri.parse(url),
                  headers: {"authorization": "TOKEN " + (preferences.getString('token') ?? defaultToken)});
              Navigator.pop(context);
            },
          ),
        ],
      );
    },
  );
}
