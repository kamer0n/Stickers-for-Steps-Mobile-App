import 'package:darkmodetoggle/backend/align_quantity.dart';
import 'package:darkmodetoggle/backend/send_trade_friend.dart';
import 'package:darkmodetoggle/backend/sticker.dart';
import 'package:darkmodetoggle/backend/stickers_as_grid.dart';
import 'package:darkmodetoggle/backend/trades.dart';
import 'package:darkmodetoggle/screens/nav.dart';
import 'package:darkmodetoggle/screens/trade_response.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:matomo/matomo.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TradeScreen extends TraceableStatefulWidget {
  const TradeScreen({Key? key}) : super(key: key);
  @override
  _TradeScreenState createState() => _TradeScreenState();
}

class _TradeScreenState extends State<TradeScreen> {
  bool isSender = true;
  bool isReceiver = true;
  bool isAccepted = false;
  bool isDeclined = false;
  bool isCountered = false;
  bool isInvalid = false;
  bool isCancelled = false;
  List<Trade> trades = [];
  @override
  Widget build(BuildContext context) {
    MatomoTracker.trackScreen(context, 'visited trade screen');
    return Scaffold(
        appBar: _appBar(),
        body: RefreshIndicator(
          onRefresh: () {
            Navigator.pop(context);
            return Navigator.push(
              context,
              PageRouteBuilder(
                pageBuilder: (c, a1, a2) => Nav('Trade'),
                transitionsBuilder: (c, anim, a2, child) => FadeTransition(opacity: anim, child: child),
                transitionDuration: const Duration(milliseconds: 0),
              ),
            );
            //throw e;
          },
          child: FutureBuilder<List<dynamic>>(
            future: getData(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                print(snapshot.error);
                print('snapshot error in tradescreen');
                return const Center(
                  child: Text('An error has occurred!'),
                );
              } else if (snapshot.hasData) {
                List<Trade> _trades = snapshot.data! as List<Trade>;
                trades = [];

                if (isSender) {
                  trades.addAll(_trades
                      .where((i) =>
                          i.sender &&
                          (i.tradeStatus != 3 && i.tradeStatus != 4 && i.tradeStatus != 5 && i.tradeStatus != 6))
                      .toList());
                }
                if (isReceiver) {
                  trades.addAll(_trades
                      .where((i) =>
                          i.sender == false &&
                          (i.tradeStatus != 3 && i.tradeStatus != 4 && i.tradeStatus != 5 && i.tradeStatus != 6))
                      .toList());
                }
                if (isAccepted) {
                  trades.addAll(_trades.where((i) => i.tradeStatus == 2).toList());
                }
                if (isDeclined) {
                  trades.addAll(_trades.where((i) => i.tradeStatus == 3).toList());
                }
                if (isCountered) {
                  trades.addAll(_trades.where((i) => i.tradeStatus == 4).toList());
                }
                if (isInvalid) {
                  trades.addAll(_trades.where((i) => i.tradeStatus! < 1 && i.tradeStatus! > 4).toList());
                }
                if (isCancelled) {
                  trades.addAll(_trades.where((i) => i.tradeStatus == 6).toList());
                }
                if (!isSender &&
                    !isReceiver &&
                    !isAccepted &&
                    !isDeclined &&
                    !isCountered &&
                    !isInvalid &&
                    !isCancelled) {
                  trades = _trades;
                }
                return ListView.builder(
                    itemCount: trades.length,
                    itemBuilder: (context, index) {
                      if (trades[index].tradeStatus == 1) {
                        return tradeCard(context, trades[index]);
                      } else if (trades[index].tradeStatus == 2) {
                        return tradeCard(context, trades[index], color: (Colors.lightGreen[700])!);
                      } else {
                        return tradeCard(context, trades[index], color: (Colors.red[300])!);
                      }
                    });
              } else {
                return const Center(child: CircularProgressIndicator());
              }
            },
          ),
        ),
        floatingActionButton: FloatingActionButton(
          splashColor: Colors.blue,
          onPressed: () {
            displayTradeFriends(context);
          },
          tooltip: 'Send Trade',
          child: const Icon(
            Icons.send,
            color: Colors.white,
          ),
        ));
  }

  Card tradeCard(BuildContext context, Trade trade, {Color color = Colors.black12}) {
    return Card(
      color: color,
      child: InkWell(
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => TradeResponseScreen(trade)));
        },
        child: Column(
          children: [
            alignQuantity("Trade from ${trade.senderName} to ${trade.receiverName}", Alignment.topCenter, 24),
            alignQuantity(trade.statusString(), Alignment.topCenter, 12),
            displayTradeGrid(trade, 's'),
            displayTradeGrid(trade, 'r'),
          ],
        ),
      ),
    );
  }

  AppBar _appBar() {
    return AppBar(
      leading: InkWell(
        child: const Icon(Icons.logout),
        onTap: () async {
          SharedPreferences preferences = await SharedPreferences.getInstance();
          preferences.clear();
          Navigator.popUntil(context, (route) => false);
          Navigator.pushNamed(context, "/signin");
        },
      ),
      title: const Text(
        "Stickers for Steps",
      ),
      backgroundColor: Colors.black87,
      centerTitle: true,
      actions: <Widget>[
        Padding(
          padding: const EdgeInsets.only(right: 20.0),
          child: PopupMenuButton(
            padding: const EdgeInsets.all(2.0),
            child: const Icon(Icons.filter_alt_outlined),
            offset: Offset.fromDirection(1.5, 50),
            itemBuilder: (context) {
              return popUpItems();
            },
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
          ),
        ),
      ],
    );
  }

  List<PopupMenuItem<String>> popUpItems() {
    return [
      PopupMenuItem(
        value: 'sent',
        child: StatefulBuilder(builder: (_context, _setState) {
          return CheckboxListTile(
            activeColor: Colors.blue,
            value: isSender,
            onChanged: (value) => _setState(() {
              isSender = value!;
              setState(() {});
            }),
            title: const Text('Sent'),
          );
        }),
      ),
      PopupMenuItem(
        value: 'received',
        child: StatefulBuilder(builder: (_context, _setState) {
          return CheckboxListTile(
            activeColor: Colors.blue,
            value: isReceiver,
            onChanged: (value) => _setState(() {
              isReceiver = value!;
              setState(() {});
            }),
            title: const Text('Received'),
          );
        }),
      ),
      PopupMenuItem(
        value: 'accepted',
        child: StatefulBuilder(builder: (_context, _setState) {
          return CheckboxListTile(
            activeColor: Colors.blue,
            value: isAccepted,
            onChanged: (value) => _setState(() {
              isAccepted = value!;
              setState(() {});
            }),
            title: const Text('Accepted'),
          );
        }),
      ),
      PopupMenuItem(
        value: 'declined',
        child: StatefulBuilder(builder: (_context, _setState) {
          return CheckboxListTile(
            activeColor: Colors.blue,
            value: isDeclined,
            onChanged: (value) => _setState(() {
              isDeclined = value!;
              setState(() {});
            }),
            title: const Text('Declined'),
          );
        }),
      ),
      PopupMenuItem(
        value: 'countered',
        child: StatefulBuilder(builder: (_context, _setState) {
          return CheckboxListTile(
            activeColor: Colors.blue,
            value: isCountered,
            onChanged: (value) => _setState(() {
              isCountered = value!;
              setState(() {});
            }),
            title: const Text('Countered'),
          );
        }),
      ),
      PopupMenuItem(
        value: 'invalid',
        child: StatefulBuilder(builder: (_context, _setState) {
          return CheckboxListTile(
            activeColor: Colors.blue,
            value: isInvalid,
            onChanged: (value) => _setState(() {
              isInvalid = value!;
              setState(() {});
            }),
            title: const Text('Invalid'),
          );
        }),
      ),
      PopupMenuItem(
        value: 'cancelled',
        child: StatefulBuilder(builder: (_context, _setState) {
          return CheckboxListTile(
            activeColor: Colors.blue,
            value: isCancelled,
            onChanged: (value) => _setState(() {
              isCancelled = value!;
              setState(() {});
            }),
            title: const Text('Cancelled'),
          );
        }),
      ),
    ];
  }
}

Widget displayTradeGrid(Trade trade, String sOrR, {bool full = false}) {
  int sendEnd = 2;
  int recvEnd = 2;
  TextStyle tS = const TextStyle(fontSize: 12);
  List<Color> colors = [Colors.red, Colors.blue];
  List<Widget> info = [
    Text(
      "You\nsend   ",
      style: tS,
      textAlign: TextAlign.center,
    ),
    Text(
      "You\nreceive",
      style: tS,
      textAlign: TextAlign.center,
    ),
  ];

  if (trade.sender == false) {
    info = info.reversed.toList();
    colors = colors.reversed.toList();
  }
  if (sOrR == 's') {
    try {
      sendEnd = trade.senderStickers!.length;
      if (sendEnd > 2) {
        sendEnd = 2;
      }
    } catch (e) {
      sendEnd = 1;
    }
  } else if (sOrR == 'r') {
    try {
      recvEnd = trade.receiverStickers!.length;
      if (recvEnd > 2) {
        recvEnd = 2;
      }
    } catch (e) {
      recvEnd = 1;
    }
  }
  if (sOrR == 's') {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        info[0],
        SizedBox(
            height: 110,
            width: 300,
            child:
                Card(color: colors[0], child: stickersAsGrid(trade.senderStickers?.sublist(0, sendEnd), trade: true))),
      ],
    );
  } else {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        info[1],
        SizedBox(
            height: 110,
            width: 300,
            child: Card(
                color: colors[1], child: stickersAsGrid(trade.receiverStickers?.sublist(0, recvEnd), trade: true))),
      ],
    );
  }
}

//Widget recvSend(Trade trade){
//
//}

Future<List<dynamic>> getData() async {
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
  return data[0];
}
