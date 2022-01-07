import 'dart:convert';

import 'package:darkmodetoggle/apis/api.dart';
import 'package:darkmodetoggle/backend/friends.dart';
import 'package:darkmodetoggle/screens/friend_screen.dart';
import 'package:flutter/material.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  late Channel channel;
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: getChannel(context),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          //List<dynamic> data = snapshot.data as List;
          return StreamChannel(
            channel: channel,
            child: const ChannelPage(),
          );
        } else {
          return const Text("loading");
        }
      },
    );
  }

  Future<int> getChannel(context) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String? username = preferences.getString("username");
    String? chatToken = preferences.getString("chatToken");
    if (chatToken == null) {
      final response = await http.post(Uri.parse(chatTokenUrl),
          headers: {
            "Accept": "application/json",
            "Content-Type": "application/x-www-form-urlencoded",
            "authorization": ("TOKEN " + (preferences.getString('token') ?? defaultToken))
          },
          encoding: Encoding.getByName("utf-8"));
      if (response.statusCode == 200) {
        Map<String, dynamic> resposne = jsonDecode(response.body);
        preferences.setString("chatToken", resposne["chatToken"]);
        chatToken = resposne["chatToken"];
      }
    }

    StreamChat.of(context).client.disconnectUser();
    await StreamChat.of(context).client.connectUser(
          User(
              id: username ?? 'default',
              name: username,
              image: 'http://188.166.153.138:3000/api/avataaars/' + username! + '.png'),
          chatToken!,
        );
    channel = StreamChat.of(context).client.channel('lobby', id: 'Lobby');
    await channel.watch();
    return 1;
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  void dispose() {
    channel.dispose();
    super.dispose();
  }
}

/// Displays the list of messages inside the channel
class ChannelPage extends StatelessWidget {
  const ChannelPage({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Expanded(
            child: MessageListView(
          showFloatingDateDivider: false,
          messageBuilder: (context, details, messages, defaultMessage) {
            return defaultMessage.copyWith(
              showFlagButton: false,
              showEditMessage: false,
              showCopyMessage: false,
              showDeleteMessage: details.isMyMessage,
              showReplyMessage: false,
              showThreadReplyMessage: false,
              showReactions: false,
              showUserAvatar: DisplayWidget.show,
              onUserAvatarTap: (user) {
                print(user.id);
                List<Friend> friends = [];
                friends.add(Friend(id: user.id, avatar: user.image ?? '', name: user.name, fluff: ''));

                Navigator.push(context, MaterialPageRoute(builder: (context) => (FriendScreen(friends[0]))));
              },
              onMessageTap: (message) {
                print('pog');
              },
              //onMessageActions: (p0, p1) {},
              customActions: [
                MessageAction(
                  leading: const Icon(
                    Icons.add,
                    color: Colors.white,
                  ),
                  title: const Text(
                    'View Profile',
                    style: TextStyle(color: Colors.white),
                  ),
                  onTap: (message) {
                    print(message.user?.id);
                    List<Friend> friends = [];
                    friends.add(Friend(
                        id: message.user!.id, avatar: message.user!.image ?? '', name: message.user!.name, fluff: ''));

                    Navigator.push(context, MaterialPageRoute(builder: (context) => (FriendScreen(friends[0]))));
                  },
                ),
              ],
              showSendingIndicator: false,
            );
          },
        )),
        const MessageInput(
          disableAttachments: true,
        ),
      ],
    );
  }
}
