import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class WeeklyTestPage extends StatefulWidget {
  const WeeklyTestPage({Key? key}) : super(key: key);

  @override
  State<WeeklyTestPage> createState() => _WeeklyTestPageState();
}

class _WeeklyTestPageState extends State<WeeklyTestPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool submitstate = false;
  DateTime RefreshTime = DateTime(0, 1, 1, 13, 15);
  Timer? timer;
  List<Map<String, dynamic>> questions = [];

  @override
  void initState() {
    super.initState();
    timer = Timer.periodic(const Duration(seconds: 1), (Timer t) => CheckTime());
    _initConfig();
    fetchSurveys();
  }

  void _initConfig() async {
    int last_submitday, last_submitmonth, last_submityear;
    // 模拟从持久化存储中读取配置
    Map<String, dynamic> config = {
      'submitstate': false,
      'submityear': 0,
      'submitmonth': 0,
      'submitday': 0
    };

    submitstate = config['submitstate'] ?? false;
    last_submityear = config['submityear'] ?? 0;
    last_submitmonth = config['submitmonth'] ?? 0;
    last_submitday = config['submitday'] ?? 0;
    if (last_submityear < DateTime.now().year) {
      submitstate = false;
    }
    if (last_submityear == DateTime.now().year &&
        last_submitmonth < DateTime.now().month) {
      submitstate = false;
    }
    if (last_submityear == DateTime.now().year &&
        last_submitmonth == DateTime.now().month &&
        last_submitday < DateTime.now().day) {
      submitstate = false;
    }
    if (last_submityear == DateTime.now().year &&
        last_submitmonth == DateTime.now().month &&
        last_submitday == DateTime.now().day &&
        CompareTime(RefreshTime, DateTime.now())) {
      submitstate = false;
    }
    setState(() {});
  }

  Future<void> fetchSurveys() async {
    var url = Uri.parse('http://10.0.2.2:5001/surveys');
    var response = await http.get(url);

    if (response.statusCode == 200) {
      var jsonData = jsonDecode(response.body) as List;
      DateTime now = DateTime.now();
      var dateFormat = DateFormat('EEE, dd MMM yyyy HH:mm:ss \'GMT\''); // 解析日期格式

      var activeSurvey = jsonData.firstWhere(
        (survey) {
          DateTime startTime = dateFormat.parseUTC(survey['scheduled_start_time']).toLocal();
          DateTime endTime = dateFormat.parseUTC(survey['scheduled_end_time']).toLocal();
          return startTime.isBefore(now) && endTime.isAfter(now);
        },
        orElse: () => null,
      );

      if (activeSurvey != null) {
        fetchQuestions(activeSurvey['survey_id']);
      } else {
        // Handle case where no active survey is found
        setState(() {
          questions = [];
        });
      }
    } else {
      throw Exception('Failed to load surveys');
    }
  }

  Future<void> fetchQuestions(int surveyId) async {
    var url = Uri.parse('http://10.0.2.2:5001/surveys/$surveyId');
    var response = await http.get(url);

    if (response.statusCode == 200) {
      var jsonData = jsonDecode(response.body);
      setState(() {
        questions = (jsonData['questions'] as List).map((data) => {
          'question': data['question'],
          'choice1': data['choice1'],
          'choice2': data['choice2'],
          'choice3': data['choice3'],
          'choice4': data['choice4'],
        }).toList();
      });
    } else {
      throw Exception('Failed to load questions');
    }
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text('每周小测试'),
      ),
      body: Form(
        key: _formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          children: [
            ...questions.map((question) {
              return Column(
                children: [
                  const SizedBox(height: 6),
                  SelectQuestion(
                    submitstate: submitstate,
                    question: question['question'] as String,
                    choose1: question['choice1'] as String,
                    choose2: question['choice2'] as String,
                    choose3: question['choice3'] as String,
                    choose4: question['choice4'] as String,
                  ),
                ],
              );
            }).toList(),
            const SizedBox(height: 60),
            buildSubmitButton(context),
            if (submitstate) buildSubmitText(),
            const SizedBox(height: 60),
          ],
        ),
      ),
    );
  }

  Widget buildSubmitButton(BuildContext context) {
    return Align(
      child: SizedBox(
        height: 35,
        width: 150,
        child: FloatingActionButton(
          backgroundColor: submitstate ? Colors.grey : Colors.black,
          child: Text('提交',
              style: Theme.of(context).primaryTextTheme.headlineSmall),
          onPressed: submitstate
              ? null
              : () {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    setState(() => submitstate = true);
                    DateTime this_submit_time = DateTime.now();
                    if (CompareTime(RefreshTime, this_submit_time)) {
                      this_submit_time = this_submit_time.add(const Duration(days: 1));
                    }
                    // 模拟保存配置到持久化存储
                    Map<String, dynamic> config = {
                      'submitstate': submitstate,
                      'submityear': this_submit_time.year,
                      'submitmonth': this_submit_time.month,
                      'submitday': this_submit_time.day
                    };
                  }
                },
        ),
      ),
    );
  }

  Widget buildSubmitText() {
    return const Padding(
      padding: EdgeInsets.only(left: 140),
      child: Text(
        '提交成功！',
        style: TextStyle(fontSize: 17, color: Colors.red),
      ),
    );
  }

  bool CompareTime(DateTime time1, DateTime time2) {
    return time1.hour * 3600 + time1.minute * 60 + time1.second <=
        time2.hour * 3600 + time2.minute * 60 + time2.second;
  }

  void CheckTime() {
    DateTime current_time = DateTime.now();
    bool flag = ((current_time.hour == RefreshTime.hour) &&
        (current_time.minute == RefreshTime.minute) &&
        (current_time.second == RefreshTime.second));
    if (flag) {
      setState(() => submitstate = false);
      // 模拟保存配置到持久化存储
      Map<String, dynamic> config = {
        'submitstate': submitstate
      };
    }
  }
}

class SelectQuestion extends StatefulWidget {
  const SelectQuestion(
      {Key? key,
      required this.submitstate,
      required this.question,
      required this.choose1,
      required this.choose2,
      required this.choose3,
      required this.choose4})
      : super(key: key);
  final String question, choose1, choose2, choose3, choose4;
  final bool submitstate;

  @override
  State<SelectQuestion> createState() => _SelectQuestionState();
}

class _SelectQuestionState extends State<SelectQuestion> {
  int _selectedValue = 1;

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Row(children: [
        Expanded(
            child: Text(
          widget.question,
          textAlign: TextAlign.left,
          style: const TextStyle(fontSize: 18),
          maxLines: 4,
          overflow: TextOverflow.ellipsis,
        ))
      ]),
      Row(children: [
        Radio(
            value: 1,
            groupValue: _selectedValue,
            onChanged: widget.submitstate ? null : (value) {
              setState(() {
                _selectedValue = value as int;
              });
            }),
        Text(
          widget.choose1,
          style: const TextStyle(fontSize: 18),
        )
      ]),
      Row(children: [
        Radio(
            value: 2,
            groupValue: _selectedValue,
            onChanged: widget.submitstate ? null : (value) {
              setState(() {
                _selectedValue = value as int;
              });
            }),
        Text(
          widget.choose2,
          style: const TextStyle(fontSize: 18),
        )
      ]),
      Row(children: [
        Radio(
            value: 3,
            groupValue: _selectedValue,
            onChanged: widget.submitstate ? null : (value) {
              setState(() {
                _selectedValue = value as int;
              });
            }),
        Text(
          widget.choose3,
          style: const TextStyle(fontSize: 18),
        )
      ]),
      Row(children: [
        Radio(
            value: 4,
            groupValue: _selectedValue,
            onChanged: widget.submitstate ? null : (value) {
              setState(() {
                _selectedValue = value as int;
              });
            }),
        Text(
          widget.choose4,
          style: const TextStyle(fontSize: 18),
        )
      ])
    ]);
  }
}
