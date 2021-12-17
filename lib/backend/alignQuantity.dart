import 'package:flutter/material.dart';

import 'sticker.dart';

Align alignQuantity(Sticker picture) {
  return Align(
    child: Padding(
      padding: const EdgeInsets.all(8.0),
      child: Stack(
        children: <Widget>[
          Text(
            picture.quantity.toString(),
            style: TextStyle(
              fontSize: 36,
              foreground: Paint()
                ..style = PaintingStyle.stroke
                ..strokeWidth = 4
                ..color = Colors.black,
            ),
          ),
          Text(
            picture.quantity.toString(),
            style: TextStyle(color: Colors.white, fontSize: 36),
          ),
        ],
      ),
    ),
    alignment: Alignment.bottomRight,
  );
}
