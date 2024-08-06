import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'new_question_page.dart';
import '../../config.dart';

class NewSurveyPage extends StatefulWidget {
  @override
  _NewSurveyPageState createState() => _NewSurveyPageState();
}

class _NewSurveyPageState extends State<NewSurveyPage> {
  final _formKey = GlobalKey<FormState>();
  String title = '';
  String description = '';
  DateTime scheduledStartTime = DateTime.now();
  DateTime scheduledEndTime = DateTime.now().add(Duration(days: 1));

  Future<void> submitSurvey() async {
    final String apiUrl = Config.baseUrl + '/surveys';
    var url = Uri.parse(apiUrl);

    var response = await http.post(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode({
        'title': title,
        'description': description,
        'scheduled_start_time': scheduledStartTime.toIso8601String(),
        'scheduled_end_time': scheduledEndTime.toIso8601String(),
      }),
    );

    if (response.statusCode == 201) {
      var surveyId = jsonDecode(response.body)['survey_id'];
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => NewQuestionPage(surveyId)),
      );
    } else {
      throw Exception('Failed to create survey');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('新建问卷')),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextFormField(
                decoration: InputDecoration(labelText: '标题'),
                onChanged: (value) => setState(() => title = value),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '请输入标题';
                  }
                  return null;
                },
              ),
              TextFormField(
                decoration: InputDecoration(labelText: '描述'),
                onChanged: (value) => setState(() => description = value),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '请输入描述';
                  }
                  return null;
                },
              ),
              ListTile(
                title: Text("开始时间: ${scheduledStartTime.toLocal()}"),
                trailing: Icon(Icons.calendar_today),
                onTap: () async {
                  DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: scheduledStartTime,
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2101),
                  );
                  if (picked != null && picked != scheduledStartTime)
                    setState(() {
                      scheduledStartTime = picked;
                    });
                },
              ),
              ListTile(
                title: Text("结束时间: ${scheduledEndTime.toLocal()}"),
                trailing: Icon(Icons.calendar_today),
                onTap: () async {
                  DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: scheduledEndTime,
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2101),
                  );
                  if (picked != null && picked != scheduledEndTime)
                    setState(() {
                      scheduledEndTime = picked;
                    });
                },
              ),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    submitSurvey();
                  }
                },
                child: Text('提交问卷'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
