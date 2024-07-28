import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class PatientMotionPage extends StatefulWidget {
  const PatientMotionPage({Key? key, required this.patientID}) : super(key: key);
  final String patientID;

  @override
  State<PatientMotionPage> createState() => _PatientMotionPageState();
}

class _PatientMotionPageState extends State<PatientMotionPage> with TickerProviderStateMixin {
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
    var url = Uri.parse('http://10.0.2.2:5001/motion/fetch');
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
        _statusMessages = responseData.map((post) {
          return {
            'content': post['content'],
            'time': post['time'],
            'post_id': post['post_id']
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
                  return Dismissible(
                    key: Key(message['post_id'].toString()),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      color: Colors.red,
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      alignment: Alignment.centerRight,
                      child: const Icon(Icons.delete, color: Colors.white),
                    ),
                    child: Padding(
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
                            style: TextStyle(color: Colors.grey),
                          ),
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
                        ),
                      ),
                    ),
                  );
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
