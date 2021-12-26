import 'dart:convert';

import 'package:darkmodetoggle/backend/friend_requests.dart';
import 'package:flutter/material.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import 'package:darkmodetoggle/apis/api.dart';

Future<void> displayFriends(BuildContext context, {UniqueKey? key}) async {
  return showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('Friend Requests'),
        content: SizedBox(
          height: 300.0,
          width: 300.0,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: SingleChildScrollView(
                child: FutureBuilder<List<FriendRequest>>(
              future: fetchFriendRequests(http.Client()),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Center(
                    child: Text('An error has occurred!'),
                  );
                } else if (snapshot.hasData) {
                  return FriendRequestList(friendRequests: snapshot.data!);
                } else {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
              },
            )),
          ),
        ),
      );
    },
  );
}

requestresponse(id, type) async {
  SharedPreferences preferences = await SharedPreferences.getInstance();
  Uri uri;
  if (type == "accept") {
    uri = Uri.parse(friendaccept + id.toString() + '/');
  } else {
    uri = Uri.parse(frienddecline + id.toString() + '/');
  }

  final response = await http.post(uri,
      headers: {
        "Accept": "application/json",
        "Content-Type": "application/x-www-form-urlencoded",
        "authorization": ("TOKEN " + (preferences.getString('token') ?? defaultToken))
      },
      encoding: Encoding.getByName("utf-8"));
  if (response.statusCode == 200) {
    Map<String, dynamic> resposne = jsonDecode(response.body);
    if (resposne.containsKey('error')) {}
  }
}



//TODO decline function
//TODO delete function
