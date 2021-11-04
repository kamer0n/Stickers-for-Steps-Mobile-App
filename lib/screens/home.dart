import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:darkmodetoggle/backend/sticker.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'package:http/http.dart' as http;

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black54,
      appBar: AppBar(
        leading: InkWell(
          child: const Icon(Icons.compare_arrows),
          onTap: () async {
            SharedPreferences preferences =
                await SharedPreferences.getInstance();
            preferences.clear();
            Navigator.popUntil(context, (route) => false);
            Navigator.pushNamed(context, "/signin");
          },
        ),
        title: Text(
          "Stickers for Steps",
          style: GoogleFonts.roboto(
              textStyle: const TextStyle(fontSize: 18, letterSpacing: 1)),
        ),
        backgroundColor: Colors.black87,
        centerTitle: true,
        actions: const <Widget>[],
      ),
      body: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child:
            /* WebView(
            javascriptMode: JavascriptMode.unrestricted,
            initialUrl: 'http://188.166.153.138',
            onPageFinished: (value) {
              setState(() {
                isLoading = true;
              });
            },
          ), */
            SingleChildScrollView(
                child: FutureBuilder<List<Collection>>(
          future: fetchSticker(http.Client()),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              print(snapshot.error);
              return const Center(
                child: Text('An error has occurred!'),
              );
            } else if (snapshot.hasData) {
              return StickerList(collections: snapshot.data!);
            } else {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
          },
        )),
        /* (!isLoading)
              ? const Center(
                  child: CircularProgressIndicator(
                    backgroundColor: Colors.green,
                  ),
                )
              : Container() */
      ),
    );
  }
}
