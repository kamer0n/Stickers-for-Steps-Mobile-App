import 'package:darkmodetoggle/screens/friends.dart';
import 'package:darkmodetoggle/screens/stickers_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int _currentIndex = 0;
  _getDrawerItemWidget(int pos) {
    switch (pos) {
      case 0:
        return Center(child: Text('home'));
      case 1:
        return StickerScreen();
      case 2:
        return FriendScreen();

      default:
        return Text("Error");
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
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
        bottomNavigationBar: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            currentIndex: _currentIndex,
            backgroundColor: colorScheme.surface,
            selectedItemColor: colorScheme.onSurface,
            unselectedItemColor: colorScheme.onSurface.withOpacity(.60),
            selectedLabelStyle: textTheme.caption,
            unselectedLabelStyle: textTheme.caption,
            onTap: (value) {
              setState(() {
                _currentIndex = value;
              });
            },
            items: const [
              BottomNavigationBarItem(label: ('Home'), icon: Icon(Icons.home)),
              BottomNavigationBarItem(
                  label: ('Stickers'), icon: Icon(Icons.sticky_note_2)),
              BottomNavigationBarItem(
                  label: ('Friends'), icon: Icon(Icons.person)),
            ]),
        body: _getDrawerItemWidget(_currentIndex));
  }
}
