import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../config.dart'; // 根据您的项目结构调整路径

class UploadKnowledgeLearningPage extends StatefulWidget {
  @override
  _UploadKnowledgeLearningPageState createState() => _UploadKnowledgeLearningPageState();
}

class _UploadKnowledgeLearningPageState extends State<UploadKnowledgeLearningPage> {
  final TextEditingController _topicController = TextEditingController();
  final TextEditingController _urlController = TextEditingController();

  // 定义 GlobalKey 用于获取 ScaffoldMessengerState
  final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();

  Future<void> _uploadKnowledgeLearning() async {
    if (_topicController.text.isEmpty || _urlController.text.isEmpty) {
      if (!mounted) return;
      _scaffoldMessengerKey.currentState?.showSnackBar(
        SnackBar(content: Text("请填写所有字段。")),
      );
      return;
    }

    final String uploadUrl = Config.baseUrl + '/upload_knowledge_learning';
    var request = http.MultipartRequest('POST', Uri.parse(uploadUrl));
    request.fields['topic'] = _topicController.text;
    request.fields['url'] = _urlController.text;

    var response = await request.send();

    if (!mounted) return; // 确保部件仍然挂载

    if (response.statusCode == 200) {
      _scaffoldMessengerKey.currentState?.showSnackBar(
        SnackBar(content: Text("知识学习上传成功!")),
      );
      // 重置表单
      setState(() {
        _topicController.clear();
        _urlController.clear();
      });
    } else {
      _scaffoldMessengerKey.currentState?.showSnackBar(
        SnackBar(content: Text("知识学习上传失败。")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldMessenger(
      key: _scaffoldMessengerKey,
      child: Scaffold(
        appBar: AppBar(
          title: Text('上传知识学习'),
        ),
        body: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextField(
                controller: _topicController,
                decoration: InputDecoration(labelText: '知识主题'),
              ),
              TextField(
                controller: _urlController,
                decoration: InputDecoration(labelText: '链接地址'),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _uploadKnowledgeLearning,
                child: Text('上传知识学习'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
