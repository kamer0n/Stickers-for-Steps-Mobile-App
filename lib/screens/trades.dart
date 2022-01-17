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
        body: FutureBuilder<List<Trade>>(
      future: fetchTrades(http.Client()),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          print(snapshot.error);
          return const Center(
            child: Text('An error has occurred!'),
          );
        } else if (snapshot.hasData) {
          print(snapshot.data);
          print(snapshot.data![0].receiverStickers);
          //print(fetchSingleSticker(id: snapshot.data![0].senderStickers![0].id));
          return Text('lol');
        } else {
          return const Center(child: CircularProgressIndicator());
        }
      },
    ));
  }
}
