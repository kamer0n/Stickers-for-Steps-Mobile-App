import 'package:darkmodetoggle/backend/collection.dart';
import 'package:darkmodetoggle/backend/friend_sticker_list.dart';
import 'package:darkmodetoggle/backend/friends.dart';
import 'package:flutter/material.dart';

class FriendScreen extends StatefulWidget {
  Friend friend;
  FriendScreen(this.friend);

  _FriendScreenState createState() => _FriendScreenState();
}

class _FriendScreenState extends State<FriendScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          //widget.collection.name,
          widget.friend.name,
        ),
        backgroundColor: Colors.black87,
        centerTitle: true,
      ),
      body: ListView(
        //physics: const AlwaysScrollableScrollPhysics(),
        children: [
          FutureBuilder<List<Collection>>(
            future: fetchCollections(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return const Center(
                  child: Text('An error has occurred!'),
                );
              } else if (snapshot.hasData) {
                return FriendStickerList(snapshot.data!, widget.friend.name);
              } else {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
            },
          )
        ],
      ),
    );
  }
}
