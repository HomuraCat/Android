// lib/fitness_app/my_diary/knowledge_learning/upload_exercise_suggestion_page.dart

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart'; // 新增：用于获取文件的 MIME 类型
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
  File? _imageFile; // 用于存储选择的图片
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _infoController = TextEditingController();
  final TextEditingController _titleController = TextEditingController(); // 新增：用于输入标题

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

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _uploadExerciseSuggestion() async {
    if (_titleController.text.isEmpty ||
        _tutorialVideo == null ||
        _followAlongVideo == null ||
        _descriptionController.text.isEmpty ||
        _imageFile == null) {
      if (!mounted) return;
      _scaffoldMessengerKey.currentState?.showSnackBar(
        SnackBar(content: Text("请填写所有字段并选择标题、两个视频和一张图片。")),
      );
      return;
    }

    final String uploadUrl = Config.baseUrl + '/upload_exercise_suggestion';
    var uri = Uri.parse(uploadUrl);
    var request = http.MultipartRequest('POST', uri);
    request.fields['title'] = _titleController.text; // 添加标题字段
    request.fields['info'] = _descriptionController.text;
    request.fields['source'] = _infoController.text;

    // 打印请求详细信息，便于调试
    print('正在上传到 $uploadUrl');
    print('标题: ${_titleController.text}');
    print('描述: ${_descriptionController.text}');
    print('图片文件路径: ${_imageFile!.path}');
    print('完整视频文件路径: ${_tutorialVideo!.path}');
    print('预览视频文件路径: ${_followAlongVideo!.path}');

    // 添加图片文件，指定 MIME 类型
    request.files.add(
      await http.MultipartFile.fromPath(
        'image',
        _imageFile!.path,
        contentType:
            MediaType('image', lookupMimeType(_imageFile!.path)!.split('/')[1]),
      ),
    );

    // 添加教程视频文件，指定 MIME 类型
    request.files.add(
      await http.MultipartFile.fromPath(
        'source_1',
        _tutorialVideo!.path,
        contentType: MediaType(
            'video', lookupMimeType(_tutorialVideo!.path)!.split('/')[1]),
      ),
    );

    // 添加跟练视频文件，指定 MIME 类型
    request.files.add(
      await http.MultipartFile.fromPath(
        'source_2',
        _followAlongVideo!.path,
        contentType: MediaType(
            'video', lookupMimeType(_followAlongVideo!.path)!.split('/')[1]),
      ),
    );

    try {
      var response = await request.send();

      if (!mounted) return; // 确保部件仍然挂载

      // 读取响应内容
      final responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        _scaffoldMessengerKey.currentState?.showSnackBar(
          SnackBar(content: Text("运动建议上传成功!")),
        );
        // 重置表单
        setState(() {
          _titleController.clear(); // 重置标题
          _tutorialVideo = null;
          _followAlongVideo = null;
          _imageFile = null; // 重置图片
          _descriptionController.clear();
          _infoController.clear();
        });
      } else {
        _scaffoldMessengerKey.currentState?.showSnackBar(
          SnackBar(content: Text("运动建议上传失败: $responseBody")),
        );
        print('上传失败，状态码 ${response.statusCode}: $responseBody');
      }
    } catch (e) {
      if (!mounted) return;
      _scaffoldMessengerKey.currentState?.showSnackBar(
        SnackBar(content: Text("上传过程中发生错误: $e")),
      );
      print("上传过程中发生错误: $e");
    }
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _infoController.dispose();
    _titleController.dispose(); // 释放标题控制器
    super.dispose();
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
              // 标题输入框
              TextField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: '标题',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 20),

              // 上传教程视频
              ElevatedButton(
                onPressed: _pickTutorialVideo,
                child: Text('选择预览视频'),
              ),
              if (_tutorialVideo != null)
                Text(
                    '已选择预览视频: ${_tutorialVideo!.path.split('/').last}'),
              SizedBox(height: 10),

              // 上传跟练视频
              ElevatedButton(
                onPressed: _pickFollowAlongVideo,
                child: Text('选择完整视频'),
              ),
              if (_followAlongVideo != null)
                Text(
                    '已选择完整视频: ${_followAlongVideo!.path.split('/').last}'),
              SizedBox(height: 10),

              // 上传图片
              ElevatedButton(
                onPressed: _pickImage,
                child: Text('选择视频封面图片'),
              ),
              if (_imageFile != null)
                Column(
                  children: [
                    Text('已选择图片: ${_imageFile!.path.split('/').last}'),
                    SizedBox(height: 10),
                    Image.file(
                      _imageFile!,
                      height: 150,
                    ),
                  ],
                ),
              SizedBox(height: 10),

              // 描述文本框
              TextField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: '视频描述',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              SizedBox(height: 10),
              TextField(
                controller: _infoController,
                decoration: InputDecoration(
                  labelText: '信息来源（可以为空）',
                  border: OutlineInputBorder(),
                ),
                maxLines: 1,
              ),
              SizedBox(height: 20),

              // 上传按钮
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
