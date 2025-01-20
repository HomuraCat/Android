// lib/fitness_app/my_diary/knowledge_learning/sport_section.dart

import 'package:flutter/material.dart';
import 'sport_advice_page.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../../config.dart';
import 'package:cached_network_image/cached_network_image.dart'; // 添加缓存图片库

import '../../utils/Spsave_module.dart';

class SportSection extends StatefulWidget {
  @override
  _SportSectionState createState() => _SportSectionState();
}

class _SportSectionState extends State<SportSection> {
  // 存储后端返回的视频列表
  List<Map<String, dynamic>> videos = [];

  // 用于存储当前用户的 userID
  String? _userID;

  @override
  void initState() {
    super.initState();
    // 先获取用户信息（主要是获取 userID）
    fetchUserData().then((_) {
      // 获取到 userID 后再拉取视频列表
      fetchVideos();
    });
  }

  /// 从本地和后端获取用户信息（包含 userID）
  Future<void> fetchUserData() async {
    // 从本地存储读取 patientID
    Map<String, dynamic>? account = await SpStorage.instance.readAccount();
    if (account != null) {
      _userID = account['patientID'];
    } else {
      // 如果没有账户信息，可以在这里处理错误或提示
      print('No account information found');
      return;
    }
  }

  /// 拉取视频列表
  Future<void> fetchVideos() async {
    final String apiUrl = Config.baseUrl + '/mysport_videos';
    var url = Uri.parse(apiUrl);
    try {
      var response = await http.get(url);
      if (response.statusCode == 200) {
        var jsonData = jsonDecode(response.body) as List;
        setState(() {
          // 将 completed 直接保存为列表
          // 可能后端返回的 completed 是 List<dynamic>，这里暂存为 List<String> 或 List<dynamic> 都行
          videos = jsonData.map<Map<String, dynamic>>((data) {
          // Attempt to parse 'completed' if it's a String
          final completedField = data['completed'];
          //print('completedField runtimeType: ${completedField.runtimeType}');
          //print('completedField value: $completedField');
          List<dynamic> completedList;
          if (completedField is String) {
            try {
              completedList = jsonDecode(completedField) as List<dynamic>;
            } catch (e) {
              // If it fails to parse, fallback to empty list
              completedList = [];
            }
          } else if (completedField is List) {
            // If your backend is actually returning a List already
            completedList = completedField;
          } else {
            completedList = [];
          }

          return {
            'id': data['id'],
            'title': data['title'],
            'source_1': data['source_1'],
            'source_2': data['source_2'],
            'completed': completedList,
            'image': data['image'],
          };
        }).toList();
        });
        print("Fetched videos: $videos");
      } else {
        throw Exception('Failed to load videos');
      }
    } catch (e) {
      print('Error fetching videos: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('加载视频失败: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // 如果还没获取到 userID，就显示一个加载中
    if (_userID == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text("运动建议"),
        ),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("运动建议"),
      ),
      body: videos.isEmpty
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: EdgeInsets.all(16),
              itemCount: videos.length,
              itemBuilder: (context, index) {
                return buildVideoListItem(videos[index]);
              },
            ),
    );
  }

  /// 构建单个视频列表项
  Widget buildVideoListItem(Map<String, dynamic> video) {
    // 构建图片 URL
    String imageUrl = Config.baseUrl.endsWith('/')
        ? Config.baseUrl + video['image']
        : Config.baseUrl + '/' + video['image'];

    // 判断当前用户是否在 completed 列表里
    // 注意：completed 里可能是字符串或数字，要和 _userID 类型对得上
    bool isCompleted = false;
    if (video['completed'] is List) {
      // 这里假设 completed 是 List<String>
      isCompleted = (video['completed'] as List).contains(_userID);
      //print(video);
      //print(video['completed']);
      //print(_userID);
      //print("1!!!!!");
    }

    return Card(
      margin: EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 4,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch, // 让图片宽度填满卡片
        children: [
          // 图片作为封面，保持原始宽高比
          ClipRRect(
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            child: CachedNetworkImage(
              imageUrl: imageUrl,
              fit: BoxFit.cover,
              width: double.infinity,
              placeholder: (context, url) => Container(
                height: 200, // 设置一个高度占位
                color: Colors.grey[300],
                child: Center(child: CircularProgressIndicator()),
              ),
              errorWidget: (context, url, error) => Container(
                height: 200, // 设置一个高度占位
                color: Colors.grey[200],
                child: Icon(
                  Icons.broken_image,
                  color: Colors.grey,
                  size: 50,
                ),
              ),
            ),
          ),
          ListTile(
            title: Text(
              video['title'],
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            // 根据 isCompleted 显示不同的文案
            subtitle: Text(
              isCompleted ? '已学' : '学习中',
              style: TextStyle(
                fontSize: 16,
                color: isCompleted ? Colors.green : Colors.orange,
              ),
            ),
            trailing: Icon(
              Icons.arrow_forward_ios,
              color: Colors.grey,
            ),
            onTap: () async {
              // 跳转到详情页
              // 如果在详情页更新了完成状态，就会返回 true
              bool? updated = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SportAdvicePage(video: video, isCompleted: isCompleted),
                ),
              );

              // 如果详情页有更新，并且当前还没有标记完成，就把当前 userID 加到 completed 列表里
              if (updated == true && !isCompleted) {
                setState(() {
                  // 把当前用户 ID 加进去
                  if (video['completed'] is List) {
                    (video['completed'] as List).add(_userID);
                  }
                });
              }
            },
          ),
        ],
      ),
    );
  }
}
