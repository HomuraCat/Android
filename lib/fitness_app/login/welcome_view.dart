import 'package:flutter/material.dart';
import 'package:best_flutter_ui_templates/fitness_app/login/login_page.dart';
import 'package:best_flutter_ui_templates/fitness_app/login/register_page.dart';

class WelcomeView extends StatelessWidget {
  const WelcomeView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: MediaQuery.of(context).size.height * 0.1),
              Image.asset(
                'assets/introduction_animation/welcome.png',
                fit: BoxFit.contain,
                width: MediaQuery.of(context).size.width * 0.8,
              ),
              SizedBox(height: 24),
              Text(
                "Welcome",
                style: TextStyle(fontSize: 25.0, fontWeight: FontWeight.bold),
              ),
              Padding(
                padding: const EdgeInsets.all(32.0),
                child: Text(
                  "Stay organised and live stress-free with you-do app",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18),
                ),
              ),
              SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            RegistrationPage()), // Changed to RegisterPage to match import
                  );
                },
                child: Text('Sign Up'),
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                  backgroundColor: Colors.black, // Background color
                  foregroundColor: Colors.white, // Text color
                  elevation: 4.0, // Shadow depth
                ),
              ),
              SizedBox(height: 12),
              OutlinedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => LoginPage(title: "登录")),
                  );
                },
                child: Text('Login'),
                style: OutlinedButton.styleFrom(
                  minimumSize: Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                  side: BorderSide(color: Colors.black),
                  foregroundColor: Colors.black, // Text color
                ),
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.1),
            ],
          ),
        ),
      ),
    );
  }
}
