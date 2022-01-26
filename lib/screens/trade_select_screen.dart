import 'package:darkmodetoggle/backend/align_quantity.dart';
import 'package:darkmodetoggle/backend/friends.dart';
import 'package:darkmodetoggle/backend/sticker.dart';
import 'package:darkmodetoggle/backend/stickers_as_grid.dart';
import 'package:darkmodetoggle/backend/trades.dart';
import 'package:darkmodetoggle/screens/trade_friend_screen.dart';
import 'package:darkmodetoggle/screens/trade_response.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class TradeSelectScreen extends StatefulWidget {
  const TradeSelectScreen({Key? key, required this.friend}) : super(key: key);
  final Friend friend;
  @override
  _TradeSelectScreenState createState() => _TradeSelectScreenState();
}

class _TradeSelectScreenState extends State<TradeSelectScreen> {
  List<Sticker> senders = [];
  List<Sticker> receivers = [];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Trade to ${widget.friend.name}"),
          backgroundColor: Colors.black,
          centerTitle: true,
        ),
        body: Container(
          color: Colors.grey[800]!,
          child: FutureBuilder<List<dynamic>>(
              future: getData(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  print(snapshot.error);
                  print('snapshot error in trade select screen');
                  return const Center(
                    child: Text('An error has occurred!'),
                  );
                } else if (snapshot.hasData) {
                  Trade newTrade = Trade(
                      senderId: 1,
                      receiverId: int.parse(widget.friend.id),
                      senderStickers: senders,
                      receiverStickers: receivers);
                  return SingleChildScrollView(
                    child: Column(
                      children: [
                        tradeStickerCard(context, newTrade.senderStickers!, snapshot.data![1], false),
                        tradeStickerCard(context, newTrade.receiverStickers!, widget.friend, true),
                        ElevatedButton(
                            onPressed: () {
                              print("Sender stickers: ${newTrade.senderStickers}");
                              print("Sender stickers: ${newTrade.receiverStickers}");
                              setState(() {});
                            },
                            child: const Text(
                              "Send Trade",
                              textAlign: TextAlign.center,
                            ),
                            style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all<Color>(Colors.green),
                            ))
                      ],
                    ),
                  );
                } else {
                  return const Center(child: CircularProgressIndicator());
                }
              }),
        ));
  }

  Card tradeStickerCard(BuildContext context, List trades, var userID, bool sender) {
    print(userID);
    Color bg;
    if (userID.runtimeType == String) {
      userID = Friend(name: userID, id: '', fluff: '', avatar: '');
    }
    List<Widget> info = [
      alignQuantity("You send", Alignment.topCenter, 14),
      alignQuantity("You receive", Alignment.topCenter, 14)
    ];
    if (sender == false) {
      bg = Colors.red;
    } else {
      bg = Colors.blue;
      info = info.reversed.toList();
    }
    return Card(
      child: InkWell(
        onTap: () async {
          final result = await Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => Theme(
                      data: ThemeData(canvasColor: Colors.grey[900]),
                      child: TradeFriendScreen(
                        userID,
                        true,
                        trades as List<Sticker>,
                      ))));
          print("result in trade response: $result");
          if (sender) {
            for (var item in result) {
              receivers.add(item);
            }
          } else {
            for (var item in result) {
              senders.add(item);
            }
          }
          setState(() {});
        },
        child: Column(
          children: [
            info[0],
            stickersAsGrid(trades),
          ],
        ),
      ),
      color: bg,
    );
  }
}

Future<List<dynamic>> getData() async {
  SharedPreferences preferences = await SharedPreferences.getInstance();
  String? username = preferences.getString("username");
  List<dynamic> data = [];
  List<Trade> trades = await fetchTrades(http.Client());
  for (Trade trade in trades) {
    if (trade.senderStickers != null) {
      List<Sticker> stickers = [];
      for (Map<dynamic, dynamic> sticker in trade.senderStickers ?? []) {
        Sticker stick = (await fetchSingleSticker(id: sticker['id']))[0];
        stick.quantity = sticker['quantity'];
        stickers.add(stick);
      }
      trade.senderStickers = stickers;
    }
    if (trade.receiverStickers != null) {
      List<Sticker> stickers = [];
      for (Map<dynamic, dynamic> sticker in trade.receiverStickers ?? []) {
        Sticker stick = (await fetchSingleSticker(id: sticker['id']))[0];
        stick.quantity = sticker['quantity'];
        stickers.add(stick);
      }
      trade.receiverStickers = stickers;
    }
  }
  data.add(trades);
  data.add(username);
  return data;
}
