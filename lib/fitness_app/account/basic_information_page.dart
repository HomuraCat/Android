import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import '../utils/Spsave_module.dart';
import '../../config.dart';

class BasicInforPage extends StatefulWidget {
  const BasicInforPage({Key? key}) : super(key: key);

  @override
  State<BasicInforPage> createState() => _BasicInforPageState();
}

class _BasicInforPageState extends State<BasicInforPage>{
  final GlobalKey _formKey = GlobalKey<FormState>();
  late String patientID, name, age, user_name, height, weight, Co_morbidities;
  bool submitstate = false;
  int gender = 1, smoke = 1, drink = 1, marry = 1, CA = 1, ill_type = 1, duration = 1, treatment = 1, surgery = 1;
  int metastasis = 1, education = 1, work = 1, residency = 1, income = 1, insurance = 1, MVratio = 1, oil = 1, salt = 1;
  String _smoke = '有', _drink = '有', _marry = '已婚', _CA = '非小细胞CA', _ill_type = '首次确诊', _duration = '≤3个月';
  String _treatment = '化疗', _surgery = '无', _metastasis = '未转移', _education = '小学及以下', _work = '管理';
  String _residency = '独居', _income = '<3000元', _insurance = '自费', _MVratio = '素食为主', _oil = '偏多', _salt = '偏咸';
  final List<TextEditingController> controllers = List.generate(5, (index) => TextEditingController());

  void initState() {
    super.initState();
    _initConfig();
  }

  void _initConfig() async {
    Map<String, dynamic> account = await SpStorage.instance.readAccount();
    patientID = account['patientID'];
    user_name = account['name'];
    if (user_name != "未命名") setState(() => submitstate = true);
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text('基本信息'),
      ),
      body: Form(
        key: _formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          children: [
            buildIndividualInforTitle(),
            const SizedBox(height: 10),
            buildNameField(0),
            const SizedBox(height: 10),
            buildGenderField(),
            const SizedBox(height: 10),
            buildAgeField(1),
            const SizedBox(height: 10),
            buildHeightField(2),
            const SizedBox(height: 10),
            buildWeightField(3),
            const SizedBox(height: 10),
            buildCoMorbiditiesField(4),
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
            buildSubmitButton(context),
            if (submitstate) buildSubmitText(),
            const SizedBox(height: 60),
          ],
        ),
      ),
    );
  }

  Widget buildNameField(int index) {
    return TextFormField(
      controller: controllers[index],
      enabled: !submitstate,
      decoration: const InputDecoration(
          contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 10),
          border: OutlineInputBorder(),
          labelText: '姓名'),
      validator: (v) {
        if (v!.isEmpty) {
          return '请输入姓名';
        }
      },
      onSaved: (v) => age = v!,
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

  Widget buildGenderField() {
    return Row(children: [
      const SizedBox(width: 8),
      Text(
        '性别',
        style: TextStyle(fontSize: 18),
      ),
      const SizedBox(width: 40),
      Radio(
          value: 1,
          groupValue: gender,
          onChanged: (value) {
            setState(() {
              gender = value as int;
            });
          }),
      Text(
        '男',
        style: TextStyle(fontSize: 18),
      ),
      Radio(
          value: 2,
          groupValue: gender,
          onChanged: submitstate ? null : (value){
            setState(() {
              gender = value as int;
            });
          }),
      Text(
        '女',
        style: TextStyle(fontSize: 18),
      )
    ]);
  }

  Widget buildAgeField(int index) {
    return TextFormField(
      controller: controllers[index],
      enabled: !submitstate,
      decoration: const InputDecoration(
          contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 10),
          border: OutlineInputBorder(),
          labelText: '年龄'),
      validator: (v) {
        var ageReg = RegExp(r"^[0-9]+");
        if (!ageReg.hasMatch(v!)) {
          return '请正确输入年龄';
        }
      },
      onSaved: (v) => age = v!,
    );
  }

  Widget buildHeightField(int index) {
    return TextFormField(
      controller: controllers[index],
      enabled: !submitstate,
      decoration: const InputDecoration(
          contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 10),
          border: OutlineInputBorder(),
          labelText: '身高'),
      validator: (v) {
        var ageReg = RegExp(r"^[0-9]+");
        if (!ageReg.hasMatch(v!)) {
          return '请正确输入身高';
        }
      },
      onSaved: (v) => height = v!,
    );
  }

  Widget buildWeightField(int index) {
    return TextFormField(
      controller: controllers[index],
      enabled: !submitstate,
      decoration: const InputDecoration(
          contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 10),
          border: OutlineInputBorder(),
          labelText: '体重'),
      validator: (v) {
        var ageReg = RegExp(r"^[0-9]+");
        if (!ageReg.hasMatch(v!)) {
          return '请正确输入体重';
        }
      },
      onSaved: (v) => weight = v!,
    );
  }

  Widget buildCoMorbiditiesField(int index) {
    return TextFormField(
      controller: controllers[index],
      enabled: !submitstate,
      decoration: const InputDecoration(
          contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 10),
          border: OutlineInputBorder(),
          labelText: '共病情况'),
      validator: (v) {
        if (v!.isEmpty) {
          return '请输入共病情况';
        }
      },
      onSaved: (v) => Co_morbidities = v!,
    );
  }

  Widget buildSmokeField() {
    return Row(children: [
      const SizedBox(width: 8),
      Text(
        '吸烟史',
        style: TextStyle(fontSize: 18),
      ),
      const SizedBox(width: 40),
      Radio(
          value: 1,
          groupValue: smoke,
          onChanged: (value) {
            setState(() {
              smoke = value as int;
              _smoke = '有';
            });
          }),
      Text(
        '有',
        style: TextStyle(fontSize: 18),
      ),
      Radio(
          value: 2,
          groupValue: smoke,
          onChanged: submitstate ? null : (value){
            setState(() {
              smoke = value as int;
              _smoke = '无';
            });
          }),
      Text(
        '无',
        style: TextStyle(fontSize: 18),
      ),
      Radio(
          value: 3,
          groupValue: smoke,
          onChanged: submitstate ? null : (value){
            setState(() {
              smoke = value as int;
              _smoke = '已戒';
            });
          }),
      Text(
        '已戒',
        style: TextStyle(fontSize: 18),
      )
    ]);
  }

  Widget buildDrinkField() {
    return Row(children: [
      const SizedBox(width: 8),
      Text(
        '饮酒史',
        style: TextStyle(fontSize: 18),
      ),
      const SizedBox(width: 40),
      Radio(
          value: 1,
          groupValue: drink,
          onChanged: (value) {
            setState(() {
              drink = value as int;
              _drink = '有';
            });
          }),
      Text(
        '有',
        style: TextStyle(fontSize: 18),
      ),
      Radio(
          value: 2,
          groupValue: drink,
          onChanged: submitstate ? null : (value){
            setState(() {
              drink = value as int;
              _drink = '无';
            });
          }),
      Text(
        '无',
        style: TextStyle(fontSize: 18),
      ),
      Radio(
          value: 3,
          groupValue: drink,
          onChanged: submitstate ? null : (value){
            setState(() {
              drink = value as int;
              _drink = '已戒';
            });
          }),
      Text(
        '已戒',
        style: TextStyle(fontSize: 18),
      )
    ]);
  }

  Widget buildMarryField() {
    return Column(children:[
      Row(children: [
        const SizedBox(width: 8),
        Text(
          '婚姻状况',
          style: TextStyle(fontSize: 18),
        ),
        const SizedBox(width: 20),
        Radio(
            value: 1,
            groupValue: marry,
            onChanged: (value) {
              setState(() {
                marry = value as int;
                _marry = '已婚';
              });
            }),
        Text(
          '已婚',
          style: TextStyle(fontSize: 18),
        ),
      ]),
      Row(children: [
        const SizedBox(width: 100),
        Radio(
            value: 2,
            groupValue: marry,
            onChanged: submitstate ? null : (value){
              setState(() {
                marry = value as int;
                _marry = '未婚';
              });
            }),
        Text(
          '未婚',
          style: TextStyle(fontSize: 18),
        ),
      ]),
      Row(children: [
        const SizedBox(width: 100),
        Radio(
            value: 3,
            groupValue: marry,
            onChanged: submitstate ? null : (value){
              setState(() {
                marry = value as int;
                _marry = '离异或丧偶';
              });
            }),
        Text(
          '离异或丧偶',
          style: TextStyle(fontSize: 18),
        ),
      ])
    ]);
  }

  Widget buildCAField() {
    return Column(children:[
      Row(children: [
        const SizedBox(width: 8),
        Text(
          'CA类型',
          style: TextStyle(fontSize: 18),
        ),
        const SizedBox(width: 20),
        Radio(
            value: 1,
            groupValue: CA,
            onChanged: (value) {
              setState(() {
                CA = value as int;
                _CA = '非小细胞CA';
              });
            }),
        Text(
          '非小细胞CA',
          style: TextStyle(fontSize: 18),
        ),
      ]),
      Row(children: [
        const SizedBox(width: 90),
        Radio(
            value: 2,
            groupValue: CA,
            onChanged: submitstate ? null : (value){
              setState(() {
                CA = value as int;
                _CA = '小细胞CA';
              });
            }),
        Text(
          '小细胞CA',
          style: TextStyle(fontSize: 18),
        ),
      ]),
      Row(children: [
        const SizedBox(width: 90),
        Radio(
            value: 3,
            groupValue: CA,
            onChanged: submitstate ? null : (value){
              setState(() {
                CA = value as int;
                _CA = '其他';
              });
            }),
        Text(
          '其他',
          style: TextStyle(fontSize: 18),
        ),
      ])
    ]);
  }

  Widget buildTypeField() {
    return Column(children:[
      Row(children: [
        const SizedBox(width: 8),
        Text(
          '类型',
          style: TextStyle(fontSize: 18),
        ),
        const SizedBox(width: 20),
        Radio(
            value: 1,
            groupValue: ill_type,
            onChanged: (value) {
              setState(() {
                ill_type = value as int;
                _ill_type = '首次确诊';
              });
            }),
        Text(
          '首次确诊',
          style: TextStyle(fontSize: 18),
        ),
      ]),
      Row(children: [
        const SizedBox(width: 65),
        Radio(
            value: 2,
            groupValue: ill_type,
            onChanged: submitstate ? null : (value){
              setState(() {
                ill_type = value as int;
                _ill_type = '复发';
              });
            }),
        Text(
          '复发',
          style: TextStyle(fontSize: 18),
        ),
      ]),
      Row(children: [
        const SizedBox(width: 65),
        Radio(
            value: 3,
            groupValue: ill_type,
            onChanged: submitstate ? null : (value){
              setState(() {
                ill_type = value as int;
                _ill_type = '转移';
              });
            }),
        Text(
          '转移',
          style: TextStyle(fontSize: 18),
        ),
      ]),
      Row(children: [
        const SizedBox(width: 65),
        Radio(
            value: 4,
            groupValue: ill_type,
            onChanged: submitstate ? null : (value){
              setState(() {
                ill_type = value as int;
                _ill_type = '分期';
              });
            }),
        Text(
          '分期',
          style: TextStyle(fontSize: 18),
        ),
      ])
    ]);
  }

  Widget buildDurationField() {
    return Column(children:[
      Row(children: [
        const SizedBox(width: 8),
        Text(
          '病程',
          style: TextStyle(fontSize: 18),
        ),
        const SizedBox(width: 20),
        Radio(
            value: 1,
            groupValue: duration,
            onChanged: (value) {
              setState(() {
                duration = value as int;
                _duration = '≤3个月';
              });
            }),
        Text(
          '≤3个月',
          style: TextStyle(fontSize: 18),
        ),
      ]),
      Row(children: [
        const SizedBox(width: 65),
        Radio(
            value: 2,
            groupValue: duration,
            onChanged: submitstate ? null : (value){
              setState(() {
                duration = value as int;
                _duration = '3-6个月';
              });
            }),
        Text(
          '3-6个月',
          style: TextStyle(fontSize: 18),
        ),
      ]),
      Row(children: [
        const SizedBox(width: 65),
        Radio(
            value: 3,
            groupValue: duration,
            onChanged: submitstate ? null : (value){
              setState(() {
                duration = value as int;
                _duration = '6-12个月';
              });
            }),
        Text(
          '6-12个月',
          style: TextStyle(fontSize: 18),
        ),
      ]),
      Row(children: [
        const SizedBox(width: 65),
        Radio(
            value: 4,
            groupValue: duration,
            onChanged: submitstate ? null : (value){
              setState(() {
                duration = value as int;
                _duration = '≥12个月';
              });
            }),
        Text(
          '≥12个月',
          style: TextStyle(fontSize: 18),
        ),
      ])
    ]);
  }

  Widget buildTreatmentField() {
    return Column(children:[
      Row(children: [
        const SizedBox(width: 8),
        Text(
          '治疗方式',
          style: TextStyle(fontSize: 18),
        ),
        const SizedBox(width: 20),
        Radio(
            value: 1,
            groupValue: treatment,
            onChanged: (value) {
              setState(() {
                treatment = value as int;
                _treatment = '化疗';
              });
            }),
        Text(
          '化疗',
          style: TextStyle(fontSize: 18),
        ),
      ]),
      Row(children: [
        const SizedBox(width: 100),
        Radio(
            value: 2,
            groupValue: treatment,
            onChanged: submitstate ? null : (value){
              setState(() {
                treatment = value as int;
                _treatment = '放疗';
              });
            }),
        Text(
          '放疗',
          style: TextStyle(fontSize: 18),
        ),
      ]),
      Row(children: [
        const SizedBox(width: 100),
        Radio(
            value: 3,
            groupValue: treatment,
            onChanged: submitstate ? null : (value){
              setState(() {
                treatment = value as int;
                _treatment = '免疫治疗';
              });
            }),
        Text(
          '免疫治疗',
          style: TextStyle(fontSize: 18),
        ),
      ]),
      Row(children: [
        const SizedBox(width: 100),
        Radio(
            value: 4,
            groupValue: treatment,
            onChanged: submitstate ? null : (value){
              setState(() {
                treatment = value as int;
                _treatment = '靶向治疗';
              });
            }),
        Text(
          '靶向治疗',
          style: TextStyle(fontSize: 18),
        ),
      ])
    ]);
  }

  Widget buildSurgeryField() {
    return Column(children:[
      Row(children: [
        const SizedBox(width: 8),
        Text(
          '手术类型',
          style: TextStyle(fontSize: 18),
        ),
        const SizedBox(width: 20),
        Radio(
            value: 1,
            groupValue: surgery,
            onChanged: (value) {
              setState(() {
                surgery = value as int;
                _surgery = '无';
              });
            }),
        Text(
          '无',
          style: TextStyle(fontSize: 18),
        ),
      ]),
      Row(children: [
        const SizedBox(width: 100),
        Radio(
            value: 2,
            groupValue: surgery,
            onChanged: submitstate ? null : (value){
              setState(() {
                surgery = value as int;
                _surgery = '根治性手术';
              });
            }),
        Text(
          '根治性手术',
          style: TextStyle(fontSize: 18),
        ),
      ]),
      Row(children: [
        const SizedBox(width: 100),
        Radio(
            value: 3,
            groupValue: surgery,
            onChanged: submitstate ? null : (value){
              setState(() {
                surgery = value as int;
                _surgery = '姑息性手术';
              });
            }),
        Text(
          '姑息性手术',
          style: TextStyle(fontSize: 18),
        ),
      ])
    ]);
  }

  Widget buildMetastasisField() {
    return Column(children:[
      Row(children: [
        const SizedBox(width: 8),
        Text(
          '转移情况',
          style: TextStyle(fontSize: 18),
        ),
        const SizedBox(width: 20),
        Radio(
            value: 1,
            groupValue: metastasis,
            onChanged: (value) {
              setState(() {
                metastasis = value as int;
                _metastasis = '未转移';
              });
            }),
        Text(
          '未转移',
          style: TextStyle(fontSize: 18),
        ),
      ]),
      Row(children: [
        const SizedBox(width: 100),
        Radio(
            value: 2,
            groupValue: metastasis,
            onChanged: submitstate ? null : (value){
              setState(() {
                metastasis = value as int;
                _metastasis = '局部转移';
              });
            }),
        Text(
          '局部转移',
          style: TextStyle(fontSize: 18),
        ),
      ]),
      Row(children: [
        const SizedBox(width: 100),
        Radio(
            value: 3,
            groupValue: metastasis,
            onChanged: submitstate ? null : (value){
              setState(() {
                metastasis = value as int;
                _metastasis = '远处转移';
              });
            }),
        Text(
          '远处转移',
          style: TextStyle(fontSize: 18),
        ),
      ])
    ]);
  }

  Widget buildEducationField() {
    return Column(children:[
      Row(children: [
        const SizedBox(width: 8),
        Text(
          '文化程度',
          style: TextStyle(fontSize: 18),
        ),
        const SizedBox(width: 20),
        Radio(
            value: 1,
            groupValue: education,
            onChanged: (value) {
              setState(() {
                education = value as int;
                _education = '小学及以下';
              });
            }),
        Text(
          '小学及以下',
          style: TextStyle(fontSize: 18),
        ),
      ]),
      Row(children: [
        const SizedBox(width: 100),
        Radio(
            value: 2,
            groupValue: education,
            onChanged: submitstate ? null : (value){
              setState(() {
                education = value as int;
                 _education = '初中';
              });
            }),
        Text(
          '初中',
          style: TextStyle(fontSize: 18),
        ),
      ]),
      Row(children: [
        const SizedBox(width: 100),
        Radio(
            value: 3,
            groupValue: education,
            onChanged: submitstate ? null : (value){
              setState(() {
                education = value as int;
                 _education = '高中或中专';
              });
            }),
        Text(
          '高中或中专',
          style: TextStyle(fontSize: 18),
        ),
      ]),
      Row(children: [
        const SizedBox(width: 100),
        Radio(
            value: 4,
            groupValue: education,
            onChanged: submitstate ? null : (value){
              setState(() {
                education = value as int;
                 _education = '大专';
              });
            }),
        Text(
          '大专',
          style: TextStyle(fontSize: 18),
        ),
      ]),
      Row(children: [
        const SizedBox(width: 100),
        Radio(
            value: 5,
            groupValue: education,
            onChanged: submitstate ? null : (value){
              setState(() {
                education = value as int;
                 _education = '本科及以上';
              });
            }),
        Text(
          '本科及以上',
          style: TextStyle(fontSize: 18),
        ),
      ])
    ]);
  }

  Widget buildWorkField() {
    return Column(children:[
      Row(children: [
        const SizedBox(width: 8),
        Text(
          '工作状态',
          style: TextStyle(fontSize: 18),
        ),
        const SizedBox(width: 20),
        Radio(
            value: 1,
            groupValue: work,
            onChanged: (value) {
              setState(() {
                work = value as int;
                _work = '管理';
              });
            }),
        Text(
          '管理',
          style: TextStyle(fontSize: 18),
        ),
      ]),
      Row(children: [
        const SizedBox(width: 100),
        Radio(
            value: 2,
            groupValue: work,
            onChanged: submitstate ? null : (value){
              setState(() {
                work = value as int;
                _work = '技术';
              });
            }),
        Text(
          '技术',
          style: TextStyle(fontSize: 18),
        ),
      ]),
      Row(children: [
        const SizedBox(width: 100),
        Radio(
            value: 3,
            groupValue: work,
            onChanged: submitstate ? null : (value){
              setState(() {
                work = value as int;
                _work = '文书';
              });
            }),
        Text(
          '文书',
          style: TextStyle(fontSize: 18),
        ),
      ]),
      Row(children: [
        const SizedBox(width: 100),
        Radio(
            value: 4,
            groupValue: work,
            onChanged: submitstate ? null : (value){
              setState(() {
                work = value as int;
                _work = '销售';
              });
            }),
        Text(
          '销售',
          style: TextStyle(fontSize: 18),
        ),
      ]),
      Row(children: [
        const SizedBox(width: 100),
        Radio(
            value: 5,
            groupValue: work,
            onChanged: submitstate ? null : (value){
              setState(() {
                work = value as int;
                _work = '工/农/渔/林';
              });
            }),
        Text(
          '工/农/渔/林',
          style: TextStyle(fontSize: 18),
        ),
      ]),
      Row(children: [
        const SizedBox(width: 100),
        Radio(
            value: 6,
            groupValue: work,
            onChanged: submitstate ? null : (value){
              setState(() {
                work = value as int;
                _work = '个体';
              });
            }),
        Text(
          '个体',
          style: TextStyle(fontSize: 18),
        ),
      ]),
      Row(children: [
        const SizedBox(width: 100),
        Radio(
            value: 7,
            groupValue: work,
            onChanged: submitstate ? null : (value){
              setState(() {
                work = value as int;
                _work = '自由职业';
              });
            }),
        Text(
          '自由职业',
          style: TextStyle(fontSize: 18),
        ),
      ]),
      Row(children: [
        const SizedBox(width: 100),
        Radio(
            value: 8,
            groupValue: work,
            onChanged: submitstate ? null : (value){
              setState(() {
                work = value as int;
                _work = '病休';
              });
            }),
        Text(
          '病休',
          style: TextStyle(fontSize: 18),
        ),
      ]),
      Row(children: [
        const SizedBox(width: 100),
        Radio(
            value: 9,
            groupValue: work,
            onChanged: submitstate ? null : (value){
              setState(() {
                work = value as int;
                _work = '退休';
              });
            }),
        Text(
          '退休',
          style: TextStyle(fontSize: 18),
        ),
      ])
    ]);
  }

  Widget buildResidencyField() {
    return Column(children:[
      Row(children: [
        const SizedBox(width: 8),
        Text(
          '居住方式',
          style: TextStyle(fontSize: 18),
        ),
        const SizedBox(width: 20),
        Radio(
            value: 1,
            groupValue: residency,
            onChanged: (value) {
              setState(() {
                residency = value as int;
                _residency = '独居';
              });
            }),
        Text(
          '独居',
          style: TextStyle(fontSize: 18),
        ),
      ]),
      Row(children: [
        const SizedBox(width: 100),
        Radio(
            value: 2,
            groupValue: residency,
            onChanged: submitstate ? null : (value){
              setState(() {
                residency = value as int;
                _residency = '与配偶居住';
              });
            }),
        Text(
          '与配偶居住',
          style: TextStyle(fontSize: 18),
        ),
      ]),
      Row(children: [
        const SizedBox(width: 100),
        Radio(
            value: 3,
            groupValue: residency,
            onChanged: submitstate ? null : (value){
              setState(() {
                residency = value as int;
                _residency = '与子女居住';
              });
            }),
        Text(
          '与子女居住',
          style: TextStyle(fontSize: 18),
        ),
      ]),
      Row(children: [
        const SizedBox(width: 100),
        Radio(
            value: 4,
            groupValue: residency,
            onChanged: submitstate ? null : (value){
              setState(() {
                residency = value as int;
                _residency = '养老院';
              });
            }),
        Text(
          '养老院',
          style: TextStyle(fontSize: 18),
        ),
      ]),
      Row(children: [
        const SizedBox(width: 100),
        Radio(
            value: 5,
            groupValue: residency,
            onChanged: submitstate ? null : (value){
              setState(() {
                residency = value as int;
                _residency = '与配偶和子女共同居住';
              });
            }),
        Text(
          '与配偶和子女共同居住',
          style: TextStyle(fontSize: 18),
        ),
      ]),
      Row(children: [
        const SizedBox(width: 100),
        Radio(
            value: 6,
            groupValue: residency,
            onChanged: submitstate ? null : (value){
              setState(() {
                residency = value as int;
                _residency = '与父母居住';
              });
            }),
        Text(
          '与父母居住',
          style: TextStyle(fontSize: 18),
        ),
      ]),
      Row(children: [
        const SizedBox(width: 100),
        Radio(
            value: 7,
            groupValue: residency,
            onChanged: submitstate ? null : (value){
              setState(() {
                residency = value as int;
                _residency = '其他';
              });
            }),
        Text(
          '其他',
          style: TextStyle(fontSize: 18),
        ),
      ])
    ]);
  }

  Widget buildIncomeField() {
    return Column(children:[
      Row(children: [
        const SizedBox(width: 8),
        Text(
          '收入情况',
          style: TextStyle(fontSize: 18),
        ),
        const SizedBox(width: 20),
        Radio(
            value: 1,
            groupValue: income,
            onChanged: (value) {
              setState(() {
                income = value as int;
                _income = '<3000元';
              });
            }),
        Text(
          '<3000元',
          style: TextStyle(fontSize: 18),
        ),
      ]),
      Row(children: [
        const SizedBox(width: 100),
        Radio(
            value: 2,
            groupValue: income,
            onChanged: submitstate ? null : (value){
              setState(() {
                income = value as int;
                _income = '3000-5000元';
              });
            }),
        Text(
          '3000-5000元',
          style: TextStyle(fontSize: 18),
        ),
      ]),
      Row(children: [
        const SizedBox(width: 100),
        Radio(
            value: 3,
            groupValue: income,
            onChanged: submitstate ? null : (value){
              setState(() {
                income = value as int;
                _income = '5001-10000元';
              });
            }),
        Text(
          '5001-10000元',
          style: TextStyle(fontSize: 18),
        ),
      ]),
      Row(children: [
        const SizedBox(width: 100),
        Radio(
            value: 4,
            groupValue: income,
            onChanged: submitstate ? null : (value){
              setState(() {
                income = value as int;
                _income = '>10000元';
              });
            }),
        Text(
          '>10000元',
          style: TextStyle(fontSize: 18),
        ),
      ])
    ]);
  }

  Widget buildInsuranceField() {
    return Column(children:[
      Row(children: [
        const SizedBox(width: 8),
        Text(
          '医保方式',
          style: TextStyle(fontSize: 18),
        ),
        const SizedBox(width: 20),
        Radio(
            value: 1,
            groupValue: insurance,
            onChanged: (value) {
              setState(() {
                insurance = value as int;
                _insurance = '自费';
              });
            }),
        Text(
          '自费',
          style: TextStyle(fontSize: 18),
        ),
      ]),
      Row(children: [
        const SizedBox(width: 100),
        Radio(
            value: 2,
            groupValue: insurance,
            onChanged: submitstate ? null : (value){
              setState(() {
                insurance = value as int;
                _insurance = '居民保险';
              });
            }),
        Text(
          '居民保险',
          style: TextStyle(fontSize: 18),
        ),
      ]),
      Row(children: [
        const SizedBox(width: 100),
        Radio(
            value: 3,
            groupValue: insurance,
            onChanged: submitstate ? null : (value){
              setState(() {
                insurance = value as int;
                _insurance = '职工保险';
              });
            }),
        Text(
          '职工保险',
          style: TextStyle(fontSize: 18),
        ),
      ]),
      Row(children: [
        const SizedBox(width: 100),
        Radio(
            value: 4,
            groupValue: insurance,
            onChanged: submitstate ? null : (value){
              setState(() {
                insurance = value as int;
                _insurance = '新农合';
              });
            }),
        Text(
          '新农合',
          style: TextStyle(fontSize: 18),
        ),
      ]),
      Row(children: [
        const SizedBox(width: 100),
        Radio(
            value: 5,
            groupValue: insurance,
            onChanged: submitstate ? null : (value){
              setState(() {
                insurance = value as int;
                _insurance = '其他';
              });
            }),
        Text(
          '其他',
          style: TextStyle(fontSize: 18),
        ),
      ])
    ]);
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
    return Column(children:[
      Row(children: [
        const SizedBox(width: 8),
        Text(
          '肉菜比例',
          style: TextStyle(fontSize: 18),
        ),
        const SizedBox(width: 20),
        Radio(
            value: 1,
            groupValue: MVratio,
            onChanged: (value) {
              setState(() {
                MVratio = value as int;
                _MVratio = '素食为主';
              });
            }),
        Text(
          '素食为主',
          style: TextStyle(fontSize: 18),
        ),
      ]),
      Row(children: [
        const SizedBox(width: 100),
        Radio(
            value: 2,
            groupValue: MVratio,
            onChanged: submitstate ? null : (value){
              setState(() {
                MVratio = value as int;
                _MVratio = '荤素搭配';
              });
            }),
        Text(
          '荤素搭配',
          style: TextStyle(fontSize: 18),
        ),
      ]),
      Row(children: [
        const SizedBox(width: 100),
        Radio(
            value: 3,
            groupValue: MVratio,
            onChanged: submitstate ? null : (value){
              setState(() {
                MVratio = value as int;
                _MVratio = '肉食为主';
              });
            }),
        Text(
          '肉食为主',
          style: TextStyle(fontSize: 18),
        ),
      ])
    ]);
  }

  Widget buildOilField() {
    return Column(children:[
      Row(children: [
        const SizedBox(width: 8),
        Text(
          '放油程度',
          style: TextStyle(fontSize: 18),
        ),
        const SizedBox(width: 20),
        Radio(
            value: 1,
            groupValue: oil,
            onChanged: (value) {
              setState(() {
                oil = value as int;
                _oil = '偏多';
              });
            }),
        Text(
          '偏多',
          style: TextStyle(fontSize: 18),
        ),
      ]),
      Row(children: [
        const SizedBox(width: 100),
        Radio(
            value: 2,
            groupValue: oil,
            onChanged: submitstate ? null : (value){
              setState(() {
                oil = value as int;
                _oil = '适中';
              });
            }),
        Text(
          '适中',
          style: TextStyle(fontSize: 18),
        ),
      ]),
      Row(children: [
        const SizedBox(width: 100),
        Radio(
            value: 3,
            groupValue: oil,
            onChanged: submitstate ? null : (value){
              setState(() {
                oil = value as int;
                _oil = '偏少';
              });
            }),
        Text(
          '偏少',
          style: TextStyle(fontSize: 18),
        ),
      ])
    ]);
  }

  Widget buildSaltField() {
    return Column(children:[
      Row(children: [
        const SizedBox(width: 8),
        Text(
          '放盐程度',
          style: TextStyle(fontSize: 18),
        ),
        const SizedBox(width: 20),
        Radio(
            value: 1,
            groupValue: salt,
            onChanged: (value) {
              setState(() {
                salt = value as int;
                _salt = '偏咸';
              });
            }),
        Text(
          '偏咸',
          style: TextStyle(fontSize: 18),
        ),
      ]),
      Row(children: [
        const SizedBox(width: 100),
        Radio(
            value: 2,
            groupValue: salt,
            onChanged: submitstate ? null : (value){
              setState(() {
                salt = value as int;
                _salt = '适中';
              });
            }),
        Text(
          '适中',
          style: TextStyle(fontSize: 18),
        ),
      ]),
      Row(children: [
        const SizedBox(width: 100),
        Radio(
            value: 3,
            groupValue: salt,
            onChanged: submitstate ? null : (value){
              setState(() {
                salt = value as int;
                _salt = '偏淡';
              });
            }),
        Text(
          '偏淡',
          style: TextStyle(fontSize: 18),
        ),
      ])
    ]);
  }

  Widget buildSubmitButton(BuildContext context) {
    return Align(
      child: SizedBox(
        height: 35,
        width: 150,
        child: FloatingActionButton(
          backgroundColor: Colors.black,
          child: Text('提交',
              style: Theme.of(context).primaryTextTheme.headlineSmall),
          onPressed: submitstate
            ? null
            : () {
                  if ((_formKey.currentState as FormState).validate()) {
                    (_formKey.currentState as FormState).save();
                    SendBasicInformation(context);
                  }
                },
        ),
      ),
    );
  }

  Widget buildSubmitText() {
    return const Padding(
        padding: EdgeInsets.only(left: 150),
        child: Text(
          '已提交',
          style: TextStyle(fontSize: 17, color: Colors.red),
        ));
  }

  Future<void> SendBasicInformation(BuildContext context) async {
    final String apiUrl = Config.baseUrl + '/patient/save';
    var url = Uri.parse(apiUrl);
    if (controllers[0].text.isNotEmpty) name = controllers[0].text;
    if (controllers[1].text.isNotEmpty) age = controllers[1].text;
    if (controllers[2].text.isNotEmpty) height = controllers[2].text;
    if (controllers[3].text.isNotEmpty) weight = controllers[3].text;
    if (controllers[4].text.isNotEmpty) Co_morbidities = controllers[4].text;

    var response = await http.post(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'patientID': patientID,
        'name': name,
        'gender': gender.toString(),
        'age': age,
        'height': height,
        'weight': weight, 
        'Co_morbidities': Co_morbidities,
        'smoke': _smoke,
        'drink': _drink,
        'marry': _marry,
        'CA': _CA,
        'ill_type': _ill_type,
        'duration': _duration,
        'treatment': _treatment,
        'surgery': _surgery,
        'metastasis': _metastasis,
        'education': _education,
        'work': _work,
        'residency': _residency,
        'income': _income,
        'insurance': _insurance,
        'MVratio': _MVratio,
        'oil': _oil,
        'salt': _salt
      }),
    );

    if (response.statusCode == 200) {
      var responseData = response.body;
      if (responseData == '1') {
        setState(() => submitstate = true);
        SpStorage.instance.saveAccount(patientID: patientID, name: name);
        _showDialog(context, '提交成功！', onDialogClose: () {
          Navigator.pop(context);
        });
      }
        else _showDialog(context, '提交失败！', onDialogClose: () {
          Navigator.pop(context);
        });
    } else print('Request failed with status: ${response.statusCode}.');
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