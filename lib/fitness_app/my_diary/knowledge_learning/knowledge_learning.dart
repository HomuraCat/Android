import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../../config.dart';

class LearnSection extends StatefulWidget {
  @override
  _LearnSectionState createState() => _LearnSectionState();
}

class _LearnSectionState extends State<LearnSection> {
  // 假设这是您的视频列表数据
  List<Map<String, dynamic>> videos = [];

  @override
  void initState() {
    super.initState();
    fetchVideos();
  }

  Future<void> fetchVideos() async {
    final String apiUrl = Config.baseUrl + '/mylearn_videos';
    var url = Uri.parse(apiUrl);
    var response = await http.get(url);
    if (response.statusCode == 200) {
      var jsonData = jsonDecode(response.body) as List;
      setState(() {
        videos = jsonData.map((data) => {
              'id': data['id'],
              'title': data['title'],
              'status': data['status'],
              'source': data['source'],
              'info': data['info'],
              'completed': data['completed'] == 1
            }).toList();
      });
    } else {
      throw Exception('Failed to load videos');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("知识学习"),
      ),
      body: Form(
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          children: [
            const SizedBox(height: 60),
            const SizedBox(height: 4),
            const SizedBox(height: 60),
            const SizedBox(height: 24),
            for (var video in videos) buildVideoListItem(video),
          ],
        ),
      ),
    );
  }

  // 构建视频列表项的函数
Widget buildVideoListItem(Map<String, dynamic> video) {
  return Card(
    child: ListTile(
      title: Text(video['title']),
      subtitle: Text(video['completed'] ? '已学' : '学习中'),
      trailing: Icon(
        video['completed'] ? Icons.check_circle : Icons.play_circle_fill,
        color: video['completed'] ? Colors.green : Colors.blue,
      ),
      onTap: () async {
        String urlString = video['source'];
        if (!urlString.startsWith('http://') && !urlString.startsWith('https://')) {
          urlString = 'https://' + urlString;
        }
        final Uri url = Uri.parse(urlString);

        try {
          await launchUrl(url, mode: LaunchMode.externalApplication);
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('无法打开链接: $urlString')),
          );
        }
      },

    ),
  );
}

}
