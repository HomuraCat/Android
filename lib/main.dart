import 'dart:io';
import 'package:best_flutter_ui_templates/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

// 假设这里就是你的本地存储操作类
import 'package:provider/provider.dart'; 
import 'fitness_app/utils/Spsave_module.dart';
import 'fitness_app/utils/common_tools.dart';
import 'fitness_app/utils/font_scale_notifier.dart'; 

import 'package:best_flutter_ui_templates/fitness_app/fitness_app_home_screen.dart';
import 'package:best_flutter_ui_templates/fitness_app/fitness_app_home_screen_nurseside.dart';
import 'package:best_flutter_ui_templates/fitness_app/login/welcome_view.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. 先读取账号信息和字体倍数
  NotificationHelper notificationHelper = NotificationHelper();
  Map<String, dynamic>? account = await SpStorage.instance.readAccount();
  
  // 初始化账号身份
  int my_status = 0;
  if (account != null && account.containsKey('identity')) {
    // identity == true => 1, else => 2
    my_status = (account['identity'] == true) ? 1 : 2;
  }


  // 初始化通知
  await notificationHelper.initialize();

  // 锁定竖屏
  await SystemChrome.setPreferredOrientations(<DeviceOrientation>[
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown
  ]);
  final fontScaleNotifier = FontScaleNotifier();
  await fontScaleNotifier.initFontScale();

  // 2. 运行App并把 fontScale 传给MyApp
  runApp(
    ChangeNotifierProvider<FontScaleNotifier>.value(
      value: fontScaleNotifier,
      child: MyApp(status: my_status),
    ),
  );
}

class MyApp extends StatelessWidget {
  final int? status;

  const MyApp({
    Key? key,
    this.status,
  }) : super(key: key);

  Widget getHomePage() {
    switch (status) {
      case 0:
        return const WelcomeView();
      case 1:
        return  FitnessAppHomeScreen();
      case 2:
        return FitnessAppHomeScreenNurseSide();
      default:
        return const Center(child: Text("无效的账号状态，请检查数据"));
    }
  }

  @override
  Widget build(BuildContext context) {
    // 设置系统UI样式
    final fontScale = Provider.of<FontScaleNotifier>(context).fontScale;
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness:
          !kIsWeb && Platform.isAndroid ? Brightness.dark : Brightness.light,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarDividerColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.dark,
    ));

    // 3. 在MaterialApp里，通过builder使用MediaQuery覆盖 textScaleFactor
    return MaterialApp(
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: [
        const Locale('en', 'US'), // 英语
        const Locale('zh', 'CN'), // 中文
      ],
      title: 'Flutter UI',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        textTheme: AppTheme.textTheme,
        platform: TargetPlatform.iOS,
      ),
      home: getHomePage(),
            builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaleFactor: fontScale,
          ),
          child: child!,
        );
      },
    );
  }
}

// 颜色辅助类
class HexColor extends Color {
  HexColor(final String hexColor) : super(_getColorFromHex(hexColor));

  static int _getColorFromHex(String hexColor) {
    hexColor = hexColor.toUpperCase().replaceAll('#', '');
    if (hexColor.length == 6) {
      hexColor = 'FF' + hexColor;
    }
    return int.parse(hexColor, radix: 16);
  }
}
