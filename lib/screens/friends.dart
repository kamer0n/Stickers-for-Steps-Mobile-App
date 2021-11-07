import 'package:darkmodetoggle/apis/add_friend.dart';
import 'package:darkmodetoggle/backend/friends.dart';
import 'package:flutter/material.dart';

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
          child: SingleChildScrollView(
              child: FutureBuilder<List<Friend>>(
            future: fetchFriends(http.Client()),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                print(snapshot.error);
                return const Center(
                  child: Text('An error has occurred!'),
                );
              } else if (snapshot.hasData) {
                var list = FriendsList(Friends: snapshot.data!);
                return list;
              } else {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
            },
          )),
        ),
        floatingActionButton: FloatingActionButton(
          splashColor: Colors.blue,
          onPressed: () {
            displayTextInputDialog(context, key: UniqueKey());
          },
          tooltip: 'Increment',
          child: const Icon(Icons.add),
        ));
  }
}
