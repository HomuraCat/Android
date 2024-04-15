import 'package:flutter/material.dart';
import '../utils/common_tools.dart';
import 'daily_report_page.dart';
import 'basic_information_page.dart';

class MineCell extends StatelessWidget {
  final String? title;
  final String? subTitle;
  final String? imageName;
  final String? subImageName;

  const MineCell(
      {this.title, this.subTitle, this.imageName, this.subImageName});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        switch (this.title) {
          case "每日上报":
            Navigator.of(context).push(MaterialPageRoute(
                builder: (BuildContext context) => DailyReportPage()));
            break;
          case "基本信息":
            Navigator.of(context).push(MaterialPageRoute(
                builder: (BuildContext context) => BasicInforPage()));
            break;
          default:
            Navigator.of(context).push(MaterialPageRoute(
                builder: (BuildContext context) => ChildPage(title: '$title')));
        }
      },
      child: Container(
        color: Colors.white,
        height: 54,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Container(
              padding: const EdgeInsets.all(10),
              child: Row(
                children: <Widget>[
                  Image(
                    image: AssetImage(imageName!),
                    width: 20,
                  ),
                  SizedBox(
                    width: 15,
                  ),
                  Text(title!),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.all(10),
              child: Row(
                children: <Widget>[
                  subTitle != null ? Text(subTitle!) : const Text(''),
                  subImageName != null
                      ? Image(
                          image: AssetImage(subImageName!),
                          width: 12,
                        )
                      : Container(),
                  const Image(
                    image: AssetImage('assets/images/icon_right.png'),
                    width: 14,
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}