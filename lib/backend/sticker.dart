import 'dart:convert';
import 'dart:async';
import 'dart:typed_data';

import 'package:darkmodetoggle/backend/databasehandler.dart';
import 'package:flutter/foundation.dart';
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

Future<List<Sticker>> fetchSingleSticker({required int id}) async {
  DatabaseHandler db = DatabaseHandler();
  return await db.retrieveSticker(id: id);
}

Future<List<Sticker>> fetchTradeStickers(List<dynamic> stickers) async {
  DatabaseHandler db = DatabaseHandler();
  return await db.retrieveTradeSticker(id: 1);
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
  bool? locked;
  int? quantity;

  Sticker({
    required this.id,
    required this.picture,
    required this.title,
    required this.desc,
    required this.collection,
    required this.rarity,
    this.locked,
    this.quantity,
  });

  factory Sticker.fromJson(Map<String, dynamic> json) {
    Uint8List pict;
    try {
      pict = Uint8List.fromList(utf8.encode(json['key']));
    } catch (e) {
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

  String rarityString() {
    if (rarity == 0) {
      return "Common";
    } else if (rarity == 1) {
      return "Uncommon";
    } else if (rarity == 2) {
      return "Rare";
    } else if (rarity == 3) {
      return "Legendary";
    } else {
      return "Never before seen";
    }
  }

  void lockedSticker() async {
    locked = true;
  }

  @override
  String toString() {
    return title;
  }

  Map<String, Object?> toMap() {
    return {'id': id, 'name': title, 'desc': desc, 'rarity': rarity, 'collection': collection, 'key': picture};
  }
}
