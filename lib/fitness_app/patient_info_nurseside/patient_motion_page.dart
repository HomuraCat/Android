import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../config.dart';

class PatientMotionPage extends StatefulWidget {
  final String patientID;

  const PatientMotionPage({Key? key, required this.patientID})
      : super(key: key);

  @override
  State<PatientMotionPage> createState() => _PatientMotionPageState();
}

class _PatientMotionPageState extends State<PatientMotionPage> {
  late List<Map<String, dynamic>> _statusMessages;

  @override
  void initState() {
    super.initState();
    _statusMessages = [];
    _fetchPosts();
  }

  Future<void> _fetchPosts() async {
    final String apiUrl = Config.baseUrl + '/motion/fetch';
    var url = Uri.parse(apiUrl);
    try {
      var response = await http.post(
        url,
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode({'username': widget.patientID}),
      );
      if (response.statusCode == 200) {
        List<dynamic> responseData = jsonDecode(response.body);
        setState(() {
          _statusMessages = responseData
              .map((post) => {
                    'content': post['content'],
                    'time': post['time'],
                    'post_id': post['post_id']
                  })
              .toList();
        });
      } else {
        print('Request failed with status: ${response.statusCode}.');
      }
    } catch (e) {
      print('Error fetching posts: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text('树洞'),
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
                  return _buildListTile(context, message);
                },
                childCount: _statusMessages.length,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListTile(BuildContext context, Map<String, dynamic> message) {
    return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Material(
          // Ensure ListTile has a Material ancestor
          child: Container(
            decoration: BoxDecoration(
              color: CupertinoColors.systemGrey6,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                )
              ],
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.all(16),
              title: Text(
                message['content'],
                style: const TextStyle(fontSize: 16),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              subtitle: Text(
                message['time'],
                style: const TextStyle(color: Colors.grey),
              ),
              onTap: () {
                showCupertinoModalPopup(
                  context: context,
                  builder: (context) => CupertinoAlertDialog(
                    content: Text(message['content']),
                    actions: [
                      CupertinoDialogAction(
                        child: const Text('关闭'),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      );
  }
}

class PatientMotionPageAll extends StatefulWidget {
  final String patientID;

  const PatientMotionPageAll({Key? key, required this.patientID})
      : super(key: key);

  @override
  State<PatientMotionPageAll> createState() => _PatientMotionPageAllState();
}

class _PatientMotionPageAllState extends State<PatientMotionPageAll>
    with TickerProviderStateMixin {
  late List<Map<String, dynamic>> _statusMessages = [];

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
        body: jsonEncode(<String, dynamic>{'username': widget.patientID}),
      );

      if (response.statusCode == 200) {
        List<dynamic> responseData = jsonDecode(response.body);
        _statusMessages = responseData.where((post) => post['patient_id'] == widget.patientID)
        .map((post) {
          return {
            'content': post['content'],
            'time': post['time'],
            'post_id': post['post_id'],
            'user_id': post['patient_id'],
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

  @override
  void dispose() {
    animationController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text('动态'),
        automaticallyImplyLeading: false,
      ),
      child: SafeArea(
        child: CustomScrollView(
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
                  return postWidget;
                },
                childCount: _statusMessages.length,
              ),
            ),
          ],
        )
      ),
    );
  }
}