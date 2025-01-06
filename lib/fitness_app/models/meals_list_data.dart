import 'package:flutter/material.dart';
import '../utils/Spsave_module.dart';   // 你的 Spsave_module.dart 路径
import '../../config.dart';           // 你的 config.dart 路径
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';

class MealsListData {
  /// 构造函数：可以把需要的属性都在这里声明好
  MealsListData({
    this.imagePath = '',
    this.titleTxt = '',
    this.startColor = '',
    this.endColor = '',
    this.meals,
    this.kacl = 0,
    this.userHeight = 0.0,
    this.userWeight = 0.0,
    this.userBMR = 0.0,
    this.userSex = '',
    this.userAge = 0,
  });

  /// --- 基础显示属性 ---
  String imagePath;
  String titleTxt;
  String startColor;
  String endColor;
  List<String>? meals;
  int kacl; // 具体此餐预计要消耗多少卡路里

  /// --- 用户相关属性 ---
  double userHeight;
  double userWeight;
  double userBMR;
  String userSex;
  int userAge;

  /// 计算 BMR 的方法（公因式）
  double calcBMR(String sex, double weight, double height, int age) {
    double bmr = 0.0;
    if (sex.toLowerCase() == 'male') {
      // 男性 BMR
      bmr = 66 + (13.7 * weight) + (5 * height) - (6.8 * age);
    } else {
      // 女性 BMR
      bmr = 655 + (9.6 * weight) + (1.8 * height) - (4.7 * age);
    }
    // 保留整数或者你想要的小数精度
    return double.parse(bmr.toStringAsFixed(0));
  }

  /// 从后端接口获取用户信息，并更新到当前对象
  Future<void> fetchUserData() async {
    try {
      // 1. 从本地存储中读取 patientID
      Map<String, dynamic>? account = await SpStorage.instance.readAccount();
      if (account == null || !account.containsKey('patientID')) {
        print('无效的 patientID');
        return;
      }
      final String patientID = account['patientID'];
      
      // 2. 请求后端接口
      final String apiUrl = Config.baseUrl + '/patient/get_info_json';
      final url = Uri.parse(apiUrl);

      final response = await http.post(
        url,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'patientID': patientID,
        }),
      );

      // 3. 后端返回成功则更新本地属性
      if (response.statusCode == 200) {
        Map<String, dynamic> data = jsonDecode(response.body);

        if (data['height'] != null) {
          userHeight = double.tryParse(data['height'].toString()) ?? 0.0;
        }
        if (data['weight'] != null) {
          userWeight = double.tryParse(data['weight'].toString()) ?? 0.0;
        }
        if (data['gender'] != null) {
          // 假设后端返回 1 代表 male, 否则 female
          userSex = (data['gender'] == 1) ? "male" : "female";
        }
        if (data['age'] != null) {
          userAge = int.tryParse(data['age'].toString()) ?? 0;
        }

        // 4. 计算 BMR
        if (userWeight > 0 &&
            userHeight > 0 &&
            userAge > 0 &&
            (userSex == 'male' || userSex == 'female')) {
          userBMR = calcBMR(userSex, userWeight, userHeight, userAge);
        } else {
          userBMR = 0.0;
        }
      } else {
        print('Failed to fetch patient info: ${response.statusCode}');
      }
    } catch (e) {
      print('Error in fetchUserData: $e');
    }
  }

  /// --- 用来获取早餐/午餐/晚餐卡路里配比的 Getter ---
  int get breakfastBMR => (userBMR * 0.3).toInt();
  int get lunchBMR => (userBMR * 0.4).toInt();
  int get dinnerBMR => (userBMR * 0.3).toInt();
  
  /// 
  /// ==============
  ///  以下示例演示如何基于上面计算好的 userBMR 值，来生成对应的 MealsListData 列表
  ///  你可以根据自己的业务需求调用
  /// ==============
  ///

  /// 利用当前对象的 BMR，生成不同餐次的 MealsListData
  /// 如果你想把这些列表做成静态的，可以改写成 static，但注意不要引用实例属性。
  List<MealsListData> generateMealsList() {
    return [
      MealsListData(
        imagePath: 'assets/fitness_app/breakfast.jpg',
        titleTxt: '早餐',
        kacl: breakfastBMR, // 调用 Getter
        meals: <String> ["此选项已废弃"],
        startColor: '#FFA62C',
        endColor: '#FFA62C',
      ),
      MealsListData(
        imagePath: 'assets/fitness_app/breakfast.jpg',
        titleTxt: '早餐加餐',
        kacl: 0,
        meals: <String>[],
        startColor: '#FFA62C',
        endColor: '#FFA62C',
      ),
      MealsListData(
        imagePath: 'assets/fitness_app/lunch.jpg',
        titleTxt: '午餐',
        kacl: lunchBMR,  // 调用 Getter
        meals: <String>['高能量','均衡'],
        startColor: '#CF9F6E',
        endColor: '#CF9F6E',
      ),
      MealsListData(
        imagePath: 'assets/fitness_app/lunch.jpg',
        titleTxt: '午餐加餐',
        kacl: 0,
        meals: <String>[],
        startColor: '#CF9F6E',
        endColor: '#CF9F6E',
      ),
      MealsListData(
        imagePath: 'assets/fitness_app/dinner.jpg',
        titleTxt: '晚餐',
        kacl: dinnerBMR, // 调用 Getter
        meals: <String>['易消化', '温和'],
        startColor: '#BFB9AC',
        endColor: '#BFB9AC',
      ),
      MealsListData(
        imagePath: 'assets/fitness_app/dinner.jpg',
        titleTxt: '晚餐加餐',
        kacl: 0,
        meals: <String>[],
        startColor: '#BFB9AC',
        endColor: '#BFB9AC',
      ),  
    ];
  }
}
