import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter/cupertino.dart';
import '../utils/Spsave_module.dart';
import 'package:best_flutter_ui_templates/fitness_app/login/welcome_view.dart';

class SettingPage extends StatefulWidget {
  const SettingPage({Key? key}) : super(key: key);

  @override
  State<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text('设置'),
      ),
      body: Form(
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          children: [
            const SizedBox(height: 60),
            buildDeleteButton(context),
            const SizedBox(height: 60),
          ],
        ),
      ),
    );
  }

  Future<void> DeleteIndividualInfo(BuildContext context) async {
    await SpStorage.instance.clearAccount();
    _showDialog(context, '已经退出登录！', onDialogClose: () {
        Navigator.pushAndRemoveUntil(context,
            MaterialPageRoute(builder: (context) => WelcomeView()),
            (Route<dynamic> route) => false
        );
    });
  }

  Widget buildDeleteButton(BuildContext context) {
    return Align(
      child: SizedBox(
        height: 40,
        width: 250,
        child: FloatingActionButton(
          backgroundColor: Colors.red,
          child: Text('退出该账号',
              style: Theme.of(context).primaryTextTheme.headlineSmall),
          onPressed: () {DeleteIndividualInfo(context);},
        ),
      ),
    );
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