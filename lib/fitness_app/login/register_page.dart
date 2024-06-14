import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/cupertino.dart';
import 'package:best_flutter_ui_templates/fitness_app/login/login_page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Registration Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: RegistrationPage(),
    );
  }
}

class RegistrationPage extends StatefulWidget {
  @override
  _RegistrationPageState createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  final _formKey = GlobalKey<FormState>();
  String phoneNumber = '';
  String email = '';
  String password = '';
  String confirmPassword = '';
  String verificationCode = '';
  Future<void> sendVerificationCode(
      String phoneNumber, BuildContext context) async {
    var url = Uri.parse('http://10.0.2.2:5001/phone_ver');
    // print(phoneNumber);

    var response = await http.post(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'phone': phoneNumber,
      }),
    );

    if (response.statusCode == 200) {
      var responseData = jsonDecode(response.body);
      // Implement your logic based on the response data
      // print(responseData);
      if (responseData == 1) {
        _showDialog(context, '验证码已发送'); // Verification code sent
      } else if (responseData == 0) {
        _showDialog(context, '验证码发送失败'); // Failed to send verification code
      }
    } else {
      print('Request failed with status: ${response.statusCode}.');
    }
  }

  Future<void> registerUser(
      String username,
      String phoneNumber,
      String verificationCode,
      String password,
      String confirmPassword,
      BuildContext context) async {
    var url = Uri.parse('http://10.0.2.2:5001/register');
    // print(phoneNumber);

    var response = await http.post(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'email': email,
        'phone': phoneNumber,
        'code': verificationCode,
        'password': password,
        'confirm_password': confirmPassword
      }),
    );

    if (response.statusCode == 200) {
      var responseData = jsonDecode(response.body);
      if (responseData == 1) {
        _showDialog(context, '注册成功！', onDialogClose: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => LoginPage(title: "登录", status: true)),
          ); // Redirect to login page after dialog is closed
        });
      } else if (responseData == 0) {
        _showDialog(context, '注册失败,该手机或邮箱已被占用！');
      }
    } else {
      print('Request failed with status: ${response.statusCode}.');
    }
  }

  void _showDialog(BuildContext context, String message,
      {VoidCallback? onDialogClose}) {
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
                Navigator.of(context).pop(); // Close the dialog
                if (onDialogClose != null) {
                  onDialogClose(); // Call the callback if it's provided
                }
              },
            ),
          ],
        );
      },
    );
  }

  void showUserAgreement() {
    showCupertinoDialog(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: Text('用户协议'), // User Agreement
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(
                  '这里是用户协议的内容...', // Here is the content of the user agreement...
                ),
              ],
            ),
          ),
          actions: <Widget>[
            CupertinoDialogAction(
              child: Text('关闭'), // Close
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void showPrivacyPolicy() {
    showCupertinoDialog(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: Text('隐私政策'), // Privacy Policy
          content: CupertinoScrollbar(
            child: SingleChildScrollView(
              child: Text(
                '这里是隐私政策的内容...', // Here is the content of the privacy policy...
              ),
            ),
          ),
          actions: <Widget>[
            CupertinoDialogAction(
              child: Text('关闭'), // Close
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('用户注册'), // User Registration
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                TextFormField(
                  decoration: InputDecoration(
                    labelText: '请输入手机号', // Please enter your phone number
                  ),
                  onChanged: (value) => phoneNumber = value,
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '手机号不能为空'; // Phone number cannot be empty
                    }
                    // Regular expression to validate a Chinese phone number
                    String pattern =
                        r'^(13[0-9]|14[5|7]|15[0-3,5-9]|16[6]|17[0-8]|18[0-9]|19[8|9])\d{8}$';
                    RegExp regex = RegExp(pattern);
                    if (!regex.hasMatch(value)) {
                      return '请输入有效的手机号码'; // Please enter a valid phone number
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16.0),
                ElevatedButton(
                  onPressed: () {
                    sendVerificationCode(phoneNumber, context);
                  },
                  child: Text('获取验证码'), // Get verification code
                ),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: '请输入验证码', // Please enter verification code
                  ),
                  onChanged: (value) => verificationCode = value,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '验证码不能为空'; // Verification code cannot be empty
                    }
                    return null;
                  },
                ),
                // Email TextFormField
                TextFormField(
                  decoration: InputDecoration(
                    labelText: '邮箱', // Email
                  ),
                  keyboardType: TextInputType.emailAddress,
                  onChanged: (value) => email = value,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return null; // Email cannot be empty
                    }
                    // Simple email validation regex
                    String pattern = r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$';
                    RegExp regex = RegExp(pattern);
                    if (!regex.hasMatch(value)) {
                      return '请输入有效的邮箱地址'; // Please enter a valid email address
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16.0),
                // Password TextFormField
                TextFormField(
                  decoration: InputDecoration(
                    labelText: '设置密码', // Set password
                  ),
                  obscureText: true, // Use secure text for passwords.
                  onChanged: (value) => password = value,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '密码不能为空'; // Password cannot be empty
                    }
                    if (value.length < 8) {
                      return '密码长度至少为8个字符'; // Password must be at least 8 characters long
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16.0),

                // Confirm Password TextFormField
                TextFormField(
                  decoration: InputDecoration(
                    labelText: '确认密码', // Confirm password
                  ),
                  obscureText: true, // Use secure text for passwords.
                  onChanged: (value) => confirmPassword = value,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '请确认密码'; // Please confirm the password
                    }
                    if (value != password) {
                      return '两次输入的密码不匹配'; // The two passwords do not match
                    }
                    return null;
                  },
                ),
                SizedBox(height: 24.0),

                SizedBox(height: 24.0),
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      registerUser(email, phoneNumber, verificationCode,
                          password, confirmPassword, context);
                    }
                  },
                  child: Text('注册'), // Register
                ),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 16.0),
                  child: RichText(
                    text: TextSpan(
                      style: Theme.of(context).textTheme.bodyText2,
                      children: [
                        TextSpan(
                            text:
                                '注册即代表同意 '), // Registering signifies agreement to
                        TextSpan(
                          text: '用户协议 ',
                          style: TextStyle(color: Colors.blue),
                          recognizer: TapGestureRecognizer()
                            ..onTap = showUserAgreement,
                        ),
                        TextSpan(text: '和 '), // and
                        TextSpan(
                          text: '隐私政策',
                          style: TextStyle(color: Colors.blue),
                          recognizer: TapGestureRecognizer()
                            ..onTap = showPrivacyPolicy,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
