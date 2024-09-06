import "package:flutter/material.dart";
import "package:flutter_chat_bubble/bubble_type.dart";
import 'package:flutter_chat_bubble/clippers/chat_bubble_clipper_1.dart';
import 'package:intl/intl.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:record/record.dart';
import 'package:audioplayers/audioplayers.dart';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
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
  word,
  voice
}

class Chat {
  final String message;
  final ChatMessageType send_type;
  final ChatMessageType message_type;
  final DateTime time;

  Chat({required this.message, required this.send_type, required this.message_type, required this.time});

  factory Chat.sent_word({required message}) =>
      Chat(message: message, send_type: ChatMessageType.sent, message_type: ChatMessageType.word, time: DateTime.now());
  
  factory Chat.received_word({required message}) =>
      Chat(message: message, send_type: ChatMessageType.received, message_type: ChatMessageType.word, time: DateTime.now());
  
  factory Chat.sent_voice({required message}) =>
      Chat(message: message, send_type: ChatMessageType.sent, message_type: ChatMessageType.voice, time: DateTime.now());
  
  factory Chat.received_voice({required message}) =>
      Chat(message: message, send_type: ChatMessageType.received, message_type: ChatMessageType.voice, time: DateTime.now());

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
  final Record _audioRecorder = Record();

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

  void addMessage(String message, String message_type)
  {
    if (message_type == "word")
      chatList = [
        ...chatList,
        Chat.received_word(message: message),
      ];
    else
      chatList = [
        ...chatList,
        Chat.received_voice(message: message),
      ];
    notifyListeners();
  }

  Future<void> startRecording() async {
    final directory = await Directory.systemTemp.createTemp();
    final String? _filePath = '${directory.path}/voice_${DateTime.now().millisecondsSinceEpoch}.mp4';
    await _audioRecorder.start(
      path: _filePath,  // 指定音频保存路径
      encoder: AudioEncoder.wav,       // 音频编码器
      bitRate: 128000,                 // 比特率
      samplingRate: 44100,             // 采样率
    );
  }

  Future<void> stopRecordingAndSend() async {
    final path = await _audioRecorder.stop();
    if (path != null) 
    {
      File audioFile = File(path);
      List<int> audioBytes = await audioFile.readAsBytes();
      String base64Audio = base64Encode(audioBytes);

      chatList = [
        ...chatList,
        Chat.sent_voice(message: base64Audio),
      ];

      // Send the message to the backend
      sendMessageToBackend(myid, base64Audio, friendid, "voice");

      // Scroll and reset input field
      scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );

      textEditingController.text = '';
      notifyListeners();
    }
  }

  Future<void> onFieldSubmitted() async {
    if (!isTextFieldEnable) return;

    final String userMessage = textEditingController.text;

    // Existing message sent by the user
    chatList = [
      ...chatList,
      Chat.sent_word(message: userMessage),
    ];

    // Send the message to the backend
    sendMessageToBackend(myid, userMessage, friendid, "word");

    // Scroll and reset input field
    scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );

    textEditingController.text = '';
    notifyListeners();
  }

  void sendMessageToBackend(String user1, String message, String user2, String message_type){
    socket.emit('private_message', {
        'sender': user1,
        'receiver': user2, // 指定接收方
        'message': message,
        'message_type': message_type
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

  void playVoiceMessage(String base64Audio) async {
    // 解码 Base64 字符串
    Uint8List audioBytes = base64Decode(base64Audio);

    // 将字节数据写入临时文件
    final directory = await Directory.systemTemp.createTemp();
    String tempPath = '${directory.path}/temp_voice_${DateTime.now().millisecondsSinceEpoch}.m4a';
    File tempFile = File(tempPath);
    await tempFile.writeAsBytes(audioBytes);

    // 播放音频
    final player = AudioPlayer();
    await player.play(tempFile.path, isLocal: true);
  }

  @override
  Widget build(BuildContext context) {
    if (chat.message_type == "word")
      return Row(
        mainAxisAlignment: alignmentOnType,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (chat.send_type == ChatMessageType.received)
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
    else
      return GestureDetector(
        onTap: () => playVoiceMessage(chat.message),
        child: Container(
          padding: EdgeInsets.all(10),
          margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
          decoration: BoxDecoration(
            color: Colors.green[200],
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              Icon(Icons.play_arrow),
              SizedBox(width: 10),
              Text('语音消息'),
            ],
          ),
        ),
      );
  }

  Color get textColorOnType {
    switch (chat.send_type) {
      case ChatMessageType.sent:
        return Colors.white;
      case ChatMessageType.received:
        return const Color(0xFF0F0F0F);
    }
    return Colors.white;
  }

  Color get bgColorOnType {
    switch (chat.send_type) {
      case ChatMessageType.received:
        return const Color(0xFFE7E7ED);
      case ChatMessageType.sent:
        return const Color(0xFF007AFF);
    }
    return const Color(0xFFE7E7ED);
  }

  CustomClipper<Path> get clipperOnType {
    switch (chat.send_type) {
      case ChatMessageType.sent:
        return ChatBubbleClipper1(type: BubbleType.sendBubble);
      case ChatMessageType.received:
        return ChatBubbleClipper1(type: BubbleType.receiverBubble);
    }
    return ChatBubbleClipper1(type: BubbleType.sendBubble);
  }

  CrossAxisAlignment get crossAlignmentOnType {
    switch (chat.send_type) {
      case ChatMessageType.sent:
        return CrossAxisAlignment.end;
      case ChatMessageType.received:
        return CrossAxisAlignment.start;
    }
    return CrossAxisAlignment.end;
  }

  MainAxisAlignment get alignmentOnType {
    switch (chat.send_type) {
      case ChatMessageType.received:
        return MainAxisAlignment.start;

      case ChatMessageType.sent:
        return MainAxisAlignment.end;
    }
    return MainAxisAlignment.start;
  }

  EdgeInsets get paddingOnType {
    switch (chat.send_type) {
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
    return const EdgeInsets.only(top: 10, bottom: 10, left: 10, right: 24);
  }
}