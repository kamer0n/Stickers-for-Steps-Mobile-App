import 'package:darkmodetoggle/backend/collection.dart';
import 'package:darkmodetoggle/backend/sticker.dart';
import 'package:darkmodetoggle/backend/stickers_as_grid.dart';
import 'package:flutter/material.dart';
import 'package:matomo/matomo.dart';

// ignore: must_be_immutable
class StickerGrid extends TraceableStatefulWidget {
  Collection collection;
  StickerGrid(this.collection, {Key? key}) : super(key: key);
  @override
  _StickerGridState createState() => _StickerGridState();
}

class _StickerGridState extends State<StickerGrid> {
  //Collection collection;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(
            widget.collection.name,
          ),
          backgroundColor: Colors.black87,
          centerTitle: true,
        ),
        body: FutureBuilder<List<Sticker>>(
          future: fetchSticker(id: widget.collection.id),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return const Center(
                child: Text('An error has occurred!'),
              );
            } else if (snapshot.hasData) {
              //print(snapshot.data);
              return ListView(children: [stickersAsGrid(snapshot.data)]);
            } else {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
          },
        ));
  }
}
