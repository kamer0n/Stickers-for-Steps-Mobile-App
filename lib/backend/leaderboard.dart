import 'dart:convert';
import 'dart:async';

import 'package:darkmodetoggle/apis/add_friend.dart';
import 'package:darkmodetoggle/backend/scaffmanager.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:darkmodetoggle/apis/api.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<List<Leaderboard>> fetchLeaderboard(http.Client client) async {
  SharedPreferences preferences = await SharedPreferences.getInstance();
  final token = preferences.getString('token') ?? defaultToken;
  final response = await client.post(Uri.parse(leaderboardurl), headers: {"authorization": "TOKEN " + (token)});
  //final response = await client.get(Uri.parse(friendsurl), headers: {"authorization": "TOKEN " + (defaultToken)});
  // Use the compute function to run parsePhotos in a separate isolate.
  return compute(parseLeaderboard, response.body);
}

List<Leaderboard> parseLeaderboard(String responseBody) {
  final parsed = jsonDecode(responseBody);
  return parsed.map<Leaderboard>((json) => Leaderboard.fromJson(json)).toList();
}

class Leaderboard {
  final String name;
  final int count;
  final String friends;
  Leaderboard({
    required this.name,
    required this.count,
    required this.friends,
  });

  factory Leaderboard.fromJson(Map<String, dynamic> json) {
    return Leaderboard(
      name: json['name'],
      count: json['count'],
      friends: json['friends'],
    );
  }

  @override
  String toString() {
    return name;
  }
}

class LeaderboardView extends StatelessWidget {
  const LeaderboardView({Key? key, required this.leaderboard}) : super(key: key);

  final List<Leaderboard> leaderboard;
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        physics: const NeverScrollableScrollPhysics(),
        scrollDirection: Axis.vertical,
        shrinkWrap: true,
        /* gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 1,
      ), */
        itemCount: leaderboard.length,
        itemBuilder: (context, index) {
          Color bg = Color.fromRGBO(66, 66, 66, 1.0);
          if (index == 0) {
            bg = Color.fromRGBO(255, 215, 0, 100);
          } else if (index == 1) {
            bg = Color.fromRGBO(192, 192, 192, 100);
          } else if (index == 2) {
            bg = Color.fromRGBO(205, 127, 50, 100);
          } //else if (leaderboard[index].friends == 'self') {
          //bg = Colors.blue;
          //}

          return Center(
            child: Card(
                color: bg,
                child: InkWell(
                    splashColor: Colors.blue.withAlpha(30),
                    child: SizedBox(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Text(
                            (index + 1).toString(),
                            textScaleFactor: 3.0,
                          ),
                          Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                            Text(
                              leaderboard[index].name,
                              textScaleFactor: 1.4,
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              "Stickers collected: " + leaderboard[index].count.toString(),
                              textScaleFactor: 1.0,
                            ),
                            if ((leaderboard[index].friends == 'false'))
                              ElevatedButton(
                                style: ButtonStyle(
                                  backgroundColor: MaterialStateProperty.all<Color>(Colors.green),
                                ),
                                child: Icon(Icons.add),
                                onPressed: () {
                                  addFriendPost(leaderboard[index].name);
                                  popup(context, 'Friend request sent!');
                                },
                              ),
                            if ((leaderboard[index].friends == 'true'))
                              Text(
                                "Already friends!",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            if ((leaderboard[index].friends == 'self'))
                              Text(
                                "You",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                          ]),
                        ],
                      ),
                      height: 100,
                      width: 300,
                    ))),
          );
        });
  }
}
