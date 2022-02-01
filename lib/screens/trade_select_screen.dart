import 'dart:convert';

import 'package:darkmodetoggle/apis/api.dart';
import 'package:darkmodetoggle/backend/align_quantity.dart';
import 'package:darkmodetoggle/backend/friends.dart';
import 'package:darkmodetoggle/backend/scaffmanager.dart';
import 'package:darkmodetoggle/backend/sticker.dart';
import 'package:darkmodetoggle/backend/stickers_as_grid.dart';
import 'package:darkmodetoggle/backend/trades.dart';
import 'package:darkmodetoggle/screens/trade_friend_screen.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class TradeSelectScreen extends StatefulWidget {
  TradeSelectScreen({Key? key, required this.friend, this.trade}) : super(key: key);
  final Friend friend;
  Trade? trade;
  @override
  _TradeSelectScreenState createState() => _TradeSelectScreenState();
}

class _TradeSelectScreenState extends State<TradeSelectScreen> {
  List<Sticker> senders = [];
  List<Sticker> receivers = [];
  @override
  Widget build(BuildContext context) {
    if (widget.trade != null) {
      senders = widget.trade?.senderStickers as List<Sticker>;
      receivers = widget.trade?.receiverStickers as List<Sticker>;
      widget.trade = null;
    }
    return Scaffold(
        backgroundColor: Colors.grey[800],
        appBar: AppBar(
            title: Text("Trade to ${widget.friend.name}"),
            backgroundColor: Colors.black,
            centerTitle: true,
            leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
                onPressed: () {
                  Navigator.pop(context, 'cancel');
                })),
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
                  senders = senders.toSet().toList();
                  receivers = receivers.toSet().toList();
                  Trade newTrade = Trade(
                      senderId: 1,
                      receiverId: int.parse(widget.friend.id),
                      senderStickers: senders,
                      receiverStickers: receivers,
                      sender: true);
                  return SingleChildScrollView(
                    child: Column(
                      children: [
                        tradeStickerCard(context, newTrade.senderStickers!, snapshot.data![1], false),
                        tradeStickerCard(context, newTrade.receiverStickers!, widget.friend, true),
                        ElevatedButton(
                            onPressed: () {
                              _onLoading();
                              postTrade(senders, receivers, widget.friend.id).then((value) {
                                if (value == 0) {
                                  //Navigator.pop(context);
                                  Navigator.pop(context);
                                  popup(context, "Trade sent succesfully!");
                                  Navigator.pop(context, 'sent');
                                } else if (value == 1) {
                                  popup(context, "A trade between these users already exists");
                                }
                                Navigator.pop(context);
                              });
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

  void _onLoading() {
    showDialog(
      context: context,
      barrierDismissible: false,
      useRootNavigator: false,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: SizedBox(
            height: 50,
            width: 50,
            child: Column(
              children: const [
                CircularProgressIndicator(),
              ],
            ),
          ),
        );
      },
    );
  }

  Card tradeStickerCard(BuildContext context, List trades, var userID, bool sender) {
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
          if (sender) {
            receivers = [];
            for (var item in result) {
              item.quantity = 1;
              receivers.add(item);
            }
          } else {
            senders = [];
            for (var item in result) {
              item.quantity = 1;
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

Future<int> postTrade(List<Sticker> senderStickers, List<Sticker> receiverStickers, String receiverID) async {
  SharedPreferences preferences = await SharedPreferences.getInstance();
  List<Map<String, int>> sendSticks = [];
  List<Map<String, int>> recvSticks = [];
  for (Sticker sticker in senderStickers) {
    Map<String, int> map = {};
    map['sticker'] = sticker.id;
    map['quantity'] = sticker.quantity!;
    sendSticks.add(map);
  }
  for (Sticker sticker in receiverStickers) {
    Map<String, int> map = {};
    map['sticker'] = sticker.id;
    map['quantity'] = sticker.quantity!;
    recvSticks.add(map);
  }
  //Map<String, List<Map<String, int>>> senderMap = {"sender_stickers": sendSticks};
  //Map<String, List<Map<String, int>>> receiverMap = {"receiver_stickers": recvSticks};

  final response = await http.Client().post(
    Uri.parse(tradeURL),
    body: jsonEncode(<String, dynamic>{
      "receiver": int.parse(receiverID),
      "sender_stickers": sendSticks,
      "receiver_stickers": recvSticks,
    }),
    headers: {
      "authorization": "TOKEN " + (preferences.getString('token') ?? defaultToken),
      'Content-Type': 'application/json; charset=UTF-8',
    },
  );

  print(response.body);
  Map<String, dynamic> code = jsonDecode(response.body);
  if (code['message'] == "A trade between these users already exists") {
    return 1;
  } else if (code['message'] == "Trade sent successfully") {
    return 0;
  }

  return 1;
}
