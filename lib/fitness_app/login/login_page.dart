import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:best_flutter_ui_templates/fitness_app/fitness_app_home_screen.dart';
import 'package:best_flutter_ui_templates/fitness_app/fitness_app_home_screen_nurseside.dart';
import '../utils/Spsave_module.dart';
import '../../config.dart';
import 'package:best_flutter_ui_templates/fitness_app/login/register_page.dart';

Future<void> registerUser(
    String email, String password, bool my_status, BuildContext context) async {
  // 根据 my_status 选择不同的 API 路由
  final String apiUrl = my_status ? Config.baseUrl + '/login' : Config.baseUrl + '/nurse_login';
  var url = Uri.parse(apiUrl);

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
    var responseData = response.body;

    if (responseData == "2") {
      _showDialog(context, '用户不存在！');
    } else if (responseData == "0") {
      _showDialog(context, '用户或密码错误！');
    } else {
      List<String> user_data = responseData.toString().split("+-*/");
      SpStorage.instance
          .saveAccount(patientID: user_data[0], name: user_data[1]);

      if (my_status) {
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => FitnessAppHomeScreen()));
      } else {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => FitnessAppHomeScreenNurseSide()));
      }
    }
  } else {
    print('Request failed with status: ${response.statusCode}.');
    _showDialog(context, '网络请求失败，请稍后重试！'); // 可选：向用户显示网络错误
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
  const LoginPage({Key? key, required this.title, required this.status})
      : super(key: key);
  final String title;
  final bool status;

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
            if (widget.status) buildForgetPasswordText(),
            const SizedBox(height: 70),
            if (widget.status) buildRegisterButton(),
            if (widget.status) const SizedBox(height: 20),
            buildLoginButton(widget.status),
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

  buildForgetPasswordText() {
    return Align(
      alignment: Alignment.centerRight,
      child: CupertinoButton(
        child: Text(
          '忘记密码？',
          style: TextStyle(fontSize: 14, color: CupertinoColors.systemBlue),
        ),
        onPressed: () {
          _showForgotPasswordDialog(context); // 触发弹窗
        },
      ),
    );
  }

  Column buildRegisterButton() {
    return Column(
      children: [
        SizedBox(
          height: 56,
          width: double.infinity,
          child: CupertinoButton(
            child: Text('注册'),
            color: CupertinoColors.black,
            borderRadius: BorderRadius.circular(8),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        RegistrationPage()), // Changed to RegisterPage to match import
              );
            },
          ),
        ),
      ],
    );
  }

  Column buildLoginButton(my_status) {
    return Column(
      children: [
        SizedBox(
          height: 56,
          width: double.infinity,
          child: CupertinoButton(
            child: Text('登录'),
            color: CupertinoColors.activeBlue,
            borderRadius: BorderRadius.circular(8),
            onPressed: () {
              if (_formKey.currentState?.validate() ?? false) {
                _formKey.currentState?.save();
                registerUser(_email, _password, my_status, context);
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
              SpStorage.instance
                  .saveAccount(patientID: "15500000000", name: "测试人员");
              if (my_status)
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => FitnessAppHomeScreen()),
                );
              else
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => FitnessAppHomeScreenNurseSide()),
                );
            },
          ),
        ),
      ],
    );
  }
}

void _showForgotPasswordDialog(BuildContext context) {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController idController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  showCupertinoDialog(
    context: context,
    builder: (BuildContext context) {
      return CupertinoAlertDialog(
        title: Text("忘记密码"),
        content: Column(
          children: <Widget>[
            CupertinoTextField(
              controller: nameController,
              placeholder: "请输入姓名",
            ),
            SizedBox(height: 10),
            CupertinoTextField(
              controller: phoneController,
              placeholder: "请输入手机号",
              keyboardType: TextInputType.phone,
            ),
            SizedBox(height: 10),
            CupertinoTextField(
              controller: idController,
              placeholder: "请输入身份证号",
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 10),
            CupertinoTextField(
                controller: passwordController, placeholder: "请输入新密码")
          ],
        ),
        actions: <Widget>[
          CupertinoDialogAction(
            child: Text("取消"),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          CupertinoDialogAction(
            child: Text("确认"),
            onPressed: () {
              String name = nameController.text;
              String phone = phoneController.text;
              String idNumber = idController.text;
              String newPassword = passwordController.text;

              if (name.isEmpty || phone.isEmpty || idNumber.isEmpty) {
                _showDialog(context, "请填写所有字段！");
              } else {
                // Call the password reset function with provided details
                resetPassword(name, phone, idNumber, newPassword, context);
              }
            },
          ),
        ],
      );
    },
  );
}

Future<void> resetPassword(String name, String phone, String idNumber,
    String newPassword, BuildContext context) async {
  final String apiUrl = Config.baseUrl + '/resetPassword';
  var url = Uri.parse(apiUrl);

  var response = await http.post(
    url,
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: jsonEncode(<String, String>{
      'name': name,
      'phone': phone,
      'idNumber': idNumber,
      'new_password': newPassword
    }),
  );

  if (response.body == '200') {
    // First, close the 忘记密码 dialog
    Navigator.of(context).pop();

    // Then show the success message
    _showDialog(context, '密码重置成功！');
  } else {
    // If it fails, we can directly show the failure message
    _showDialog(context, '密码重置失败，请检查输入是否正确！');
  }
}
