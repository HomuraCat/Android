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
import '../../utils/Spsave_module.dart';

class SportAdvicePage extends StatefulWidget {
  final Map<String, dynamic> video;

  /// 新增一个 isCompleted 参数，用来接收父页面判断好的完成状态
  final bool isCompleted;

  SportAdvicePage({
    Key? key,
    required this.video,
    required this.isCompleted, // 这里要求必须传
  }) : super(key: key);

  @override
  _SportAdvicePageState createState() => _SportAdvicePageState();
}

class _SportAdvicePageState extends State<SportAdvicePage> {
  late VideoPlayerController _videoPlayerController;
  ChewieController? _chewieController;

  /// 这里的 isPracticeVideo = false，表示初始进来用哪一个 source 播放，
  /// 你可以根据实际需求调整默认值
  bool isPracticeVideo = false;

  String buttonText = '跳转到完整版视频';
  double topBarOpacity = 0.0;
  String info = "温馨提示：感觉不适请立即停止运动。";
  ScrollController scrollController = ScrollController();
  bool isLoading = false;
  String? _userID;
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
  @override
  void initState() {
    fetchUserData();
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
        print("完整视频链接: $fullVideoUrl");
        print("local视频链接: $localVideoPath");
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

    // 当视频播放结束，并且当前是练习视频（或完整视频，视你需求而定）
    // 这里假设 "练习视频" 才标记已完成，如果你想要"完整版"标记完成，就把条件改成 isPracticeVideo == false
    if (!isPlaying && isVideoEnded && isPracticeVideo) {
      _markVideoAsLearned();
    }
  }

void _markVideoAsLearned() async {
  // 后端接口，带上当前视频的 ID
  final String apiUrl =
      Config.baseUrl + '/update_sport_video_status/${widget.video['id']}';
  var url = Uri.parse(apiUrl);

  try {
    var response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      // 把 userID 传给后端
      body: jsonEncode({'userID': _userID}),
    );

    if (response.statusCode == 200) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("视频标记为已完成！")),
      );
      // 返回上一页，通知父页面刷新
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
    buttonText = isPracticeVideo ? '跳转预览视频' : '跳转完整视频';
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

    // 拿到父页面传入的完成状态
    bool userAlreadyCompleted = widget.isCompleted;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.video['title']),
      ),
      body: SingleChildScrollView(
        controller: scrollController,
        child: Column(
          children: [
            // 视频播放器区域或封面
            AspectRatio(
              aspectRatio: _chewieController != null &&
                      _chewieController!.videoPlayerController.value.isInitialized
                  ? _chewieController!.videoPlayerController.value.aspectRatio
                  : 16 / 9,
              child: _chewieController != null &&
                      _chewieController!.videoPlayerController.value.isInitialized
                  ? Chewie(
                      key: UniqueKey(),
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
            // 切换按钮
            Padding(
              padding: EdgeInsets.all(16),
              child: ElevatedButton(
                style: ButtonStyle(
                  backgroundColor:
                      MaterialStateProperty.resolveWith<Color>(
                    (Set<MaterialState> states) {
                      if (states.contains(MaterialState.pressed))
                        return buttonText == "跳转完整视频"
                            ? Colors.green[800]!
                            : Colors.blue[800]!;
                      return buttonText == "跳转预览视频" ? Colors.green : Colors.blue;
                    },
                  ),
                  foregroundColor:
                      MaterialStateProperty.all<Color>(Colors.white),
                  minimumSize:
                      MaterialStateProperty.all<Size>(Size(double.infinity, 50)),
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
            // 提示信息
            Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                info,
                style: TextStyle(
                  fontSize: 16,
                ),
              ),
            ),
            // 当 isPracticeVideo = false（假设此时是完整版）时，显示已学/学习中
            // 你可以根据自己需求决定这里用什么条件判断
            if (true)
              Padding(
                padding: EdgeInsets.only(bottom: 20),
                child: Text(
                  userAlreadyCompleted ? '已学' : '学习中',
                  style: TextStyle(
                    fontSize: 16,
                    color: userAlreadyCompleted ? Colors.green : Colors.orange,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
