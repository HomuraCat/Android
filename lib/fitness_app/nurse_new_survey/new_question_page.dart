import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../config.dart';

class NewQuestionPage extends StatefulWidget {
  final int surveyId;

  NewQuestionPage(this.surveyId);

  @override
  _NewQuestionPageState createState() => _NewQuestionPageState();
}

class _NewQuestionPageState extends State<NewQuestionPage> {
  final _formKey = GlobalKey<FormState>();

  /// 问题列表，每个问题数据示例：
  /// {
  ///   'questionType': 'multiple_choice' 或 'fill_in_the_blank',
  ///   'question': '',
  ///   'choices': ['选项1', '选项2', ...] (multiple_choice使用),
  ///   'answer': '' (fill_in_the_blank使用，如果不需要正确答案，此字段可忽略)
  /// }
  List<Map<String, dynamic>> questions = [];

  void addQuestion() {
    setState(() {
      questions.add({
        'questionType': 'multiple_choice',
        'question': '',
        'choices': [''],
        'answer': ''
      });
    });
  }

  void removeQuestion(int index) {
    setState(() {
      questions.removeAt(index);
    });
  }

  void addChoice(int questionIndex) {
    setState(() {
      questions[questionIndex]['choices'].add('');
    });
  }

  void removeChoice(int questionIndex, int choiceIndex) {
    setState(() {
      questions[questionIndex]['choices'].removeAt(choiceIndex);
    });
  }

  Future<void> submitQuestions() async {
    final String apiUrl = Config.baseUrl + '/questions';
    var url = Uri.parse(apiUrl);

    for (int i = 0; i < questions.length; i++) {
      var question = questions[i];

      Map<String, dynamic> requestBody = {
        'survey_id': widget.surveyId,
        'question': question['question'],
        'question_type': question['questionType']
      };

      if (question['questionType'] == 'multiple_choice') {
        requestBody['choices'] = question['choices'];
        // 无需正确选项字段
      } else if (question['questionType'] == 'fill_in_the_blank') {
        // 如果也不需要正确答案，请移除此行
        //requestBody['answer'] = question['answer'];
      }

      var response = await http.post(
        url,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(requestBody),
      );

      if (response.statusCode != 201) {
        throw Exception('Failed to submit question');
      }
    }

    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Questions submitted successfully')));
    Navigator.pop(context);
  }

  Widget buildMultipleChoiceSection(int index) {
    var question = questions[index];
    List<String> choices = List<String>.from(question['choices']);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...choices.asMap().entries.map((entry) {
          int choiceIndex = entry.key;
          String choiceText = entry.value;

          return Row(
            children: [
              Expanded(
                child: TextFormField(
                  decoration: InputDecoration(
                    labelText: '选项 ${choiceIndex + 1}',
                    labelStyle:
                        TextStyle(color: Color.fromARGB(255, 19, 194, 194)),
                  ),
                  initialValue: choiceText,
                  onChanged: (value) {
                    setState(() {
                      questions[index]['choices'][choiceIndex] = value;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '请输入选项 ${choiceIndex + 1}';
                    }
                    return null;
                  },
                ),
              ),
              IconButton(
                icon: Icon(Icons.delete, color: Colors.red),
                onPressed: choices.length > 1
                    ? () => removeChoice(index, choiceIndex)
                    : null,
              ),
            ],
          );
        }).toList(),
        ElevatedButton(
          onPressed: () => addChoice(index),
          child: Text('添加选项'),
        ),
      ],
    );
  }

  Widget buildFillInTheBlankSection(int index) {
    return TextFormField(
      decoration: InputDecoration(
        labelText: '填空答案（如果不需要可移除此项）',
        labelStyle: TextStyle(color: Color.fromARGB(255, 19, 194, 194)),
      ),
      initialValue: questions[index]['answer'],
      onChanged: (value) {
        setState(() {
          questions[index]['answer'] = value;
        });
      },

    );
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
                      var question = entry.value;

                      return Column(
                        key: ValueKey(index),
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
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
                          DropdownButtonFormField<String>(
                            value: question['questionType'],
                            items: [
                              DropdownMenuItem(
                                  value: 'multiple_choice', child: Text('多选题')),
                              DropdownMenuItem(
                                  value: 'fill_in_the_blank', child: Text('填空题')),
                            ],
                            onChanged: (value) {
                              setState(() {
                                questions[index]['questionType'] = value!;
                                // 切换题型后重置相应的数据
                                if (value == 'multiple_choice') {
                                  questions[index]['choices'] = [''];
                                  questions[index]['answer'] = '';
                                } else {
                                  questions[index]['choices'] = [];
                                  questions[index]['answer'] = '';
                                }
                              });
                            },
                            decoration: InputDecoration(
                              labelText: '题型',
                              labelStyle:
                                  TextStyle(color: Color.fromARGB(255, 0, 71, 79)),
                            ),
                          ),
                          TextFormField(
                            decoration: InputDecoration(
                              labelText: '题干 ${index + 1}',
                              labelStyle: TextStyle(
                                  color: Color.fromARGB(255, 0, 71, 79)),
                            ),
                            initialValue: question['question'],
                            onChanged: (value) {
                              setState(() {
                                questions[index]['question'] = value;
                              });
                            },
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return '请输入问题';
                              }
                              return null;
                            },
                          ),
                          if (question['questionType'] == 'multiple_choice')
                            buildMultipleChoiceSection(index),
                          //if (question['questionType'] == 'fill_in_the_blank')
                          //  buildFillInTheBlankSection(index),
                          SizedBox(height: 20),
                        ],
                      );
                    }).toList(),
                    SizedBox(height: 100),
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
