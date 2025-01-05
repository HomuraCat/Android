import 'package:flutter/material.dart';
import 'cell.dart';

class PatientDetailsPage extends StatefulWidget {
  const PatientDetailsPage({Key? key, required this.patientName, required this.patientID}) : super(key: key);
  final String patientName, patientID;
  @override
  _PatientDetailsState createState() => _PatientDetailsState();
}

class _PatientDetailsState extends State<PatientDetailsPage> {

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
                            widget.patientID.isEmpty ?"加载中..." :"ID:" + widget.patientID,
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