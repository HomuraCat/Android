import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'patient_detail_page.dart'; // Import the new page

class SurveyDetailPage extends StatefulWidget {
  final int surveyId;

  SurveyDetailPage({required this.surveyId});

  @override
  _SurveyDetailPageState createState() => _SurveyDetailPageState();
}

class _SurveyDetailPageState extends State<SurveyDetailPage> {
  Map<String, dynamic>? survey;
  List questions = [];
  List patientDetails = [
    {
      'patient_name': '患者A',
      'answered': true,
      'score': 85
    },
    {
      'patient_name': '患者B',
      'answered': false,
      'score': null
    },
    {
      'patient_name': '患者C',
      'answered': true,
      'score': 90
    }
  ];

  @override
  void initState() {
    super.initState();
    fetchSurveyDetails();
  }

  Future<void> fetchSurveyDetails() async {
    var url = Uri.parse('http://10.0.2.2:5001/surveys/${widget.surveyId}');
    var response = await http.get(url);

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      setState(() {
        survey = data['survey'];
        questions = data['questions'];
        // patientDetails = data['patient_details']; // This line will be uncommented once the database is updated
      });
    } else {
      throw Exception('Failed to load survey details');
    }
  }

  Future<void> deleteSurvey() async {
    var url = Uri.parse('http://10.0.2.2:5001/surveys/${widget.surveyId}');
    var response = await http.delete(url);

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Survey deleted successfully')));
      Navigator.pop(context, true);
    } else {
      throw Exception('Failed to delete survey');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('问卷详情'),
      ),
      body: survey == null
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('标题: ${survey!['title']}', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    SizedBox(height: 8),
                    Text('描述: ${survey!['description']}'),
                    SizedBox(height: 8),
                    Text('预计发布时间: ${survey!['scheduled_start_time']}'),
                    SizedBox(height: 8),
                    Text('预计结束时间: ${survey!['scheduled_end_time']}'),
                    SizedBox(height: 16),
                    Text('问题列表:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    ...questions.map((question) {
                      return ListTile(
                        title: Text(question['question']),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('选项 1: ${question['choice1']}'),
                            Text('选项 2: ${question['choice2']}'),
                            Text('选项 3: ${question['choice3']}'),
                            Text('选项 4: ${question['choice4']}'),
                            Text('正确选项: 选项 ${question['correct_choice']}'),
                          ],
                        ),
                      );
                    }).toList(),
                    SizedBox(height: 16),
                    Center(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PatientDetailPage(patientDetails: patientDetails),
                            ),
                          );
                        },
                        child: Text('查看病人答题详情'),
                      ),
                    ),
                    SizedBox(height: 16),
                    Center(
                      child: ElevatedButton(
                        onPressed: deleteSurvey,
                        child: Text('删除问卷'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red, // Use backgroundColor instead of primary
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
