import 'package:darkmodetoggle/screens/chat.dart';
import 'package:darkmodetoggle/screens/trades.dart';
import 'package:flutter/material.dart';
import 'package:matomo/matomo.dart';

class TradeNav extends TraceableStatefulWidget {
  const TradeNav({Key? key}) : super(key: key);
  @override
  _TradeNavState createState() => _TradeNavState();
}

class _TradeNavState extends State<TradeNav> {
  int _currentIndex = 0;
  _getDrawerItemWidget(int pos) {
    switch (pos) {
      case 0:
        MatomoTracker.trackScreen(context, 'visited trade from trade nav');
        return const TradeScreen();
      case 1:
        MatomoTracker.trackScreen(context, 'visited chat from trade nav');
        return const ChatScreen();
      default:
        return const Text("Error");
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      body: _getDrawerItemWidget(_currentIndex),
      bottomNavigationBar: SizedBox(
        height: 46,
        child: BottomNavigationBar(
          iconSize: 15.0,
          currentIndex: _currentIndex,
          backgroundColor: colorScheme.surface,
          selectedItemColor: colorScheme.onSurface,
          unselectedItemColor: colorScheme.onSurface.withOpacity(.60),
          showSelectedLabels: false,
          showUnselectedLabels: false,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.compare_arrows), label: 'Trade'),
            BottomNavigationBarItem(icon: Icon(Icons.message), label: 'Chat'),
          ],
          onTap: (value) async {
            setState(() {
              _currentIndex = value;
            });
          },
        ),
      ),
    );
  }
}
