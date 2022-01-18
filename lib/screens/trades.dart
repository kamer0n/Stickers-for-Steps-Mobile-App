import 'package:darkmodetoggle/backend/align_quantity.dart';
import 'package:darkmodetoggle/backend/sticker.dart';
import 'package:darkmodetoggle/backend/stickers_as_grid.dart';
import 'package:darkmodetoggle/backend/trades.dart';
import 'package:darkmodetoggle/screens/trade_response.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class TradeScreen extends StatefulWidget {
  const TradeScreen({Key? key}) : super(key: key);
  @override
  _TradeScreenState createState() => _TradeScreenState();
}

class _TradeScreenState extends State<TradeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: FutureBuilder<List<dynamic>>(
      future: getData(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          print(snapshot.error);
          print('snapshot error in tradescreen');
          return const Center(
            child: Text('An error has occurred!'),
          );
        } else if (snapshot.hasData) {
          List<Trade> trades = snapshot.data! as List<Trade>;
          return ListView.builder(
              itemCount: trades.length,
              itemBuilder: (context, index) {
                if (trades[index].tradeStatus == 1) {
                  return tradeCard(context, trades[index]);
                } else if (trades[index].tradeStatus == 2) {
                  return tradeCard(context, trades[index]);
                } else {
                  return tradeCard(context, trades[index], color: (Colors.red[300])!);
                }
              });
        } else {
          return const Center(child: CircularProgressIndicator());
        }
      },
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
}

Widget displayTradeGrid(Trade trade, String sOrR, {bool full = false}) {
  int end = 2;
  TextStyle tS = const TextStyle(fontSize: 12);
  List<Color> colors = [Colors.blue, Colors.red];
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
  if (full && sOrR == 's') {
    end = trade.senderStickers!.length;
  } else if (full && sOrR == 'r') {
    end = trade.receiverStickers!.length;
  } else {
    end = 2;
  }
  if (sOrR == 's') {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        info[0],
        SizedBox(
            height: 110,
            width: 300,
            child: Card(color: colors[0], child: stickersAsGrid(trade.senderStickers?.sublist(0, end), trade: true))),
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
            child: Card(color: colors[1], child: stickersAsGrid(trade.receiverStickers?.sublist(0, end), trade: true))),
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
