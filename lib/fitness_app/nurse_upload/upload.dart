import 'package:flutter/material.dart';
import 'upload_exercise_suggestion_page.dart';
import 'upload_recipe_recommendation_page.dart';
import 'upload_knowledge_learning_page.dart';

class UploadPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('上传'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => UploadExerciseSuggestionPage()),
                );
              },
              child: Text('上传运动建议'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => UploadRecipeRecommendationPage()),
                );
              },
              child: Text('上传食谱推荐'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => UploadKnowledgeLearningPage()),
                );
              },
              child: Text('上传知识学习'),
            ),
          ],
        ),
      ),
    );
  }
}
