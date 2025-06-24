import 'package:flutter/material.dart';
import 'upload_exercise_suggestion_page.dart';
import 'upload_recipe_recommendation_page.dart';
import 'upload_knowledge_learning_page.dart';
import 'upload_point_shopping_page.dart';
import 'manage_recipes_page.dart';
import 'manage_exercise_suggestions_page.dart'; // <-- Import the new page
import 'manage_knowledge_learning_page.dart';
import 'manage_point_shopping_page.dart'; 

class UploadPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('上传与管理'),
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // --- Upload Buttons ---
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => UploadExerciseSuggestionPage()),
                      );
                    },
                    child: Text('上传运动建议'),
                    style: _buttonStyle(),
                  ),
                ),
                SizedBox(height: 24.0),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => UploadRecipeRecommendationPage()),
                      );
                    },
                    child: Text('上传食谱推荐'),
                    style: _buttonStyle(),
                  ),
                ),
                SizedBox(height: 24.0),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => UploadKnowledgeLearningPage()),
                      );
                    },
                    child: Text('上传知识学习'),
                    style: _buttonStyle(),
                  ),
                ),
                SizedBox(height: 24.0),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => UploadPointShoppingPage()),
                      );
                    },
                    child: Text('上传积分商城'),
                    style: _buttonStyle(),
                  ),
                ),
                SizedBox(height: 36.0), // Separator

                // --- Management Buttons ---
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: Icon(Icons.restaurant_menu), // Recipe icon
                    label: Text('管理食谱推荐'),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => ManageRecipesPage()),
                      );
                    },
                    style: _buttonStyle(isManageButton: true),
                  ),
                ),
                SizedBox(height: 24.0), // Spacing between manage buttons

                // --- NEW: Manage Exercise Suggestions Button ---
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: Icon(Icons.fitness_center), // Exercise icon
                    label: Text('管理运动建议'), // Chinese label
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => ManageVideosPage()), // Navigate to new page
                      );
                    },
                    style: _buttonStyle(isManageButton: true), // Use manage style
                  ),
                ),
                SizedBox(height: 24.0), 
                // --- End of Management Buttons ---
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: Icon(Icons.menu_book), // Knowledge icon
                    label: Text('管理知识学习'), // Chinese label
                    onPressed: () {
                      Navigator.push(
                        context,
                        // Navigate to the new page
                        MaterialPageRoute(builder: (context) => ManageKnowledgeLearningPage()),
                      );
                    },
                    style: _buttonStyle(isManageButton: true), // Pass context, use manage style
                  ),
                ),
                SizedBox(height: 24.0), // Spacing

                // --- NEW: Manage Point Shopping Button ---
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: Icon(Icons.shopping_cart), // Shopping cart icon
                    label: Text('管理积分商城'), // Chinese label
                    onPressed: () {
                      Navigator.push(
                        context,
                        // Navigate to the new page
                        MaterialPageRoute(builder: (context) => ManagePointShoppingPage()),
                      );
                    },
                    style: _buttonStyle(isManageButton: true), // Pass context, use manage style
                  ),
                ),
                SizedBox(height: 80.0), // Bottom padding
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Helper function for button style to avoid repetition
  ButtonStyle _buttonStyle({bool isManageButton = false}) {
    return ElevatedButton.styleFrom(
      foregroundColor: isManageButton ? Colors.white : null, // Text color
      backgroundColor: isManageButton ? Colors.blueGrey : null, // Button background color
      padding: EdgeInsets.symmetric(vertical: 16.0),
      textStyle: TextStyle(fontSize: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
    );
  }
}