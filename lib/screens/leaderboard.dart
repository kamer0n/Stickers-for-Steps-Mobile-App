import 'package:darkmodetoggle/backend/leaderboard.dart';
import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({Key? key}) : super(key: key);

  @override
  _LeaderboardScreenState createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  @override
  void initState() {
    super.initState();
  }

  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //backgroundColor: Colors.black54,
      body: FutureBuilder<List<Leaderboard>>(
        future: fetchLeaderboard(http.Client()),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            //print(snapshot);
            return const Center(
              child: Text('An error has occurred!'),
            );
          } else if (snapshot.hasData) {
            var list = LeaderboardView(leaderboard: snapshot.data!);
            return ListView(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [list],
                  ),
                )
              ],
            );
          } else {
            return const Align(
              alignment: Alignment.center,
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
    );
  }
}
