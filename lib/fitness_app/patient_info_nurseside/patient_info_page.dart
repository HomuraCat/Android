import 'package:flutter/material.dart';
import 'patient_details_page.dart';
import 'package:http/http.dart' as http;

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
                child: Image.asset('assets/images/southeast.jpeg', width: 20, height: 20),
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
      itemBuilder: (BuildContext context, int index) {
        if (index == 0) {
          return _contactHeader();
        } else {
          return _contactBody(context, contactGroupList[index - 1]);
        }
      },
      itemCount: contactGroupList.length + 1,
    );
  }

  Future<void> GetPatientInfo(BuildContext context) async {
    var url = Uri.parse('http://10.0.2.2:5001//patient/get_list');

    var response = await http.get(url);
    
    if (response.statusCode == 200) {
      if (response.body != '0') 
      {
        String res = "";
        List<String> temp_res = response.body.split('"')[1].split("/*-+");
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