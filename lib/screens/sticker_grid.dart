import 'package:darkmodetoggle/backend/alignQuantity.dart';
import 'package:darkmodetoggle/backend/collection.dart';
import 'package:darkmodetoggle/backend/sticker.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:convert';

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
              return ListView(children: [
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
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      var picture = snapshot.data![index];
                      if (picture.locked != true) {
                        return Stack(children: [
                          Align(
                              child: Image.memory(
                            base64.decode(utf8.decode(picture.picture)),
                            alignment: Alignment.center,
                          )),
                          alignQuantity(picture)
                        ]);
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
                ]))
              ]);
            } else {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
          },
        ));
  }
}
