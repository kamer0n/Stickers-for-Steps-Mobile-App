import 'dart:convert';

import 'package:darkmodetoggle/apis/api.dart';
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
  List<Trade> trades = [];
  final parsed = jsonDecode(responseBody);
  trades.add((parsed['sent'].map<Trade>((json) => Trade.fromJson(json, sender_: true)).toList())[0]);
  trades.add((parsed['received'].map<Trade>((json) => Trade.fromJson(json, sender_: false)).toList())[0]);
  return trades;
}

class Trade {
  final int senderId;
  final int receiverId;
  final String senderName;
  final String receiverName;
  final DateTime? timeSent;
  final int tradeStatus;
  List<dynamic>? senderStickers;
  List<dynamic>? receiverStickers;
  bool sender;

  Trade({
    required this.senderId,
    required this.receiverId,
    required this.senderName,
    required this.receiverName,
    this.timeSent,
    required this.tradeStatus,
    this.senderStickers,
    this.receiverStickers,
    required this.sender,
  });

  factory Trade.fromJson(Map<String, dynamic> json, {required bool sender_}) {
    return Trade(
      senderId: json['sender'],
      receiverId: json['receiver'],
      senderName: json['sender_name'],
      receiverName: json['receiver_name'],
      timeSent: DateTime.parse(json['time_sent']),
      tradeStatus: json['trade_status'],
      senderStickers: json['sender_stickers'],
      receiverStickers: json['receiver_stickers'],
      sender: sender_,
    );
  }

  String statusString() {
    if (tradeStatus == 1) {
      return "This trade has been received";
    } else if (tradeStatus == 2) {
      return "This trade has been accepted!";
    } else if (tradeStatus == 3) {
      return "This trade has been declined";
    } else if (tradeStatus == 4) {
      return "This trade has been counteroffered";
    } else {
      return "This trade is now invalid";
    }
  }

  @override
  String toString() {
    return "Trade from $senderName to $receiverName";
  }
}
