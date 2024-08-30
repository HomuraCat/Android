import "package:flutter/material.dart";
import "package:flutter_chat_bubble/bubble_type.dart";
import 'package:flutter_chat_bubble/clippers/chat_bubble_clipper_1.dart';
import 'package:intl/intl.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import '../utils/Spsave_module.dart';

abstract class Formatter {
  Formatter._();

  static String formatDateTime(DateTime dateTime) {
    final DateFormat dateFormat = DateFormat('hh:mm a');
    return dateFormat.format(dateTime);
  }
}

enum ChatMessageType {
  sent,
  received,
}

class Chat {
  final String message;
  final ChatMessageType type;
  final DateTime time;

  Chat({required this.message, required this.type, required this.time});

  factory Chat.sent({required message}) =>
      Chat(message: message, type: ChatMessageType.sent, time: DateTime.now());
  
  factory Chat.received({required message}) =>
      Chat(message: message, type: ChatMessageType.received, time: DateTime.now());

  static Future<List<Chat>> generate({required String sendID, required String receiveID}) async {
    final List<Chat> chat_history = await SpStorage.instance.readChat(sendID: sendID, receiveID: receiveID);
    if (chat_history.isNotEmpty) return chat_history;
      else return [];
  }
}

class ChatController extends ChangeNotifier {
  ChatController({Key? key, required this.myid, required this.friendid, required this.socket}) {_initializeChatList();}
  final String myid, friendid;
  final IO.Socket socket;

  List<Chat> chatList = [];
  
  late final ScrollController scrollController = ScrollController();
  late final TextEditingController textEditingController =
      TextEditingController();
  late final FocusNode focusNode = FocusNode();

  @override
  void dispose() {
    save_chat_history();
    super.dispose();
  }

  void save_chat_history() async {
    await SpStorage.instance.saveChat(sendID: myid, receiveID: friendid, chatList: chatList);
  }

  void _initializeChatList() async {
    chatList = await Chat.generate(sendID: myid, receiveID: friendid);
    notifyListeners();
    print("Initialize the history chat for ${friendid} successfully!");
  }

  void addMessage(String message)
  {
    chatList = [
      ...chatList,
      Chat.received(message: message),
    ];
    notifyListeners();
  }

  Future<void> startRecording() async {
    print("no");
  }

    Future<void> stopRecordingAndSend() async {
    print("yes");
  }

  Future<void> onFieldSubmitted() async {
    if (!isTextFieldEnable) return;

    final String userMessage = textEditingController.text;

    // Existing message sent by the user
    chatList = [
      ...chatList,
      Chat.sent(message: userMessage),
    ];

    // Send the message to the backend
    sendMessageToBackend(myid, userMessage, friendid);

    // Scroll and reset input field
    scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );

    textEditingController.text = '';
    notifyListeners();
  }

  void sendMessageToBackend(String user1, String message, String user2){
    socket.emit('private_message', {
        'sender': user1,
        'receiver': user2, // 指定接收方
        'message': message,
      });
  }

  void onFieldChanged(String term) {
    notifyListeners();
  }

  bool get isTextFieldEnable => textEditingController.text.isNotEmpty;
}

class Bubble extends StatelessWidget {
  final EdgeInsetsGeometry? margin;
  final Chat chat;
  final String avatar;

  const Bubble({
    super.key,
    this.margin,
    required this.chat,
    required this.avatar,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: alignmentOnType,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (chat.type == ChatMessageType.received)
          CircleAvatar(
            backgroundImage: AssetImage(avatar),
          ),
        Container(
          margin: margin ?? EdgeInsets.zero,
          child: PhysicalShape(
            clipper: clipperOnType,
            elevation: 2,
            color: bgColorOnType,
            shadowColor: Colors.grey.shade200,
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.8,
              ),
              padding: paddingOnType,
              child: Column(
                crossAxisAlignment: crossAlignmentOnType,
                children: [
                  Text(
                    chat.message,
                    style: TextStyle(color: textColorOnType),
                  ),
                  const SizedBox(
                    height: 8,
                  ),
                  Text(
                    Formatter.formatDateTime(chat.time),
                    style: TextStyle(color: textColorOnType, fontSize: 12),
                  )
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Color get textColorOnType {
    switch (chat.type) {
      case ChatMessageType.sent:
        return Colors.white;
      case ChatMessageType.received:
        return const Color(0xFF0F0F0F);
    }
  }

  Color get bgColorOnType {
    switch (chat.type) {
      case ChatMessageType.received:
        return const Color(0xFFE7E7ED);
      case ChatMessageType.sent:
        return const Color(0xFF007AFF);
    }
  }

  CustomClipper<Path> get clipperOnType {
    switch (chat.type) {
      case ChatMessageType.sent:
        return ChatBubbleClipper1(type: BubbleType.sendBubble);
      case ChatMessageType.received:
        return ChatBubbleClipper1(type: BubbleType.receiverBubble);
    }
  }

  CrossAxisAlignment get crossAlignmentOnType {
    switch (chat.type) {
      case ChatMessageType.sent:
        return CrossAxisAlignment.end;
      case ChatMessageType.received:
        return CrossAxisAlignment.start;
    }
  }

  MainAxisAlignment get alignmentOnType {
    switch (chat.type) {
      case ChatMessageType.received:
        return MainAxisAlignment.start;

      case ChatMessageType.sent:
        return MainAxisAlignment.end;
    }
  }

  EdgeInsets get paddingOnType {
    switch (chat.type) {
      case ChatMessageType.sent:
        return const EdgeInsets.only(top: 10, bottom: 10, left: 10, right: 24);
      case ChatMessageType.received:
        return const EdgeInsets.only(
          top: 10,
          bottom: 10,
          left: 24,
          right: 10,
        );
    }
  }
}