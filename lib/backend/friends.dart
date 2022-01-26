import 'dart:convert';
import 'dart:async';

import 'package:darkmodetoggle/screens/friend_screen.dart';
import 'package:darkmodetoggle/screens/nav.dart';
import 'package:darkmodetoggle/screens/trade_select_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:darkmodetoggle/apis/api.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<List<Friend>> fetchFriends(http.Client client) async {
  SharedPreferences preferences = await SharedPreferences.getInstance();
  final token = preferences.getString('token') ?? defaultToken;
  final response = await client.get(Uri.parse(friendsurl), headers: {"authorization": "TOKEN " + (token)});
  return compute(parseFriend, response.body);
}

Future<List<Friend>> fetchSingleFriend(http.Client client, int id) async {
  SharedPreferences preferences = await SharedPreferences.getInstance();
  final token = preferences.getString('token') ?? defaultToken;
  Uri uri = Uri.parse(friendsurl + id.toString() + '/');
  final response = await client.post(uri,
      headers: {
        "Accept": "application/json",
        "Content-Type": "application/x-www-form-urlencoded",
        "authorization": ("TOKEN " + (token))
      },
      encoding: Encoding.getByName("utf-8"));
  return compute(parseFriend, response.body);
}

List<Friend> parseFriend(String responseBody) {
  final parsed = jsonDecode(responseBody);
  return parsed.map<Friend>((json) => Friend.fromJson(json)).toList();
}

class Friend {
  final String name;
  final String id;
  final String avatar;
  final String fluff;

  Friend({
    required this.name,
    required this.id,
    required this.avatar,
    required this.fluff,
  });

  factory Friend.fromJson(Map<String, dynamic> json) {
    return Friend(
      name: json['user'],
      id: json['id'].toString(),
      avatar: json['avatar'],
      fluff: json['fluff'],
    );
  }

  @override
  String toString() {
    return name;
  }
}

class FriendsList extends StatelessWidget {
  const FriendsList({Key? key, required this.friends, required this.type}) : super(key: key);

  final String type;
  final List<Friend> friends;
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        physics: const NeverScrollableScrollPhysics(),
        scrollDirection: Axis.vertical,
        shrinkWrap: true,
        /* gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 1,
      ), */
        itemCount: friends.length,
        itemBuilder: (context, index) {
          print(friends[index].avatar);
          return Center(child: friendType(context, index, type));
        });
  }

  InkWell friendType(BuildContext context, int index, String type) {
    Color bg = Colors.grey;
    return InkWell(
        splashColor: Colors.blue.withAlpha(30),
        onTap: () {
          if (type == 'friends') {
            Navigator.push(context, MaterialPageRoute(builder: (context) => (FriendScreen(friends[index], false))));
          }
        },
        child: Card(
          color: bg,
          child: SizedBox(
            child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
              Image.network(
                friends[index].avatar,
                height: 70,
                width: 70,
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    friends[index].name,
                    textScaleFactor: 1.3,
                  ),
                  (type == 'friends')
                      ? Text(
                          friends[index].fluff,
                          textScaleFactor: 0.6,
                        )
                      : Container(),
                  ElevatedButton(
                      style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all<Color>(Colors.red),
                          minimumSize: MaterialStateProperty.all<Size>(const Size(10, 20))),
                      onPressed: () {
                        if (type == 'friends') {
                          deletefriend(friends[index].id).then((value) {
                            Navigator.pop(context);
                            Navigator.push(
                              context,
                              PageRouteBuilder(
                                pageBuilder: (c, a1, a2) => Nav('Friends'),
                                transitionsBuilder: (c, anim, a2, child) => FadeTransition(opacity: anim, child: child),
                                transitionDuration: const Duration(milliseconds: 0),
                              ),
                            );
                          });
                        } else if (type == 'trade') {
                          Navigator.push(context,
                              MaterialPageRoute(builder: (context) => TradeSelectScreen(friend: friends[index])));
                        }
                      },
                      child: (type == 'friends') ? const Text('Delete') : const Text('Send trade')),
                ],
              ),
            ]),
            height: 100,
            width: 300,
          ),
        ));
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
  if (response.statusCode != 200) {}
}
