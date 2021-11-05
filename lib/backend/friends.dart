import 'dart:convert';
import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:darkmodetoggle/apis/api.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<List<Friend>> fetchFriends(http.Client client) async {
  SharedPreferences preferences = await SharedPreferences.getInstance();
  print(defaultToken);
  /* final response = await client.get(Uri.parse(stickerurl), headers: {
    "authorization": "TOKEN " + (preferences.getString('token') ?? defaultToken)
  }); */
  final response = await client.get(Uri.parse(friendsurl), headers: {"authorization": "TOKEN " + (defaultToken)});

  print(preferences.getString('token'));
  // Use the compute function to run parsePhotos in a separate isolate.
  return compute(parseFriend, response.body);
}

List<Friend> parseFriend(String responseBody) {
  final parsed = jsonDecode(responseBody);
  return parsed.map<Friend>((json) => Friend.fromJson(json)).toList();
}

class Friend {
  final String name;
  Friend({
    required this.name,
  });

  factory Friend.fromJson(Map<String, dynamic> json) {
    return Friend(
      name: json['user'],
    );
  }

  @override
  String toString() {
    return this.name;
  }
}

class FriendsList extends StatelessWidget {
  const FriendsList({Key? key, required this.Friends}) : super(key: key);

  final List<Friend> Friends;
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        physics: const NeverScrollableScrollPhysics(),
        scrollDirection: Axis.vertical,
        shrinkWrap: true,
        /* gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 1,
      ), */
        itemCount: Friends.length,
        itemBuilder: (context, index) {
          return Center(
              child: Card(
            child: InkWell(
                splashColor: Colors.blue.withAlpha(30),
                onTap: () {
                  print(Friends);
                },
                child: SizedBox(
                  child: Center(child: Text(Friends[index].name)),
                  height: 100,
                  width: 300,
                )),
          ));
        });
  }
}