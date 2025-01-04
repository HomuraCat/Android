import 'dart:io';
import 'package:best_flutter_ui_templates/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'fitness_app/utils/common_tools.dart';
import 'fitness_app/utils/Spsave_module.dart';
import 'package:best_flutter_ui_templates/fitness_app/fitness_app_home_screen.dart';
import 'package:best_flutter_ui_templates/fitness_app/fitness_app_home_screen_nurseside.dart';

import 'package:best_flutter_ui_templates/fitness_app/login/welcome_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  NotificationHelper notificationHelper = NotificationHelper();
  Map<String, dynamic>? account = await SpStorage.instance.readAccount();
  int my_status = 0;
  print(account);
  if (account != null){
    if (account.containsKey('identity')) {
      if (account['identity'] == true) my_status = 1;
        else my_status = 2;
    }
  }
  await notificationHelper.initialize();
  await SystemChrome.setPreferredOrientations(<DeviceOrientation>[
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown
  ]).then((_) => runApp(MyApp(status: my_status)));
}

class MyApp extends StatelessWidget {
  final int? status;

  const MyApp({Key? key, this.status}) : super(key: key);

  Widget getHomePage() {
      switch (status) {
        case 0:
          return WelcomeView();
        case 1:
          return FitnessAppHomeScreen();
        case 2:
          return FitnessAppHomeScreenNurseSide();
        default:
          return Center(child: Text("无效的账号状态，请检查数据"));
      }
    }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness:
          !kIsWeb && Platform.isAndroid ? Brightness.dark : Brightness.light,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarDividerColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.dark,
    ));
    return MaterialApp(
      title: 'Flutter UI',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        textTheme: AppTheme.textTheme,
        platform: TargetPlatform.iOS,
      ),
      home: getHomePage(),
    );
  }
}

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
