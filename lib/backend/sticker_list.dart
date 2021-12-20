import 'dart:convert';

import 'package:darkmodetoggle/backend/collection.dart';
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
                return Padding(
                  padding: EdgeInsets.fromLTRB(0.0, 9.0, 0.0, 0.0),
                  child: SizedBox(
                    child: ElevatedButton(
                        style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all<Color>(Color.fromRGBO(66, 66, 66, 1.0))),
                        onPressed: () {
                          Navigator.push(
                              context, MaterialPageRoute(builder: (context) => StickerGrid(widget.collections[index])));
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(30.0),
                          child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                            Image.memory(base64.decode(utf8.decode(widget.collections[index].icon))),
                            Text(
                              widget.collections[index].name,
                              textScaleFactor: 1.5,
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ]),
                        )),
                    height: 100,
                    width: 300,
                  ),
                );
              },
            )
          ]);
        });
  }
}
