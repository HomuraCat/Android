import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/Spsave_module.dart';
import '../../config.dart';

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
        List<dynamic> responseData = jsonDecode(response.body);
        _statusMessages = responseData.map((post) {
          return {
            'content': post['content'],
            'time': post['time'],
            'post_id': post['post_id'],
            'user_id': post['patient_id'], // Include user_id
          };
        }).toList();
        setState(() {});
      } else {
        print('Request failed with status: ${response.statusCode}.');
        setState(() {
          _statusMessages = [];
        });
      }
    } catch (e) {
      print('Error fetching posts: $e');
      setState(() {
        _statusMessages = [];
      });
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
        _fetchPosts(); // Refresh the posts list to include the new post
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

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
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
      ),
      child: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics()),
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
                                    onPressed: () =>
                                        Navigator.of(context).pop(),
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
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
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
        ),
      ),
    );
  }
}

void main() {
  runApp(const CupertinoApp(home: MotionPageAll()));
}
