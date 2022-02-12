import 'package:darkmodetoggle/backend/align_quantity.dart';
import 'package:darkmodetoggle/backend/collection.dart';
import 'package:darkmodetoggle/backend/friend_sticker_list.dart';
import 'package:darkmodetoggle/backend/friends.dart';
import 'package:darkmodetoggle/backend/sticker.dart';
import 'package:flutter/material.dart';
import 'package:matomo/matomo.dart';

// ignore: must_be_immutable
class FriendScreen extends TraceableStatefulWidget {
  FriendScreen(this.friend, this.trade, {Key? key}) : super(key: key);
  Friend friend;
  bool trade;

  @override
  _FriendScreenState createState() => _FriendScreenState();
}

class _FriendScreenState extends State<FriendScreen> {
  List<Sticker> selected = [];
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
          leading: widget.trade
              ? IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
                  onPressed: () => Navigator.of(context).pop(selected),
                )
              : null),
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
                widget.trade == false
                    ? Card(
                        shape: const ContinuousRectangleBorder(),
                        child: SizedBox(
                            height: 200,
                            width: MediaQuery.of(context).size.width,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Padding(
                                  padding: EdgeInsets.fromLTRB(22, 0, 0, 0),
                                ),
                                Expanded(child: Image.network(widget.friend.avatar)),
                                Expanded(child: alignQuantity(widget.friend.name, Alignment.centerLeft, 30))
                              ],
                            )),
                        color: Colors.grey[600],
                      )
                    : Container(),
                Flexible(
                    child: SingleChildScrollView(
                        child: FriendStickerList(snapshot.data!, widget.friend.name, trade: widget.trade)))
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
