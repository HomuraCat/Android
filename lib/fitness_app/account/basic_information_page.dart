import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';
import 'package:flutter/cupertino.dart';

class BasicInforPage extends StatefulWidget {
  const BasicInforPage({Key? key}) : super(key: key);

  @override
  State<BasicInforPage> createState() => _BasicInforPageState();
}

class _BasicInforPageState extends State<BasicInforPage> {
  final GlobalKey _formKey = GlobalKey<FormState>();
  late String name,
      age;
  int gender = 1;
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text('基本信息'),
      ),
      body: Form(
        key: _formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          children: [
            buildIndividualInforTitle(),
            const SizedBox(height: 10),
            buildNameField(),
            const SizedBox(height: 10),
            buildGenderField(),
            const SizedBox(height: 10),
            buildAgeField(),
            const SizedBox(height: 60),
            buildSubmitButton(context),
            const SizedBox(height: 60),
          ],
        ),
      ),
    );
  }

  Widget buildNameField() {
    return TextFormField(
      decoration: const InputDecoration(
          contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 10),
          border: OutlineInputBorder(),
          labelText: '姓名'),
      validator: (v) {
        if (v!.isEmpty) {
          return '请输入姓名';
        }
      },
      onSaved: (v) => name = v!,
    );
  }

  Widget buildIndividualInforTitle() {
    return const Padding(
        padding: EdgeInsets.only(bottom: 5),
        child: Text(
          '个人信息',
          style: TextStyle(fontSize: 20),
        ));
  }

  Widget buildGenderField() {
    return Row(children: [
      const SizedBox(width: 8),
      Text(
        '性别',
        style: TextStyle(fontSize: 18),
      ),
      const SizedBox(width: 50),
      Text(
        '男',
        style: TextStyle(fontSize: 18),
      ),
      Radio(
          value: 1,
          groupValue: gender,
          onChanged: (value) {
            setState(() {
              gender = value as int;
            });
          }),
      Text(
        '女',
        style: TextStyle(fontSize: 18),
      ),
      Radio(
          value: 2,
          groupValue: gender,
          onChanged: (value) {
            setState(() {
              gender = value as int;
            });
          })
    ]);
  }

    Widget buildAgeField() {
    return TextFormField(
      decoration: const InputDecoration(
          contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 10),
          border: OutlineInputBorder(),
          labelText: '年龄'),
      validator: (v) {
        var ageReg = RegExp(r"^[0-9]+");
        if (!ageReg.hasMatch(v!)) {
          return '请正确输入年龄';
        }
      },
      onSaved: (v) => name = v!,
    );
  }

  Widget buildSubmitButton(BuildContext context) {
    return Align(
      child: SizedBox(
        height: 35,
        width: 150,
        child: FloatingActionButton(
          backgroundColor: Colors.black,
          child: Text('提交',
              style: Theme.of(context).primaryTextTheme.headlineSmall),
          onPressed: () {
                  if ((_formKey.currentState as FormState).validate()) {
                    (_formKey.currentState as FormState).save();
                    SendBasicInformation(context);
                  }
                },
        ),
      ),
    );
  }

  Future<void> SendBasicInformation(BuildContext context) async {
    var url = Uri.parse('http://10.0.2.2:5001/questionnaire/send');

    var response = await http.post(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'name': name,
        'gender': (gender==1)?"男":"女",
        'age': age
      }),
    );

    if (response.statusCode == 200) {
      var responseData = jsonDecode(response.body);
      if (responseData == 1) {
        _showDialog(context, '提交成功！', onDialogClose: () {
          Navigator.pop(context);
        });
      }
    } else print('Request failed with status: ${response.statusCode}.');
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
}