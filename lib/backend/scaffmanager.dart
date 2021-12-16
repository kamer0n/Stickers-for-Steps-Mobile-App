import 'package:flutter/material.dart';

void popup(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    content: Text(message),
    backgroundColor: Colors.grey,
    duration: Duration(seconds: 1),
  ));
}