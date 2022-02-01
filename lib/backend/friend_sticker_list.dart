import 'dart:convert';

import 'package:darkmodetoggle/apis/api.dart';
import 'package:darkmodetoggle/backend/collection.dart';
import 'package:darkmodetoggle/backend/sticker.dart';
import 'package:darkmodetoggle/backend/stickers_as_grid.dart';
import 'package:darkmodetoggle/components/trade_sticker_grid.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:http/http.dart' as http;

// ignore: must_be_immutable
class FriendStickerList extends StatefulWidget {
  List<Collection> collections;
  String name;
  bool? trade;

  FriendStickerList(this.collections, this.name, {Key? key, this.trade}) : super(key: key);
  @override
  _FriendListState createState() => _FriendListState();
}

class _FriendListState extends State<FriendStickerList> {
  List<Sticker> selected = <Sticker>[];
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        physics: const NeverScrollableScrollPhysics(),
        scrollDirection: Axis.vertical,
        shrinkWrap: true,
        itemCount: widget.collections.length,
        itemBuilder: (context, index) {
          return Column(children: [
            FutureBuilder<List<Collection>>(
              builder: (context, snapshot) {
                return Padding(
                  padding: const EdgeInsets.fromLTRB(0.0, 9.0, 0.0, 0.0),
                  child: SizedBox(
                    child: ElevatedButton(
                        style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all<Color>(const Color.fromRGBO(66, 66, 66, 1.0))),
                        onPressed: () async {
                          final List result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => newMethod(context, widget.collections[index].id, widget.name,
                                      widget.collections[index].name, widget.trade!, selected)));
                          print(result);
                          for (var element in result) {
                            if (!selected.contains(element)) {
                              selected.add(element);
                            }
                          }
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(30.0),
                          child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                            Image.memory(base64.decode(utf8.decode(widget.collections[index].icon))),
                            Text(
                              widget.collections[index].name,
                              textScaleFactor: 1.5,
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ]),
                        )),
                    height: 100,
                    width: 300,
                  ),
                );
              },
            )
          ]);
        });
  }
}

Future<List> friendStickers({required int collectionId, required String friendName}) async {
  SharedPreferences preferences = await SharedPreferences.getInstance();
  final response = await http.Client().post(
    Uri.parse(userstickerurl),
    body: jsonEncode(<String, dynamic>{"user": friendName.toString(), "collection": collectionId}),
    headers: {
      "authorization": "TOKEN " + (preferences.getString('token') ?? defaultToken),
      'Content-Type': 'application/json; charset=UTF-8',
    },
  );
  final List<dynamic> parsed = jsonDecode(response.body);
  List<int> ids = [];
  List<int> quantities = [];
  for (var item in parsed) {
    ids.add(item['id']);
    quantities.add(item['quantity']);
  }
  List<Sticker> stickers = await fetchSticker(id: collectionId);
  for (Sticker s in stickers) {
    if (ids.contains(s.id)) {
      s.locked = false;
      s.quantity = quantities[ids.indexOf(s.id)];
    } else {
      s.locked = true;
    }
  }
  return stickers;
}

Scaffold newMethod(
    BuildContext? context, int id, String name, String collectionName, bool trade, List<dynamic> selected) {
  AppBar? bar = friendAppBar(collectionName);
  if (trade) {
    bar = null;
  }
  print("newMethod scaffold $selected");
  return Scaffold(
    appBar: bar,
    body: Container(
      color: Colors.grey[700],
      child: FutureBuilder<List>(
        future: friendStickers(collectionId: id, friendName: name),
        builder: (context, snapshot) {
          //print(snapshot);
          if (snapshot.hasError) {
            return const Center(
              child: Text('An error has occurred!'),
            );
          } else if (snapshot.hasData) {
            //print(snapshot.data);
            if (trade) {
              return TradeStickerGrid(1, snapshot.data, true, selected, collectionName);
            } else {
              return ListView(children: [stickersAsGrid(snapshot.data)]);
            }
          } else {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
    ),
  );
}

AppBar friendAppBar(String collectionName) {
  return AppBar(
    title: Text(collectionName),
    backgroundColor: Colors.black87,
    centerTitle: true,
  );
}

//void tradeAppBar(BuildContext context, String collectionName) {
//}
