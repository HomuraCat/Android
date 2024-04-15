import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:best_flutter_ui_templates/fitness_app/fitness_app_home_screen.dart';
import '../utils/Spsave_module.dart';

Future<void> registerUser(
    String email, String password, BuildContext context) async {
  var url = Uri.parse('http://10.0.2.2:5001/login');

  var response = await http.post(
    url,
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: jsonEncode(<String, String>{
      'username': email,
      'password': password,
    }),
  );

  if (response.statusCode == 200) {
    var responseData = jsonDecode(response.body);

    if (responseData == 2) {
      _showDialog(context, '用户不存在！');
    } else if (responseData == 0) {
      _showDialog(context, '用户或密码错误！');
    } else{
      SpStorage.instance.saveAccount(
                        patientID: "0",
                        name: "testing");
      Navigator.pushNamed(context, "/app");
    }
  } else {
    print('Request failed with status: ${response.statusCode}.');
  }
}

void _showDialog(BuildContext context, String message) {
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
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late String _email, _password;
  bool _isObscure = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Form(
        key: _formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 22),
          children: [
            const SizedBox(height: 100),
            buildTitle(),
            buildTitleLine(),
            const SizedBox(height: 70),
            buildEmailTextField(),
            const SizedBox(height: 30),
            buildPasswordTextField(),
            buildForgetPasswordText(),
            const SizedBox(height: 70),
            buildLoginButton(),
          ],
        ),
      ),
    );
  }

  Padding buildTitle() {
    return const Padding(
      padding: EdgeInsets.all(8),
      child: Text(
        '登录',
        style: TextStyle(fontSize: 42, fontWeight: FontWeight.bold),
      ),
    );
  }

  Padding buildTitleLine() {
    return Padding(
      padding: const EdgeInsets.only(left: 12.0, top: 4.0),
      child: Align(
        alignment: Alignment.bottomLeft,
        child: Container(
          color: CupertinoColors.systemGrey,
          width: 70,
          height: 2,
        ),
      ),
    );
  }

  TextFormField buildEmailTextField() {
    return TextFormField(
      keyboardType: TextInputType.emailAddress,
      decoration: InputDecoration(
        labelText: '账号',
        labelStyle: TextStyle(color: CupertinoColors.systemGrey),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: CupertinoColors.systemGrey2),
          borderRadius: BorderRadius.circular(8.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: CupertinoColors.activeBlue),
          borderRadius: BorderRadius.circular(8.0),
        ),
        prefixIcon: Icon(
          CupertinoIcons.mail, // 邮件图标
          color: CupertinoColors.black,
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return '请输入有效的账号地址';
        }
        return null;
      },
      onSaved: (value) => _email = value ?? '',
    );
  }

  TextFormField buildPasswordTextField() {
    return TextFormField(
      obscureText: _isObscure,
      decoration: InputDecoration(
        labelText: '密码',
        labelStyle: TextStyle(color: CupertinoColors.systemGrey),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: CupertinoColors.systemGrey2),
          borderRadius: BorderRadius.circular(8.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: CupertinoColors.activeBlue),
          borderRadius: BorderRadius.circular(8.0),
        ),
        prefixIcon: Icon(
          CupertinoIcons.lock, // 锁图标
          color: CupertinoColors.black,
        ),
        suffixIcon: GestureDetector(
          onTap: () {
            setState(() {
              _isObscure = !_isObscure;
            });
          },
          child: Icon(
            _isObscure ? CupertinoIcons.eye : CupertinoIcons.eye_slash,
            color: CupertinoColors.systemGrey,
          ),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return '请输入密码';
        }
        return null;
      },
      onSaved: (value) => _password = value ?? '',
    );
  }

  Align buildForgetPasswordText() {
    return Align(
      alignment: Alignment.centerRight,
      child: CupertinoButton(
        child: Text(
          '忘记密码？',
          style: TextStyle(fontSize: 14, color: CupertinoColors.systemBlue),
        ),
        onPressed: () {
          // Implement forgot password functionality
        },
      ),
    );
  }

  Column buildLoginButton() {
    return Column(
      children: [
        SizedBox(
          height: 56,
          width: double.infinity,
          child: CupertinoButton(
            child: Text('登录'),
            color: CupertinoColors.black,
            borderRadius: BorderRadius.circular(8),
            onPressed: () {
              if (_formKey.currentState?.validate() ?? false) {
                _formKey.currentState?.save();
                registerUser(_email, _password, context);
              }
            },
          ),
        ),
        SizedBox(height: 20),
        SizedBox(
          height: 56,
          width: double.infinity,
          child: CupertinoButton(
            child: Text(
              'Debug 登录',
              style: TextStyle(color: CupertinoColors.white),
            ),
            color: CupertinoColors.activeBlue,
            borderRadius: BorderRadius.circular(8),
            onPressed: () {
              // Assuming this code is within a Widget that has a BuildContext
              SpStorage.instance.saveAccount(
                        patientID: "114514",
                        name: "测试人员");
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => FitnessAppHomeScreen()),
              );
            },
          ),
        ),
      ],
    );
  }
}
