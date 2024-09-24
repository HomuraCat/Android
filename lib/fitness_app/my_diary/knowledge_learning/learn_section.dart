// lib/fitness_app/my_diary/knowledge_learning/learn_section.dart

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../../config.dart';
import '../../models/video.dart'; // 确保导入 Video 模型

class LearnSection extends StatefulWidget {
  @override
  _LearnSectionState createState() => _LearnSectionState();
}

class _LearnSectionState extends State<LearnSection> {
  List<Video> videos = [];
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    fetchVideos();
  }

  Future<void> fetchVideos() async {
    final String apiUrl = Config.baseUrl + '/mylearn_videos';
    var url = Uri.parse(apiUrl);
    try {
      var response = await http.get(url);
      if (response.statusCode == 200) {
        var jsonData = jsonDecode(response.body) as List;
        List<Video> fetchedVideos =
            jsonData.map((data) => Video.fromJson(data)).toList();
        setState(() {
          videos = fetchedVideos;
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = '加载视频失败，状态码: ${response.statusCode}';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = '加载视频时发生错误: $e';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("知识学习"),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : errorMessage != null
              ? Center(child: Text(errorMessage!))
              : videos.isEmpty
                  ? Center(child: Text('暂无视频'))
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: videos.length,
                      itemBuilder: (context, index) {
                        return buildVideoListItem(videos[index]);
                      },
                    ),
    );
  }

  // 构建视频列表项的函数
  Widget buildVideoListItem(Video video) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8.0),
      child: ListTile(
        title: Text(
          video.title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        // 移除 subtitle
        // 移除 trailing 图标
        onTap: () async {
          String urlString = video.source;
          if (!urlString.startsWith('http://') && !urlString.startsWith('https://')) {
            urlString = 'https://' + urlString;
          }
          final Uri url = Uri.parse(urlString);

          // 检查 URL 是否可以被打开
          if (await canLaunchUrl(url)) {
            try {
              await launchUrl(url, mode: LaunchMode.externalApplication);
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('无法打开链接: $urlString')),
              );
            }
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('无法打开链接: $urlString')),
            );
          }
        },
      ),
    );
  }
}