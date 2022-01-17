import 'dart:convert';

import 'package:darkmodetoggle/apis/api.dart';
import 'package:darkmodetoggle/backend/sticker.dart';
import 'package:darkmodetoggle/backend/databasehandler.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:http/http.dart' as http;

Future<List<Trade>> fetchTrades(http.Client client) async {
  SharedPreferences preferences = await SharedPreferences.getInstance();
  final token = preferences.getString('token') ?? defaultToken;
  final response = await client.get(Uri.parse(tradeURL), headers: {"authorization": "TOKEN " + (token)});
  return compute(parseTrades, response.body);
}

List<Trade> parseTrades(String responseBody) {
  final parsed = jsonDecode(responseBody);
  return parsed['sent'].map<Trade>((json) => Trade.fromJson(json)).toList();
}

class Trade {
  final int senderId;
  final int receiverId;
  final DateTime? timeSent;
  final int tradeStatus;
  final List<dynamic>? senderStickers;
  final List<dynamic>? receiverStickers;

  Trade({
    required this.senderId,
    required this.receiverId,
    this.timeSent,
    required this.tradeStatus,
    this.senderStickers,
    this.receiverStickers,
  });

  factory Trade.fromJson(Map<String, dynamic> json) {
    return Trade(
      senderId: json['sender'],
      receiverId: json['receiver'],
      timeSent: DateTime.parse(json['time_sent']),
      tradeStatus: json['trade_status'],
      senderStickers: json['sender_stickers'],
      receiverStickers: json['receiver_stickers'],
    );
  }

  @override
  String toString() {
    return "Trade from ${senderId.toString()} to ${receiverId.toString()}";
  }
}
