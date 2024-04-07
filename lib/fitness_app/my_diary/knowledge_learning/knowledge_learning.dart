import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:best_flutter_ui_templates/fitness_app/my_diary/knowledge_learning/weekly_test_page.dart';

class KnowledgeLearningPage extends StatefulWidget {
  @override
  _KnowledgeLearningPageState createState() => _KnowledgeLearningPageState();
}

class LearnSection extends StatefulWidget {
  @override
  _LearnSectionState createState() => _LearnSectionState();
}

class _LearnSectionState extends State<LearnSection> {
  // 假设这是您的视频列表数据
  final List<Map<String, String>> videos = [
    {
      'title': '视频标题1',
      'status': '学习',
    },
    {
      'title': '视频标题2',
      'status': '学习',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Form(
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          children: [
            const SizedBox(height: 60),
            const SizedBox(height: 4),
            const SizedBox(height: 60),
            // 这里假设 buildTestButton 是一个创建按钮的函数
            buildTestButton(context),
            const SizedBox(height: 24),
            // 构建视频列表
            for (var video in videos) buildVideoListItem(video),
          ],
        ),
      ),
    );
  }

  Widget buildTestButton(BuildContext context) {
    return Align(
      child: SizedBox(
        height: 35,
        width: 150,
        child: FloatingActionButton(
          backgroundColor: Colors.black,
          child: Text('开始测试',
              style: Theme.of(context).primaryTextTheme.headlineSmall),
          onPressed: () {
            Navigator.of(context).push(MaterialPageRoute(
                builder: (BuildContext context) => WeeklyTestPage()));
          },
        ),
      ),
    );
  }
  // 构建视频列表项的函数
  Widget buildVideoListItem(Map<String, String> video) {
    return Card(
      child: ListTile(
        title: Text(video['title']!),
        trailing: Text(
          video['status']!,
          style: TextStyle(
            color: video['status'] == '已学' ? Colors.green : Colors.blue,
          ),
        ),
        leading: Icon(Icons.play_circle_fill),
        onTap: () async {
          bool? updated = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => KnowledgeLearningPage(),
            ),
          );

          if (updated != null && updated) {
            setState(() {
              video['status'] = '已学';
            });
          }
        },
      ),
    );
  }
}

class _KnowledgeLearningPageState extends State<KnowledgeLearningPage> {
  List<Widget> listViews = <Widget>[];
  final ScrollController scrollController = ScrollController();
  late VideoPlayerController _videoPlayerController;
  ChewieController? _chewieController;
  int currentVideoIndex = 0;
  double topBarOpacity = 0.0;
  //String info = "你好，我是肺癌知识。以下文字是为了让这段文字尽可能长来看看UI效果。以下文字是为了让这段文字尽可能长来看看UI效果。以下文字是为了让这段文字尽可能长来看看UI效果。以下文字是为了让这段文字尽可能长来看看UI效果。以下文字是为了让这段文字尽可能长来看看UI效果。以下文字是为了让这段文字尽可能长来看看UI效果。以下文字是为了让这段文字尽可能长来看看UI效果。以下文字是为了让这段文字尽可能长来看看UI效果。以下文字是为了让这段文字尽可能长来看看UI效果。以下文字是为了让这段文字尽可能长来看看UI效果。以下文字是为了让这段文字尽可能长来看看UI效果。以下文字是为了让这段文字尽可能长来看看UI效果。";
  String info = "你好，我是肺癌知识。以下文字是为了让这段文字尽可能长来看看UI效果。以下文字是为了让这段文字尽可能长来看看UI效果。以下文字是为了让这段文字尽可能长来看看UI效果。以下文字是为了让这段文字尽可能长来看看UI效果。以下文字是为了让这段文字尽可能长来看看UI效果。以下文字是为了让这段文字尽可能长来看看UI效果。以下文字是为了让这段文字尽可能长来看看UI效果。以下文字是为了让这段文字尽可能长来看看UI效果。以下文字是为了让这段文字尽可能长来看看UI效果。以下文字是为了让这段文字尽可能长来看看UI效果。以下文字是为了让这段文字尽可能长来看看UI效果。以下文字是为了让这段文字尽可能长来看看UI效果。以下文字是为了让这段文字尽可能长来看看UI效果。以下文字是为了让这段文字尽可能长来看看UI效果。以下文字是为了让这段文字尽可能长来看看UI效果。以下文字是为了让这段文字尽可能长来看看UI效果。以下文字是为了让这段文字尽可能长来看看UI效果。以下文字是为了让这段文字尽可能长来看看UI效果。以下文字是为了让这段文字尽可能长来看看UI效果。以下文字是为了让这段文字尽可能长来看看UI效果。以下文字是为了让这段文字尽可能长来看看UI效果。以下文字是为了让这段文字尽可能长来看看UI效果。以下文字是为了让这段文字尽可能长来看看UI效果。以下文字是为了让这段文字尽可能长来看看UI效果。以下文字是为了让这段文字尽可能长来看看UI效果。以下文字是为了让这段文字尽可能长来看看UI效果。以下文字是为了让这段文字尽可能长来看看UI效果。以下文字是为了让这段文字尽可能长来看看UI效果。以下文字是为了让这段文字尽可能长来看看UI效果。以下文字是为了让这段文字尽可能长来看看UI效果。以下文字是为了让这段文字尽可能长来看看UI效果。以下文字是为了让这段文字尽可能长来看看UI效果。以下文字是为了让这段文字尽可能长来看看UI效果。以下文字是为了让这段文字尽可能长来看看UI效果。以下文字是为了让这段文字尽可能长来看看UI效果。以下文字是为了让这段文字尽可能长来看看UI效果。以下文字是为了让这段文字尽可能长来看看UI效果。以下文字是为了让这段文字尽可能长来看看UI效果。以下文字是为了让这段文字尽可能长来看看UI效果。以下文字是为了让这段文字尽可能长来看看UI效果。以下文字是为了让这段文字尽可能长来看看UI效果。以下文字是为了让这段文字尽可能长来看看UI效果。以下文字是为了让这段文字尽可能长来看看UI效果。以下文字是为了让这段文字尽可能长来看看UI效果。以下文字是为了让这段文字尽可能长来看看UI效果。以下文字是为了让这段文字尽可能长来看看UI效果。以下文字是为了让这段文字尽可能长来看看UI效果。以下文字是为了让这段文字尽可能长来看看UI效果。以下文字是为了让这段文字尽可能长来看看UI效果。以下文字是为了让这段文字尽可能长来看看UI效果。以下文字是为了让这段文字尽可能长来看看UI效果。以下文字是为了让这段文字尽可能长来看看UI效果。以下文字是为了让这段文字尽可能长来看看UI效果。";
  
  final List<String> _videoSources = [
    'assets/videos/1.mp4',
  ];

  @override
  void initState() {
    super.initState();
    _initializeVideoPlayer();
      scrollController.addListener(() {
      if (scrollController.offset >= 24) {
        if (topBarOpacity != 1.0) {
          setState(() {
            topBarOpacity = 1.0;
          });
        }
      } else if (scrollController.offset <= 24 &&
          scrollController.offset >= 0) {
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
    });
  }

  Future<void> _initializeVideoPlayer() async {
    _videoPlayerController = VideoPlayerController.asset(_videoSources[currentVideoIndex]);
    await _videoPlayerController.initialize();
    _videoPlayerController.addListener(_checkVideo); // Add listener
    _createChewieController();
    setState(() {});
  }

void _checkVideo() {
  final bool isPlaying = _videoPlayerController.value.isPlaying;
  final bool isVideoEnded = _videoPlayerController.value.position >= _videoPlayerController.value.duration;
  if (!isPlaying && isVideoEnded) {
    // If the video has finished playing, mark it as learned
    _markVideoAsLearned();
  }
}

  void _markVideoAsLearned() {
    // Logic to mark the video as "已学"
    Navigator.pop(context, true);
  }

  @override
  void dispose() {
    _videoPlayerController.removeListener(_checkVideo); // Remove listener
    _videoPlayerController.dispose();
    _chewieController?.dispose();
    super.dispose();
  }


  void _createChewieController() {
    _chewieController = ChewieController(
      videoPlayerController: _videoPlayerController,
      autoPlay: false,
      looping: false,
      // Here you can add additional options, subtitles, or any other custom configurations.
      // Example for adding an option:
      additionalOptions: (context) => [
        OptionItem(
          onTap: _toggleVideo,
          iconData: Icons.swap_horiz,
          title: 'Toggle Video',
        ),
      ],
      // Example for subtitles, if you have subtitle files:
      // subtitle: Subtitles([
      //   Subtitle(
      //     index: 0,
      //     start: Duration.zero,
      //     end: const Duration(seconds: 10),
      //     text: 'Subtitle text',
      //   ),
      // ]),
      // subtitleBuilder: (context, subtitle) => Text(
      //   subtitle,
      //   style: TextStyle(color: Colors.white),
      // ),
    );
  }

  Future<void> _toggleVideo() async {
    final newIndex = (currentVideoIndex + 1) % _videoSources.length;
    setState(() {
      currentVideoIndex = newIndex;
    });
    await _videoPlayerController.dispose();
    await _initializeVideoPlayer();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('知识学习'),
      ),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: _chewieController != null &&
                      _chewieController!.videoPlayerController.value.isInitialized
                  ? Chewie(
                      controller: _chewieController!,
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        CircularProgressIndicator(),
                        SizedBox(height: 20),
                        Text('Loading'),
                      ],
                    ),
            ),
          ),
          TextButton(
            onPressed: () {
              _chewieController?.enterFullScreen();
            },
            child: const Text('点击全屏'),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Text(info),
            ),
          ),
          //ElevatedButton(
          //  onPressed: () {
          //    // Logic to mark the video as "已学"
          //    Navigator.pop(context, true);
          //  },
          //  child: Text('标记为已学'),
          //),
          // Add any other controls or information you want to display
        ],
      ),
    );
  }



  Future<bool> getData() async {
    await Future<dynamic>.delayed(const Duration(milliseconds: 50));
    return true;
  }
  Widget getMainListViewUI() {
    return FutureBuilder<bool>(
      future: getData(),
      builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
        if (!snapshot.hasData) {
          return const SizedBox();
        } else {
          return ListView.builder(
            controller: scrollController,
            padding: EdgeInsets.only(
              top: AppBar().preferredSize.height +
                  MediaQuery.of(context).padding.top +
                  24,
              bottom: 62 + MediaQuery.of(context).padding.bottom,
            ),
            itemCount: listViews.length,
            scrollDirection: Axis.vertical,
            itemBuilder: (BuildContext context, int index) {
              return listViews[index];
            },
          );
        }
      },
    );
  }
}

