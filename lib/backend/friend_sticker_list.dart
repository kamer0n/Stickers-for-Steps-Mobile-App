import 'dart:convert';

import 'package:darkmodetoggle/apis/api.dart';
import 'package:darkmodetoggle/backend/collection.dart';
import 'package:darkmodetoggle/backend/sticker.dart';
import 'package:darkmodetoggle/screens/sticker_grid.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:http/http.dart' as http;

import 'alignQuantity.dart';

class FriendStickerList extends StatefulWidget {
  List<Collection> collections;
  String name;

  FriendStickerList(this.collections, this.name);
  @override
  _FriendListState createState() => _FriendListState();
}

class _FriendListState extends State<FriendStickerList> {
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
                  padding: EdgeInsets.fromLTRB(0.0, 9.0, 0.0, 0.0),
                  child: SizedBox(
                    child: ElevatedButton(
                        style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all<Color>(Color.fromRGBO(66, 66, 66, 1.0))),
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => newMethod(
                                      widget.collections[index].id, widget.name, widget.collections[index].name)));
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(30.0),
                          child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                            Icon(Icons.sticky_note_2_outlined),
                            Text(
                              widget.collections[index].name,
                              textScaleFactor: 1.5,
                              style: TextStyle(fontWeight: FontWeight.bold),
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

Scaffold newMethod(int id, String name, String collectionName) {
  return Scaffold(
    appBar: AppBar(
      title: Text(collectionName),
      backgroundColor: Colors.black87,
      centerTitle: true,
    ),
    body: FutureBuilder<List>(
      future: friendStickers(collectionId: id, friendName: name),
      builder: (context, snapshot) {
        //print(snapshot);
        if (snapshot.hasError) {
          return const Center(
            child: Text('An error has occurred!'),
          );
        } else if (snapshot.hasData) {
          //print(snapshot.data);
          return ListView(children: [
            Card(
                child: Column(children: [
              GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisSpacing: 0,
                  mainAxisSpacing: 0,
                  crossAxisCount: 3,
                ),
                shrinkWrap: true,
                physics: AlwaysScrollableScrollPhysics(),
                scrollDirection: Axis.vertical,
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  var picture = snapshot.data![index];
                  if (picture.locked != true) {
                    return Stack(children: <Widget>[
                      Align(
                          child: Image.memory(
                        base64.decode(utf8.decode(picture.picture)),
                        alignment: Alignment.center,
                      )),
                      alignQuantity(picture),
                    ]);
                  } else {
                    return Align(
                        child: Image.memory(
                      base64.decode(utf8.decode(picture.picture)),
                      color: Colors.black,
                      alignment: Alignment.center,
                    ));
                  }
                  //return Image.memory(base64.decode(utf8.decode(snapshot.data![index].picture)), scale: 2);
                },
              ),
            ]))
          ]);
        } else {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
      },
    ),
  );
}
