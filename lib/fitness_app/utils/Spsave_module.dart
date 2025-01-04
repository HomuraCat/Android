import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../chat/chat_tool.dart';

class SpStorage {
  SpStorage._();

  static SpStorage? _storage;

  static SpStorage get instance {
    _storage = _storage ?? SpStorage._();
    return _storage!;
  }

  SharedPreferences? _sp;

  Future<void> initSpWhenNull() async {
    if (_sp != null) return;
    _sp = _sp ?? await SharedPreferences.getInstance();
  }

  Future<Map<String, dynamic>> readWeeklyTestConfig() async {
    await initSpWhenNull();
    String content = _sp!.getString('WeeklyTest-config') ?? "{}";
    return json.decode(content);
  }

  Future<Map<String, dynamic>?> readAccount() async {
    try {
      await initSpWhenNull();
      String content = _sp!.getString('Account-config') ?? "{}";
      return json.decode(content);
    } catch(e) {
      print('Error reading Account-config: $e');
      return null;
    }
  }

  Future<void> clearAccount() async {
    try {
      await _sp!.remove('Account-config');
      print('Account data cleared successfully');
    } catch (e) {
      print('Error clearing Account-config: $e');
    }
  }

  Future<List<Chat>> readChat({required String sendID, required String receiveID}) async {
    await initSpWhenNull();
    String content = _sp!.getString('Chat-${sendID}-${receiveID}') ?? "[]";
    
    // Convert the JSON string to a List<dynamic>
    List<dynamic> chatListJson = json.decode(content);

    // Convert the List<dynamic> to a List<Chat>
    return chatListJson.map((jsonItem) => Chat(
      message: jsonItem['message'],
      send_type: ChatMessageType.values.firstWhere((e) => e.toString() == jsonItem['send_type']),
      message_type: ChatMessageType.values.firstWhere((e) => e.toString() == jsonItem['message_type']),
      time: DateTime.parse(jsonItem['time']))).toList();
  }
  //required String message, String type, DateTime time

  Future<bool> saveWeeklyTestConfig(
      {required bool submitstate,
      int? submityear,
      int? submitmonth,
      int? submitday}) async {
    await initSpWhenNull();
    String content = json.encode({
      'submitstate': submitstate,
      'submityear': submityear,
      'submitmonth': submitmonth,
      'submitday': submitday
    });
    return _sp!.setString('WeeklyTest-config', content);
  }

  Future<bool> saveAccount(
      {required String patientID,
      required String name,
      required bool identity}) async {
    await initSpWhenNull();
    String content = json.encode({
      'patientID': patientID,
      'name': name,
      'identity': identity
    });
    return _sp!.setString('Account-config', content);
  }

  Future<bool> saveChat(
      {required String sendID,
      required String receiveID,
      required List<Chat> chatList}) async {
    await initSpWhenNull();

    // Convert the List<Chat> to a List<Map<String, dynamic>>
    List<Map<String, dynamic>> chatListToSave = chatList.map((chat) => {
      'message': chat.message,
      'send_type': chat.send_type.toString(),
      'message_type': chat.message_type.toString(),
      'time': chat.time.toIso8601String(),
    }).toList();

    // Convert the List<Map<String, dynamic>> to a JSON string
    String content = json.encode(chatListToSave);
    return _sp!.setString('Chat-${sendID}-${receiveID}', content);
  }
}