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
  late String _temperature,
      high_pressure,
      low_pressure,
      medication_type,
      medication_dosage,
      last_time = "";
  
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
            
            const SizedBox(height: 60),
            buildSubmitButton(context),
            const SizedBox(height: 60),
          ],
        ),
      ),
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
        'name': 'testing',
        'type': 'daily_report'
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