import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class NewQuestionPage extends StatefulWidget {
  final int surveyId;

  NewQuestionPage(this.surveyId);

  @override
  _NewQuestionPageState createState() => _NewQuestionPageState();
}

class _NewQuestionPageState extends State<NewQuestionPage> {
  final _formKey = GlobalKey<FormState>();
  List<Map<String, String>> questions = [];
  List<int> correctChoices = [];

  void addQuestion() {
    setState(() {
      questions.add({
        'question': '',
        'choice1': '',
        'choice2': '',
        'choice3': '',
        'choice4': ''
      });
      correctChoices.add(1); // 默认正确选项为1
    });
  }

  void removeQuestion(int index) {
    setState(() {
      questions.removeAt(index);
      correctChoices.removeAt(index);
    });
  }

  Future<void> submitQuestions() async {
    var url = Uri.parse('http://43.136.14.179:5001/questions');
    for (int i = 0; i < questions.length; i++) {
      var question = questions[i];
      var response = await http.post(
        url,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({
          'survey_id': widget.surveyId,
          'question': question['question'],
          'choice1': question['choice1'],
          'choice2': question['choice2'],
          'choice3': question['choice3'],
          'choice4': question['choice4'],
          'correct_choice': correctChoices[i],
        }),
      );

      if (response.statusCode != 201) {
        throw Exception('Failed to submit question');
      }
    }

    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Questions submitted successfully')));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('新建问题'),
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: addQuestion,
                    child: Text('添加问题'),
                  ),
                  SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        submitQuestions();
                      }
                    },
                    child: Text('提交问题'),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    ...questions.asMap().entries.map((entry) {
                      int index = entry.key;
                      Map<String, String> question = entry.value;

                      return Column(
                        key: ValueKey(index),
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '问题 ${index + 1}',
                                style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Color.fromARGB(255, 0, 71, 79)),
                              ),
                              IconButton(
                                icon: Icon(Icons.delete, color: Colors.red),
                                onPressed: () {
                                  removeQuestion(index);
                                },
                              ),
                            ],
                          ),
                          TextFormField(
                            decoration: InputDecoration(
                              labelText: '题干 ${index + 1}',
                              labelStyle: TextStyle(color: Color.fromARGB(255, 0, 71, 79)),
                            ),
                            onChanged: (value) {
                              setState(() {
                                question['question'] = value;
                              });
                            },
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return '请输入问题';
                              }
                              return null;
                            },
                          ),
                          TextFormField(
                            decoration: InputDecoration(
                              labelText: '选项 1',
                              labelStyle: TextStyle(color: Color.fromARGB(255, 19, 194, 194)),
                            ),
                            onChanged: (value) {
                              setState(() {
                                question['choice1'] = value;
                              });
                            },
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return '请输入选项 1';
                              }
                              return null;
                            },
                          ),
                          TextFormField(
                            decoration: InputDecoration(
                              labelText: '选项 2',
                              labelStyle: TextStyle(color: Color.fromARGB(255, 19, 194, 194)),
                            ),
                            onChanged: (value) {
                              setState(() {
                                question['choice2'] = value;
                              });
                            },
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return '请输入选项 2';
                              }
                              return null;
                            },
                          ),
                          TextFormField(
                            decoration: InputDecoration(
                              labelText: '选项 3',
                              labelStyle: TextStyle(color: Color.fromARGB(255, 19, 194, 194)),
                            ),
                            onChanged: (value) {
                              setState(() {
                                question['choice3'] = value;
                              });
                            },
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return '请输入选项 3';
                              }
                              return null;
                            },
                          ),
                          TextFormField(
                            decoration: InputDecoration(
                              labelText: '选项 4',
                              labelStyle: TextStyle(color: Color.fromARGB(255, 19, 194, 194)),
                            ),
                            onChanged: (value) {
                              setState(() {
                                question['choice4'] = value;
                              });
                            },
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return '请输入选项 4';
                              }
                              return null;
                            },
                          ),
                          DropdownButtonFormField<int>(
                            value: correctChoices[index],
                            items: [
                              DropdownMenuItem(value: 1, child: Text('选项 1')),
                              DropdownMenuItem(value: 2, child: Text('选项 2')),
                              DropdownMenuItem(value: 3, child: Text('选项 3')),
                              DropdownMenuItem(value: 4, child: Text('选项 4')),
                            ],
                            onChanged: (value) {
                              setState(() {
                                correctChoices[index] = value!;
                              });
                            },
                            decoration: InputDecoration(
                              labelText: '正确选项',
                              labelStyle: TextStyle(color: Color.fromARGB(255, 19, 194, 194)),
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                    SizedBox(height: 100), // 保证最后的按钮不会被遮挡
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
