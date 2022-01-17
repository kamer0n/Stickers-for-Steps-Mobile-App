import 'dart:convert';
import 'dart:async';

import 'package:darkmodetoggle/backend/databasehandler.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import 'package:darkmodetoggle/apis/api.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<List<UserSticker>> fetchUserSticker() async {
  DatabaseHandler db = DatabaseHandler();
  List<UserSticker> userstickers = await webFetch();
  await db.insertUserStickers(userstickers);
  return await db.retrieveUserStickers();
}

Future<List<UserSticker>> webFetch() async {
  SharedPreferences preferences = await SharedPreferences.getInstance();
  final response = await http.Client().post(Uri.parse(userstickerurl),
      headers: {"authorization": "TOKEN " + (preferences.getString('token') ?? defaultToken)});
  return compute(parseUserSticker, response.body);
}

List<UserSticker> parseUserSticker(String responseBody) {
  final parsed = jsonDecode(responseBody);
  return parsed.map<UserSticker>((json) => UserSticker.fromJson(json)).toList();
}

List<UserSticker> parseUserStickerTrade(var responseBody) {
  return responseBody.map<UserSticker>((json) => UserSticker.fromJson(json)).toList();
}

class UserSticker {
  final int id;
  int? quantity;

  UserSticker({required this.id, this.quantity});

  factory UserSticker.fromJson(Map<String, dynamic> json) {
    return UserSticker(id: json['id'], quantity: json['quantity']);
  }

  Map<String, Object?> toMap() {
    return {'id': id, 'quantity': quantity};
  }
}
