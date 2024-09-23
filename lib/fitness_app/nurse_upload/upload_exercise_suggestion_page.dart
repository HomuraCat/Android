import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import '../../config.dart'; // 根据您的项目结构调整路径

class UploadExerciseSuggestionPage extends StatefulWidget {
  @override
  _UploadExerciseSuggestionPageState createState() =>
      _UploadExerciseSuggestionPageState();
}

class _UploadExerciseSuggestionPageState
    extends State<UploadExerciseSuggestionPage> {
  final ImagePicker _picker = ImagePicker();
  File? _tutorialVideo;
  File? _followAlongVideo;
  final TextEditingController _descriptionController = TextEditingController();

  // 定义 GlobalKey 用于获取 ScaffoldMessengerState
  final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();

  Future<void> _pickTutorialVideo() async {
    final pickedFile = await _picker.pickVideo(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _tutorialVideo = File(pickedFile.path);
      });
    }
  }

  Future<void> _pickFollowAlongVideo() async {
    final pickedFile = await _picker.pickVideo(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _followAlongVideo = File(pickedFile.path);
      });
    }
  }

  Future<void> _uploadExerciseSuggestion() async {
    if (_tutorialVideo == null ||
        _followAlongVideo == null ||
        _descriptionController.text.isEmpty) {
      if (!mounted) return;
      _scaffoldMessengerKey.currentState?.showSnackBar(
        SnackBar(content: Text("请填写所有字段并选择两个视频。")),
      );
      return;
    }

    final String uploadUrl = Config.baseUrl + '/upload_exercise_suggestion';
    var request = http.MultipartRequest('POST', Uri.parse(uploadUrl));
    request.fields['description'] = _descriptionController.text;
    request.files.add(
      await http.MultipartFile.fromPath('tutorial_video', _tutorialVideo!.path),
    );
    request.files.add(
      await http.MultipartFile.fromPath(
          'follow_along_video', _followAlongVideo!.path),
    );

    var response = await request.send();

    if (!mounted) return; // 确保部件仍然挂载

    if (response.statusCode == 200) {
      _scaffoldMessengerKey.currentState?.showSnackBar(
        SnackBar(content: Text("运动建议上传成功!")),
      );
      // 重置表单
      setState(() {
        _tutorialVideo = null;
        _followAlongVideo = null;
        _descriptionController.clear();
      });
    } else {
      _scaffoldMessengerKey.currentState?.showSnackBar(
        SnackBar(content: Text("运动建议上传失败。")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldMessenger(
      key: _scaffoldMessengerKey,
      child: Scaffold(
        appBar: AppBar(
          title: Text('上传运动建议'),
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.all(16.0),
          child: Column(
            children: [
              ElevatedButton(
                onPressed: _pickTutorialVideo,
                child: Text('选择教程视频'),
              ),
              if (_tutorialVideo != null)
                Text('已选择教程视频: ${_tutorialVideo!.path.split('/').last}'),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: _pickFollowAlongVideo,
                child: Text('选择跟练视频'),
              ),
              if (_followAlongVideo != null)
                Text('已选择跟练视频: ${_followAlongVideo!.path.split('/').last}'),
              TextField(
                controller: _descriptionController,
                decoration: InputDecoration(labelText: '视频描述'),
                maxLines: 3,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _uploadExerciseSuggestion,
                child: Text('上传运动建议'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
