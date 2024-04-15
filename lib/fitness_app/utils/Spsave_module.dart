import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

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

    Future<Map<String, dynamic>> readAccount() async {
    await initSpWhenNull();
    String content = _sp!.getString('Account-config') ?? "{}";
    return json.decode(content);
  }

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
      required String name}) async {
    await initSpWhenNull();
    String content = json.encode({
      'patientID': patientID,
      'name': name
    });
    return _sp!.setString('Account-config', content);
  }
}