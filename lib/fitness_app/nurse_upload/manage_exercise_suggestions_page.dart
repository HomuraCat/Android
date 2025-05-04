import 'package:flutter/material.dart';
import 'dart:convert'; // For jsonDecode
import 'package:http/http.dart' as http; // For HTTP requests
import '../../config.dart'; // Import your config file

// --- Define Sport Video Model ---
// **MODIFIED**: Now uses 'title' instead of 'name' to match backend JSON
class SportVideo {
  final int id;
  final String title; // <--- CHANGED from 'name'

  SportVideo({
    required this.id,
    required this.title, // <--- CHANGED from 'name'
  });

  // Factory constructor to create a SportVideo from JSON
  // **MODIFIED**: Checks for and uses 'title' key from JSON
  factory SportVideo.fromJson(Map<String, dynamic> json) {
    // Check if 'id' and 'title' keys exist in the JSON response
    if (json['id'] == null || json['title'] == null) { // <--- CHANGED from 'name'
      print("Error parsing JSON: $json");
      // Updated error message
      throw FormatException("Invalid Video JSON format: Missing 'id' or 'title' key. Check backend response.");
    }
    try {
       return SportVideo(
        id: json['id'] as int,
        title: json['title'] as String, // <--- CHANGED from 'name'
      );
    } catch (e) {
       print("Error casting values during SportVideo.fromJson: $e, JSON: $json");
       throw FormatException("Error parsing video data: $e");
    }
  }
}

// --- Manage Videos Page Widget ---
class ManageVideosPage extends StatefulWidget {
  @override
  _ManageVideosPageState createState() => _ManageVideosPageState();
}

class _ManageVideosPageState extends State<ManageVideosPage> {
  List<SportVideo> _videos = [];
  bool _isLoading = true;
  String? _error;

  final String _baseUrl = Config.baseUrl;

  @override
  void initState() {
    super.initState();
    _fetchVideos();
  }

  // --- Fetch Videos from Backend ---
  Future<void> _fetchVideos() async {
    // Added check for mounted state before async operation
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final response = await http.get(Uri.parse('$_baseUrl/videos')).timeout(const Duration(seconds: 15));

      // Added check for mounted state after async operation
      if (!mounted) return;

      if (response.statusCode == 200) {
        final dynamic decodedBody = jsonDecode(utf8.decode(response.bodyBytes));

        if (decodedBody is List) {
          List<SportVideo> fetchedVideos = [];
          String? parsingErrorMsg; // Track parsing errors separately
          for (var item in decodedBody) {
            if (item is Map<String, dynamic>) {
              try {
                // Uses the modified SportVideo.fromJson which expects 'title'
                fetchedVideos.add(SportVideo.fromJson(item));
              } catch (e) {
                print("Error parsing video item: $item, Error: $e");
                parsingErrorMsg = "部分视频数据加载失败，请检查后台数据格式或键名 ('id', 'title') 是否存在。";
              }
            } else {
              print("Skipping invalid video list item: $item");
            }
          }

          // Check mounted state before final setState
          if (mounted) {
            setState(() {
              _videos = fetchedVideos;
              _isLoading = false;
              // Set error state based on parsing outcome
              _error = parsingErrorMsg;
               // If list is empty AND there was a parsing error, keep the error message.
               // If list is populated despite some errors, the error will show as a snackbar later.
               // If list is empty and no parsing error, it's just an empty list.
            });
          }
        } else {
          throw Exception('Backend did not return a List. Response type: ${decodedBody.runtimeType}');
        }
      } else {
         String errorMsg = '加载视频失败。状态码：${response.statusCode}';
         try {
             final errorData = jsonDecode(response.body);
             errorMsg += "\n错误: ${errorData['error'] ?? errorData['message'] ?? response.body}";
         } catch(_){}
         print(errorMsg);
         // Throw user-friendly message but keep detailed log
         throw Exception('加载视频失败，请稍后重试。');
      }
    } catch (e) {
      print("Error fetching videos: $e");
      // Check mounted state before setting error state
      if (mounted) {
        setState(() {
          // Use more specific error from Exception if available
          _error = e is Exception ? e.toString().split(': ').last : "无法加载视频，请检查网络或稍后重试。";
          _isLoading = false;
        });
      }
    }
  }

  // --- Delete Video Function --- (No changes needed here)
  Future<void> _deleteVideo(int videoId) async {
    final url = Uri.parse('$_baseUrl/videos/$videoId');
    try {
      final response = await http.delete(url).timeout(const Duration(seconds: 10));
      if (!mounted) return;
      if (response.statusCode == 200 || response.statusCode == 204) {
        setState(() {
          _videos.removeWhere((video) => video.id == videoId);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('视频删除成功！'), backgroundColor: Colors.green),
        );
      } else if (response.statusCode == 404) {
         ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('服务器上未找到该视频。'), backgroundColor: Colors.orange),
        );
         _fetchVideos(); // Refresh list if item not found on server
      } else {
         print('Failed to delete video. Status code: ${response.statusCode}');
         print('Response body: ${response.body}');
         String errorMessage = '未知错误';
         try {
            final errorData = jsonDecode(response.body);
            errorMessage = errorData['error'] ?? errorData['message'] ?? '未知错误';
         } catch(_){}
         throw Exception('删除视频失败: $errorMessage');
      }
    } catch (e) {
      print("Error deleting video: $e");
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('删除视频失败，请稍后重试。'), backgroundColor: Colors.red),
      );
    }
  }

  // --- Show Confirmation Dialog for Deletion ---
  // **MODIFIED**: Displays 'video.title' in the confirmation message
  Future<void> _showDeleteConfirmationDialog(SportVideo video) async {
    if (!mounted) return;
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text('确认删除'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                // Use video.title here
                Text('您确定要删除视频 "${video.title}" 吗？'), // <--- CHANGED from video.name
                SizedBox(height: 8),
                Text('此操作无法撤销。', style: TextStyle(color: Colors.grey[600])),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('取消'),
              onPressed: () => Navigator.of(dialogContext).pop(),
            ),
            TextButton(
              child: Text('删除', style: TextStyle(color: Colors.red)),
              onPressed: () {
                Navigator.of(dialogContext).pop();
                _deleteVideo(video.id);
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('管理运动视频'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _isLoading ? null : _fetchVideos,
            tooltip: '刷新',
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  // --- Build Body Based on State ---
  Widget _buildBody() {
    if (_isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    // Show full error page if loading failed AND list is empty
    if (_error != null && _videos.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
             mainAxisAlignment: MainAxisAlignment.center,
             children: [
                Icon(Icons.error_outline, color: Colors.red, size: 50),
                SizedBox(height: 10),
                Text('加载视频数据时出错', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                SizedBox(height: 10),
                Text(_error!, textAlign: TextAlign.center),
                SizedBox(height: 20),
                ElevatedButton(
                   onPressed: _fetchVideos,
                   child: Text('重试'),
                )
             ]
          ),
        ),
      );
    }

    // Show Snackbar for partial errors if some data was loaded
    if (_error != null && _videos.isNotEmpty) {
       WidgetsBinding.instance.addPostFrameCallback((_) {
         if(mounted) { // Check mounted again before showing snackbar
             ScaffoldMessenger.of(context).showSnackBar(SnackBar(
               content: Text(_error!),
               backgroundColor: Colors.orange,
            ));
         }
       });
       // Proceed to show the partially loaded data
    }


    if (_videos.isEmpty && _error == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
              Icon(Icons.video_library_outlined, size: 60, color: Colors.grey),
              SizedBox(height: 15),
              Text('未找到任何运动视频。'),
              SizedBox(height: 10),
              ElevatedButton(
                 onPressed: _fetchVideos,
                 child: Text('刷新'),
              )
          ],
        )
      );
    }

    // --- Display Video List ---
    return ListView.builder(
      itemCount: _videos.length,
      itemBuilder: (context, index) {
        final video = _videos[index];
        return Card(
          margin: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
          child: ListTile(
            // **MODIFIED**: Display 'video.title'
            title: Text(video.title), // <--- CHANGED from video.name
            leading: Icon(Icons.video_camera_back_outlined),
            trailing: IconButton(
              icon: Icon(Icons.delete_outline, color: Colors.redAccent),
              tooltip: '删除视频',
              onPressed: () {
                _showDeleteConfirmationDialog(video);
              },
            ),
          ),
        );
      },
    );
  }
}