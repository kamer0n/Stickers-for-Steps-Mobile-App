import 'package:darkmodetoggle/backend/sticker.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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
            style: GoogleFonts.roboto(textStyle: const TextStyle(fontSize: 18, letterSpacing: 1)),
          ),
          backgroundColor: Colors.black87,
          centerTitle: true,
        ),
        body: Column(children: [
          Card(
              child: Column(children: [
            GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisSpacing: 0,
                mainAxisSpacing: 0,
                crossAxisCount: 3,
              ),
              shrinkWrap: true,
              physics: AlwaysScrollableScrollPhysics(),
              scrollDirection: Axis.vertical,
              itemCount: widget.collection.stickers.length,
              itemBuilder: (context, index) {
                return Image.network(widget.collection.stickers[index].url, scale: 2);
              },
            ),
          ]))
        ]));
  }
}
