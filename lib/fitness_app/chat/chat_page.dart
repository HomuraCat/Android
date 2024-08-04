import "package:flutter/material.dart";
import "chat_tool.dart";
import "package:flutter_svg/svg.dart";
import "package:provider/provider.dart";
import 'package:http/http.dart' as http;
import 'package:web_socket_channel/io.dart';
import '../utils/Spsave_module.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({Key? key}) : super(key: key);

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  late String patientInfo = "";
  List<ChatPartner> ChatPartners = <ChatPartner>[];
  late IOWebSocketChannel _channel;
  String patientID = "", name = "";

  @override
  void initState() {
    super.initState();
    _initConfig();
  }

  void _initConfig() async {
    Map<String, dynamic> account = await SpStorage.instance.readAccount();
    patientID = account['patientID'];
    name = account['name'];
    await GetPatientInfo(context);
    if (patientInfo != "ERROR")
    {
      List<String> each_patient = patientInfo.split(' ');
      each_patient.forEach((single_patient) {
        List<String> single_patient_info = single_patient.split('_');
        ChatPartner temp_partner = ChatPartner(myid: patientID, friendname: single_patient_info[1], subinfo: "一个平平无奇的病人", friendid: single_patient_info[0]);
        ChatPartners.add(temp_partner);
      });
    }
    _connectToWebSocket();
  }

    void _connectToWebSocket() {
    _channel = IOWebSocketChannel.connect(
      'ws://10.0.2.2:5001/socket.io/?user_id=$patientID',
    );
    _channel.stream.listen((message) {
      // 处理收到的新消息
      print('Received: $message');
    });
  }

  @override
  void dispose() {
    _channel.sink.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text(
            '聊天',
            style: TextStyle(color: Colors.black),
          ),
        ),
        body: ListView(scrollDirection: Axis.vertical, children: ChatPartners));
  }

  Future<void> GetPatientInfo(BuildContext context) async {
    var url = Uri.parse('http://43.136.14.179:5001/patient/get_list');

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
  const ChatPartner({Key? key, required this.myid, required this.friendname, required this.subinfo, required this.friendid})
      : super(key: key);
  final String myid, friendname, subinfo, friendid;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () {
        Navigator.of(context).push(MaterialPageRoute(
            builder: (BuildContext context) => ChangeNotifierProvider(
                create: (_) => ChatController(myid: this.myid, friendid: this.friendid),
                child:
                    ChatUI(friendname: friendname, avatar: "assets/images/aaa.png"))));
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
      subtitle: Text(
        subinfo,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class ChatUI extends StatelessWidget {
  const ChatUI({Key? key, required this.friendname, required this.avatar})
      : super(key: key);
  final String friendname, avatar;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: Text(friendname),
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
                        return Bubble(chat: chatList[index], avatar: avatar);
                      },
                    );
                  },
                ),
              ),
            ),
          ),
          const _BottomInputField(),
        ],
      ),
    );
  }
}

class _BottomInputField extends StatelessWidget {
  const _BottomInputField({Key? key}) : super(key: key);

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