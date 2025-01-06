import 'package:best_flutter_ui_templates/fitness_app/fitness_app_theme.dart';
import 'package:flutter/material.dart';
import '../utils/Spsave_module.dart';
import '../../config.dart';
import 'package:http/http.dart' as http;

import 'dart:async';
import 'dart:convert';
import 'package:flutter/cupertino.dart';

class BodyMeasurementView extends StatefulWidget {
  final AnimationController? animationController;
  final Animation<double>? animation;

  const BodyMeasurementView({Key? key, this.animationController, this.animation})
      : super(key: key);

  @override
  _BodyMeasurementViewState createState() => _BodyMeasurementViewState();
}

class _BodyMeasurementViewState extends State<BodyMeasurementView> {
  double user_height = 0.0;
  double user_weight = 0.0;
  double user_BMI = 0.0;
  double user_BMR = 0.0;
  String user_sex = '';
  int user_age = 0;

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    // Fetch patientID from storage
    Map<String, dynamic>? account = await SpStorage.instance.readAccount();
    late String patientID;
    if (account != null) {
      patientID = account['patientID'];
    }

    final String apiUrl = Config.baseUrl + '/patient/get_info_json';
    var url = Uri.parse(apiUrl);

    var response = await http.post(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'patientID': patientID,
      }),
    );

    if (response.statusCode == 200) {
      Map<String, dynamic> data = jsonDecode(response.body);

      setState(() {
        if (data['height'] != null) {
          user_height = double.parse(data['height'].toString());
        }
        if (data['weight'] != null) {
          user_weight = double.parse(data['weight'].toString());
        }
        if (data['gender'] != null) {
          user_sex = data['gender'] == 1 ? "male" : "female";
        }
        if (data['age'] != null) {
          user_age = int.parse(data['age'].toString());
        }

        // 计算 BMI
        if (user_height > 0 && user_weight > 0) {
          user_BMI = user_weight * 10000 / (user_height * user_height);
          user_BMI = double.parse(user_BMI.toStringAsFixed(1));
        }

        // 计算 BMR
        if (user_weight > 0 &&
            user_height > 0 &&
            user_age > 0 &&
            (user_sex == 'male' || user_sex == 'female')) {
          user_BMR = calcBMR(user_sex, user_weight, user_height, user_age);
        }
      });
    } else {
      print('Failed to fetch patient info: ${response.statusCode}');
    }
  }

  double calcBMR(String sex, double weight, double height, int age) {
    double bmr = 0.0;
    if (sex.toLowerCase() == 'male') {
      // 男性 BMR
      bmr = 66 + (13.7 * weight) + (5 * height) - (6.8 * age);
    } else {
      // 女性 BMR
      bmr = 655 + (9.6 * weight) + (1.8 * height) - (4.7 * age);
    }
    return double.parse(bmr.toStringAsFixed(0)); // 保留整数或根据需要调整
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.animationController!,
      builder: (BuildContext context, Widget? child) {
        return FadeTransition(
          opacity: widget.animation!,
          child: Transform(
            transform: Matrix4.translationValues(
                0.0, 30 * (1.0 - widget.animation!.value), 0.0),
            child: Padding(
              padding: const EdgeInsets.only(
                  left: 24, right: 24, top: 16, bottom: 18),
              child: Container(
                decoration: BoxDecoration(
                  color: FitnessAppTheme.white,
                  borderRadius: BorderRadius.all(Radius.circular(8.0)),
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                        color: FitnessAppTheme.grey.withOpacity(0.2),
                        offset: Offset(1.1, 1.1),
                        blurRadius: 10.0),
                  ],
                ),
                child: Column(
                  children: <Widget>[
                    Padding(
                      padding:
                          const EdgeInsets.only(top: 16, left: 16, right: 24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          // 体重与BMR标题
                          Padding(
                            padding: const EdgeInsets.only(
                                left: 4, bottom: 8, top: 16),
                            child: Text(
                              '体重                                      BMR',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontFamily: FitnessAppTheme.fontName,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 16,
                                  letterSpacing: -0.1,
                                  color: FitnessAppTheme.darkText),
                            ),
                          ),
                          // 体重和BMR 显示行
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              // 体重信息
                              MeasurementItem(
                                label: '体重',
                                value: user_weight > 0
                                    ? user_weight.toString()
                                    : '0.0',
                                unit: '千克',
                              ),
                              // BMR 信息
                              MeasurementItem(
                                label: 'BMR',
                                value: user_BMR > 0
                                    ? user_BMR.toString()
                                    : '0.0',
                                unit: '卡路里',
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 8),
                      child: Container(
                        height: 2,
                        decoration: BoxDecoration(
                          color: FitnessAppTheme.background,
                          borderRadius:
                              BorderRadius.all(Radius.circular(4.0)),
                        ),
                      ),
                    ),
                    // 身高和 BMI 信息
                    Padding(
                      padding: const EdgeInsets.only(
                          left: 24, right: 24, top: 8, bottom: 16),
                      child: Row(
                        children: <Widget>[
                          // 显示身高
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  user_height > 0
                                      ? '${user_height.toString()} 厘米'
                                      : '0.0 厘米',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontFamily: FitnessAppTheme.fontName,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 16,
                                    letterSpacing: -0.2,
                                    color: FitnessAppTheme.darkText,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(top: 6),
                                  child: Text(
                                    '身高',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontFamily: FitnessAppTheme.fontName,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 12,
                                      color: FitnessAppTheme.grey
                                          .withOpacity(0.5),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // 显示 BMI
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                Text(
                                  user_BMI > 0
                                      ? '${user_BMI.toString()} BMI'
                                      : '0.0 BMI',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontFamily: FitnessAppTheme.fontName,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 16,
                                    letterSpacing: -0.2,
                                    color: FitnessAppTheme.darkText,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(top: 6),
                                  child: Text(
                                    user_BMI > 0 ? getBMIStatus(user_BMI) : '',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontFamily: FitnessAppTheme.fontName,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 12,
                                      color: FitnessAppTheme.grey
                                          .withOpacity(0.5),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  String getBMIStatus(double bmi) {
    if (bmi < 18.5) {
      return '偏瘦';
    } else if (bmi >= 18.5 && bmi < 24) {
      return '正常';
    } else if (bmi >= 24 && bmi < 28) {
      return '超重';
    } else {
      return '肥胖';
    }
  }
}

// 通用的 MeasurementItem 小部件
class MeasurementItem extends StatelessWidget {
  final String label;
  final String value;
  final String unit;

  const MeasurementItem({
    Key? key,
    required this.label,
    required this.value,
    required this.unit,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 数值和单位
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              value,
              style: TextStyle(
                fontFamily: FitnessAppTheme.fontName,
                fontWeight: FontWeight.w600,
                fontSize: 32,
                color: FitnessAppTheme.nearlyDarkBlue,
              ),
            ),
            SizedBox(width: 8),
            Text(
              unit,
              style: TextStyle(
                fontFamily: FitnessAppTheme.fontName,
                fontWeight: FontWeight.w500,
                fontSize: 18,
                letterSpacing: -0.2,
                color: FitnessAppTheme.nearlyDarkBlue,
              ),
            ),
          ],
        ),
        //SizedBox(height: 4),
        // 标签
      //  Text(
      //    label,
      //    style: TextStyle(
      //      fontFamily: FitnessAppTheme.fontName,
      //      fontWeight: FontWeight.w600,
      //      fontSize: 12,
      //      color: FitnessAppTheme.grey.withOpacity(0.5),
      //    ),
      //  ),
      ],
    );
  }
}
