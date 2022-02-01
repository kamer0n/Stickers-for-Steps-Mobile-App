import 'dart:convert';
import 'dart:typed_data';

import 'package:darkmodetoggle/backend/align_quantity.dart';
import 'package:darkmodetoggle/backend/sticker.dart';
import 'package:flutter/material.dart';

Widget stickersAsGrid(var snapshot, {bool trade = false}) {
  double quantitySize = 36;
  double titleSize = 9;
  if (trade) {
    snapshot.add(Sticker(
        id: 1,
        collection: 1,
        title: '',
        desc: '',
        rarity: 1,
        quantity: 0,
        picture: Uint8List.fromList(utf8.encode("R0lGODlhAQABAAAAACH5BAEKAAEALAAAAAABAAEAAAICTAEAOw=="))));
    quantitySize = 23;
    titleSize = 9;
  }
  return Column(children: [
    GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisSpacing: 0,
        mainAxisSpacing: 0,
        crossAxisCount: 3,
      ),
      shrinkWrap: true,
      physics: const PageScrollPhysics(),
      scrollDirection: Axis.vertical,
      itemCount: snapshot.length,
      itemBuilder: (context, index) {
        var picture = snapshot[index];
        if (picture.locked != true) {
          if ((index < 2) || (trade == false)) {
            return picture.quantity != 0
                ? Card(
                    color: Colors.grey[900],
                    shape: RoundedRectangleBorder(
                        side: BorderSide(color: Colors.grey[800]!, width: 3.0),
                        borderRadius: BorderRadius.circular(4.0)),
                    child: InkWell(
                      splashColor: Colors.blue.withAlpha(30),
                      onTap: () {
                        showDialog(
                            context: context,
                            builder: (context) {
                              return stickerDialog(picture);
                            });
                      },
                      child: Stack(children: <Widget>[
                        Align(
                            child: Image.memory(
                          base64.decode(utf8.decode(picture.picture)),
                          alignment: Alignment.center,
                        )),
                        alignQuantity(picture.quantity.toString(), Alignment.topRight, quantitySize),
                        alignQuantity(picture.title, Alignment.bottomCenter, titleSize)
                      ]),
                    ),
                  )
                : Container();
          } else if (index == 2) {
            return Card(
              color: Colors.grey[900],
              shape: RoundedRectangleBorder(
                  side: BorderSide(color: Colors.grey[800]!, width: 3.0), borderRadius: BorderRadius.circular(4.0)),
              child: alignQuantity('...', Alignment.bottomCenter, 36),
            );
          } else {
            return const SizedBox(width: 0.0, height: 0.0);
          }
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
  ]);
}

AlertDialog stickerDialog(picture) {
  return AlertDialog(
    shape: RoundedRectangleBorder(
        side: const BorderSide(color: Colors.white70, width: 3.0), borderRadius: BorderRadius.circular(4.0)),
    title: Text(
      picture.title,
      textAlign: TextAlign.center,
    ),
    content: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.memory(
          base64.decode(utf8.decode(picture.picture)),
          alignment: Alignment.center,
        ),
        Text(picture.desc, style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey[500])),
        Text(picture.rarityString()),
      ],
    ),
  );
}
