// lib/fitness_app/my_diary/knowledge_learning/sport_advice_page.dart

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../../config.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../utils/Spsave_module.dart';

class SportAdvicePage extends StatefulWidget {
  final Map<String, dynamic> video;
  final bool isCompleted;

  SportAdvicePage({
    Key? key,
    required this.video,
    required this.isCompleted,
  }) : super(key: key);

  @override
  _SportAdvicePageState createState() => _SportAdvicePageState();
}

class _SportAdvicePageState extends State<SportAdvicePage> {
  late VideoPlayerController _videoPlayerController;
  ChewieController? _chewieController;
  Map<String, dynamic>? _videoDetails;

  // [SIMPLIFIED] Simplified loading states, no download state needed
  bool _isLoadingDetails = true;
  bool _isLoadingVideo = false; // General loading state for video initialization

  // false = preview video, true = full video
  bool isPracticeVideo = false;

  String buttonText = '跳转到完整版视频';
  double topBarOpacity = 0.0;
  String info = "温馨提示：感觉不适请立即停止运动。";
  ScrollController scrollController = ScrollController();
  String? _userID;

  @override
  void initState() {
    super.initState();
    fetchUserData().then((_) {
      _fetchVideoDetails();
    });
    // Initialize with the default video (preview)
    _initializeVideoPlayer();
    scrollController.addListener(_scrollListener);
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

  Future<void> fetchUserData() async {
    Map<String, dynamic>? account = await SpStorage.instance.readAccount();
    if (account != null) {
      _userID = account['patientID'];
    } else {
      print('No account information found');
    }
  }

  Future<void> _fetchVideoDetails() async {
    final String apiUrl = '${Config.baseUrl}/get_video_details/${widget.video['id']}';
    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        if (!mounted) return;
        setState(() {
          _videoDetails = jsonDecode(response.body);
          _isLoadingDetails = false;
        });
      } else {
        print('Failed to load video details: ${response.body}');
        _handleLoadError();
      }
    } catch (e) {
      print('Error fetching video details: $e');
      _handleLoadError();
    }
  }

  // [OPTIMIZATION] Fully streamlined video initialization. All videos are streamed.
  Future<void> _initializeVideoPlayer() async {
    if (!mounted) return;
    setState(() {
      _isLoadingVideo = true;
    });

    String videoSource = isPracticeVideo ? widget.video['source_2'] : widget.video['source_1'];
    String fullVideoUrl = Config.baseUrl.endsWith('/')
        ? Config.baseUrl + videoSource
        : Config.baseUrl + '/' + videoSource;

    try {
      print("Initializing network stream for video: $fullVideoUrl");
      _videoPlayerController = VideoPlayerController.networkUrl(
        Uri.parse(fullVideoUrl),
        videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true),
      );

      await _videoPlayerController.initialize();
      _createChewieController();
      _videoPlayerController.addListener(_checkVideo);

    } catch (e) {
      print("Error initializing video: $e");
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("视频初始化失败: $e")));
    } finally {
      if(mounted) {
        setState(() {
          _isLoadingVideo = false;
        });
      }
    }
  }

  void _createChewieController() {
    _chewieController = ChewieController(
      videoPlayerController: _videoPlayerController,
      autoPlay: true,
      looping: false,
      errorBuilder: (context, errorMessage) {
        return Center(child: Text(errorMessage, style: TextStyle(color: Colors.white)));
      },
    );
  }

  Future<void> _toggleVideo() async {
    // Gracefully dispose previous controllers
    await _videoPlayerController.pause();
    _videoPlayerController.removeListener(_checkVideo);
    _videoPlayerController.dispose();
    _chewieController?.dispose();
    _chewieController = null;

    // Toggle state and update button text
    isPracticeVideo = !isPracticeVideo;
    buttonText = isPracticeVideo ? '返回预览视频' : '学习完整版';

    // Re-initialize for the new video
    await _initializeVideoPlayer();
  }

  void _checkVideo() {
    if (_videoPlayerController.value.isInitialized) {
      final bool isPlaying = _videoPlayerController.value.isPlaying;
      final bool isVideoEnded = _videoPlayerController.value.position >= _videoPlayerController.value.duration;

      // Mark as learned only when the full practice video is finished
      if (!isPlaying && isVideoEnded && isPracticeVideo) {
        _markVideoAsLearned();
      }
    }
  }

  void _markVideoAsLearned() async {
    // Prevent multiple submissions if already completed
    if(widget.isCompleted) return;
    
    final String apiUrl = '${Config.baseUrl}/update_sport_video_status/${widget.video['id']}';
    var url = Uri.parse(apiUrl);

    try {
      var response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'userID': _userID}),
      );

      if (response.statusCode == 200) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("恭喜你，已完成学习！")));
        Navigator.pop(context, true); // Return true to notify parent page
      } else {
        throw Exception('Failed to update status: ${response.body}');
      }
    } catch (e) {
      print("Error updating video status: $e");
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("更新学习状态失败: $e")));
    }
  }
  
  void _scrollListener() {
    if (scrollController.offset >= 24) {
      if (topBarOpacity != 1.0) setState(() => topBarOpacity = 1.0);
    } else if (scrollController.offset > 0) {
      setState(() => topBarOpacity = scrollController.offset / 24);
    } else {
      if (topBarOpacity != 0.0) setState(() => topBarOpacity = 0.0);
    }
  }

  void _handleLoadError() {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('无法加载视频详情')));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.video['title'])),
      body: SingleChildScrollView(
        controller: scrollController,
        child: Column(
          children: [
            AspectRatio(
              aspectRatio: 16 / 9,
              child: (_isLoadingVideo || _chewieController == null || !_chewieController!.videoPlayerController.value.isInitialized)
                  ? Container(
                      color: Colors.black,
                      child: Center(
                        child: _isLoadingVideo 
                            ? CircularProgressIndicator(color: Colors.white) 
                            : CachedNetworkImage(
                                // Display thumbnail while loading or before video starts
                                imageUrl: Config.baseUrl + '/' + widget.video['image'],
                                fit: BoxFit.cover,
                                placeholder: (context, url) => Center(child: CircularProgressIndicator()),
                                errorWidget: (context, url, error) => Icon(Icons.broken_image, color: Colors.grey, size: 50),
                              ),
                      ),
                    )
                  : Chewie(key: UniqueKey(), controller: _chewieController!),
            ),
            Padding(
              padding: EdgeInsets.all(16),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: isPracticeVideo ? Colors.green : Colors.blue,
                  foregroundColor: Colors.white,
                  minimumSize: Size(double.infinity, 50),
                  textStyle: TextStyle(fontSize: 20),
                ),
                onPressed: _isLoadingVideo ? null : _toggleVideo, // Disable button while loading
                child: _isLoadingVideo ? CircularProgressIndicator(color: Colors.white) : Text(buttonText),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(info, style: TextStyle(fontSize: 16, color: Colors.grey[800])),
                  SizedBox(height: 16),
                  if (widget.video['info'] != null && widget.video['info'].isNotEmpty)
                    Padding(
                      padding: EdgeInsets.only(bottom: 12),
                      child: Text(widget.video['info'], style: TextStyle(fontSize: 16)),
                    ),
                  if (widget.video['source'] != null && widget.video['source'].isNotEmpty)
                    Text('信息来源：${widget.video['source']}',
                        style: TextStyle(fontSize: 14, color: Colors.grey[600], fontStyle: FontStyle.italic)),
                  SizedBox(height: 20),
                  Center(
                    child: Text(
                      widget.isCompleted ? '已学完' : '学习中',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: widget.isCompleted ? Colors.green : Colors.orange,
                      ),
                    ),
                  ),
                   SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}