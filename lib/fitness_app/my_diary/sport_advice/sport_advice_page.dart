// lib/fitness_app/my_diary/knowledge_learning/sport_advice_page.dart

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../../config.dart';
import 'package:cached_network_image/cached_network_image.dart';

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

  @override
  void initState() {
    super.initState();
    _initializeVideoPlayer();
    scrollController.addListener(_scrollListener);
  }

  ScrollController scrollController = ScrollController();

  Future<void> _initializeVideoPlayer() async {
    String videoSource = isPracticeVideo ? widget.video['source_2'] : widget.video['source_1'];
    String fullVideoUrl = Config.baseUrl.endsWith('/')
        ? Config.baseUrl + videoSource
        : Config.baseUrl + '/' + videoSource;
    print("Initializing video from URL: $fullVideoUrl"); // Debug statement

    Uri videoUri = Uri.parse(fullVideoUrl);
    print("!!!!!!!!!!!!!!!!");
    print(videoUri);
    _videoPlayerController = VideoPlayerController.networkUrl(videoUri)
      ..addListener(() {
        if (_videoPlayerController.value.hasError) {
          print("Video Player Error: ${_videoPlayerController.value.errorDescription}");
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("视频播放错误: ${_videoPlayerController.value.errorDescription}")),
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("视频初始化失败: $e")),
      );
    }
  }

  void _checkVideo() {
    final bool isPlaying = _videoPlayerController.value.isPlaying;
    final bool isVideoEnded = _videoPlayerController.value.position >= _videoPlayerController.value.duration;
    if (!isPlaying && isVideoEnded && isPracticeVideo) {
      // 如果视频播放结束，标记为已完成
      _markVideoAsLearned();
    }
  }

  void _markVideoAsLearned() async {
    final String apiUrl = Config.baseUrl + '/update_sport_video_status/${widget.video['id']}';
    var url = Uri.parse(apiUrl);
    try {
      var response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'completed': 1}) // Use integer instead of string
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("视频标记为已完成！")),
        );
        // 传递更新状态回上一页面
        Navigator.pop(context, true);
      } else {
        print("Failed to update video status: ${response.body}");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("更新视频状态失败。")),
        );
      }
    } catch (e) {
      print("Error updating video status: $e");
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
      isPracticeVideo = !isPracticeVideo;
      buttonText = isPracticeVideo ? '教学' : '跟练';
    });
    await _videoPlayerController.dispose();
    await _initializeVideoPlayer();
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
    String imageUrl = Config.baseUrl.endsWith('/')
        ? Config.baseUrl + widget.video['image']
        : Config.baseUrl + '/' + widget.video['image']; // 构建图片URL
    print("Displaying image from URL: $imageUrl"); // Debug statement

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.video['title']),
      ),
      body: SingleChildScrollView(
        controller: scrollController,
        child: Column(
          children: [
            // 封面图片和视频播放器
            _chewieController != null &&
                    _chewieController!.videoPlayerController.value.isInitialized
                ? Chewie(
                    controller: _chewieController!,
                  )
                : Container(
                    height: 200,
                    child: CachedNetworkImage(
                      imageUrl: imageUrl,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      placeholder: (context, url) => Center(child: CircularProgressIndicator()),
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
                  backgroundColor: MaterialStateProperty.resolveWith<Color>(
                    (Set<MaterialState> states) {
                      if (states.contains(MaterialState.pressed))
                        return buttonText == "跟练" ? Colors.green[800]! : Colors.blue[800]!;
                      return buttonText == "教学" ? Colors.green : Colors.blue;
                    },
                  ),
                  foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
                  minimumSize: MaterialStateProperty.all<Size>(Size(double.infinity, 50)),
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