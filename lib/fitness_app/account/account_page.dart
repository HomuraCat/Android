import 'package:flutter/material.dart';
import 'cell.dart';
import '../utils/Spsave_module.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({Key? key}) : super(key: key);
  @override
  _AccountPageState createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  late String patientID = "", name = "";

  @override
  void initState(){
    super.initState();
    _InitConfig();
  }

  void _InitConfig() async{
    Map<String, dynamic> account = await SpStorage.instance.readAccount();
    patientID = account['patientID'];
    name = account['name'];
    setState(() {});
  }

  Widget headerWidget() {
    return Container(
      height: 110,
      color: Colors.white,
      child: Container(
        child: Container(
          margin:
              const EdgeInsets.only(top: 0, bottom: 20, left: 10, right: 10),
          child: Row(children: [
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  image: const DecorationImage(
                      image: AssetImage("assets/images/southeast.jpeg"),
                      fit: BoxFit.cover)),
            ),
            Container(
              width: MediaQuery.of(context).size.width - 90,
              padding: const EdgeInsets.only(left: 10, top: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    height: 35,
                    child: Text(
                      name.isEmpty ?"加载中..." :name,
                      style: TextStyle(fontSize: 25, color: Colors.grey),
                    ),
                  ),
                  Container(
                      height: 35,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text(
                            patientID.isEmpty ?"加载中..." :"ID:" + patientID,
                            style: TextStyle(fontSize: 17, color: Colors.grey),
                          ),
                          Image(
                            image: AssetImage("assets/images/icon_right.png"),
                            width: 15,
                          )
                        ],
                      )),
                ],
              ),
            )
          ]),
        ),
      ),
    );
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
                  imageName: 'assets/images/southeast.jpeg',
                  title: '基本信息',
                ),
                const SizedBox(
                  height: 10,
                ),
                const MineCell(
                  imageName: 'assets/images/southeast.jpeg',
                  title: '每日上报',
                ),
                Row(
                  children: <Widget>[
                    Container(width: 50, height: 0.5, color: Colors.white),
                  ],
                ),
                const MineCell(
                  imageName: 'assets/images/southeast.jpeg',
                  title: '评估日记',
                ),
                Row(
                  children: <Widget>[
                    Container(width: 50, height: 0.5, color: Colors.white),
                    Container(height: 0.5, color: Colors.grey)
                  ],
                ),
                Row(
                  children: <Widget>[
                    Container(width: 50, height: 0.5, color: Colors.white),
                    Container(height: 0.5, color: Colors.grey)
                  ],
                ),
                const MineCell(
                  imageName: 'assets/images/southeast.jpeg',
                  title: '喜欢',
                ),
                const SizedBox(
                  height: 10,
                ),
                const MineCell(
                  imageName: 'assets/images/southeast.jpeg',
                  title: '设置',
                ),
              ])
            ],
          ),
        ),
      ),
    );
  }
}