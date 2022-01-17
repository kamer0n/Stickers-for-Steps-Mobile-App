import 'package:darkmodetoggle/apis/add_friend.dart';
import 'package:darkmodetoggle/backend/friends.dart';
import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;

class FriendScreen extends StatefulWidget {
  const FriendScreen({Key? key}) : super(key: key);

  @override
  _FriendScreenState createState() => _FriendScreenState();
}

class _FriendScreenState extends State<FriendScreen> {
  bool isLoading = false;
  bool rebuild = false;

  @override
  Widget build(BuildContext context) {
    if (rebuild) {
      setState(() {
        rebuild = false;
      });
    }
    return Scaffold(
        //backgroundColor: Colors.black54,
        body: FutureBuilder<List<Friend>>(
          future: fetchFriends(http.Client()),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return const Center(
                child: Text('An error has occurred!'),
              );
            } else if (snapshot.hasData) {
              var list = FriendsList(friends: snapshot.data!);
              return ListView(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [list],
                    ),
                  )
                ],
              );
            } else {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
          },
        ),
        floatingActionButton: FloatingActionButton(
          splashColor: Colors.blue,
          onPressed: () {
            addFriendDialog(context, key: UniqueKey());
          },
          tooltip: 'Add Friend',
          child: const Icon(
            Icons.person_add,
            color: Colors.white,
          ),
        ));
  }
}
