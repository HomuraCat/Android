import "package:flutter/material.dart";
import "chat_tool.dart";
import "package:flutter_svg/svg.dart";
import "package:provider/provider.dart";
import 'package:http/http.dart' as http;
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:permission_handler/permission_handler.dart';
import '../utils/Spsave_module.dart';
import '../utils/common_tools.dart';
import '../../config.dart';

class ChatManager extends ChangeNotifier{
  final List<ChatPartner> partners = [];

  void addPartner(ChatPartner chat_partner) {
    partners.add(chat_partner);
  }

  void AddChat(String friendid, String message, String message_type) {
    final ChatController this_one = partners.firstWhere((p) => p.friendid == friendid).chatController;
    this_one.addMessage(message, message_type);
  }

  void deconstruction() {
    ChatPartner temp;
    for (temp in partners)
      temp.chatController.dispose();
  }
}

class ChatPage extends StatefulWidget {
  const ChatPage({Key? key}) : super(key: key);

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  late String patientInfo = "";
  List<ChatPartner> ChatPartners = <ChatPartner>[];
  late IO.Socket socket;
  String patientID = "", name = "";
  NotificationHelper notificationHelper = NotificationHelper();
  late ChatManager chat_manager;

  @override
  void initState() {
    super.initState();
    chat_manager = ChatManager();
    _initConfig();
    _requestPermissions();
  }

  void _initConfig() async {
    Map<String, dynamic> account = await SpStorage.instance.readAccount();
    patientID = account['patientID'];
    name = account['name'];
    connectToServer();
    await GetPatientInfo(context);
    if (patientInfo != "ERROR")
    {
      List<String> each_patient = patientInfo.split(' ');
      each_patient.forEach((single_patient) {
        List<String> single_patient_info = single_patient.split('_');
        ChatPartner temp_partner = ChatPartner(myid: patientID, friendname: single_patient_info[1], friendid: single_patient_info[0], socket: socket);
        chat_manager.addPartner(temp_partner);
      });
      setState(() {});
    }
    socket.connect();
  }

  Future<void> _requestPermissions() async {
    final microphone_status = await Permission.microphone.status;
    if (microphone_status != PermissionStatus.granted) {
      await Permission.microphone.request();
    }
    final storageStatus = await Permission.storage.status;
    if (storageStatus != PermissionStatus.granted) {
      await Permission.storage.request();
    }
  }

  void connectToServer() {
    String url = 'http://43.136.52.103:5001?username=$patientID';
    socket = IO.io(url, <String, dynamic>{
      'transports': ['websocket'],
      'forceNew': true,
      'reconnection': false,
    });

    socket.on('message', (data) {
      notificationHelper.showChatMessageNotification(notificationId: 0, title: data['sender'], message: (data['message_type'] == 'word')?data['message']:'语音消息');
      chat_manager.AddChat(data['sender'], data['message'], data['message_type']);
    });

    socket.onConnect((_) {
      print('Connected!');
    });

    socket.onDisconnect((_) {
      print('Disconnected!');
    });

    socket.onConnectError((error) {
      print('Connect Error: $error');
    });

    socket.onError((error) {
      print('Error: $error');
    });
  }

  @override
  void dispose() {
    chat_manager.deconstruction();
    socket.disconnect();
    socket.destroy();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => chat_manager,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            '聊天',
            style: TextStyle(color: Colors.black),
          ),
        ),
        body: Consumer<ChatManager>(
          builder: (context, chatManager, child) {
          return ListView.builder(
            itemCount: chatManager.partners.length,
            itemBuilder: (context, index) {
              return chatManager.partners[index];
            },
          );},
        ),
      ),
    );
  }

  Future<void> GetPatientInfo(BuildContext context) async {
    final String apiUrl = Config.baseUrl + '/patient/get_list';
    var url = Uri.parse(apiUrl);

    var response = await http.get(url);
    
    if (response.statusCode == 200) {
      if (response.body != '0') 
      {
        String res = "";
        List<String> temp_res = response.body.split("/*-+");
        for (int i = 0; i < temp_res.length; i++)
        {
          if (i != 0) res = res + " ";
          List<String> temp = temp_res[i].split("+-*/");
          res = res + temp[0] + "_";
          if (temp[1] == "") res = res + "未命名";
            else res = res + temp[1];
          res = res + "_";
          if (temp[2] == "") res = res + "未分组";
            else res = res + temp[2];
        }
        setState(() => patientInfo = res);
      }
        else setState(() => patientInfo = "ERROR");
    }
      else setState(() => patientInfo = "ERROR");
  }
}

class ChatPartner extends StatelessWidget {
  ChatPartner({Key? key, required this.myid, required this.friendname, required this.friendid, required this.socket})
      : super(key: key) {chatController = ChatController(myid: myid, friendid: friendid, socket: socket);}
  final String myid, friendname, friendid;
  final IO.Socket socket;
  late final ChatController chatController;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () {
        Navigator.of(context).push(MaterialPageRoute(
            builder: (BuildContext context) => ChangeNotifierProvider.value(
                value: chatController,
                child: ChatUI(friendname: friendname, avatar: "assets/images/aaa.png"))));
      },
      leading: CircleAvatar(
        backgroundImage: AssetImage("assets/images/aaa.png"),
      ),
      title: Text(
        friendname,
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class ChatUI extends StatefulWidget {
  const ChatUI({Key? key, required this.friendname, required this.avatar}) : super(key: key);
  final String friendname, avatar;

  @override
  State<ChatUI> createState() => _ChatUI();
}

class _ChatUI extends State<ChatUI> {
  bool isVoiceInput = false, isSpeaking = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: Text(widget.friendname),
        backgroundColor: const Color(0xFF007AFF),
      ),
      body: Column(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () {
                context.read<ChatController>().focusNode.unfocus();
              },
              child: Align(
                alignment: Alignment.topCenter,
                child: Selector<ChatController, List<Chat>>(
                  selector: (context, controller) =>
                      controller.chatList.reversed.toList(),
                  builder: (context, chatList, child) {
                    return ListView.separated(
                      shrinkWrap: true,
                      reverse: true,
                      padding: const EdgeInsets.only(top: 12, bottom: 20) +
                          const EdgeInsets.symmetric(horizontal: 12),
                      separatorBuilder: (_, __) => const SizedBox(
                        height: 12,
                      ),
                      controller:
                          context.read<ChatController>().scrollController,
                      itemCount: chatList.length,
                      itemBuilder: (context, index) {
                        return Bubble(chat: chatList[index], avatar: widget.avatar);
                      },
                    );
                  },
                ),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: Color(0xFFE5E5EA),
                ),
              ),
            ),
            child: Row(
              children: [
                IconButton(
                  icon: Icon(isVoiceInput ? Icons.keyboard : Icons.mic),
                  onPressed: () {
                    setState(() {
                      isVoiceInput = !isVoiceInput;
                    });
                  },
                ),
                isVoiceInput
                    ? buildVoiceInputButton()
                    : Expanded(child: buildTextInputField()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildVoiceInputButton() {
    return Expanded(
      child: GestureDetector(
        onLongPressStart: (_) => {setState(() {isSpeaking = true;}), context.read<ChatController>().startRecording()},
        onLongPressEnd: (_) => {setState(() {isSpeaking = false;}), context.read<ChatController>().stopRecordingAndSend()},
        child: Container(
          padding: EdgeInsets.all(10),
          margin: EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: isSpeaking ?Colors.white :Colors.blue,
            borderRadius: BorderRadius.circular(50),
          ),
          child: Center(
            child: Text(
              isSpeaking ?'松开发送' :'按下说话',
              style: TextStyle(color: isSpeaking ?Colors.black :Colors.white),
            ),
          ),
        ),
      ),
    );
  }
}
class buildTextInputField extends StatelessWidget {
  const buildTextInputField({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: true,
      child: Container(
        constraints: const BoxConstraints(minHeight: 48),
        width: double.infinity,
        decoration: const BoxDecoration(
          border: Border(
            top: BorderSide(
              color: Color(0xFFE5E5EA),
            ),
          ),
        ),
        child: Stack(
          children: [
            TextField(
              focusNode: context.read<ChatController>().focusNode,
              onChanged: context.read<ChatController>().onFieldChanged,
              controller: context.read<ChatController>().textEditingController,
              maxLines: null,
              textAlignVertical: TextAlignVertical.top,
              decoration: InputDecoration(
                border: InputBorder.none,
                contentPadding: const EdgeInsets.only(
                  right: 42,
                  left: 16,
                  top: 18,
                ),
                hintText: '请输入消息',
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide.none,
                  borderRadius: BorderRadius.circular(8.0),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide.none,
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: IconButton(
                icon: SvgPicture.asset(
                  "assets/images/send.svg",
                  colorFilter: ColorFilter.mode(
                    context.select<ChatController, bool>(
                            (value) => value.isTextFieldEnable)
                        ? const Color(0xFF007AFF)
                        : const Color(0xFFBDBDC2),
                    BlendMode.srcIn,
                  ),
                ),
                onPressed: context.read<ChatController>().onFieldSubmitted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}