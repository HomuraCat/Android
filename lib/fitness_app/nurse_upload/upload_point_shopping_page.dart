import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import '../../config.dart'; // 根据您的项目结构调整路径

class UploadPointShoppingPage extends StatefulWidget {
  @override
  _UploadPointShoppingPageState createState() =>
      _UploadPointShoppingPageState();
}

class _UploadPointShoppingPageState
    extends State<UploadPointShoppingPage> {
  final ImagePicker _picker = ImagePicker();
  File? _itemImage;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _pointsController = TextEditingController();
  final TextEditingController _instructionsController = TextEditingController();

  // 定义 GlobalKey 用于获取 ScaffoldMessengerState
  final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();

  Future<void> _pickFoodImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _itemImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _uploadRecipeRecommendation() async {
    if (_itemImage == null ||
        _nameController.text.isEmpty ||
        _pointsController.text.isEmpty ||
        _instructionsController.text.isEmpty
      ) {
      if (!mounted) return;
      _scaffoldMessengerKey.currentState?.showSnackBar(
        SnackBar(content: Text("请填写所有字段并选择一张图片。")),
      );
      return;
    }

    final String uploadUrl = Config.baseUrl + '/upload_point_shopping';
    var request = http.MultipartRequest('POST', Uri.parse(uploadUrl));
    request.fields['name'] = _nameController.text;
    request.fields['points'] = _pointsController.text;
    request.fields['instructions'] = _instructionsController.text;
    request.files.add(
      await http.MultipartFile.fromPath('item_image', _itemImage!.path),
    );

    var response = await request.send();

    if (!mounted) return; // 确保部件仍然挂载

    if (response.statusCode == 200) {
      _scaffoldMessengerKey.currentState?.showSnackBar(
        SnackBar(content: Text("商品上传成功!")),
      );
      // 重置表单
      setState(() {
        _itemImage = null;
        _nameController.clear();
        _pointsController.clear();
        _instructionsController.clear();
      });
    } else {
      _scaffoldMessengerKey.currentState?.showSnackBar(
        SnackBar(content: Text("商品上传失败。")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldMessenger(
      key: _scaffoldMessengerKey,
      child: Scaffold(
        appBar: AppBar(
          title: Text('上传积分商城'),
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.all(16.0),
          child: Column(
            children: [
              ElevatedButton(
                onPressed: _pickFoodImage,
                child: Text('选择商品图片'),
              ),
              if (_itemImage != null)
                Image.file(
                  _itemImage!,
                  height: 200,
                ),
              TextField(
                controller: _nameController,
                decoration: InputDecoration(labelText: '商品名'),
              ),
              TextField(
                controller: _pointsController,
                decoration: InputDecoration(labelText: '积分'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: _instructionsController,
                decoration: InputDecoration(labelText: '介绍'),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _uploadRecipeRecommendation,
                child: Text('上传商品'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
