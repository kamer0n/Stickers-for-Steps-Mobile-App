import 'package:darkmodetoggle/backend/usersticker.dart';
import 'package:darkmodetoggle/screens/friend_requests.dart';
import 'package:darkmodetoggle/screens/friends.dart';
import 'package:darkmodetoggle/screens/home.dart';
import 'package:darkmodetoggle/screens/leaderboard.dart';
import 'package:darkmodetoggle/screens/stickers_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Nav extends StatefulWidget {
  String screen;
  Nav(this.screen);
  //int screen;
  @override
  _NavState createState() => _NavState();
}

class _NavState extends State<Nav> {
  int _currentIndex = 0;
  _getDrawerItemWidget(int pos) {
    switch (pos) {
      case 0:
        return Home();
      case 1:
        return StickerScreen();
      case 2:
        return LeaderboardScreen();
      case 3:
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
    if (widget.screen == 'Home') {
      widget.screen = '';
      _currentIndex = 0;
    } else if (widget.screen == 'Friends') {
      widget.screen = '';
      _currentIndex = 3;
    }
    return Scaffold(
        appBar: _appBar(),
        bottomNavigationBar: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            currentIndex: _currentIndex,
            backgroundColor: colorScheme.surface,
            selectedItemColor: colorScheme.onSurface,
            unselectedItemColor: colorScheme.onSurface.withOpacity(.60),
            selectedLabelStyle: textTheme.caption,
            unselectedLabelStyle: textTheme.caption,
            onTap: (value) async {
              setState(() {
                _currentIndex = value;
              });
              await fetchUserSticker();
            },
            items: const [
              BottomNavigationBarItem(label: ('Home'), icon: Icon(Icons.home)),
              BottomNavigationBarItem(label: ('Stickers'), icon: Icon(Icons.sticky_note_2)),
              BottomNavigationBarItem(label: ('Leaderboard'), icon: Icon(Icons.leaderboard)),
              BottomNavigationBarItem(label: ('Friends'), icon: Icon(Icons.person)),
            ]),
        body: _getDrawerItemWidget(_currentIndex));
  }

  AppBar _appBar() {
    return AppBar(
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
      actions: _currentIndex != 3
          ? null
          : <Widget>[
              Padding(
                  padding: const EdgeInsets.only(right: 20.0),
                  child: GestureDetector(
                    onTap: () {
                      displayFriends(context, key: UniqueKey()).then((value) {
                        setState(() {
                          _currentIndex = 3;
                        });
                      });
                    },
                    child: const Icon(Icons.notifications),
                  )),
            ],
    );
  }
}
