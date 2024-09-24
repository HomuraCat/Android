// lib/fitness_app/my_diary/knowledge_learning/knowledge_learning.dart

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../../config.dart';
import '../../models/video.dart'; // 确保导入 Video 模型
import 'package:best_flutter_ui_templates/fitness_app/fitness_app_theme.dart';
import 'learn_section.dart'; // 确保导入 LearnSection
import 'package:url_launcher/url_launcher.dart';

class LearnTopicsPreview extends StatefulWidget {
  final AnimationController animationController;
  final Animation<double> animation;

  const LearnTopicsPreview({
    Key? key,
    required this.animationController,
    required this.animation,
  }) : super(key: key);

  @override
  _LearnTopicsPreviewState createState() => _LearnTopicsPreviewState();
}

class _LearnTopicsPreviewState extends State<LearnTopicsPreview> {
  List<Video> topicPreviews = [];
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    fetchTopicPreviews();
  }

  Future<void> fetchTopicPreviews() async {
    final String apiUrl = Config.baseUrl + '/learn_topics'; // 使用正确的 API 端点
    var url = Uri.parse(apiUrl);
    try {
      var response = await http.get(url);
      if (response.statusCode == 200) {
        var jsonData = jsonDecode(response.body) as List;
        List<Video> fetchedVideos =
            jsonData.map((data) => Video.fromJson(data)).toList();
        setState(() {
          // 仅保留前两个视频作为预览
          if (fetchedVideos.length >= 2) {
            topicPreviews = fetchedVideos.sublist(0, 2);
          } else {
            topicPreviews = fetchedVideos;
          }
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
    return AnimatedBuilder(
      animation: widget.animationController,
      builder: (BuildContext context, Widget? child) {
        return FadeTransition(
          opacity: widget.animation,
          child: Transform(
            transform: Matrix4.translationValues(
                0.0, 30 * (1.0 - widget.animation.value), 0.0),
            child: Container(
              decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color(0xFFB3E5FC), // 浅蓝色
                        Color(0xFF81D4FA), // 中蓝色
                        Color(0xFF29B6F6), // 深蓝色
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(8.0),
                  bottomLeft: Radius.circular(8.0),
                  bottomRight: Radius.circular(8.0),
                  topRight: Radius.circular(68.0),
                ),
                boxShadow: <BoxShadow>[
                  BoxShadow(
                    color: Color.fromARGB(255, 95, 109, 118).withOpacity(0.2),
                    offset: Offset(1.1, 1.1),
                    blurRadius: 10.0,
                  ),
                ],
              ),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "主题预览",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: FitnessAppTheme.darkerText,
                      ),
                    ),
                    SizedBox(height: 10),
                    if (isLoading)
                      Center(child: CircularProgressIndicator())
                    else if (errorMessage != null)
                      Center(child: Text(errorMessage!))
                    else if (topicPreviews.isEmpty)
                      Center(child: Text('暂无主题可供预览'))
                    else
                      Column(
                        children: topicPreviews
                            .map((video) => buildVideoPreview(video))
                            .toList(),
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // 构建视频预览的函数
  Widget buildVideoPreview(Video video) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8.0),
      elevation: 3.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: ListTile(
        // 移除 leading 属性（图片缩略图）
        // 移除 trailing 属性（视频播放图标）
        title: Text(
          video.title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          video.info,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
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