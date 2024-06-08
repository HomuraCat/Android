import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:best_flutter_ui_templates/fitness_app/my_diary/knowledge_learning/weekly_test_page.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
class SportAdvicePage extends StatefulWidget {
  final Map<String, dynamic> video;
  SportAdvicePage({Key? key, required this.video}) : super(key: key);
  @override
  _SportAdvicePageState createState() => _SportAdvicePageState();
}

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
    var url = Uri.parse('http://10.0.2.2:5001/mysport_videos');
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
          'image': data['image']
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
        title: Text("运动建议"),
      ),
      body: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 1,
          childAspectRatio: 1.0,
        ),
        itemCount: videos.length,
        itemBuilder: (context, index) {
          return buildVideoGridItem(videos[index]);
        },
      ),
    );
  }

Widget buildVideoGridItem(Map<String, dynamic> video) {
  return GestureDetector(
    onTap: () async {
      bool? updated = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SportAdvicePage(video: video),
        ),
      );
      if (updated != null && updated && !video['completed']) {
        setState(() {
          video['status'] = '已学';
          video['completed'] = true;
        });
      }
    },
    child: Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30)
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            flex: 2,
            child: ClipRRect(
              borderRadius: BorderRadius.all(Radius.circular(30)), // 设置所有角的圆角
              child: Image.asset(
                video['image'],  // Use Image.asset for local assets
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
              ),
            ),
          ),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                //Icon(
                //  video['completed'] ? Icons.check_circle : Icons.play_circle_fill,
                //  color: video['completed'] ? Colors.green : Colors.blue,
                //  size: 24,
                //),
                Padding(
                  padding: EdgeInsets.only(top: 8),
                  child: Text(
                    video['title'],
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                Text(
                  video['completed'] ? '已学' : '学习中',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
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
      subtitle: Text(video['completed'] ? '已学' : '学习中'),  // Show learning status as a subtitle
      trailing: Icon(video['completed'] ? Icons.check_circle : Icons.play_circle_fill, 
                     color: video['completed'] ? Colors.green : Colors.blue),
      onTap: () async {
        // Navigate to the video page whether it's completed or not
        bool? updated = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SportAdvicePage(video: video),
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

class _SportAdvicePageState extends State<SportAdvicePage> {
  List<Widget> listViews = <Widget>[];
  final ScrollController scrollController = ScrollController();
  late VideoPlayerController _videoPlayerController;
  ChewieController? _chewieController;
  bool isPracticeVideo = false; 
  String buttonText = '跟练';
  int currentVideoIndex = 0;
  double topBarOpacity = 0.0;
  String info = "温馨提示：感觉不适请立即停止运动。";


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
  //_videoPlayerController = VideoPlayerController.asset(widget.video['source']);
  //print("!@#!@#");
  //print(widget.video);
  //_videoPlayerController = VideoPlayerController.asset("assets/videos/2.mp4");
  _videoPlayerController = isPracticeVideo ? VideoPlayerController.asset(widget.video['source_2']) : VideoPlayerController.asset(widget.video['source_1']);
  await _videoPlayerController.initialize();
  _createChewieController();
  setState(() {});
  _videoPlayerController.addListener(_checkVideo);
}

void _checkVideo() {
  final bool isPlaying = _videoPlayerController.value.isPlaying;
  final bool isVideoEnded = _videoPlayerController.value.position >= _videoPlayerController.value.duration;
  if (!isPlaying && isVideoEnded && isPracticeVideo) {
    // If the video has finished playing, mark it as learned
    _markVideoAsLearned();
  }
}

void _markVideoAsLearned() async {
  // Assuming 'id' is a property of your video that identifies it uniquely in the backend.
  var url = Uri.parse('http://10.0.2.2:5001/update_sport_video_status/${widget.video['id']}');
  var response = await http.post(
    url,
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({'completed': '1'})
  );

  if (response.statusCode == 200) {
    // Optionally handle the response, e.g., showing a success message
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Video marked as completed!")));
  } else {
    // Handle error, e.g., showing an error message
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Failed to update video status.")));
  }
}

  @override
  void dispose() {
    _videoPlayerController.removeListener(_checkVideo); // Remove listener
    _videoPlayerController.dispose();
    _chewieController?.dispose();
    scrollController.dispose();
    super.dispose();
  }


  void _createChewieController() {
    _chewieController = ChewieController(
      videoPlayerController: _videoPlayerController,
      autoPlay: true,
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
    setState(() {
      isPracticeVideo = !isPracticeVideo;
      buttonText = isPracticeVideo ? '教学' : '跟练';
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
                        Text('加载中...'),
                      ],
                    ),
            ),
          ),
          Padding(
              padding: EdgeInsets.only(left: 16, right: 16, bottom: 16),
              child: ElevatedButton(
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.resolveWith<Color>((Set<MaterialState> states) {
                    if (states.contains(MaterialState.pressed))
                      return buttonText == "跟练" ? Colors.green[800]! : Colors.blue[800]!; // Pressed color
                    return buttonText == "教学" ? Colors.green : Colors.blue; // Default color
                  }),
                  foregroundColor: MaterialStateProperty.all<Color>(Colors.white), // Text color
                  minimumSize: MaterialStateProperty.all<Size>(Size(double.infinity, 50)), // Button width and height
                ),
                onPressed: () {
                  setState(() {
                    buttonText = buttonText == "跟练" ? "教学" : "跟练";
                  });
                  _toggleVideo();
                },
                child: 
                  Text(buttonText,
                  style: TextStyle(
                    fontSize: 30, // Increase the font size here
                  ),
                )
              ),
            ),
          Expanded(
            child: SingleChildScrollView(
              controller: scrollController,
              child: Text(info,
                style: TextStyle(
                    fontSize:   20, // Increase the font size here
                  ),
              ),
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

