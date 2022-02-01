import 'dart:convert';

import 'package:darkmodetoggle/backend/align_quantity.dart';
import 'package:darkmodetoggle/backend/sticker.dart';
import 'package:flutter/material.dart';

class TradeStickerGrid extends StatefulWidget {
  TradeStickerGrid(this.friend, this.snapshot, this.trade, this.selected, this.collection, {Key? key})
      : super(key: key);
  dynamic snapshot;
  dynamic friend;
  bool trade;
  String collection;
  List<dynamic> selected = [];
  @override
  _TradeStickerGridState createState() => _TradeStickerGridState();
}

class _TradeStickerGridState extends State<TradeStickerGrid> {
  double quantitySize = 36;
  double titleSize = 9;
  List<int> strange = [];
  @override
  Widget build(BuildContext context) {
    Color cardCol = Colors.grey[900]!;
    return Scaffold(
      backgroundColor: Colors.grey[800],
      appBar: AppBar(
        title: Text(widget.collection),
        backgroundColor: Colors.black87,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(widget.selected),
        ),
      ),
      body: ListView(
        children: [
          Column(children: [
            StatefulBuilder(
              builder: (_context, _setState) => GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisSpacing: 0,
                  mainAxisSpacing: 0,
                  crossAxisCount: 3,
                ),
                shrinkWrap: true,
                physics: const PageScrollPhysics(),
                scrollDirection: Axis.vertical,
                itemCount: widget.snapshot.length,
                itemBuilder: (context, index) {
                  var picture = widget.snapshot[index];
                  if (picture.locked != true) {
                    for (Sticker item in widget.selected) {
                      if (item.id == picture.id) {
                        cardCol = Colors.green;
                        if (!strange.contains(item.id)) {
                          strange.add(item.id);
                        }
                      } else {
                        cardCol = Colors.grey[900]!;
                        //strange.remove(item.id);
                      }
                    }
                    return GestureDetector(
                      onTap: () {
                        if (picture.quantity > 1) {
                          if (widget.selected.contains(picture) || strange.contains(picture.id)) {
                            widget.selected.removeWhere((item) => picture.id == item.id);
                            strange.remove(picture.id);
                          } else {
                            widget.selected.add(picture);
                          }
                        }
                        _setState(() {});
                      },
                      child: Card(
                        color: colorPick(picture),
                        shape: RoundedRectangleBorder(
                            side: BorderSide(color: Colors.grey[800]!, width: 3.0),
                            borderRadius: BorderRadius.circular(4.0)),
                        child: Stack(children: <Widget>[
                          Align(
                              child: Image.memory(
                            base64.decode(utf8.decode(picture.picture)),
                            alignment: Alignment.center,
                          )),
                          alignQuantity(picture.quantity.toString(), Alignment.topRight, quantitySize),
                          alignQuantity(picture.title, Alignment.bottomCenter, titleSize),
                        ]),
                      ),
                    );
                  } else {
                    return Align(
                        child: Image.memory(
                      base64.decode(utf8.decode(picture.picture)),
                      color: Colors.black,
                      alignment: Alignment.center,
                    ));
                  }
                  //return Image.memory(base64.decode(utf8.decode(snapshot.data![index].picture)), scale: 2);
                },
              ),
            ),
          ])
        ],
      ),
    );
  }

  Color colorPick(Sticker item) {
    Color cardCol;
    if (strange.contains(item.id)) {
      cardCol = Colors.green;
      //strange.add(item.id);
    } else if (item.quantity! <= 1) {
      cardCol = Colors.grey[500]!;
    } else {
      cardCol = Colors.grey[900]!;
      //strange.remove(item.id);
    }
    return cardCol;
  }
}
