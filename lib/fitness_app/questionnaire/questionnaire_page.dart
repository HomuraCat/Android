import 'package:flutter/material.dart';
import '../utils/Spsave_module.dart';
import 'package:flutter/cupertino.dart';
import '../../config.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';

class QuestionnairePage extends StatefulWidget {
  @override
  _QuestionnairePageState createState() => _QuestionnairePageState();
}

class _QuestionnairePageState extends State<QuestionnairePage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  late String patientID, user_name;
  bool submitstate = false;

  List<Map<String, dynamic>> _questions = [];
  Map<int, dynamic> _answers = {};

  List<dynamic> _validSurveys = [];
  int? _selectedSurveyId;
  String _surveyTitle = "";

  @override
  void initState() {
    super.initState();
    print('QuestionnairePage initialized');
    _initConfig();
    _fetchValidSurveys();
  }

  void _initConfig() async {
    Map<String, dynamic>? account = await SpStorage.instance.readAccount();
    if (account != null) {
      patientID = account['patientID'];
      user_name = account['name'];
    }
    if (user_name != "未命名") setState(() => submitstate = false);
  }

  Future<void> _fetchValidSurveys() async {
    final String apiUrl = Config.baseUrl + '/user/surveys/valid';
    var url = Uri.parse(apiUrl);
    var response = await http.get(url);
    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      setState(() {
        _validSurveys = data['surveys'];
      });
    } else {
      print('Failed to fetch valid surveys');
    }
  }

  Future<void> _checkIfAnswered(int surveyId) async {
    final String checkApiUrl = Config.baseUrl + '/user/surveys/$surveyId/answered?patient_id=$patientID';
    var url = Uri.parse(checkApiUrl);
    var response = await http.get(url);
    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      bool answered = data['answered'];
      setState(() {
        submitstate = answered;
      });
    } else {
      print('Failed to check if answered');
    }
  }

  Future<void> _fetchSurveyDetails(int surveyId) async {
    await _checkIfAnswered(surveyId);
    final String apiUrl = Config.baseUrl + '/user/surveys/$surveyId';
    var url = Uri.parse(apiUrl);
    var response = await http.get(url);
    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      List questionsData = data['questions'];
      print(questionsData);

      String title = data['title'] ?? "问卷";

      // Map backend question types to frontend types
      List<Map<String, dynamic>> transformedQuestions = questionsData.map((q) {
        String frontType;
        switch (q['question_type']) {
          case 'multiple_choice':
            frontType = 'multipleChoice';
            break;
          case 'single_choice':
            frontType = 'singleChoice';
            break;
          case 'fill_in_the_blank':
            frontType = 'shortAnswer';
            break;
          default:
            frontType = 'unknown';
            break;
        }

        List<dynamic> rawOptions = q['choices'] ?? [];
        List<String> options = rawOptions.map((opt) => opt.toString()).toList();

        return {
          'question_id': q['question_id'],
          'type': frontType,
          'question': q['question'],
          'options': options,
          'regex': null,
          'errorMessage': '请填写/选择合适的答案',
        };
      }).toList().cast<Map<String, dynamic>>();

      print("!!!!!!");
      print(transformedQuestions);
      setState(() {
        _questions = transformedQuestions;
        _answers.clear();
        _currentPage = 0;
        _selectedSurveyId = surveyId;
        _surveyTitle = title;
      });
    } else {
      print('打开问卷失败');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_selectedSurveyId == null) {
      return Scaffold(
        appBar: AppBar(title: Text("选择问卷")),
        body: _validSurveys.isEmpty
            ? Center(child: Text("暂无可用问卷"))
            : ListView.builder(
                itemCount: _validSurveys.length,
                itemBuilder: (context, index) {
                  var survey = _validSurveys[index];
                  return ListTile(
                    title: Text(survey['title'] ?? '无标题'),
                    subtitle: Text(
                        "起始时间: ${survey['scheduled_start_time']}\n结束时间: ${survey['scheduled_end_time']}"),
                    onTap: () {
                      _fetchSurveyDetails(survey['survey_id']);
                    },
                  );
                },
              ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(_surveyTitle.isEmpty ? "问卷" : _surveyTitle)),
      body: _questions.isEmpty
          ? Center(child: CircularProgressIndicator())
          : Column(
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
                        return Center(
                          child: Text("问卷已填写，无法继续。"),
                        );
                      }
                      return _buildQuestionPage(index);
                    },
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (_currentPage > 0 && !submitstate)
                      ElevatedButton(
                        onPressed: () {
                          _pageController.previousPage(
                            duration: Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        },
                        child: Text("上一题"),
                      ),
                    if (!submitstate)
                      ElevatedButton(
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
                        child: Text(
                            _currentPage == _questions.length - 1 ? "提交" : "下一题"),
                      ),
                  ],
                ),
              ],
            ),
    );
  }

  Widget _buildQuestionPage(int index) {
    final question = _questions[index];
    if (question['type'] == 'shortAnswer') {
      return _buildShortAnswerPage(index, question['question']);
    } else if (question['type'] == 'singleChoice') {
      return _buildSingleChoicePage(index, question['question'], question['options']);
    } else if (question['type'] == 'multipleChoice') {
      return _buildMultipleChoicePage(index, question['question'], question['options']);
    } else {
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

  Widget _buildSingleChoicePage(int index, String question, List<String> options) {
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

  Widget _buildMultipleChoicePage(int index, String question, List<String> options) {
    if (_answers[index] == null) {
      _answers[index] = [];
    }
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
            return CheckboxListTile(
              title: Text(option),
              value: (_answers[index] as List).contains(option),
              onChanged: (bool? value) {
                setState(() {
                  if (value == true) {
                    (_answers[index] as List).add(option);
                  } else {
                    (_answers[index] as List).remove(option);
                  }
                });
              },
            );
          }).toList(),
        ],
      ),
    );
  }

  bool _validateInput() {
    final question = _questions[_currentPage];
    final errorMessage = question['errorMessage'];
    final answer = _answers[_currentPage];

    if (question['type'] == 'shortAnswer') {
      if (answer == null || answer.toString().isEmpty) {
        _showErrorDialog(errorMessage);
        return false;
      }
      final regex = question['regex'];
      if (regex != null) {
        final regExp = RegExp(regex);
        if (!regExp.hasMatch(answer.toString())) {
          _showErrorDialog(errorMessage);
          return false;
        }
      }
    } else if (question['type'] == 'singleChoice') {
      if (answer == null) {
        _showErrorDialog(errorMessage);
        return false;
      }
    } else if (question['type'] == 'multipleChoice') {
      if (answer == null || (answer is List && answer.isEmpty)) {
        _showErrorDialog(errorMessage);
        return false;
      }
    }
    return true;
  }

  void _showErrorDialog(String? error) {
    final displayError = error ?? "请填写正确的答案";
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("输入错误"),
        content: Text(displayError),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text("确定"),
          ),
        ],
      ),
    );
  }

  void _showDialog(BuildContext context, String message, {VoidCallback? onDialogClose}) {
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
                Navigator.of(context).pop();
                if (onDialogClose != null) {
                  onDialogClose();
                }
              },
            ),
          ],
        );
      },
    );
  }

  void SendBasicInformation(BuildContext context) async {
    List<Map<String, dynamic>> answersList = [];
    for (int i = 0; i < _questions.length; i++) {
      final q = _questions[i];
      final question_id = q['question_id'];
      final answer_val = _answers[i];
      answersList.add({
        "question_id": question_id,
        "answer": answer_val
      });
    }

    final String apiUrl = Config.baseUrl + '/user/surveys/${_selectedSurveyId}/answers';
    var url = Uri.parse(apiUrl);

    var response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode({
        'patient_id': patientID,
        'answers': answersList
      }),
    );

    if (response.statusCode == 201) {
      final String addPointUrl = Config.baseUrl + '/addPoint';
      var addPointResponse = await http.post(
        Uri.parse(addPointUrl),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({
          'id': patientID,
          'points_to_add': 1
        }),
      );
      setState(() => submitstate = true);
      _showDialog(context, '提交成功！', onDialogClose: () {
        Navigator.pop(context);
      });
    } else {
      _showDialog(context, '提交失败！请稍后重试。');
    }
  }
}