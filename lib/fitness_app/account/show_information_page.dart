import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import '../../config.dart';

class ShowInformationPage extends StatefulWidget {
  const ShowInformationPage({Key? key, required this.patientID, required this.patientName}) : super(key: key);
  final String patientID;
  final String patientName;

  @override
  State<ShowInformationPage> createState() => _ShowInformationPageState();
}

class _ShowInformationPageState extends State<ShowInformationPage> {
  final GlobalKey _formKey = GlobalKey<FormState>();
  late String individual_info;
  int gender = -1;
  String age = '', height = '', weight = '', Co_morbidities = '', IDNumber = '';
  String _smoke = '', _drink = '', _marry = '', _CA = '', _ill_type = '', _duration = '';
  String _treatment = '', _surgery = '', _metastasis = '', _education = '', _work = '';
  String _residency = '', _income = '', _insurance = '', _MVratio = '', _oil = '', _salt = '';

  @override
  void initState() {
    super.initState();
    _initConfig();
  }

  void _initConfig() async {
    await GetPatientInfo(context);
  }


  @override
  Widget build(BuildContext context) {
    return Form(
        key: _formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          children: [
            buildIndividualInforTitle(),
            const SizedBox(height: 10),
            buildNameField(),
            const SizedBox(height: 10),
            buildGenderField(),
            const SizedBox(height: 10),
            buildAgeField(),
            const SizedBox(height: 10),
            buildHeightField(),
            const SizedBox(height: 10),
            buildWeightField(),
            const SizedBox(height: 10),
            buildIDNumberField(),
            const SizedBox(height: 10),
            buildCoMorbiditiesField(),
            const SizedBox(height: 10),
            buildSmokeField(),
            const SizedBox(height: 10),
            buildDrinkField(),
            const SizedBox(height: 10),
            buildMarryField(),
            const SizedBox(height: 10),
            buildCAField(),
            const SizedBox(height: 10),
            buildTypeField(),
            const SizedBox(height: 10),
            buildDurationField(),
            const SizedBox(height: 10),
            buildTreatmentField(),
            const SizedBox(height: 10),
            buildSurgeryField(),
            const SizedBox(height: 10),
            buildMetastasisField(),
            const SizedBox(height: 10),
            buildEducationField(),
            const SizedBox(height: 10),
            buildWorkField(),
            const SizedBox(height: 10),
            buildResidencyField(),
            const SizedBox(height: 10),
            buildIncomeField(),
            const SizedBox(height: 10),
            buildInsuranceField(),
            const SizedBox(height: 10),
            buildDietInforTitle(),
            const SizedBox(height: 10),
            buildRatioField(),
            const SizedBox(height: 10),
            buildOilField(),
            const SizedBox(height: 10),
            buildSaltField(),
            const SizedBox(height: 60),
          ],
        ),
      );
  }

  Widget buildIndividualInforTitle() {
    return const Padding(
        padding: EdgeInsets.only(bottom: 5),
        child: Text(
          '个人信息',
          style: TextStyle(fontSize: 20),
        ));
  }

  Widget buildNameField() {
    return Padding(
        padding: EdgeInsets.only(left: 5),
        child: Text(
          '姓名: ${widget.patientName}',
          style: TextStyle(fontSize: 20),
        ));
  }

  Widget buildGenderField() {
    return Row(children: [
      const SizedBox(width: 8),
      Text(
        (gender == -1)?'性别: 加载中...':(gender == 1)?'性别: 男':'按时用药: 女',
        style: TextStyle(fontSize: 18),
      )
    ]);
  }

  Widget buildAgeField() {
    return Padding(
        padding: EdgeInsets.only(left: 5),
        child: Text(
          (age.isEmpty)?'年龄: 加载中...':'年龄: $age',
          style: TextStyle(fontSize: 20),
        ));
  }

  Widget buildHeightField() {
    return Padding(
        padding: EdgeInsets.only(left: 5),
        child: Text(
          (height.isEmpty)?'身高: 加载中...':'身高: $height',
          style: TextStyle(fontSize: 20),
        ));
  }

  Widget buildWeightField() {
    return Padding(
        padding: EdgeInsets.only(left: 5),
        child: Text(
          (weight.isEmpty)?'体重: 加载中...':'体重: $weight',
          style: TextStyle(fontSize: 20),
        ));
  }

  Widget buildIDNumberField() {
    return Padding(
        padding: EdgeInsets.only(left: 5),
        child: Text(
          (Co_morbidities.isEmpty)?'身份证号: 加载中...':'身份证号: $IDNumber',
          style: TextStyle(fontSize: 20),
        ));
  }

  Widget buildCoMorbiditiesField() {
    return Padding(
        padding: EdgeInsets.only(left: 5),
        child: Text(
          (Co_morbidities.isEmpty)?'共病情况: 加载中...':'共病情况: $Co_morbidities',
          style: TextStyle(fontSize: 20),
        ));
  }

  Widget buildSmokeField() {
    return Padding(
        padding: EdgeInsets.only(left: 5),
        child: Text(
          (_smoke.isEmpty)?'吸烟史: 加载中...':'吸烟史: $_smoke',
          style: TextStyle(fontSize: 20),
        ));
  }

  Widget buildDrinkField() {
    return Padding(
        padding: EdgeInsets.only(left: 5),
        child: Text(
          (_drink.isEmpty)?'饮酒史: 加载中...':'饮酒史: $_drink',
          style: TextStyle(fontSize: 20),
        ));
  }

  Widget buildMarryField() {
    return Padding(
        padding: EdgeInsets.only(left: 5),
        child: Text(
          (_marry.isEmpty)?'婚姻状况: 加载中...':'婚姻状况: $_marry',
          style: TextStyle(fontSize: 20),
        ));
  }

  Widget buildCAField() {
    return Padding(
        padding: EdgeInsets.only(left: 5),
        child: Text(
          (_CA.isEmpty)?'CA类型: 加载中...':'CA类型: $_CA',
          style: TextStyle(fontSize: 20),
        ));
  }

  Widget buildTypeField() {
    return Padding(
        padding: EdgeInsets.only(left: 5),
        child: Text(
          (_ill_type.isEmpty)?'类型: 加载中...':'类型: $_ill_type',
          style: TextStyle(fontSize: 20),
        ));
  }

  Widget buildDurationField() {
    return Padding(
        padding: EdgeInsets.only(left: 5),
        child: Text(
          (_duration.isEmpty)?'病程: 加载中...':'病程: $_duration',
          style: TextStyle(fontSize: 20),
        ));
  }

  Widget buildTreatmentField() {
    return Padding(
        padding: EdgeInsets.only(left: 5),
        child: Text(
          (_treatment.isEmpty)?'治疗方式: 加载中...':'治疗方式: $_treatment',
          style: TextStyle(fontSize: 20),
        ));
  }

  Widget buildSurgeryField() {
    return Padding(
        padding: EdgeInsets.only(left: 5),
        child: Text(
          (_surgery.isEmpty)?'手术类型: 加载中...':'手术类型: $_surgery',
          style: TextStyle(fontSize: 20),
        ));
  }

  Widget buildMetastasisField() {
    return Padding(
        padding: EdgeInsets.only(left: 5),
        child: Text(
          (_metastasis.isEmpty)?'转移情况: 加载中...':'转移情况: $_metastasis',
          style: TextStyle(fontSize: 20),
        ));
  }

  Widget buildEducationField() {
    return Padding(
        padding: EdgeInsets.only(left: 5),
        child: Text(
          (_education.isEmpty)?'文化程度: 加载中...':'文化程度: $_education',
          style: TextStyle(fontSize: 20),
        ));
  }

  Widget buildWorkField() {
    return Padding(
        padding: EdgeInsets.only(left: 5),
        child: Text(
          (_work.isEmpty)?'工作状态: 加载中...':'工作状态: $_work',
          style: TextStyle(fontSize: 20),
        ));
  }

  Widget buildResidencyField() {
    return Padding(
        padding: EdgeInsets.only(left: 5),
        child: Text(
          (_residency.isEmpty)?'居住方式: 加载中...':'居住方式: $_residency',
          style: TextStyle(fontSize: 20),
        ));
  }

  Widget buildIncomeField() {
    return Padding(
        padding: EdgeInsets.only(left: 5),
        child: Text(
          (_income.isEmpty)?'收入情况: 加载中...':'收入情况: $_income',
          style: TextStyle(fontSize: 20),
        ));
  }

  Widget buildInsuranceField() {
    return Padding(
        padding: EdgeInsets.only(left: 5),
        child: Text(
          (_insurance.isEmpty)?'医保方式: 加载中...':'医保方式: $_insurance',
          style: TextStyle(fontSize: 20),
        ));
  }

  Widget buildDietInforTitle() {
    return const Padding(
        padding: EdgeInsets.only(bottom: 5),
        child: Text(
          '饮食情况',
          style: TextStyle(fontSize: 20),
        ));
  }

  Widget buildRatioField() {
    return Padding(
        padding: EdgeInsets.only(left: 5),
        child: Text(
          (_MVratio.isEmpty)?'肉菜比例: 加载中...':'肉菜比例: $_MVratio',
          style: TextStyle(fontSize: 20),
        ));
  }

  Widget buildOilField() {
    return Padding(
        padding: EdgeInsets.only(left: 5),
        child: Text(
          (_oil.isEmpty)?'放油程度: 加载中...':'放油程度: $_oil',
          style: TextStyle(fontSize: 20),
        ));
  }

  Widget buildSaltField() {
    return Padding(
        padding: EdgeInsets.only(left: 5),
        child: Text(
          (_salt.isEmpty)?'放盐程度: 加载中...':'放盐程度: $_salt',
          style: TextStyle(fontSize: 20),
        ));
  }

  Future<void> GetPatientInfo(BuildContext context) async {
    final String apiUrl = Config.baseUrl + '/patient/get_info';
    var url = Uri.parse(apiUrl);

    var response = await http.post(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{'patientID': widget.patientID}),
    );
    
    if (response.statusCode == 200) {
      if (response.body != '0')
      {
        individual_info = response.body;
        List<String> temp_individual_info = individual_info.split('+-*/');
        age = temp_individual_info[0];
        gender = int.parse(temp_individual_info[1]);
        height = temp_individual_info[2];
        weight = temp_individual_info[3];
        IDNumber = temp_individual_info[4];
        Co_morbidities = temp_individual_info[5];
        _smoke = temp_individual_info[6];
        _drink = temp_individual_info[7];
        _marry = temp_individual_info[8];
        _CA = temp_individual_info[9];
        _ill_type = temp_individual_info[10]; 
        _duration = temp_individual_info[11];
        _treatment = temp_individual_info[12];
        _surgery = temp_individual_info[13];
        _metastasis = temp_individual_info[14];
        _education = temp_individual_info[15];
        _work = temp_individual_info[16];
        _residency = temp_individual_info[17];
        _income = temp_individual_info[18];
        _insurance = temp_individual_info[19];
        _MVratio = temp_individual_info[20];
        _oil = temp_individual_info[21];
        _salt = temp_individual_info[22];
        setState((() => {}));
      }
        else setState(() => individual_info = "ERROR");
    }
      else print('Request failed with status: ${response.statusCode}.');;
  }

  void _showDialog(BuildContext context, String message,
      {VoidCallback? onDialogClose}) {
    showCupertinoDialog(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: Text("Message"),
          content: Text(message),
          actions: <Widget>[
            CupertinoDialogAction(
              child: Text("Close"),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                if (onDialogClose != null) {
                  onDialogClose(); // Call the callback if it's provided
                }
              },
            ),
          ],
        );
      },
    );
  }
}