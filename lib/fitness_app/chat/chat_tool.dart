import "package:flutter/material.dart";
import "package:flutter_chat_bubble/bubble_type.dart";
import 'package:flutter_chat_bubble/clippers/chat_bubble_clipper_1.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

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

  static List<Chat> generate() {
    return [
      Chat(
        message: "Hello!",
        type: ChatMessageType.sent,
        time: DateTime.now().subtract(const Duration(minutes: 15)),
      ),
      Chat(
        message: "Nice to meet you!",
        type: ChatMessageType.received,
        time: DateTime.now().subtract(const Duration(minutes: 14)),
      ),
      Chat(
        message: "The weather is nice today.",
        type: ChatMessageType.sent,
        time: DateTime.now().subtract(const Duration(minutes: 13)),
      ),
      Chat(
        message: "Yes, it's a great day to go out.",
        type: ChatMessageType.received,
        time: DateTime.now().subtract(const Duration(minutes: 12)),
      ),
      Chat(
        message: "Have a nice day!",
        type: ChatMessageType.sent,
        time: DateTime.now().subtract(const Duration(minutes: 11)),
      ),
      Chat(
        message: "What are your plans for the weekend?",
        type: ChatMessageType.received,
        time: DateTime.now().subtract(const Duration(minutes: 10)),
      ),
      Chat(
        message: "I'm planning to go to the beach.",
        type: ChatMessageType.sent,
        time: DateTime.now().subtract(const Duration(minutes: 9)),
      ),
      Chat(
        message: "That sounds fun!",
        type: ChatMessageType.received,
        time: DateTime.now().subtract(const Duration(minutes: 8)),
      ),
      Chat(
        message: "Do you want to come with me?",
        type: ChatMessageType.sent,
        time: DateTime.now().subtract(const Duration(minutes: 7)),
      ),
      Chat(
        message: "Sure, I'd love to!",
        type: ChatMessageType.received,
        time: DateTime.now().subtract(const Duration(minutes: 6)),
      ),
      Chat(
        message: "What time should we meet?",
        type: ChatMessageType.received,
        time: DateTime.now().subtract(const Duration(minutes: 5)),
      ),
      Chat(
        message: "Let's meet at 10am.",
        type: ChatMessageType.sent,
        time: DateTime.now().subtract(const Duration(minutes: 4)),
      ),
      Chat(
        message: "Sounds good to me!",
        type: ChatMessageType.received,
        time: DateTime.now().subtract(const Duration(minutes: 3)),
      ),
      Chat(
        message: "See you then!",
        type: ChatMessageType.sent,
        time: DateTime.now().subtract(const Duration(minutes: 2)),
      ),
      Chat(
        message: "Bye!",
        type: ChatMessageType.received,
        time: DateTime.now().subtract(const Duration(minutes: 1)),
      ),
      Chat(
        message: "How was your weekend?",
        type: ChatMessageType.received,
        time: DateTime.now().subtract(const Duration(minutes: 1)),
      ),
      Chat(
        message: "It was great! The beach was awesome.",
        type: ChatMessageType.sent,
        time: DateTime.now(),
      ),
      Chat(
        message: "I'm glad to hear that!",
        type: ChatMessageType.received,
        time: DateTime.now(),
      ),
      Chat(
        message: "We should do that again sometime.",
        type: ChatMessageType.sent,
        time: DateTime.now(),
      ),
      Chat(
        message: "Definitely!",
        type: ChatMessageType.received,
        time: DateTime.now(),
      ),
    ];
  }
}

class ChatController extends ChangeNotifier {
  List<Chat> chatList = Chat.generate();

  late final ScrollController scrollController = ScrollController();
  late final TextEditingController textEditingController =
      TextEditingController();
  late final FocusNode focusNode = FocusNode();

  Future<void> onFieldSubmitted() async {
    if (!isTextFieldEnable) return;

    final String userMessage = textEditingController.text;

    // Existing message sent by the user
    chatList = [
      ...chatList,
      Chat.sent(message: userMessage),
    ];

    // Send the message to the backend
    final response = await sendMessageToBackend(userMessage);

    // Update the chat with the response from the backend
    chatList = [
      ...chatList,
      Chat(
          message: response,
          type: ChatMessageType.received,
          time: DateTime.now()),
    ];

    // Scroll and reset input field
    scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );

    textEditingController.text = '';
    notifyListeners();
  }

  Future<String> sendMessageToBackend(String message) async {
    // Replace with your backend URL
    var url = Uri.parse('http://10.0.2.2:5001/message');

    try {
      var response = await http.post(
        url,
        body: json.encode({'message': message}),
        headers: {'Content-Type': 'application/json'},
      );
      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        // Assuming the response contains a field 'reply'
        return data['reply'];
      } else {
        // Handle error or return a default message
        return "Error: could not connect to server.";
      }
    } catch (e) {
      // Handle exception or return a default message
      return "Error: server unreachable.";
    }
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