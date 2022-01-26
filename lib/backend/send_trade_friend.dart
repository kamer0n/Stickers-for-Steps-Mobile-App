import 'package:darkmodetoggle/backend/friends.dart';
import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;

Future<void> displayTradeFriends(BuildContext context, {UniqueKey? key}) async {
  return showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('Select friend'),
        content: SizedBox(
          height: 300.0,
          width: 300.0,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: SingleChildScrollView(
                child: FutureBuilder<List<Friend>>(
              future: fetchFriends(http.Client()),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Center(
                    child: Text('An error has occurred!'),
                  );
                } else if (snapshot.hasData) {
                  return FriendsList(friends: snapshot.data!, type: 'trade');
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
