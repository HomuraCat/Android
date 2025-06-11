import 'package:flutter/material.dart';
import 'cell.dart';
import 'dart:convert';
import '../utils/Spsave_module.dart';
import '../../config.dart';
import 'package:http/http.dart' as http;

class AccountPage extends StatefulWidget {
  const AccountPage({Key? key}) : super(key: key);
  @override
  _AccountPageState createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  String patientID = "", name = "", selectedAvatar = "", point = "";
  late bool identity;
  List<String> avatarOptions = [
      "assets/images/avatar1.jpg",
      "assets/images/avatar2.jpg",
  ];

  @override
  void initState(){
    super.initState();
    _InitConfig();
  }

  void _InitConfig() async{
    Map<String, dynamic>? account = await SpStorage.instance.readAccount();
    if (account != null) {
      patientID = account['patientID'];
      name = account['name'];
      identity = account['identity'];
      selectedAvatar = account['avatar'];
    }
    await GetPoint(context);
    setState(() {});
  }

  void _showAvatarSelectionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("选择头像"),
          content: Wrap(
            spacing: 10,
            children: avatarOptions.map((avatarPath) {
              return GestureDetector(
                onTap: () {
                  setState(() {
                    selectedAvatar = avatarPath;
                  });
                  SpStorage.instance.saveAccount(patientID: patientID, name: name, identity: identity, avatar: selectedAvatar);
                  Navigator.of(context).pop();
                },
                child: CircleAvatar(
                  radius: 30,
                  backgroundImage: AssetImage(avatarPath),
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }

  Widget headerWidget() {
    return Container(
      height: 110,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
      color: Colors.white,
      child: Row(
        children: [
          GestureDetector(
            onTap: () => _showAvatarSelectionDialog(context),
            child: Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                image: DecorationImage(
                  image: selectedAvatar.isEmpty ? AssetImage("assets/images/avatar1.jpg") : AssetImage(selectedAvatar),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                MediaQuery(
                    data: MediaQuery.of(context).copyWith(textScaleFactor: 1.1),
                    child: 
                      Text(
                      name.isEmpty ? "加载中..." : name,
                            style: const TextStyle(fontSize: 25, color: Colors.grey),
                      ),
                  ),
                const SizedBox(height: 5),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    MediaQuery(
                    data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
                    child: Text(
                      patientID.isEmpty ? "加载中..." : "ID: $patientID",
                      style: const TextStyle(fontSize: 17, color: Colors.grey),
                    ),
                  ),
                    
                    MediaQuery(
                    data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
                    child: Text(
                      point.isEmpty ? "加载中..." : "积分: $point",
                      style: const TextStyle(fontSize: 17, color: Colors.grey),
                    ),
                  ),
                    
                    const Image(
                      image: AssetImage("assets/images/icon_right.png"),
                      width: 15,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> GetPoint(BuildContext context) async {
    final String apiUrl = Config.baseUrl + '/getPoint';
    var url = Uri.parse(apiUrl);

    var response = await http.post(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{'patientID': patientID}),
    );
    
    if (response.statusCode == 200) {
      setState(() => point = response.body);
    }
      else setState(() => point = "ERROR");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '我的',
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: Container(
        color: Colors.white,
        child: MediaQuery.removePadding(
          removeTop: true,
          context: context,
          child: ListView(
            children: [
              headerWidget(),
              Column(children: [
                const SizedBox(
                  height: 10,
                ),
                const MineCell(
                  imageName: 'assets/images/account.png',
                  title: '基本信息',
                ),
                const SizedBox(
                  height: 10,
                ),
                const MineCell(
                  imageName: 'assets/images/account.png',
                  title: '每日上报',
                ),
                Row(
                  children: <Widget>[
                    Container(width: 50, height: 0.5, color: Colors.white),
                  ],
                ),
                const MineCell(
                  imageName: 'assets/images/account.png',
                  title: '问卷',
                ),
                const MineCell(
                  imageName: 'assets/images/account.png',
                  title: '积分商城',
                ),
                const SizedBox(
                  height: 10,
                ),
                const MineCell(
                  imageName: 'assets/images/account.png',
                  title: '设置',
                ),const SizedBox(
                  height: 10,
                ),
              ])
            ],
          ),
        ),
      ),
    );
  }
}