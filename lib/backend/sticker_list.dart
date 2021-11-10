import 'package:darkmodetoggle/backend/collection.dart';
import 'package:darkmodetoggle/backend/databasehandler.dart';
import 'package:darkmodetoggle/backend/sticker.dart';
import 'package:darkmodetoggle/screens/sticker_grid.dart';
import 'package:flutter/material.dart';

class StickerList extends StatefulWidget {
  List<Collection> collections;
  StickerList(this.collections);
  @override
  _StickerListState createState() => _StickerListState();
}

class _StickerListState extends State<StickerList> {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        physics: const NeverScrollableScrollPhysics(),
        scrollDirection: Axis.vertical,
        shrinkWrap: true,
        itemCount: widget.collections.length,
        itemBuilder: (context, index) {
          return Column(children: [
            FutureBuilder<List<Collection>>(
              builder: (context, snapshot) {
                return SizedBox(
                  child: ElevatedButton(
                      style: ButtonStyle(backgroundColor: MaterialStateProperty.all<Color>(Colors.transparent)),
                      onPressed: () {
                        Navigator.push(
                            context, MaterialPageRoute(builder: (context) => StickerGrid(widget.collections[index])));
                      },
                      child: Card(
                          child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [Center(child: Text(widget.collections[index].name))]))),
                  height: 100,
                  width: 300,
                );
              },
            )
          ]);
        });
  }
}
