import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'patient_detail_page.dart'; 
import '../../config.dart';

class SurveyDetailPage extends StatefulWidget {
  final int surveyId;

  SurveyDetailPage({required this.surveyId});

  @override
  _SurveyDetailPageState createState() => _SurveyDetailPageState();
}

class _SurveyDetailPageState extends State<SurveyDetailPage> {
  Map<String, dynamic>? survey;
  List questions = [];
  List patientDetails = [];

  @override
  void initState() {
    super.initState();
    fetchSurveyData();
  }

  Future<void> fetchSurveyData() async {
    await fetchSurveyDetails();
    await fetchPatientAnswers();
  }

  Future<void> fetchSurveyDetails() async {
    final String apiUrl = Config.baseUrl + '/surveys/${widget.surveyId}';
    var url = Uri.parse(apiUrl);
    var response = await http.get(url);

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      setState(() {
        survey = data['survey'];
        questions = data['questions'];
      });
    } else {
      throw Exception('Failed to load survey details');
    }
  }

  Future<void> fetchPatientAnswers() async {
    final String patientApiUrl = Config.baseUrl + '/surveys/${widget.surveyId}/patient_answers';
    var patientUrl = Uri.parse(patientApiUrl);
    var patientResponse = await http.get(patientUrl);

    if (patientResponse.statusCode == 200) {
      var pdata = jsonDecode(patientResponse.body);
      setState(() {
        patientDetails = pdata['patient_details'];
      });
    } else {
      throw Exception('Failed to load patient details');
    }
  }

  Future<void> deleteSurvey() async {
    final String apiUrl = Config.baseUrl + '/surveys/${widget.surveyId}';
    var url = Uri.parse(apiUrl);
    var response = await http.delete(url);

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Survey deleted successfully')));
      Navigator.pop(context, true);
    } else {
      throw Exception('Failed to delete survey');
    }
  }

  Widget buildQuestionItem(Map<String, dynamic> question) {
    String questionText = question['question'];
    String questionType = question['question_type'];

    return ListTile(
      title: Text(questionText,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (questionType == 'multiple_choice' && question['choices'] != null)
            ...List.generate(question['choices'].length, (index) {
              return Text('选项 ${index + 1}: ${question['choices'][index]}');
            }),
          if (questionType == 'fill_in_the_blank')
            Text('（填空题，无答案）', style: TextStyle(color: Colors.grey))
        ],
      ),
    );
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
                    Text('标题: ${survey!['title']}',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    SizedBox(height: 8),
                    Text('描述: ${survey!['description']}'),
                    SizedBox(height: 8),
                    Text('预计发布时间: ${survey!['scheduled_start_time']}'),
                    SizedBox(height: 8),
                    Text('预计结束时间: ${survey!['scheduled_end_time']}'),
                    SizedBox(height: 16),
                    Text('问题列表:',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    ...questions.map((q) => buildQuestionItem(q)).toList(),
                    SizedBox(height: 16),
                    Center(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PatientDetailPage(
                                patientDetails: patientDetails,
                                surveyId: widget.surveyId,
                              ),
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
                          backgroundColor: Colors.red,
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
