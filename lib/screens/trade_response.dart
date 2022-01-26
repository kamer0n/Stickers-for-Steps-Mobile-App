import 'dart:convert';

import 'package:darkmodetoggle/apis/api.dart';
import 'package:darkmodetoggle/backend/align_quantity.dart';
import 'package:darkmodetoggle/backend/scaffmanager.dart';
import 'package:darkmodetoggle/backend/stickers_as_grid.dart';
import 'package:darkmodetoggle/backend/trades.dart';
import 'package:darkmodetoggle/screens/nav.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class TradeResponseScreen extends StatefulWidget {
  final Trade trade;
  const TradeResponseScreen(this.trade, {Key? key}) : super(key: key);
  @override
  _TradeResponseScreenState createState() => _TradeResponseScreenState();
}

class _TradeResponseScreenState extends State<TradeResponseScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.trade.toString(),
        ),
        backgroundColor: Colors.black87,
        centerTitle: true,
      ),
      body: ListView(
        physics: const ClampingScrollPhysics(),
        children: [
          stickerCard(widget.trade.senderStickers!, 'sender', widget.trade.sender!),
          stickerCard(widget.trade.receiverStickers!, 'receiver', widget.trade.sender!),
          statusDependence(context, widget.trade)
        ],
      ),
    );
  }

  Widget statusDependence(BuildContext context, Trade trade) {
    if (trade.tradeStatus == 1) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton(
              style: ButtonStyle(backgroundColor: MaterialStateProperty.all<Color>(Colors.green)),
              onPressed: () {
                _onLoading();
                tradeResponse(context, trade, "accept").then((value) {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (c, a1, a2) => Nav('Trade'),
                      transitionsBuilder: (c, anim, a2, child) => FadeTransition(opacity: anim, child: child),
                      transitionDuration: const Duration(milliseconds: 0),
                    ),
                  );
                });
              },
              child: const Icon(Icons.check)),
          const SizedBox(
            width: 10,
          ),
          ElevatedButton(
              style: ButtonStyle(backgroundColor: MaterialStateProperty.all<Color>(Colors.red)),
              onPressed: () {
                tradeResponse(context, trade, "decline").then((value) {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (c, a1, a2) => Nav('Trade'),
                      transitionsBuilder: (c, anim, a2, child) => FadeTransition(opacity: anim, child: child),
                      transitionDuration: const Duration(milliseconds: 0),
                    ),
                  );
                });
              },
              child: const Icon(Icons.close))
        ],
      );
    } else {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [Text(trade.statusString())],
      );
    }
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
}

Widget stickerCard(List trades, String type, bool sender) {
  Color bg;

  List<Widget> info = [
    alignQuantity("You send", Alignment.topCenter, 14),
    alignQuantity("You receive", Alignment.topCenter, 14)
  ];
  if (sender == false && type == 'receiver') {
    bg = Colors.red;
  } else if (sender == true && type == 'sender') {
    bg = Colors.red;
  } else {
    bg = Colors.blue;
    info = info.reversed.toList();
  }
  return Card(
      child: Column(
        children: [
          info[0],
          stickersAsGrid(trades),
        ],
      ),
      color: bg);
}

Future<void> tradeResponse(BuildContext context, Trade trade, String type) async {
  SharedPreferences preferences = await SharedPreferences.getInstance();
  String url = (tradeResponseURL);
  String message = "Error";
  int status = 0;
  if (type == 'accept') {
    status = 2;
    message = "Trade accepted successfully";
  } else if (type == 'decline') {
    status = 3;
    message = "Trade declined successfully";
  } else if (type == 'counter') {
    status = 4;
    message = "Trade countered successfully";
  } else {
    status = 0;
    message = "Error";
  }
  final response = await http.post(Uri.parse(url),
      headers: {
        "Accept": "application/json",
        "Content-Type": "application/x-www-form-urlencoded",
        "authorization": ("TOKEN " + (preferences.getString('token') ?? defaultToken))
      },
      encoding: Encoding.getByName("utf-8"),
      body: <String, String>{
        "trade_id": trade.tradeId.toString(),
        "status": status.toString(),
      });
  if (response.statusCode == 200) {
    print(response.body);
    Map<String, dynamic> resp = jsonDecode(response.body);
    popup(context, resp['message']!, seconds: 4);
  }
}
