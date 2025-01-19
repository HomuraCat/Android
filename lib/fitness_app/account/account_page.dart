import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/Spsave_module.dart'; // For account storage
import 'cell.dart'; // For MineCell widget
import '../../config.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({Key? key}) : super(key: key);

  @override
  _AccountPageState createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  late String patientID = "";
  late String name = "";
  late int points = 0; // To hold user points

  @override
  void initState() {
    super.initState();
    _InitConfig();
  }

  void _InitConfig() async {
    // Fetch account details and initialize patientID and name
    Map<String, dynamic> account = await SpStorage.instance.readAccount();
    patientID = account['patientID'];
    name = account['name'];
    setState(() {});
    _fetchPoints(); // Fetch the points after initializing account details
  }

  Future<void> _fetchPoints() async {
    final String apiUrl =
        Config.baseUrl + '/getPoint'; // Replace with actual API endpoint
    var url = Uri.parse(apiUrl);

    try {
      var response = await http.post(
        url,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body:
            jsonEncode({'patientID': patientID}), // Pass patientID in the body
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // print("--------------------------------------");
        setState(() {
          points = data; // Assign points from the response
        });
      } else {
        print('Failed to fetch points. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching points: $e');
    }
  }

  Widget headerWidget() {
    return Container(
      height: 110,
      color: Colors.white,
      child: Container(
        margin: const EdgeInsets.only(top: 0, bottom: 20, left: 10, right: 10),
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
                    name.isEmpty ? "加载中..." : name,
                    style: const TextStyle(fontSize: 25, color: Colors.grey),
                  ),
                ),
                Container(
                  height: 35,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text(
                        patientID.isEmpty ? "加载中..." : "ID: $patientID",
                        style:
                            const TextStyle(fontSize: 17, color: Colors.grey),
                      ),
                      const Image(
                        image: AssetImage("assets/images/icon_right.png"),
                        width: 15,
                      )
                    ],
                  ),
                ),
              ],
            ),
          )
        ]),
      ),
    );
  }

  Widget pointsWidget() {
    // Points display widget
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Image.asset(
                'assets/images/southeast.jpeg',
                width: 30,
                height: 30,
                fit: BoxFit.cover,
              ),
              const SizedBox(width: 10),
              const Text(
                '积分',
                style: TextStyle(fontSize: 17, color: Colors.black),
              ),
            ],
          ),
          Text(
            points.toString(), // Display user's points
            style: const TextStyle(fontSize: 17, color: Colors.grey),
          ),
        ],
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
              Column(
                children: [
                  const SizedBox(height: 10),
                  const MineCell(
                    imageName: 'assets/images/southeast.jpeg',
                    title: '基本信息',
                  ),
                  const SizedBox(height: 10),
                  const MineCell(
                    imageName: 'assets/images/southeast.jpeg',
                    title: '每日上报',
                  ),
                  const MineCell(
                    imageName: 'assets/images/southeast.jpeg',
                    title: '评估日记',
                  ),
                  const MineCell(
                    imageName: 'assets/images/southeast.jpeg',
                    title: '喜欢',
                  ),
                  pointsWidget(), // Points display section
                  const SizedBox(height: 10),
                  const MineCell(
                    imageName: 'assets/images/southeast.jpeg',
                    title: '设置',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
