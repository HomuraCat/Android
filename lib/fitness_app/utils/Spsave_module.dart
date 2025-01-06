import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../chat/chat_tool.dart';

class SpStorage {
  SpStorage._();

  static SpStorage? _storage;
  static SpStorage get instance {
    _storage ??= SpStorage._();
    return _storage!;
  }

  SharedPreferences? _sp;

  /// 初始化 SharedPreferences（仅在第一次调用时执行）
  Future<void> initSpWhenNull() async {
    if (_sp == null) {
      _sp = await SharedPreferences.getInstance();
    }
  }

  //=================== 新增的读写 double 方法 ===================//
  Future<void> saveDouble(String key, double value) async {
    await initSpWhenNull();
    await _sp!.setDouble(key, value);
  }

  Future<double?> readDouble(String key) async {
    await initSpWhenNull();
    return _sp!.getDouble(key);
  }
  //========================================================//

  /// 读取每周测试配置
  Future<Map<String, dynamic>> readWeeklyTestConfig() async {
    await initSpWhenNull();
    String content = _sp!.getString('WeeklyTest-config') ?? "{}";
    return json.decode(content);
  }

  /// 读取账号信息
  Future<Map<String, dynamic>?> readAccount() async {
    try {
      await initSpWhenNull();
      String content = _sp!.getString('Account-config') ?? "{}";
      return json.decode(content);
    } catch (e) {
      print('Error reading Account-config: $e');
      return null;
    }
  }

  /// 清除账号
  Future<void> clearAccount() async {
    try {
      await initSpWhenNull();
      await _sp!.remove('Account-config');
      print('Account data cleared successfully');
    } catch (e) {
      print('Error clearing Account-config: $e');
    }
  }

  /// 读取聊天记录
  Future<List<Chat>> readChat({
    required String sendID,
    required String receiveID,
  }) async {
    await initSpWhenNull();
    String content = _sp!.getString('Chat-$sendID-$receiveID') ?? "[]";

    // Convert the JSON string to a List<dynamic>
    List<dynamic> chatListJson = json.decode(content);

    // Convert the List<dynamic> to a List<Chat>
    return chatListJson.map((jsonItem) {
      return Chat(
        message: jsonItem['message'],
        send_type: ChatMessageType.values
            .firstWhere((e) => e.toString() == jsonItem['send_type']),
        message_type: ChatMessageType.values
            .firstWhere((e) => e.toString() == jsonItem['message_type']),
        time: DateTime.parse(jsonItem['time']),
      );
    }).toList();
  }

  /// 保存每周测试配置
  Future<bool> saveWeeklyTestConfig({
    required bool submitstate,
    int? submityear,
    int? submitmonth,
    int? submitday,
  }) async {
    await initSpWhenNull();
    String content = json.encode({
      'submitstate': submitstate,
      'submityear': submityear,
      'submitmonth': submitmonth,
      'submitday': submitday,
    });
    return _sp!.setString('WeeklyTest-config', content);
  }

  /// 保存账号
  Future<bool> saveAccount({
    required String patientID,
    required String name,
    required bool identity,
    String avatar = "assets/images/avatar1.png",
  }) async {
    await initSpWhenNull();
    String content = json.encode({
      'patientID': patientID,
      'name': name,
      'identity': identity,
      'avatar': avatar,
    });
    return _sp!.setString('Account-config', content);
  }

  /// 保存聊天记录
  Future<bool> saveChat({
    required String sendID,
    required String receiveID,
    required List<Chat> chatList,
  }) async {
    await initSpWhenNull();

    // Convert the List<Chat> to a List<Map<String, dynamic>>
    List<Map<String, dynamic>> chatListToSave = chatList.map((chat) {
      return {
        'message': chat.message,
        'send_type': chat.send_type.toString(),
        'message_type': chat.message_type.toString(),
        'time': chat.time.toIso8601String(),
      };
    }).toList();

    // Convert the List<Map<String, dynamic>> to a JSON string
    String content = json.encode(chatListToSave);
    return _sp!.setString('Chat-$sendID-$receiveID', content);
  }
}
