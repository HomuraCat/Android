import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationHelper {
  static final NotificationHelper _instance = NotificationHelper._internal();
  factory NotificationHelper() => _instance;
  NotificationHelper._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings();
    
    const InitializationSettings initializationSettings =
        InitializationSettings(
            android: initializationSettingsAndroid,
            iOS: initializationSettingsIOS);
    await _notificationsPlugin.initialize(initializationSettings);
  }

  Future<void> showNotification(
      {required String title, required String body}) async {
    AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails("0", "undefined",
            channelDescription: title,
            importance: Importance.max,
            priority: Priority.high,
            ticker: body);

    const String darwinNotificationCategoryPlain = 'plainCategory';
    const DarwinNotificationDetails iosNotificationDetails =
        DarwinNotificationDetails(
      categoryIdentifier: darwinNotificationCategoryPlain,
    );
    NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidNotificationDetails,iOS: iosNotificationDetails);

    await _notificationsPlugin.show(
      1,
      title,
      body,
      platformChannelSpecifics,
    );
  }
}

class ChildPage extends StatelessWidget {
  final String title;
  ChildPage({this.title = ""});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text('$title'),
      ),
      body: Center(
        child: Text('$title'),
      ),
    );
  }
}

class SelectQuestion extends StatefulWidget {
  const SelectQuestion(
      {Key? key,
      required this.submitstate,
      required this.question,
      required this.choose1,
      required this.choose2,
      required this.choose3,
      required this.choose4})
      : super(key: key);
  final String question, choose1, choose2, choose3, choose4;
  final bool submitstate;

  @override
  State<SelectQuestion> createState() => _SelectQuestionState();
}

class _SelectQuestionState extends State<SelectQuestion> {
  int _selectedValue = 1;

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Row(children: [
        Expanded(
            child: Text(
          widget.question,
          textAlign: TextAlign.left,
          style: TextStyle(fontSize: 18),
          maxLines: 4,
          overflow: TextOverflow.ellipsis,
        ))
      ]),
      Row(children: [
        Radio(
            value: 1,
            groupValue: _selectedValue,
            onChanged: widget.submitstate ? null : (value) {
              setState(() {
                _selectedValue = value as int;
              });
            }),
        Text(
          widget.choose1,
          style: TextStyle(fontSize: 18),
        )
      ]),
      Row(children: [
        Radio(
            value: 2,
            groupValue: _selectedValue,
            onChanged: widget.submitstate ? null : (value) {
              setState(() {
                _selectedValue = value as int;
              });
            }),
        Text(
          widget.choose2,
          style: TextStyle(fontSize: 18),
        )
      ]),
      Row(children: [
        Radio(
            value: 3,
            groupValue: _selectedValue,
            onChanged: widget.submitstate ? null : (value) {
              setState(() {
                _selectedValue = value as int;
              });
            }),
        Text(
          widget.choose3,
          style: TextStyle(fontSize: 18),
        )
      ]),
      Row(children: [
        Radio(
            value: 4,
            groupValue: _selectedValue,
            onChanged: widget.submitstate ? null : (value) {
              setState(() {
                _selectedValue = value as int;
              });
            }),
        Text(
          widget.choose4,
          style: TextStyle(fontSize: 18),
        )
      ])
    ]);
  }
}