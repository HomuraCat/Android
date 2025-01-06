import 'package:flutter/material.dart';
import 'package:best_flutter_ui_templates/fitness_app/utils/Spsave_module.dart';

class FontScaleNotifier extends ChangeNotifier {
  double _fontScale = 1.0; 
  double get fontScale => _fontScale;

  // 在初始化时，把本地存储的 fontScale 读出来
  Future<void> initFontScale() async {
    double? storedValue = await SpStorage.instance.readDouble('fontScale');
    _fontScale = storedValue ?? 1.0;
  }

  // 修改字体大小并保存
  Future<void> updateFontScale(double newValue) async {
    _fontScale = newValue;
    notifyListeners();  // 通知刷新UI
    // 存到本地
    await SpStorage.instance.saveDouble('fontScale', newValue);
  }
}
