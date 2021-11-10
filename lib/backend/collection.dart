import 'dart:convert';

import 'package:darkmodetoggle/apis/api.dart';
import 'package:darkmodetoggle/backend/databasehandler.dart';
import 'package:darkmodetoggle/backend/sticker.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:http/http.dart' as http;
import 'package:sqflite/sqlite_api.dart';

Future<List<Collection>> fetchCollections() async {
  DatabaseHandler db = DatabaseHandler();
  db.initializeDB().whenComplete(() async {
    if ((await db.retrieveCollections()).isEmpty) {
      List<Collection> collections = await webFetch();
      await db.insertCollection(collections);
    }
  });
  return await db.retrieveCollections();
}

Future<List<Collection>> webFetch() async {
  SharedPreferences preferences = await SharedPreferences.getInstance();
  final response = await http.Client().get(Uri.parse(collectionurl),
      headers: {"authorization": "TOKEN " + (preferences.getString('token') ?? defaultToken)});
  return compute(parseCollection, response.body);
}

List<Collection> parseCollection(String responseBody) {
  final parsed = jsonDecode(responseBody);
  return parsed.map<Collection>((json) => Collection.fromJson(json)).toList();
}

class Collection {
  late int id;
  late String name;
  late List<Sticker>? stickers;
  late int version;

  Collection({
    required this.id,
    required this.name,
    this.stickers,
    required this.version,
  });

  Collection.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    version = json['version'];
  }

  Map<String, Object?> toMap() {
    return {'id': id, 'name': name, 'version': version};
  }

  @override
  String toString() {
    return this.name;
  }

  List<Sticker> sticks(stickerlist) {
    List<Sticker> convList = [];
    for (var stick in stickerlist) {
      convList.add(Sticker.fromJson(stick));
    }
    return convList;
  }
}
