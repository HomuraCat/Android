import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:best_flutter_ui_templates/fitness_app/my_diary/knowledge_learning/weekly_test_page.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
class KnowledgeLearningPage extends StatefulWidget {
  final Map<String, dynamic> video;

  KnowledgeLearningPage({Key? key, required this.video}) : super(key: key);

  @override
  _KnowledgeLearningPageState createState() => _KnowledgeLearningPageState();
}

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
    var url = Uri.parse('http://10.0.2.2:5001/mylearn_videos');
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
            buildTestButton(context),
            const SizedBox(height: 24),
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
Widget buildVideoListItem(Map<String, dynamic> video) {
  return Card(
    child: ListTile(
      title: Text(video['title']),
      subtitle: Text(video['completed'] ? '已学' : '学习中'),  // Show learning status as a subtitle
      trailing: Icon(video['completed'] ? Icons.check_circle : Icons.play_circle_fill, 
                     color: video['completed'] ? Colors.green : Colors.blue),
      onTap: () async {
        // Navigate to the video page whether it's completed or not
        bool? updated = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => KnowledgeLearningPage(video: video),
          ),
        );

        // Only update the state if there was a change and the video was not previously completed
        if (updated != null && updated && !video['completed']) {
          setState(() {
            video['status'] = '已学';
            video['completed'] = true;
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
  String info = "";
  final List<String> _videoSources = [
    'assets/videos/1.mp4',
  ];

  @override
  void initState() {
    super.initState();
    info = widget.video['info']; 
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
  _videoPlayerController = VideoPlayerController.asset(widget.video['source']);
  await _videoPlayerController.initialize();
  _createChewieController();
  setState(() {});
  _videoPlayerController.addListener(_checkVideo);
}

void _checkVideo() {
  final bool isPlaying = _videoPlayerController.value.isPlaying;
  final bool isVideoEnded = _videoPlayerController.value.position >= _videoPlayerController.value.duration;
  if (!isPlaying && isVideoEnded) {
    // If the video has finished playing, mark it as learned
    _markVideoAsLearned();
  }
}

void _markVideoAsLearned() async {
  // Assuming 'id' is a property of your video that identifies it uniquely in the backend.
  var url = Uri.parse('http://10.0.2.2:5001/update_learn_video_status/${widget.video['id']}');
  var response = await http.post(
    url,
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({'completed': '1'})
  );

  if (response.statusCode == 200) {
    // Optionally handle the response, e.g., showing a success message
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("视频标记为已完成!")));
  } else {
    // Handle error, e.g., showing an error message
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("视频标记失败！")));
  }
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
        title: Text(widget.video['title']),
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

