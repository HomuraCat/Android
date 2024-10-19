// lib/fitness_app/my_diary/knowledge_learning/sport_advice_page.dart

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../../config.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:path_provider/path_provider.dart';
import 'package:dio/dio.dart';
import 'dart:io';

class SportAdvicePage extends StatefulWidget {
  final Map<String, dynamic> video;
  SportAdvicePage({Key? key, required this.video}) : super(key: key);

  @override
  _SportAdvicePageState createState() => _SportAdvicePageState();
}

class _SportAdvicePageState extends State<SportAdvicePage> {
  late VideoPlayerController _videoPlayerController;
  ChewieController? _chewieController;
  bool isPracticeVideo = false;
  String buttonText = '跟练';
  double topBarOpacity = 0.0;
  String info = "温馨提示：感觉不适请立即停止运动。";
  ScrollController scrollController = ScrollController();
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeVideoPlayer();
    scrollController.addListener(_scrollListener);
  }

  Future<void> _initializeVideoPlayer() async {
    String videoSource =
        isPracticeVideo ? widget.video['source_2'] : widget.video['source_1'];
    String fullVideoUrl = Config.baseUrl.endsWith('/')
        ? Config.baseUrl + videoSource
        : Config.baseUrl + '/' + videoSource;

    // 获取本地存储路径
    Directory appDocDir = await getApplicationDocumentsDirectory();
    String videoFileName = videoSource.split('/').last; // 从 URL 中提取文件名
    String localVideoPath = '${appDocDir.path}/$videoFileName';

    File videoFile = File(localVideoPath);

    if (!videoFile.existsSync()) {
      // 如果本地不存在，则下载
      try {
        print('开始下载视频...');
        Dio dio = Dio();
        await dio.download(fullVideoUrl, localVideoPath);
        print('视频下载完成，保存在 $localVideoPath');
      } catch (e) {
        print('视频下载失败：$e');
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('视频下载失败：$e')),
        );
        return;
      }
    } else {
      print('本地视频已存在：$localVideoPath');
    }

    // 使用本地视频路径初始化视频播放器
    _videoPlayerController = VideoPlayerController.file(
      videoFile,
      videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true),
    )
      ..addListener(() {
        if (_videoPlayerController.value.hasError) {
          print(
              "Video Player Error: ${_videoPlayerController.value.errorDescription}");
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(
                    "视频播放错误: ${_videoPlayerController.value.errorDescription}")),
          );
        }
      });

    try {
      await _videoPlayerController.initialize();
      _createChewieController();
      setState(() {});
      _videoPlayerController.addListener(_checkVideo);
    } catch (e) {
      print("Error initializing video: $e");
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("视频初始化失败: $e")),
      );
    }
  }

  void _checkVideo() {
    final bool isPlaying = _videoPlayerController.value.isPlaying;
    final bool isVideoEnded = _videoPlayerController.value.position >=
        _videoPlayerController.value.duration;
    if (!isPlaying && isVideoEnded && isPracticeVideo) {
      // 如果视频播放结束，标记为已完成
      _markVideoAsLearned();
    }
  }

  void _markVideoAsLearned() async {
    final String apiUrl = Config.baseUrl +
        '/update_sport_video_status/${widget.video['id']}';
    var url = Uri.parse(apiUrl);
    try {
      var response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'completed': 1}),
      );

      if (response.statusCode == 200) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("视频标记为已完成！")),
        );
        // 传递更新状态回上一页面
        Navigator.pop(context, true);
      } else {
        print("Failed to update video status: ${response.body}");
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("更新视频状态失败。")),
        );
      }
    } catch (e) {
      print("Error updating video status: $e");
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("更新视频状态失败: $e")),
      );
    }
  }

  @override
  void dispose() {
    _videoPlayerController.removeListener(_checkVideo);
    _videoPlayerController.dispose();
    _chewieController?.dispose();
    scrollController.removeListener(_scrollListener);
    scrollController.dispose();
    super.dispose();
  }

  void _createChewieController() {
    _chewieController = ChewieController(
      videoPlayerController: _videoPlayerController,
      autoPlay: true,
      looping: false,
      additionalOptions: (context) => [
        OptionItem(
          onTap: _toggleVideo,
          iconData: Icons.swap_horiz,
          title: '切换视频',
        ),
      ],
      errorBuilder: (context, errorMessage) {
        return Center(
          child: Text(
            errorMessage,
            style: TextStyle(color: Colors.white),
          ),
        );
      },
    );
  }

  Future<void> _toggleVideo() async {
    setState(() {
      isLoading = true;
    });
    await _videoPlayerController.pause();
    await _videoPlayerController.dispose();
    _chewieController?.dispose();
    isPracticeVideo = !isPracticeVideo;
    buttonText = isPracticeVideo ? '教学' : '跟练';
    await _initializeVideoPlayer();
    setState(() {
      isLoading = false;
    });
  }

  void _scrollListener() {
    if (scrollController.offset >= 24) {
      if (topBarOpacity != 1.0) {
        setState(() {
          topBarOpacity = 1.0;
        });
      }
    } else if (scrollController.offset <= 24 && scrollController.offset >= 0) {
      if (topBarOpacity != scrollController.offset / 24) {
        setState(() {
          topBarOpacity = scrollController.offset / 24;
        });
      }
    } else if (scrollController.offset <= 0) {
      if (topBarOpacity != 0.0) {
        setState(() {
          topBarOpacity = 0.0;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // 构建图片 URL
    String imageUrl = Config.baseUrl.endsWith('/')
        ? Config.baseUrl + widget.video['image']
        : Config.baseUrl + '/' + widget.video['image'];

    if (isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: Text(widget.video['title']),
        ),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.video['title']),
      ),
      body: SingleChildScrollView(
        controller: scrollController,
        child: Column(
          children: [
            // 使用 AspectRatio 包裹视频播放器或封面图片
            AspectRatio(
              aspectRatio: _chewieController != null &&
                      _chewieController!.videoPlayerController.value.isInitialized
                  ? _chewieController!.videoPlayerController.value.aspectRatio
                  : 16 / 9, // 默认宽高比
              child: _chewieController != null &&
                      _chewieController!.videoPlayerController.value.isInitialized
                  ? Chewie(
                      key: UniqueKey(), // 确保每次切换时重新构建
                      controller: _chewieController!,
                    )
                  : CachedNetworkImage(
                      imageUrl: imageUrl,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      placeholder: (context, url) =>
                          Center(child: CircularProgressIndicator()),
                      errorWidget: (context, url, error) => Container(
                        color: Colors.grey[200],
                        child: Icon(
                          Icons.broken_image,
                          color: Colors.grey,
                          size: 50,
                        ),
                      ),
                    ),
            ),
            Padding(
              padding: EdgeInsets.all(16),
              child: ElevatedButton(
                style: ButtonStyle(
                  backgroundColor:
                      MaterialStateProperty.resolveWith<Color>(
                    (Set<MaterialState> states) {
                      if (states.contains(MaterialState.pressed))
                        return buttonText == "跟练"
                            ? Colors.green[800]!
                            : Colors.blue[800]!;
                      return buttonText == "教学" ? Colors.green : Colors.blue;
                    },
                  ),
                  foregroundColor:
                      MaterialStateProperty.all<Color>(Colors.white),
                  minimumSize: MaterialStateProperty.all<Size>(
                      Size(double.infinity, 50)),
                ),
                onPressed: () {
                  _toggleVideo();
                },
                child: Text(
                  buttonText,
                  style: TextStyle(
                    fontSize: 20,
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                info,
                style: TextStyle(
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
