import 'package:darkmodetoggle/backend/align_quantity.dart';
import 'package:darkmodetoggle/backend/stickers_as_grid.dart';
import 'package:darkmodetoggle/backend/trades.dart';
import 'package:flutter/material.dart';

class TradeResponseScreen extends StatefulWidget {
  Trade trade;
  TradeResponseScreen(this.trade, {Key? key}) : super(key: key);
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
          stickerCard(widget.trade.senderStickers!, 'sender', widget.trade.sender),
          stickerCard(widget.trade.receiverStickers!, 'receiver', widget.trade.sender),
          statusDependence(widget.trade)
        ],
      ),
    );
  }

  Row statusDependence(Trade trade) {
    if (trade.tradeStatus == 1) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton(
              style: ButtonStyle(backgroundColor: MaterialStateProperty.all<Color>(Colors.green)),
              onPressed: () {},
              child: const Icon(Icons.check)),
          const SizedBox(
            width: 10,
          ),
          ElevatedButton(
              style: ButtonStyle(backgroundColor: MaterialStateProperty.all<Color>(Colors.red)),
              onPressed: () {},
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
}

Widget stickerCard(List trades, String type, bool sender) {
  Color bg;

  List<Widget> info = [
    alignQuantity("You send", Alignment.topCenter, 14),
    alignQuantity("You receive", Alignment.topCenter, 14)
  ];
  if (sender == false && type == 'receiver') {
    bg = Colors.blue;
  } else if (sender == true && type == 'sender') {
    bg = Colors.blue;
  } else {
    bg = Colors.red;
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
