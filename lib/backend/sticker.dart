import 'dart:convert';
import 'dart:async';
import 'dart:typed_data';

import 'package:darkmodetoggle/backend/databasehandler.dart';
import 'package:darkmodetoggle/screens/sticker_grid.dart';
import 'package:expandable/expandable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:darkmodetoggle/apis/api.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<List<Sticker>> fetchSticker({int? id}) async {
  DatabaseHandler db = DatabaseHandler();
  db.initializeDB().whenComplete(() async {
    if ((await db.retrieveStickers()).isEmpty) {
      List<Sticker> stickers = await webFetch();
      await db.insertSticker(stickers);
    }
  });
  return await db.retrieveStickers(id: id);
}

Future<List<Sticker>> webFetch() async {
  SharedPreferences preferences = await SharedPreferences.getInstance();
  final response = await http.Client().get(Uri.parse(stickerurl),
      headers: {"authorization": "TOKEN " + (preferences.getString('token') ?? defaultToken)});
  return compute(parseSticker, response.body);
}

List<Sticker> parseSticker(String responseBody) {
  final parsed = jsonDecode(responseBody);
  return parsed.map<Sticker>((json) => Sticker.fromJson(json)).toList();
}

class Sticker {
  final int id;
  Uint8List picture;
  final String title;
  final String desc;
  final int collection;
  final int rarity;

  Sticker({
    required this.id,
    required this.picture,
    required this.title,
    required this.desc,
    required this.collection,
    required this.rarity,
  });

  factory Sticker.fromJson(Map<String, dynamic> json) {
    var pict;
    try {
      pict = Uint8List.fromList(utf8.encode(json['key']));
    } catch (Exception) {
      pict = json['key'];
    }
    return Sticker(
      id: json['id'],
      picture: pict,
      title: json['name'],
      desc: json['desc'],
      rarity: json['rarity'],
      collection: json['collection'],
    );
  }

  void lockedSticker() {
    this.picture = Uint8List.fromList(utf8.encode(
        "iVBORw0KGgoAAAANSUhEUgAAAPoAAAD6CAQAAAAi5ZK2AAABcUlEQVR42u3RAQ0AAAgDIJ/e2FrDTahAeopnIl060pGOdKQjHelIRzrSkY50pCMd6UhHunSkIx3pSEc60pGOdKQjHelIRzrSkY506UhHOtKRjnSkIx3pSEc60pGOdKQjHenSkY50pCMd6UhHOtKRjnSkIx3pSEc60qUjHelIRzrSkY50pCMd6UhHOtKRjnSkS5cuHelIRzrSkY50pCMd6UhHOtKRjnSkI1060pGOdKQjHelIRzrSkY50pCMd6UhHunSkIx3pSEc60pGOdKQjHelIRzrSkY506UhHOtKRjnSkIx3pSEc60pGOdKQjHenSkY50pCMd6UhHOtKRjnSkIx3pSEc60qVLl450pCMd6UhHOtKRjnSkIx3pSEc60pEuHelIRzrSkY50pCMd6UhHOtKRjnSkI1060pGOdKQjHelIRzrSkY50pCMd6UhHunSkIx3pSEc60pGOdKQjHelIRzrSkY506UhHOtKRjnSkI50bFqkTfea5/KkYAAAAAElFTkSuQmCC"));
  }

  @override
  String toString() {
    return title;
  }

  Map<String, Object?> toMap() {
    return {'id': id, 'name': title, 'desc': desc, 'rarity': rarity, 'collection': collection, 'key': picture};
  }
}
