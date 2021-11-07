import 'dart:convert';
import 'dart:async';

import 'package:darkmodetoggle/screens/home.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:darkmodetoggle/apis/api.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<List<Friend>> fetchFriends(http.Client client) async {
  SharedPreferences preferences = await SharedPreferences.getInstance();
  final token = preferences.getString('token') ?? defaultToken;
  final response = await client.get(Uri.parse(friendsurl), headers: {"authorization": "TOKEN " + (token)});
  //final response = await client.get(Uri.parse(friendsurl), headers: {"authorization": "TOKEN " + (defaultToken)});
  // Use the compute function to run parsePhotos in a separate isolate.
  return compute(parseFriend, response.body);
}

List<Friend> parseFriend(String responseBody) {
  final parsed = jsonDecode(responseBody);
  return parsed.map<Friend>((json) => Friend.fromJson(json)).toList();
}

class Friend {
  final String name;
  final String id;
  Friend({
    required this.name,
    required this.id,
  });

  factory Friend.fromJson(Map<String, dynamic> json) {
    return Friend(
      name: json['user'],
      id: json['id'].toString(),
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
                      print("ya boyyyy");
                      print(Friends);
                    },
                    child: SizedBox(
                      child: Column(children: [
                        Center(child: Text(Friends[index].name)),
                        ElevatedButton(
                            style: ButtonStyle(
                                backgroundColor: MaterialStateProperty.all<Color>(Colors.red),
                                minimumSize: MaterialStateProperty.all<Size>(Size(10, 20))),
                            onPressed: () {
                              deletefriend(Friends[index].id).then((value) {
                                Navigator.pop(context);
                                Navigator.push(
                                  context,
                                  PageRouteBuilder(
                                    pageBuilder: (c, a1, a2) => Home('Friends'),
                                    transitionsBuilder: (c, anim, a2, child) =>
                                        FadeTransition(opacity: anim, child: child),
                                    transitionDuration: Duration(milliseconds: 0),
                                  ),
                                );
                              });
                            },
                            child: Text('Delete')),
                      ]),
                      height: 100,
                      width: 300,
                    ))),
          );
        });
  }
}

deletefriend(id) async {
  SharedPreferences preferences = await SharedPreferences.getInstance();
  Uri uri = Uri.parse(frienddelete + id.toString() + '/');

  final response = await http.post(uri,
      headers: {
        "Accept": "application/json",
        "Content-Type": "application/x-www-form-urlencoded",
        "authorization": ("TOKEN " + (preferences.getString('token') ?? defaultToken))
      },
      encoding: Encoding.getByName("utf-8"));
  if (response.statusCode != 200) {
    print(response.body);
  }
}
