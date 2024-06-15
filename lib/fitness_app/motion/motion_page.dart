import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../utils/Spsave_module.dart';

class MotionPage extends StatefulWidget {
  const MotionPage({Key? key}) : super(key: key);

  @override
  State<MotionPage> createState() => _MotionPageState();
}

class _MotionPageState extends State<MotionPage> with TickerProviderStateMixin {
  List<String> _statusMessages = [
    '今天的天气真好，阳光明媚，适合外出。',
    '在工作中遇到了一些挑战，但我相信我可以克服它们。',
    '看到了一部非常感人的电影，让我思考了很多人生的意义。',
    '“努力不一定成功，但放弃一定会失败。”这句话今天给了我很大的启发。',
  ];
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

  @override
  void dispose() {
    animationController?.dispose();
    super.dispose();
  }

  void _InitConfig() async {
    Map<String, dynamic> account = await SpStorage.instance.readAccount();
    patientID = account['patientID'];
    name = account['name'];
    setState(() {});
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
                  setState(() {
                    _statusMessages.add(_textFieldController.text);
                    _textFieldController.clear();
                  });
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
          child: const Icon(CupertinoIcons.add),
          onPressed: _showPostDialog,
        ),
        automaticallyImplyLeading:
            false, // This line prevents auto-generating the back button
      ),
      child: SafeArea(
        child: ListView.builder(
          padding: const EdgeInsets.all(8.0),
          itemCount: _statusMessages.length,
          itemBuilder: (context, index) {
            final int reversedIndex = _statusMessages.length - 1 - index;
            final message = _statusMessages[reversedIndex];
            return Dismissible(
              key: Key(message),
              direction: DismissDirection.endToStart,
              onDismissed: (direction) {
                setState(() {
                  _statusMessages.removeAt(reversedIndex);
                });
              },
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
                      message,
                      style: const TextStyle(fontSize: 16),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                    onTap: () {
                      showCupertinoModalPopup(
                        context: context,
                        builder: (context) {
                          return CupertinoAlertDialog(
                            content: Text(message),
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
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

void main() {
  runApp(const CupertinoApp(home: MotionPage()));
}
