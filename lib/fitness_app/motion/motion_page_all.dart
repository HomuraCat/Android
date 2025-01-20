import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/Spsave_module.dart';
import '../../config.dart';
import '../motion/motion_page.dart';

class MotionPageAll extends StatefulWidget {
  const MotionPageAll({Key? key}) : super(key: key);

  @override
  State<MotionPageAll> createState() => _MotionPageAllState();
}

class _MotionPageAllState extends State<MotionPageAll>
    with TickerProviderStateMixin {
  late List<Map<String, dynamic>> _statusMessages = [];

  late String patientID = "", name = "";
  AnimationController? animationController;
  String _currentPage = 'all'; // Variable to track the current page

  @override
  void initState() {
    super.initState();
    animationController = AnimationController(
        duration: const Duration(milliseconds: 800), vsync: this);
    animationController!.forward();
    _InitConfig();
  }

  void _InitConfig() async {
    Map<String, dynamic> account = await SpStorage.instance.readAccount();
    patientID = account['patientID'];
    name = account['name'];

    setState(() {
      _fetchPosts();
    });
  }

  Future<void> _addPoint(int pointValue) async {
    final String apiUrl =
        Config.baseUrl + '/addPoint'; // Replace with actual API endpoint
    var url = Uri.parse(apiUrl);

    try {
      var response = await http.post(
        url,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({
          'id': patientID, // Pass patientID
          'points_to_add': pointValue, // Pass the point value to be added
        }),
      );

      if (response.statusCode == 200) {
        // final data = jsonDecode(response.body);
        setState(() {
          // Update points with the response
        });
        print('Point added successfully');
      } else {
        print('Failed to add point. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error adding point: $e');
    }
  }

  Future<void> _fetchPosts() async {
    final String apiUrl = Config.baseUrl + '/motion/fetchall';
    var url = Uri.parse(apiUrl);

    try {
      var response = await http.post(
        url,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, dynamic>{'username': patientID}),
      );

      if (response.statusCode == 200) {
        // 如果请求成功，更新状态消息
        List<dynamic> responseData = jsonDecode(response.body);
        setState(() {
          _statusMessages = responseData.map((post) {
            return {
              'content': post['content'],
              'time': post['time'],
              'post_id': post['post_id'],
              'user_id': post['patient_id'],
            };
          }).toList();
        });
      } else {
        print('Request failed with status: ${response.statusCode}.');
        // 请求失败时保留原内容，不清空数据
      }
    } catch (e) {
      // 捕获所有错误并保留原有内容
      print('Error fetching posts: $e');
      // 可以选择在 UI 上显示错误提示
      // _showErrorDialog('网络异常，请稍后再试！');
    }
  }

  Future<void> _createPost(String content) async {
    final String apiUrl = Config.baseUrl + '/motion/create_all';
    var url = Uri.parse(apiUrl);
    try {
      var response = await http.post(
        url,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({'patientID': patientID, 'content': content}),
      );

      if (response.statusCode == 200) {
        print('Post created successfully.');
        _addPoint(5);

        // 显示成功弹窗
        showCupertinoDialog(
          context: context,
          builder: (BuildContext context) {
            return CupertinoAlertDialog(
              title: Text('成功'),
              content: Text('发表成功，分数加5！'),
              actions: <Widget>[
                CupertinoDialogAction(
                  child: Text('确定'),
                  onPressed: () {
                    Navigator.of(context).pop(); // 关闭弹窗
                  },
                ),
              ],
            );
          },
        );

        _fetchPosts(); // 刷新帖子列表，显示新发表的帖子
      } else {
        print('Failed to create the post. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error creating post: $e');
    }
  }

  Future<void> _deletePost(int postId) async {
    final String apiUrl = Config.baseUrl + '/motion/delete_all';
    var url = Uri.parse(apiUrl);
    try {
      var response = await http.delete(
        url,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({'post_id': postId}),
      );
      if (response.statusCode == 200) {
        print('Post deleted successfully.');
      } else {
        print('Failed to delete the post. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error deleting post: $e');
    }
  }

  @override
  void dispose() {
    animationController?.dispose();
    super.dispose();
  }

  void _showPostDialog() {
    TextEditingController _textFieldController = TextEditingController();
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: const Text('发布动态'),
          content: CupertinoTextField(
            controller: _textFieldController,
            autofocus: true,
            maxLines: 5,
            placeholder: '分享新鲜事...',
          ),
          actions: <Widget>[
            CupertinoDialogAction(
              child: const Text('取消'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            CupertinoDialogAction(
              child: const Text('发布'),
              isDefaultAction: true,
              onPressed: () {
                if (_textFieldController.text.isNotEmpty) {
                  _createPost(_textFieldController.text);
                  _textFieldController.clear();
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }

  // Method to build MotionPageAll content
  Widget _buildMotionPageAll() {
    return CustomScrollView(
      physics:
          const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
      slivers: [
        CupertinoSliverRefreshControl(
          onRefresh: _fetchPosts,
        ),
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              final message = _statusMessages[index];
              bool isOwnPost = message['user_id'] == patientID;

              Widget postWidget = Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Material(
                  // Wrapping with Material widget
                  color: Colors.transparent,
                  child: Container(
                    decoration: BoxDecoration(
                        color: CupertinoColors.systemGrey6,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            offset: Offset(0, 2),
                          )
                        ]),
                    child: InkWell(
                      onTap: () {
                        showCupertinoModalPopup(
                          context: context,
                          builder: (context) {
                            return CupertinoAlertDialog(
                              content: Text(message['content']),
                              actions: [
                                CupertinoDialogAction(
                                  child: const Text('关闭'),
                                  onPressed: () => Navigator.of(context).pop(),
                                ),
                              ],
                            );
                          },
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Top row with user id and time
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '用户ID: ${message['user_id']}',
                                  style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  message['time'],
                                  style: TextStyle(color: Colors.grey),
                                ),
                              ],
                            ),
                            SizedBox(height: 8),
                            Text(
                              message['content'],
                              style: const TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );

              if (isOwnPost) {
                return Dismissible(
                  key: Key(message['post_id'].toString()),
                  direction: DismissDirection.endToStart,
                  onDismissed: (direction) {
                    _deletePost(message['post_id']); // Call delete method
                    setState(() {
                      _statusMessages.removeAt(index);
                    });
                  },
                  background: Container(
                    color: Colors.red,
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    alignment: Alignment.centerRight,
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  child: postWidget,
                );
              } else {
                return postWidget;
              }
            },
            childCount: _statusMessages.length,
          ),
        ),
      ],
    );
  }

  // Method to build the navigation bar
  ObstructingPreferredSizeWidget _buildNavigationBar() {
    if (_currentPage == 'all') {
      return CupertinoNavigationBar(
        leading: CupertinoButton(
          padding: EdgeInsets.zero,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const Icon(CupertinoIcons.arrow_left,
                  color: CupertinoColors.activeBlue),
              const SizedBox(width: 4),
              Text('切换树洞', style: TextStyle(color: CupertinoColors.activeBlue)),
            ],
          ),
          onPressed: () {
            setState(() {
              _currentPage = 'motion'; // switch to 'motion' page
            });
          },
        ),
        middle: const Text('动态'),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const Icon(CupertinoIcons.add, color: CupertinoColors.activeBlue),
              const SizedBox(width: 4),
              Text('发布动态', style: TextStyle(color: CupertinoColors.activeBlue)),
            ],
          ),
          onPressed: _showPostDialog,
        ),
        automaticallyImplyLeading: false,
      );
    } else {
      // For 'motion' page, only display the switch button
      return CupertinoNavigationBar(
        leading: CupertinoButton(
          padding: EdgeInsets.zero,
          child:
              Text('切换动态', style: TextStyle(color: CupertinoColors.activeBlue)),
          onPressed: () {
            setState(() {
              _currentPage = 'all'; // switch back to 'all' page
            });
          },
        ),
        border: null, // Remove the bottom border
        backgroundColor: Colors.transparent, // Make the background transparent
        automaticallyImplyLeading: false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: _buildNavigationBar(),
      child: SafeArea(
        child: _currentPage == 'all' ? _buildMotionPageAll() : MotionPage(),
      ),
    );
  }
}

void main() {
  runApp(const CupertinoApp(home: MotionPageAll()));
}
