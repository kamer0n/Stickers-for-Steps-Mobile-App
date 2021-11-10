import 'dart:convert';
import 'dart:async';

import 'package:darkmodetoggle/screens/friend_requests.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:darkmodetoggle/apis/api.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<List<FriendRequest>> fetchFriendRequests(http.Client client) async {
  SharedPreferences preferences = await SharedPreferences.getInstance();
  final response = await client.get(Uri.parse(friendrequestul),
      headers: {"authorization": "TOKEN " + (preferences.getString('token') ?? defaultToken)});
  return compute(parseFriendRequest, response.body);
}

List<FriendRequest> parseFriendRequest(String responseBody) {
  final parsed = jsonDecode(responseBody);
  return parsed.map<FriendRequest>((json) => FriendRequest.fromJson(json)).toList();
}

class FriendRequest {
  final String name;
  final int id;
  final String rejected;
  FriendRequest({
    required this.name,
    required this.id,
    required this.rejected,
  });

  factory FriendRequest.fromJson(Map<String, dynamic> json) {
    return FriendRequest(name: json['from_user'], id: json['id'], rejected: json['rejected'].toString());
  }

  @override
  String toString() {
    return name;
  }
}

class FriendRequestList extends StatelessWidget {
  const FriendRequestList({Key? key, required this.friendRequests}) : super(key: key);

  final List<FriendRequest> friendRequests;
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        physics: const NeverScrollableScrollPhysics(),
        scrollDirection: Axis.vertical,
        shrinkWrap: true,
        /* gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 1,
      ), */
        itemCount: friendRequests.length,
        itemBuilder: (context, index) {
          if (friendRequests[index].rejected == 'null') {
            return Center(
                child: Card(
              color: Colors.black,
              child: SizedBox(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Padding(
                        child: SizedBox(
                          child: Card(
                            child: Text(friendRequests[index].name),
                            color: Colors.pink,
                          ),
                          height: 25,
                          width: 100,
                        ),
                        padding: EdgeInsets.only(top: 15.0)),
                    Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
                      ElevatedButton(
                        style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all<Color>(Colors.green),
                            minimumSize: MaterialStateProperty.all<Size>(Size(10, 20))),
                        child: Icon(Icons.check),
                        onPressed: () {
                          requestresponse(friendRequests[index].id, 'accept');
                          Navigator.pop(context);
                          displayFriends(context, key: UniqueKey());
                        },
                      ),
                      ElevatedButton(
                        style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all<Color>(Colors.red),
                            minimumSize: MaterialStateProperty.all<Size>(Size(10, 20))),
                        child: Icon(Icons.close),
                        onPressed: () {
                          requestresponse(friendRequests[index].id, 'decline');
                          Navigator.pop(context);
                          displayFriends(context, key: UniqueKey());
                        },
                      ),
                    ]),
                  ],
                ),
                height: 100,
                width: 300,
              ),
            ));
          } else {
            return Text('oops');
          }
        });
  }
}
