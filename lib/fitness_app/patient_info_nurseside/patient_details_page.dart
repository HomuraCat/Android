import 'package:flutter/material.dart';
import 'cell.dart';
import 'dart:convert';
import '../../config.dart';
import 'package:http/http.dart' as http;

class PatientDetailsPage extends StatefulWidget {
  const PatientDetailsPage({Key? key, required this.patientName, required this.patientID}) : super(key: key);
  final String patientName, patientID;
  @override
  _PatientDetailsState createState() => _PatientDetailsState();
}

class _PatientDetailsState extends State<PatientDetailsPage> {
  String point = "";

  @override
  void initState(){
    super.initState();
    _InitConfig();
  }

  void _InitConfig() async{
    await GetPoint(context);
    setState(() {});
  }

  Future<void> GetPoint(BuildContext context) async {
    final String apiUrl = Config.baseUrl + '/getPoint';
    var url = Uri.parse(apiUrl);

    var response = await http.post(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{'patientID': widget.patientID}),
    );
    
    if (response.statusCode == 200) {
      setState(() => point = response.body);
    }
      else setState(() => point = "ERROR");
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
                      image: AssetImage("assets/images/avatar1.png"),
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
                      widget.patientName.isEmpty ?"加载中..." :widget.patientName,
                      style: TextStyle(fontSize: 25, color: Colors.grey),
                    ),
                  ),
                  Container(
                      height: 35,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text(
                            point.isEmpty ?"加载中..." :"积分:" + point,
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
          '病人信息',
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
                MineCell(
                  imageName: 'assets/images/account.png',
                  title: '基本信息',
                  patientID: widget.patientID,
                  patientName: widget.patientName,
                ),
                const SizedBox(
                  height: 10,
                ),
                MineCell(
                  imageName: 'assets/images/account.png',
                  title: '每日上报',
                  patientID: widget.patientID,
                ),
                MineCell(
                  imageName: 'assets/images/account.png',
                  title: '树洞',
                  patientID: widget.patientID,
                ),
                MineCell(
                  imageName: 'assets/images/account.png',
                  title: '动态',
                  patientID: widget.patientID,
                ),
                const SizedBox(
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