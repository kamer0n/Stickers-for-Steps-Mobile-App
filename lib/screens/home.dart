import 'package:darkmodetoggle/screens/friend_requests.dart';
import 'package:darkmodetoggle/screens/friends.dart';
import 'package:darkmodetoggle/screens/stickers_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Home extends StatefulWidget {
  String screen;
  Home(this.screen);
  //int screen;
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int _currentIndex = 0;
  _getDrawerItemWidget(int pos) {
    print('pos');
    print(pos);
    switch (pos) {
      case 0:
        return const Center(child: Text('home'));
      case 1:
        return StickerScreen();
      case 2:
        return FriendScreen();

      default:
        return const Text("Error");
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    //int _currentIndex = 0;
    print(widget.screen);
    if (widget.screen == 'Home') {
      widget.screen = '';
      _currentIndex = 0;
    } else if (widget.screen == 'Friends') {
      _currentIndex = 2;
    }
    print(_currentIndex);
    return Scaffold(
        appBar: AppBar(
          leading: InkWell(
            child: const Icon(Icons.compare_arrows),
            onTap: () async {
              SharedPreferences preferences = await SharedPreferences.getInstance();
              preferences.clear();
              Navigator.popUntil(context, (route) => false);
              Navigator.pushNamed(context, "/signin");
            },
          ),
          title: Text(
            "Stickers for Steps",
            style: GoogleFonts.roboto(textStyle: const TextStyle(fontSize: 18, letterSpacing: 1)),
          ),
          backgroundColor: Colors.black87,
          centerTitle: true,
          actions: _currentIndex != 2
              ? null
              : <Widget>[
                  Padding(
                      padding: const EdgeInsets.only(right: 20.0),
                      child: GestureDetector(
                        onTap: () {
                          displayFriends(context, key: UniqueKey()).then((value) {
                            setState(() {
                              _currentIndex = 2;
                            });
                          });
                        },
                        child: const Icon(Icons.notifications),
                      )),
                ],
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
                print('setState');
                print(value);
                _currentIndex = value;
                print(_currentIndex);
              });
            },
            items: const [
              BottomNavigationBarItem(label: ('Home'), icon: Icon(Icons.home)),
              BottomNavigationBarItem(label: ('Stickers'), icon: Icon(Icons.sticky_note_2)),
              BottomNavigationBarItem(label: ('Friends'), icon: Icon(Icons.person)),
            ]),
        body: _getDrawerItemWidget(_currentIndex));
  }
}
