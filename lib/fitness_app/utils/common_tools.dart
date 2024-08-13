import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationHelper {
  static final NotificationHelper _instance = NotificationHelper._internal();
  factory NotificationHelper() => _instance;
  NotificationHelper._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    await _requestPermissions();

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    
    const InitializationSettings initializationSettings =
        InitializationSettings(
            android: initializationSettingsAndroid);
    
    await _notificationsPlugin.initialize(initializationSettings);
    tz.initializeTimeZones();
  }

  Future<void> _requestPermissions() async {
    final notification_status = await Permission.notification.status;
    if (notification_status != PermissionStatus.granted) {
      await Permission.notification.request();
    }
    final exactAlarmStatus = await Permission.scheduleExactAlarm.status;
    if (exactAlarmStatus != PermissionStatus.granted) {
      await Permission.scheduleExactAlarm.request();
    }
  }

  Future<void> scheduleNotification({
    required int notificationId,
    required String title,
    required String body,
    required int hour,
    required int minute,
  }) async {
    const AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
          "daily_medical_channel",
          "吃药通知",
          channelDescription: "吃药通知频道",
          importance: Importance.max,
          priority: Priority.high,
          ticker: '吃药通知'
        );

    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidNotificationDetails);

    final tz.TZDateTime scheduledTime = _nextInstance(hour, minute);

    await _notificationsPlugin.zonedSchedule(
      notificationId,
      title,
      body,
      scheduledTime,
      platformChannelSpecifics,
      androidAllowWhileIdle: true,
      matchDateTimeComponents: DateTimeComponents.time,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  Future<void> showChatMessageNotification({
    required int notificationId,
    required String title,
    required String message,
  }) async {
    const AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
          "chat_message_channel",
          "聊天消息通知",
          channelDescription: "聊天消息通知频道",
          importance: Importance.max,
          priority: Priority.high,
          ticker: '聊天消息'
        );

    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidNotificationDetails);

    await _notificationsPlugin.show(
      notificationId,
      title,
      message,
      platformChannelSpecifics,
    );
  }

  tz.TZDateTime _nextInstance(int hour, int minute) {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);

    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    return scheduledDate;
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