import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter/cupertino.dart';
import '../utils/Spsave_module.dart';
import 'package:best_flutter_ui_templates/fitness_app/login/welcome_view.dart';
import 'package:provider/provider.dart';
import '../utils/font_scale_notifier.dart';

class NurseSettingPage extends StatefulWidget {
  const NurseSettingPage({Key? key}) : super(key: key);

  @override
  State<NurseSettingPage> createState() => _NurseSettingPageState();
}

class _NurseSettingPageState extends State<NurseSettingPage> {

  Widget _buildFontSlider() {
    // 从 Provider 获取当前字体倍数
    final fontScaleNotifier = Provider.of<FontScaleNotifier>(context);
    final currentScale = fontScaleNotifier.fontScale;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('字体大小：${currentScale.toStringAsFixed(1)} 倍'),
        Slider(
          value: currentScale,
          min: 0.8,
          max: 2.0,
          divisions: 12, // 间隔设置，可按需修改
          onChanged: (value) {
            // 1. 实时更新全局字体倍数（从而让整个App实时刷新）
            fontScaleNotifier.updateFontScale(value);
          },
          onChangeEnd: (value) async {
            // 2. 松手后，再存到本地 (SpStorage)
            await SpStorage.instance.saveDouble('fontScale', value);
          },
        ),
      ],
    );
  }
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
            const SizedBox(height: 40),
            _buildFontSlider(),
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