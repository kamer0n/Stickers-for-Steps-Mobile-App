import 'package:darkmodetoggle/backend/collection.dart';
import 'package:darkmodetoggle/backend/sticker.dart';
import 'package:darkmodetoggle/backend/stickersAsGrid.dart';
import 'package:flutter/material.dart';

class StickerGrid extends StatefulWidget {
  Collection collection;
  StickerGrid(this.collection);
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
              return stickersAsGrid(snapshot);
            } else {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
          },
        ));
  }
}
