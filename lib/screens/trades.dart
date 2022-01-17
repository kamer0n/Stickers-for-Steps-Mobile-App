import 'package:darkmodetoggle/backend/sticker.dart';
import 'package:darkmodetoggle/backend/trades.dart';
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
          return const Center(
            child: Text('An error has occurred!'),
          );
        } else if (snapshot.hasData) {
          print(snapshot.data);
          List<Trade> trades = snapshot.data! as List<Trade>;
          print(trades[0].senderStickers);
          print(trades[0].receiverStickers);
          return Text(trades[0].receiverStickers.toString());
        } else {
          return const Center(child: CircularProgressIndicator());
        }
      },
    ));
  }
}

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
