import 'dart:convert';

import 'package:darkmodetoggle/apis/api.dart';
import 'package:flutter/material.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class ChatLobby extends StatelessWidget {
  /// To initialize this example, an instance of [client] and [channel] is required.
  ChatLobby({
    Key? key,
  }) : super(key: key);

  /// Instance of [StreamChatClient] we created earlier. This contains information about
  /// our application and connection state.

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: getChannel(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          List<dynamic> data = snapshot.data as List;
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            builder: (context, widget) {
              return StreamChat(
                streamChatThemeData: StreamChatThemeData(
                  colorTheme: ColorTheme.dark(),
                  otherMessageTheme: const MessageThemeData(),
                ),
                client: data[0],
                child: widget,
              );
            },
            home: StreamChannel(
              channel: data[1],
              child: const ChannelPage(),
            ),
          );
        } else {
          return const Text("loading");
        }
      },
    );
  }
}

Future<List<dynamic>> getChannel() async {
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
  List<dynamic> list = [];
  late final StreamChatClient client = StreamChatClient(
    '5ceytf5njkme',
    logLevel: Level.INFO,
  );
  print('here');
  print(username);
  print(chatToken);
  await client.connectUser(
    User(
        id: username ?? 'default',
        name: username,
        image: 'http://188.166.153.138:3000/api/avataaars/' + username! + '.png'),
    chatToken!,
  );
  print('pong');
  Channel channel = client.channel('lobby', id: 'Lobby');
  await channel.watch();
  list.add(client);
  list.add(channel);
  return list;
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
              showCopyMessage: true,
              showDeleteMessage: details.isMyMessage,
              showReplyMessage: false,
              showThreadReplyMessage: false,
              showReactions: false,
              showUserAvatar: DisplayWidget.show,
              onMessageTap: (message) {
                print('pog');
              },
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
