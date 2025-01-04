import 'package:flutter/material.dart';
import '../utils/Spsave_module.dart';
import 'package:flutter/cupertino.dart';
import '../../config.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';
import 'show_information_page.dart';

class BasicInforPage extends StatefulWidget {
  @override
  _BasicInforPageState createState() => _BasicInforPageState();
}

class _BasicInforPageState extends State<BasicInforPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  late String patientID, user_name;
  bool submitstate = false;

  final List<Map<String, dynamic>> _questions = [
    {
      'type': 'shortAnswer',
      'question': '姓名',
      'regex': r'^[\u4e00-\u9fa5a-zA-Z\s]+$',
      'errorMessage': '姓名只能包含中文、英文和空格',
    },
    {
      'type': 'multipleChoice',
      'question': '性别',
      'options': ['男', '女'],
      'regex': null,
      'errorMessage': '请选择一个选项', 
    },
    {
      'type': 'shortAnswer',
      'question': '年龄',
      'regex': r'^\d+$',
      'errorMessage': '年龄必须是有效的数字',
    },
    {
      'type': 'shortAnswer',
      'question': '身高',
      'regex': r'^\d+$',
      'errorMessage': '身高必须是有效的数字',
    },
    {
      'type': 'shortAnswer',
      'question': '体重',
      'regex': r'^\d+$',
      'errorMessage': '体重必须是有效的数字',
    },
    {
      'type': 'shortAnswer',
      'question': '身份证号',
      'regex': r'^[X0-9]{18}$',
      'errorMessage': '身份证号必须是有效的十八位数字',
    },
    {
      'type': 'shortAnswer',
      'question': '共病情况',
      'regex': null,
      'errorMessage': '请填写共病情况',
    },
    {
      'type': 'multipleChoice',
      'question': '吸烟史',
      'options': ['有', '无', '已戒'],
      'regex': null,
      'errorMessage': '请选择一个选项', 
    },
    {
      'type': 'multipleChoice',
      'question': '饮酒史',
      'options': ['有', '无', '已戒'],
      'regex': null,
      'errorMessage': '请选择一个选项', 
    },
    {
      'type': 'multipleChoice',
      'question': '婚姻状况',
      'options': ['已婚', '未婚', '离异或丧偶'],
      'regex': null,
      'errorMessage': '请选择一个选项', 
    },
    {
      'type': 'multipleChoice',
      'question': 'CA类型',
      'options': ['非小细胞CA', '小细胞CA', '其他'],
      'regex': null,
      'errorMessage': '请选择一个选项', 
    },
    {
      'type': 'multipleChoice',
      'question': '类型',
      'options': ['首次确诊', '复发', '转移', '分期'],
      'regex': null,
      'errorMessage': '请选择一个选项', 
    },
    {
      'type': 'multipleChoice',
      'question': '病程',
      'options': ['≤3个月', '3-6个月', '6-12个月', '≥12个月'],
      'regex': null,
      'errorMessage': '请选择一个选项', 
    },
    {
      'type': 'multipleChoice',
      'question': '治疗方式',
      'options': ['化疗', '放疗', '免疫治疗', '靶向治疗'],
      'regex': null,
      'errorMessage': '请选择一个选项', 
    },
    {
      'type': 'multipleChoice',
      'question': '手术类型',
      'options': ['无', '根治性手术', '姑息性手术'],
      'regex': null,
      'errorMessage': '请选择一个选项', 
    },
    {
      'type': 'multipleChoice',
      'question': '转移情况',
      'options': ['未转移', '局部转移', '远处转移'],
      'regex': null,
      'errorMessage': '请选择一个选项', 
    },
    {
      'type': 'multipleChoice',
      'question': '文化程度',
      'options': ['小学及以下', '初中', '高中或中专', '大专', '本科及以上'],
      'regex': null,
      'errorMessage': '请选择一个选项', 
    },
    {
      'type': 'multipleChoice',
      'question': '工作状态',
      'options': ['管理', '技术', '文书', '销售', '工/农/渔/林', '个体', '自由职业', '病休', '退休'],
      'regex': null,
      'errorMessage': '请选择一个选项', 
    },
    {
      'type': 'multipleChoice',
      'question': '居住方式',
      'options': ['独居', '与配偶居住', '与子女居住', '养老院', '与配偶和子女共同居住', '与父母居住', '其他'],
      'regex': null,
      'errorMessage': '请选择一个选项', 
    },
    {
      'type': 'multipleChoice',
      'question': '收入情况',
      'options': ['<3000元', '3000-5000元', '5001-10000元', '>10000元'],
      'regex': null,
      'errorMessage': '请选择一个选项', 
    },
    {
      'type': 'multipleChoice',
      'question': '医保方式',
      'options': ['自费', '居民保险', '职工保险', '新农合', '其他'],
      'regex': null,
      'errorMessage': '请选择一个选项', 
    },
    {
      'type': 'multipleChoice',
      'question': '肉菜比例',
      'options': ['素食为主', '荤素搭配', '肉食为主'],
      'regex': null,
      'errorMessage': '请选择一个选项', 
    },
    {
      'type': 'multipleChoice',
      'question': '放油程度',
      'options': ['偏多', '适中', '偏少'],
      'regex': null,
      'errorMessage': '请选择一个选项', 
    },
    {
      'type': 'multipleChoice',
      'question': '放盐程度',
      'options': ['偏咸', '适中', '偏淡'],
      'regex': null,
      'errorMessage': '请选择一个选项', 
    }
  ];

  final Map<int, dynamic> _answers = {};

  void initState() {
    super.initState();
    _initConfig();
  }

  void _initConfig() async {
    Map<String, dynamic>? account = await SpStorage.instance.readAccount();
    if (account != null) {
      patientID = account['patientID'];
      user_name = account['name'];
    }
    if (user_name != "未命名") setState(() => submitstate = true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("基本信息")),
      body: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index;
                });
              },
              itemCount: _questions.length,
              itemBuilder: (context, index) {
                if (submitstate) {
                  return ShowInformationPage(patientID: patientID, patientName: user_name);
                }
                return _buildQuestionPage(index);
              },
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (!submitstate)
                Container(
                  width: 150,
                  height: 60,
                  child:ElevatedButton(
                    onPressed: _currentPage > 0?() {
                      _pageController.previousPage(
                        duration: Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    }:null,
                    child: Text(_currentPage > 0?"上一题":"已经是第一题了", style: TextStyle(fontSize: _currentPage > 0?18:14)),
                  )
                 ),
              if (!submitstate)
                Container(
                  width: 150,
                  height: 60,
                  child: ElevatedButton(
                      onPressed: submitstate
                          ? null
                          : () {
                              if (_validateInput()) {
                                if (_currentPage < _questions.length - 1) {
                                  _pageController.nextPage(
                                    duration: Duration(milliseconds: 300),
                                    curve: Curves.easeInOut,
                                  );
                                } else {
                                  SendBasicInformation(context);
                                }
                              }
                            },
                      child: Text(_currentPage == _questions.length - 1? "提交": "下一题", style: TextStyle(fontSize: 18)),
                    ),
                )
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionPage(int index) {
    final question = _questions[index];

    switch (question['type']) {
      case 'shortAnswer':
        return _buildShortAnswerPage(index, question['question']);
      case 'multipleChoice':
        return _buildMultipleChoicePage(
          index,
          question['question'],
          question['options'],
        );
      default:
        return Center(child: Text("未知题型"));
    }
  }

  Widget _buildShortAnswerPage(int index, String question) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "问题 ${index + 1}/${_questions.length}",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 20),
          Text(
            question,
            style: TextStyle(fontSize: 16),
          ),
          SizedBox(height: 20),
          TextField(
            onChanged: (value) {
              _answers[index] = value;
            },
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              labelText: "请输入答案",
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMultipleChoicePage(
      int index, String question, List<String> options) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "问题 ${index + 1}/${_questions.length}",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 20),
          Text(
            question,
            style: TextStyle(fontSize: 16),
          ),
          SizedBox(height: 20),
          ...options.map((option) {
            return ListTile(
              title: Text(option),
              leading: Radio(
                value: option,
                groupValue: _answers[index],
                onChanged: (value) {
                  setState(() {
                    _answers[index] = value;
                  });
                },
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  bool _validateInput() {
    final question = _questions[_currentPage];
    final regex = question['regex'];
    final errorMessage = question['errorMessage'];
    final answer = _answers[_currentPage];

    if (regex != null) {
      final regExp = RegExp(regex);
      if (answer == null || !regExp.hasMatch(answer.toString())) {
        _showErrorDialog(errorMessage);
        return false;
      }
    } else if (answer == null) {
      _showErrorDialog(errorMessage);
      return false;
    }
    return true;
  }

  void _showErrorDialog(String error) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("输入错误"),
        content: Text(error),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text("确定"),
          ),
        ],
      ),
    );
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

  Future<void> SendBasicInformation(BuildContext context) async {
    final String apiUrl = Config.baseUrl + '/patient/save';
    var url = Uri.parse(apiUrl);

    var response = await http.post(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'patientID': patientID,
        'name': _answers[0],
        'gender': (_answers[1] == '男')?'1':'2',
        'age': _answers[2],
        'height': _answers[3],
        'weight': _answers[4],
        'IDNumber': _answers[5],
        'Co_morbidities': _answers[6],
        'smoke': _answers[7],
        'drink': _answers[8],
        'marry': _answers[9],
        'CA': _answers[10],
        'ill_type': _answers[11],
        'duration': _answers[12],
        'treatment': _answers[13],
        'surgery': _answers[14],
        'metastasis': _answers[15],
        'education': _answers[16],
        'work': _answers[17],
        'residency': _answers[18],
        'income': _answers[19],
        'insurance': _answers[20],
        'MVratio': _answers[21],
        'oil': _answers[22],
        'salt': _answers[23]
      }),
    );

    if (response.statusCode == 200) {
      var responseData = response.body;
      if (responseData == '1') {
        setState(() => submitstate = true);
        SpStorage.instance.saveAccount(patientID: patientID, name: _answers[0], identity: true);
        _showDialog(context, '提交成功！', onDialogClose: () {
          Navigator.pop(context);
        });
      }
        else _showDialog(context, '提交失败！', onDialogClose: () {
          Navigator.pop(context);
        });
    } else print('Request failed with status: ${response.statusCode}.');
  }
}