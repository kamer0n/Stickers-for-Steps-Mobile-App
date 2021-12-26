import 'package:flutter/material.dart';

Align alignQuantity(String text, Alignment align, double fontsize) {
  return Align(
    child: Padding(
      padding: const EdgeInsets.all(8.0),
      child: Stack(
        children: <Widget>[
          Text(
            text,
            style: TextStyle(
              fontSize: fontsize,
              foreground: Paint()
                ..style = PaintingStyle.stroke
                ..strokeWidth = 4
                ..color = Colors.black,
            ),
          ),
          Text(
            text,
            style: TextStyle(color: Colors.white, fontSize: fontsize),
          ),
        ],
      ),
    ),
    alignment: align,
  );
}
