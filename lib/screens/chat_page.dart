import 'package:chat_gpt_sdk/chat_gpt_sdk.dart';
import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:flutter/material.dart';
import 'package:nicoapi/const.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final _openAI = OpenAI.instance.build(
    token: OPEN_AI_APIKEY,
    // apiUrl: 'https://platform.openai.com/api-keys',
    baseOption: HttpSetup(
        receiveTimeout: const Duration(seconds: 10),
        connectTimeout: const Duration(seconds: 10)),
    enableLog: true,
  );

  final ChatUser _currentUser = ChatUser(
    id: '1',
    firstName: 'Nico',
    lastName: 'Siasit',
  );

  final ChatUser _gptChatUser = ChatUser(
    id: '2',
    firstName: 'Dominic',
    lastName: 'GPT',
  );

  List<ChatMessage> message = <ChatMessage>[];
  List<ChatUser> typingUser = <ChatUser>[];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        toolbarHeight: 100,
        backgroundColor: Colors.black,
        title: const Text(
          'DominicGPT',
          style: TextStyle(color: Colors.white, fontSize: 20),
        ),
      ),
      body: DashChat(
          currentUser: _currentUser,
          messageOptions: const MessageOptions(
            currentUserContainerColor: Colors.black,
            containerColor: Colors.green,
            textColor: Colors.white,
          ),
          onSend: (ChatMessage m) {
            getResponseChat(m);
          },
          messages: message),
    );
  }

  Future<void> getResponseChat(ChatMessage m) async {
    setState(() {
      message.insert(0, m);
      typingUser.add(_gptChatUser);
    });
    List<Messages> messageHistory = message.reversed.map((m) {
      if (m.user == _currentUser) {
        return Messages(
          role: Role.user,
          content: m.text,
        );
      } else {
        return Messages(
          role: Role.user,
          content: m.text,
        );
      }
    }).toList();
    final request = ChatCompleteText(
        model: GptTurbo0301ChatModel(),
        messages: messageHistory,
        maxToken: 200);
    final response = await _openAI.onChatCompletion(request: request);
    for (var element in response!.choices) {
      if (element.message != null) {
        setState(() {
          message.insert(
            0,
            ChatMessage(
                user: _gptChatUser,
                createdAt: DateTime.now(),
                text: element.message!.content),
          );
        });
      }
    }
    setState(() {
      typingUser.remove(_gptChatUser);
    });
  }
}
