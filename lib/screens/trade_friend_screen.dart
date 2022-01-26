import 'package:darkmodetoggle/backend/collection.dart';
import 'package:darkmodetoggle/backend/friend_trade_sticker_list.dart';
import 'package:darkmodetoggle/backend/friends.dart';
import 'package:darkmodetoggle/backend/sticker.dart';
import 'package:flutter/material.dart';

// ignore: must_be_immutable
class TradeFriendScreen extends StatefulWidget {
  TradeFriendScreen(this.friend, this.trade, this.selected, {Key? key}) : super(key: key);
  Friend friend;
  bool trade;
  List<Sticker> selected;

  @override
  _TradeFriendScreenState createState() => _TradeFriendScreenState();
}

class _TradeFriendScreenState extends State<TradeFriendScreen> {
  //List<Sticker> selected = [];
  @override
  Widget build(BuildContext context) {
    print("trade in tradefriendscreen ${widget.trade}");
    return
        //physics: const AlwaysScrollableScrollPhysics(),
        FutureBuilder<List<Collection>>(
      future: fetchCollections(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(
            child: Text('An error has occurred!'),
          );
        } else if (snapshot.hasData) {
          return FriendTradeStickerList(snapshot.data!, widget.friend.name, widget.selected, trade: widget.trade);
        } else {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
      },
    );
  }
}
