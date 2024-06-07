import 'package:flutter/material.dart';
import 'show_daily_report_page.dart';

class ContactGroup {
  bool expand = false;
  String groupName;
  List<ContactFriend> friendList = <ContactFriend>[];

  ContactGroup(this.groupName);
}

class ContactFriend {
  String patientName;
  String patientID;

  ContactFriend(this.patientName, this.patientID);
}

class ReportStatisticPage extends StatefulWidget {
  const ReportStatisticPage({Key? key}) : super(key: key);
  @override
  _ReportStatisticPageState createState() => _ReportStatisticPageState();
}

class _ReportStatisticPageState extends State<ReportStatisticPage> {
  ScrollController _scrollController = ScrollController();
  List<ContactGroup> contactGroupList = <ContactGroup>[];
  Map<String, int> contactGroupMap = {};

  @override
  void initState() {
    super.initState();
    String patientInfo = "张三_114514_未分组 李四_666666_未分组";
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
                builder: (BuildContext context) => ShowDailyReportPage(patientID: contactFriend.patientID)));
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
}