import 'dart:convert';
import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:darkmodetoggle/apis/api.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<List<Collection>> fetchSticker(http.Client client) async {
  SharedPreferences preferences = await SharedPreferences.getInstance();
  print(defaultToken);
  /* final response = await client.get(Uri.parse(stickerurl), headers: {
    "authorization": "TOKEN " + (preferences.getString('token') ?? defaultToken)
  }); */
  final response = await client.get(Uri.parse(stickerurl),
      headers: {"authorization": "TOKEN " + (defaultToken)});

  print(preferences.getString('token'));
  //print(response.body);
  //print(jsonDecode(response.body)
  // .map<Collection>((json) => Collection.fromJson(json)));
  var test = jsonDecode(response.body)
      .map<Collection>((json) => Collection.fromJson(json));
  // Use the compute function to run parsePhotos in a separate isolate.
  return compute(parseCollection, response.body);
}

// A function that converts a response body into a List<Photo>.
List<Sticker> parseSticker(String responseBody) {
  print('hyuckle');
  //final parsed = jsonDecode(responseBody[0]).cast<Map<String, dynamic>>();
  final parsed = jsonDecode(responseBody);
  return parsed[0]['stickers']
      .map<Sticker>((json) => Sticker.fromJson(json))
      .toList();
}

class Sticker {
  final String url;
  final String title;

  Sticker({
    required this.url,
    required this.title,
  });

  factory Sticker.fromJson(Map<String, dynamic> json) {
    return Sticker(
      url: json['key'],
      title: json['name'],
    );
  }

  @override
  String toString() {
    return title;
  }
}

List<Collection> parseCollection(String responseBody) {
  final parsed = jsonDecode(responseBody);
  return parsed.map<Collection>((json) => Collection.fromJson(json)).toList();
}

class Collection {
  final String name;
  final List<Sticker> stickers;

  Collection({
    required this.name,
    required this.stickers,
  });

  factory Collection.fromJson(Map<String, dynamic> json) {
    return Collection(
      name: json['name'],
      stickers: sticks(json['stickers']),
    );
  }

  @override
  String toString() {
    print(this.stickers.toString());
    return this.name;
  }
}

List<Sticker> sticks(stickerlist) {
  List<Sticker> convList = [];
  for (var stick in stickerlist) {
    convList.add(Sticker.fromJson(stick));
  }
  return convList;
}

class StickerList extends StatelessWidget {
  const StickerList({Key? key, required this.collections}) : super(key: key);

  final List<Collection> collections;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      scrollDirection: Axis.vertical,
      shrinkWrap: true,
      /* gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 1,
      ), */
      itemCount: collections.length,
      itemBuilder: (context, index) {
        return Column(children: [
          Text(collections[index].name),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            scrollDirection: Axis.vertical,
            itemCount: collections[index].stickers.length,
            itemBuilder: (context, index2) {
              return Image.network(collections[index].stickers[index2].url);
            },
          ),
        ]);
      },
    );
  }
}
