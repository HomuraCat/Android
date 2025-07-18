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
  late String patientInfo = "", nurseInfo = "";
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
    Map<String, dynamic>? account = await SpStorage.instance.readAccount();
    if (account != null) {
      patientID = account['patientID'];
      name = account['name'];
    }
    connectToServer();
    await GetNurseInfo(context);
    if (nurseInfo != "ERROR")
    {
      List<String> each_nurse = nurseInfo.split(' ');
      each_nurse.forEach((single_nurse) {
        List<String> single_nurse_info = single_nurse.split('_');
        ChatPartner temp_partner = ChatPartner(myid: patientID, friendname: single_nurse_info[1], friendid: single_nurse_info[0], type: 3, socket: socket);
        chat_manager.addPartner(temp_partner);
      });
      setState(() {});
    }
    await GetPatientInfo(context);
    if (patientInfo != "ERROR")
    {
      List<String> each_patient = patientInfo.split(' ');
      each_patient.forEach((single_patient) {
        List<String> single_patient_info = single_patient.split('_');
        ChatPartner temp_partner = ChatPartner(myid: patientID, friendname: single_patient_info[1], friendid: single_patient_info[0], type: 1, socket: socket);
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
    // Scaffold 应该作为页面的最外层结构
    child: Scaffold(
      appBar: AppBar(
        title: const Text(
          '聊天',
          style: TextStyle(color: Colors.black),
        ),
      ),
      // 将 Column 放到 body 里面
      body: Column(
        children: [
          // 用 Expanded 包裹 ListView.builder
          Expanded(
            child: Consumer<ChatManager>(
              builder: (context, chatManager, child) {
                return ListView.builder(
                  itemCount: chatManager.partners.length,
                  itemBuilder: (context, index) {
                    return chatManager.partners[index];
                  },
                );
              },
            ),
          ),
          // 在 ListView 的下方放置一个固定高度的 SizedBox
          // 注意：这里的拼写已更正为 SizedBox
          SizedBox(height: 80),
        ],
      ),
    ),
  );
}

  Future<void> GetNurseInfo(BuildContext context) async {
    final String apiUrl = Config.baseUrl + '/nurse/get_list';
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
        }
        print(res);
        setState(() => nurseInfo = res);
      }
        else setState(() => nurseInfo = "ERROR");
    }
      else setState(() => nurseInfo = "ERROR");
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
  ChatPartner({Key? key, required this.myid, required this.friendname, required this.friendid, required this.type, required this.socket})
      : super(key: key) {chatController = ChatController(myid: myid, friendid: friendid, socket: socket);}
  final String myid, friendname, friendid;
  final IO.Socket socket;
  late final ChatController chatController;
  final int type;

@override
Widget build(BuildContext context) {
  // 将原有的ListTile和新增的SizedBox包裹在一个Column中
  return Column(
    children: [
      ListTile(
        onTap: () {
          Navigator.of(context).push(MaterialPageRoute(
              builder: (BuildContext context) => ChangeNotifierProvider.value(
                  value: chatController,
                  child: ChatUI(friendname: friendname, avatar: "assets/images/avatar$type.jpg"))));
        },
        leading: CircleAvatar(
          backgroundImage: AssetImage("assets/images/avatar$type.jpg"),
        ),
        title: Text(
          friendname,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    ],
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
  bool isVoiceInput = false, isSpeaking = false, isCancel = false;
  OverlayEntry? _overlayEntry;

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

  String showRecordStatus() {
    if (isSpeaking) {
      if (isCancel) return "取消发送";
        else return "松开发送";
    }
      else return "按下说话";
  }

  void _showCancelOverlay(BuildContext context) {
    _overlayEntry = OverlayEntry(
      builder: (context) {
        return Center(
          child: Material(
            color: Colors.transparent,
            child: Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.7),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Icon(
                        Icons.mic,
                        size: 80,
                        color: Colors.white,
                      ),
                      if (isCancel)
                        Icon(
                          Icons.mic_off,
                          size: 80,
                          color: Colors.white,
                        ),
                    ],
                  ),
                  SizedBox(height: 10),
                  Text(
                    isCancel ? "松开取消发送" : "正在录音...",
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
    Overlay.of(context).insert(_overlayEntry!);
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  Widget buildVoiceInputButton() {
    return Expanded(
      child: GestureDetector(
          onLongPressStart: (_) {
            setState(() {isSpeaking = true; isCancel = false;});
            _showCancelOverlay(context);
            context.read<ChatController>().startRecording();
          },
          onLongPressMoveUpdate: (details) {
          if (details.localPosition.dy < -10) {  // 手指上移的距离
            setState(() {
              isCancel = true;
            });
            _overlayEntry?.markNeedsBuild();
          } else {
            setState(() {
              isCancel = false;
            });
            _overlayEntry?.markNeedsBuild();
          }
        },
        onLongPressEnd: (_) {
          _removeOverlay();
          setState(() {isSpeaking = false;});
          if (!isCancel) context.read<ChatController>().stopRecordingAndSend();
        },
        child: Container(
          padding: EdgeInsets.all(10),
          margin: EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: isSpeaking ?Colors.white :Colors.blue,
            borderRadius: BorderRadius.circular(50),
          ),
          child: Center(
            child: Text(
              showRecordStatus(),
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