import 'dart:convert';

import 'package:darkmodetoggle/apis/health.dart';
import 'package:darkmodetoggle/backend/sticker.dart';
import 'package:darkmodetoggle/components/progress.dart';
import 'package:flutter/material.dart';

import 'nav.dart';

class Home extends StatefulWidget {
  //int screen;
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int _steps = 1;
  int _target = 1;
  int _sticker = 0;
  late Sticker _newsticker;

  @override
  void initState() {
    super.initState();
    /* fetchStepsAndTarget().then((value) {
      setState(() {
        _steps = value[0];
        _target = value[1];
        if (value.length > 2) {
          _sticker = value[2];
        }
      });
    }); */
  }

  Future<List<Sticker>> sticker(int id) async {
    if (id != 0) {
      Future<List<Sticker>> sticker = fetchSingleSticker(id: id);
      return sticker;
    } else {
      return fetchSingleSticker(id: 1);
    }
  }

  Future<Map> TargetAndSteps() async {
    Map values = {};
    List<int> vals = await fetchStepsAndTarget();
    values['steps'] = vals[0];
    values['target'] = vals[1];
    if (vals[2] == 0) {
      values['sticker'] = 0;
    } else {
      values['sticker'] = await sticker(vals[2]);
    }
    return values;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
          future: TargetAndSteps(),
          builder: (context, snapshot) {
            Map _data = {};
            if (snapshot.hasData) {
              _data = snapshot.data! as Map;
              if (_data['sticker'] != 0) {
                _newsticker = _data['sticker'][0];
              }
              return ListView(shrinkWrap: false, children: [
                SizedBox(
                    height: 300,
                    width: 350,
                    child: Card(
                        child: Column(mainAxisAlignment: MainAxisAlignment.start, children: [
                      Text(
                        "Today's Progress",
                        textScaleFactor: 2,
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      SizedBox(
                        height: 100,
                      ),
                      Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
                        StepsProgress(
                          _data['steps'],
                          _data['target'],
                        ),
                        Column(
                          children: [
                            Text(
                              "Current steps: " + _data['steps'].toString(),
                              textScaleFactor: 1.14,
                            ),
                            Text(
                              "Target steps: " + _data['target'].toString(),
                              textScaleFactor: 1.14,
                            ),
                          ],
                        ),
                      ])
                    ]))),
                newPack(_data['sticker']),
              ]);
            } else {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
          }),
    );
  }

  Widget newPack(var sticker) {
    if (sticker != 0) {
      return Card(
          child: SizedBox(
        width: 350,
        height: 300,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            //  Image.memory(base64.decode(utf8.decode(_newsticker.picture))),
            ElevatedButton(
                onPressed: () {
                  showSticker(context, _newsticker);
                  Navigator.of(context).pop();
                  Navigator.push(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (c, a1, a2) => Nav('Home'),
                      transitionsBuilder: (c, anim, a2, child) => FadeTransition(opacity: anim, child: child),
                      transitionDuration: Duration(milliseconds: 0),
                    ),
                  );
                },
                child: Text('Open new sticker pack!'))
          ],
        ),
      ));
    } else {
      return SizedBox(
        child: Card(
            child: Center(
                child: Text(
          "You haven't reached your target yet!",
          textScaleFactor: 1.5,
        ))),
        height: 300,
        width: 300,
      );
    }
  }

  Future<void> showSticker(BuildContext context, Sticker sticker) {
    return showDialog(
        context: context,
        builder: (context) {
          return stickerDialog(sticker);
        });
  }
}

AlertDialog stickerDialog(picture) {
  return AlertDialog(
    shape: RoundedRectangleBorder(
        side: BorderSide(color: Colors.white70, width: 3.0), borderRadius: BorderRadius.circular(4.0)),
    title: Text(
      picture.title,
      textAlign: TextAlign.center,
    ),
    content: SizedBox(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.memory(
            base64.decode(utf8.decode(picture.picture)),
            alignment: Alignment.center,
          ),
          Text(picture.desc, style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey[500])),
          Text(picture.rarityString()),
        ],
      ),
    ),
  );
}
