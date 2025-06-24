import 'package:flutter/material.dart';
import 'patient_details_page.dart';
import 'package:http/http.dart' as http;
import '../../config.dart';

class ContactGroup {
  bool expand = false;
  String groupName;
  List<ContactFriend> friendList = <ContactFriend>[];

  ContactGroup(this.groupName);
}

class ContactFriend {
  String patientID;
  String patientName;

  ContactFriend(this.patientID, this.patientName);
}

class PatientInfoPage extends StatefulWidget {
  const PatientInfoPage({Key? key}) : super(key: key);
  @override
  _PatientInfoPageState createState() => _PatientInfoPageState();
}

class _PatientInfoPageState extends State<PatientInfoPage> {
  ScrollController _scrollController = ScrollController();
  List<ContactGroup> contactGroupList = <ContactGroup>[];
  Map<String, int> contactGroupMap = {};
  late String patientInfo = "";

  @override
  void initState() {
    super.initState();
    _initConfig();
  }

  void _initConfig() async {
    await GetPatientInfo(context);
    if (patientInfo != "ERROR")
    {
      List<String> each_patient = patientInfo.split(' ');
      each_patient.forEach((single_patient) {
        List<String> single_patient_info = single_patient.split('_');
        String temp_group_name = single_patient_info[2];
        ContactGroup temp_Group;
        ContactFriend temp_patient = ContactFriend(single_patient_info[0], single_patient_info[1]);
        if (!contactGroupMap.containsKey(temp_group_name)){
          temp_Group = ContactGroup(temp_group_name);
          contactGroupList.add(temp_Group);
          final new_key = <String, int>{temp_group_name: contactGroupList.length - 1};
          contactGroupMap.addEntries(new_key.entries);
        }
          else temp_Group = contactGroupList[contactGroupMap[temp_group_name]!];
        temp_Group.friendList.add(temp_patient);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    _contactHeader() {
      return Column(
        children: [
          const SizedBox(height: 10),
          const Text(
            '病人列表',
            style: TextStyle(fontSize: 18, color: Colors.black),
          ),
          const SizedBox(height: 10),
        ],
      );
    }

    _friendHeader(ContactGroup contactGroup) {
      return GestureDetector(
        onTap: () {
          setState(() {
            contactGroup.expand = !contactGroup.expand;
          });
        },
        child: Container(
          padding: EdgeInsets.only(left: 10),
          height: 60,
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(bottom: BorderSide(color: Colors.grey, width: 0.5)),
          ),
          child: Row(
            children: [
              Image.asset(contactGroup.expand ? 'assets/images/展开.png' : 'assets/images/收起.png', width: 20, height: 20),
              Text('${contactGroup.groupName}(${contactGroup.friendList.length})'),
            ],
          ),
        ),
      );
    }

    _friendBody(ContactFriend contactFriend) {
      return GestureDetector(
        onTap: () {
          Navigator.of(context).push(MaterialPageRoute(
                builder: (BuildContext context) => PatientDetailsPage(patientName: contactFriend.patientName, patientID: contactFriend.patientID)));
        },
        child: Container(
          padding: EdgeInsets.only(left: 16),
          height: 60,
          color: Colors.white,
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.asset('assets/images/avatar1.jpg', width: 20, height: 20),
              ),
              SizedBox(width: 10),
              Text('${contactFriend.patientName}')
            ],
          ),
        )
      );
    }

    _contactBody(BuildContext context, ContactGroup contactGroup) {
      return ListView.builder(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        itemBuilder: (BuildContext context, int index) {
          if (index == 0) {
            return _friendHeader(contactGroup);
          } else {
            return _friendBody(contactGroup.friendList[index - 1]);
          }
        },
        itemCount: contactGroup.expand ? contactGroup.friendList.length + 1 : 1,
      );
    }

return ListView.builder(
  controller: _scrollController,
  shrinkWrap: true,
  // 1. itemCount 在原有基础上再加 1，为 SizedBox 腾出位置
  itemCount: contactGroupList.length + 2,
  itemBuilder: (BuildContext context, int index) {
    // 顶部的 Header (index 为 0)，逻辑不变
    if (index == 0) {
      return _contactHeader();
    } 
    // 2. 新增逻辑：判断是否为最后一项
    // 最后一项的 index 是 itemCount - 1，即 (contactGroupList.length + 2) - 1
    else if (index == contactGroupList.length + 1) {
      return SizedBox(height: 80); // 在最底部返回一个 SizedBox
    } 
    // 中间的联系人列表，逻辑不变
    else {
      // 这里的 index - 1 依然是正确的，因为它将 ListView 中从 1 开始的索引
      // 映射到 contactGroupList 中从 0 开始的索引
      return _contactBody(context, contactGroupList[index - 1]);
    }
  },
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