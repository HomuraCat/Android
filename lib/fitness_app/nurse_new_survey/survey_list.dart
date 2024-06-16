import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'new_survey_page.dart';
import 'survey_detail_page.dart'; // Import the new detail page

class SurveyListPage extends StatefulWidget {
  @override
  _SurveyListPageState createState() => _SurveyListPageState();
}

class _SurveyListPageState extends State<SurveyListPage> {
  List surveys = [];

  @override
  void initState() {
    super.initState();
    fetchSurveys();
  }

  Future<void> fetchSurveys() async {
    var url = Uri.parse('http://10.0.2.2:5001/surveys');
    var response = await http.get(url);

    if (response.statusCode == 200) {
      setState(() {
        surveys = jsonDecode(response.body);
      });
    } else {
      throw Exception('Failed to load surveys');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('问卷列表')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => NewSurveyPage()),
                ).then((_) {
                  fetchSurveys(); // Refresh the list after returning
                });
              },
              child: Text('创建新问卷'),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: surveys.length,
              itemBuilder: (context, index) {
                var survey = surveys[index];
                return ListTile(
                  title: Text(survey['title']),
                  subtitle: Text(survey['status']),
                  onTap: () async {
                    var result = await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => SurveyDetailPage(surveyId: survey['survey_id'])),
                    );
                    if (result == true) {
                      fetchSurveys(); // Refresh the list if a survey was deleted
                    }
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
