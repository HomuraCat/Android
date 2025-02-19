import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

import '../utils/Spsave_module.dart';
import '../utils/font_scale_notifier.dart';
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
        title: const Text('设置', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
      ),
      body: Form(
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          children: [
            const SizedBox(height: 40),
            _buildFontSlider(),
            const SizedBox(height: 60),
            _buildDeleteButton(context),
            const SizedBox(height: 60),
          ],
        ),
      ),
    );
  }

  /// 构建字体大小调节的 Slider
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

  /// 退出账号按钮
  Widget _buildDeleteButton(BuildContext context) {
    return Align(
      child: SizedBox(
        height: 60,
        width: 300,
        child: FloatingActionButton(
          backgroundColor: Colors.red,
          child: Text(
            '退出该账号',
            style: Theme.of(context).primaryTextTheme.headlineSmall,
          ),
          onPressed: () {
            _deleteIndividualInfo(context);
          },
        ),
      ),
    );
  }

  /// 退出账号逻辑
  Future<void> _deleteIndividualInfo(BuildContext context) async {
    await SpStorage.instance.clearAccount();
    _showDialog(context, '已经退出登录！', onDialogClose: () {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const WelcomeView()),
        (Route<dynamic> route) => false,
      );
    });
  }

  /// 显示提示框
  void _showDialog(BuildContext context, String message,
      {VoidCallback? onDialogClose}) {
    showCupertinoDialog(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: const Text("Message"),
          content: Text(message),
          actions: <Widget>[
            CupertinoDialogAction(
              child: const Text("Close"),
              onPressed: () {
                Navigator.of(context).pop(); // 关闭弹窗
                onDialogClose?.call();
              },
            ),
          ],
        );
      },
    );
  }
}
