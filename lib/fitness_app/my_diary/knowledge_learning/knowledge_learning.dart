import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class KnowledgeLearningPage extends StatefulWidget {
  @override
  _KnowledgeLearningPageState createState() => _KnowledgeLearningPageState();
}

class _KnowledgeLearningPageState extends State<KnowledgeLearningPage> {
  VideoPlayerController? _controller;

  @override
  void initState() {
    super.initState();
    // 初始化 VideoPlayerController，这里使用一个示例网络视频
    _controller = VideoPlayerController.network(
      'https://www.example.com/video.mp4',
    )..initialize().then((_) {
        // 确保在视频初始化后刷新页面
        setState(() {});
      })..setLooping(true); // 如果需要视频循环播放，设置为 true
  }

  @override
  void dispose() {
    // 确保在 Widget 销毁时释放控制器资源
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('知识学习'),
      ),
      body: Center(
        child: _controller?.value.isInitialized ?? false
            ? AspectRatio(
                aspectRatio: _controller!.value.aspectRatio,
                child: VideoPlayer(_controller!),
              )
            : CircularProgressIndicator(), // 如果视频正在加载，则显示加载指示器
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // 播放或暂停视频
          setState(() {
            if (_controller?.value.isPlaying ?? false) {
              _controller?.pause();
            } else {
              _controller?.play();
            }
          });
        },
        // 根据视频播放状态显示不同的图标
        child: Icon(
          _controller?.value.isPlaying ?? false ? Icons.pause : Icons.play_arrow,
        ),
      ),
    );
  }
}