import 'package:flutter/material.dart';

class MotionPage extends StatefulWidget {
  const MotionPage({Key? key}) : super(key: key);

  @override
  State<MotionPage> createState() => _MotionPageState();
}

class _MotionPageState extends State<MotionPage> {
  List<String> _statusMessages = [
    '今天的天气真好，阳光明媚，适合外出。',
    '在工作中遇到了一些挑战，但我相信我可以克服它们。',
    '看到了一部非常感人的电影，让我思考了很多人生的意义。',
    '“努力不一定成功，但放弃一定会失败。”这句话今天给了我很大的启发。',
  ];

  void _showPostDialog() {
    TextEditingController _textFieldController = TextEditingController();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('发布动态'),
          content: TextField(
            controller: _textFieldController,
            autofocus: true,
            minLines: 3,
            maxLines: 5,
            decoration: const InputDecoration(
              hintText: '分享新鲜事...',
              border: OutlineInputBorder(),
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('取消'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('发布'),
              onPressed: () {
                setState(() {
                  _statusMessages.add(_textFieldController.text);
                  _textFieldController.clear();
                });
                Navigator.of(context).pop();
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
        title: const Text('动态', style: TextStyle(color: Colors.black)),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Colors.black),
            onPressed: _showPostDialog,
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(8.0),
        itemCount: _statusMessages.length,
        itemBuilder: (context, index) {
          final int reversedIndex = _statusMessages.length - 1 - index;
          final message = _statusMessages[reversedIndex];
          return Dismissible(
            key: Key('$reversedIndex-${_statusMessages[reversedIndex]}'),
            direction: DismissDirection.endToStart,
            onDismissed: (direction) {
              setState(() {
                _statusMessages.removeAt(reversedIndex);
              });
              ScaffoldMessenger.of(context)
                  .showSnackBar(SnackBar(content: Text('动态已删除')));
            },
            background: Container(
              alignment: AlignmentDirectional.centerEnd,
              color: Colors.red,
              child: Padding(
                padding: EdgeInsets.fromLTRB(0, 0, 16, 0),
                child: Icon(Icons.delete, color: Colors.white),
              ),
            ),
            child: Card(
              margin: const EdgeInsets.symmetric(vertical: 4.0),
              child: ListTile(
                title: Text(
                  message,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        content: Text(message),
                        actions: [
                          TextButton(
                            child: Text('关闭'),
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(home: MotionPage()));
}
