import 'package:darkmodetoggle/backend/alignQuantity.dart';
import 'package:darkmodetoggle/backend/collection.dart';
import 'package:darkmodetoggle/backend/friend_sticker_list.dart';
import 'package:darkmodetoggle/backend/friends.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

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
      body:
          //physics: const AlwaysScrollableScrollPhysics(),
          FutureBuilder<List<Collection>>(
        future: fetchCollections(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(
              child: Text('An error has occurred!'),
            );
          } else if (snapshot.hasData) {
            return Column(
              children: [
                Card(
                  shape: ContinuousRectangleBorder(),
                  child: SizedBox(
                      height: 200,
                      width: MediaQuery.of(context).size.width,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Padding(
                            padding: EdgeInsets.fromLTRB(22, 0, 0, 0),
                          ),
                          Expanded(child: SvgPicture.network(widget.friend.avatar)),
                          Expanded(child: alignQuantity(widget.friend.name, Alignment.centerLeft, 30))
                        ],
                      )),
                  color: Colors.grey[600],
                ),
                Flexible(
                  child: SingleChildScrollView(
                    child: FriendStickerList(snapshot.data!, widget.friend.name),
                    physics: AlwaysScrollableScrollPhysics(),
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
    );
  }
}
