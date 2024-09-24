// lib/fitness_app/my_diary/knowledge_learning/sport_section.dart

import 'package:flutter/material.dart';
import 'sport_advice_page.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../../config.dart';
import 'package:cached_network_image/cached_network_image.dart'; // 添加缓存图片库

class SportSection extends StatefulWidget {
  @override
  _SportSectionState createState() => _SportSectionState();
}

class _SportSectionState extends State<SportSection> {
  List<Map<String, dynamic>> videos = [];

  @override
  void initState() {
    super.initState();
    fetchVideos();
  }

  Future<void> fetchVideos() async {
    final String apiUrl = Config.baseUrl + '/mysport_videos';
    var url = Uri.parse(apiUrl);
    try {
      var response = await http.get(url);
      if (response.statusCode == 200) {
        var jsonData = jsonDecode(response.body) as List;
        setState(() {
          videos = jsonData.map((data) => {
                'id': data['id'],
                'title': data['title'],
                'source_1': data['source_1'],
                'source_2': data['source_2'],
                'completed': data['completed'] == 1,
                'image': data['image'], // 确保包含 image 字段
              }).toList();
        });
        print("Fetched videos: $videos"); // Debug statement
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

  // 构建视频列表项的函数
  Widget buildVideoListItem(Map<String, dynamic> video) {
    String imageUrl = Config.baseUrl.endsWith('/')
        ? Config.baseUrl + video['image']
        : Config.baseUrl + '/' + video['image']; // 构建图片URL
    print("Building list item with image URL: $imageUrl"); // Debug statement

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
              // 使用 Image.network 的加载和错误处理
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
            subtitle: Text(
              video['completed'] ? '已学' : '学习中',
              style: TextStyle(
                fontSize: 16,
                color: video['completed'] ? Colors.green : Colors.orange,
              ),
            ),
            trailing: Icon(
              Icons.arrow_forward_ios,
              color: Colors.grey,
            ),
            onTap: () async {
              bool? updated = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SportAdvicePage(video: video),
                ),
              );
              if (updated != null && updated && !video['completed']) {
                setState(() {
                  video['completed'] = true;
                });
              }
            },
          ),
        ],
      ),
    );
  }
}