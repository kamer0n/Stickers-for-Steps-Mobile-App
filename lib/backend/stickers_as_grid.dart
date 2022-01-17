import 'dart:convert';

import 'package:darkmodetoggle/backend/align_quantity.dart';
import 'package:flutter/material.dart';

ListView stickersAsGrid(var snapshot) {
  return ListView(children: [
    Column(children: [
      GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisSpacing: 0,
          mainAxisSpacing: 0,
          crossAxisCount: 3,
        ),
        shrinkWrap: true,
        physics: const PageScrollPhysics(),
        scrollDirection: Axis.vertical,
        itemCount: snapshot.data!.length,
        itemBuilder: (context, index) {
          var picture = snapshot.data![index];
          if (picture.locked != true) {
            return Card(
              color: Colors.grey[900],
              shape: RoundedRectangleBorder(
                  side: BorderSide(color: Colors.grey[800]!, width: 3.0), borderRadius: BorderRadius.circular(4.0)),
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
                  alignQuantity(picture.quantity.toString(), Alignment.topRight, 36),
                  alignQuantity(picture.title, Alignment.bottomCenter, 9)
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
    ])
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
