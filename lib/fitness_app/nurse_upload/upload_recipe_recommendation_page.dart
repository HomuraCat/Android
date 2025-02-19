import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import '../../config.dart'; // 根据您的项目结构调整路径

class UploadRecipeRecommendationPage extends StatefulWidget {
  @override
  _UploadRecipeRecommendationPageState createState() =>
      _UploadRecipeRecommendationPageState();
}

class _UploadRecipeRecommendationPageState
    extends State<UploadRecipeRecommendationPage> {
  final ImagePicker _picker = ImagePicker();
  File? _foodImage;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _caloriesController = TextEditingController();
  final TextEditingController _nutrientsController = TextEditingController();
  final TextEditingController _ingredientsController = TextEditingController();
  final TextEditingController _instructionsController = TextEditingController();

  // 定义餐类型选项
  final List<String> _mealTypes = [
    '早餐',
    '早餐加餐',
    '午餐',
    '午餐加餐',
    '晚餐',
    '晚餐加餐',
  ];

  String? _selectedMealType;

  // 定义 GlobalKey 用于获取 ScaffoldMessengerState
  final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();

  Future<void> _pickFoodImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _foodImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _uploadRecipeRecommendation() async {
    if (_foodImage == null ||
        _nameController.text.isEmpty ||
        _caloriesController.text.isEmpty ||
        _nutrientsController.text.isEmpty ||
        _ingredientsController.text.isEmpty ||
        _instructionsController.text.isEmpty ||
        _selectedMealType == null) {
      if (!mounted) return;
      _scaffoldMessengerKey.currentState?.showSnackBar(
        SnackBar(content: Text("请填写所有字段并选择一张图片。")),
      );
      return;
    }

    final String uploadUrl = Config.baseUrl + '/upload_recipe_recommendation';
    var request = http.MultipartRequest('POST', Uri.parse(uploadUrl));
    request.fields['name'] = _nameController.text;
    request.fields['calories'] = _caloriesController.text;
    request.fields['nutrients'] = _nutrientsController.text;
    request.fields['ingredients'] = _ingredientsController.text;
    request.fields['instructions'] = _instructionsController.text;
    request.fields['mealType'] = _selectedMealType!;
    request.files.add(
      await http.MultipartFile.fromPath('food_image', _foodImage!.path),
    );

    var response = await request.send();

    if (!mounted) return; // 确保部件仍然挂载

    if (response.statusCode == 200) {
      _scaffoldMessengerKey.currentState?.showSnackBar(
        SnackBar(content: Text("食谱推荐上传成功!")),
      );
      // 重置表单
      setState(() {
        _foodImage = null;
        _nameController.clear();
        _caloriesController.clear();
        _nutrientsController.clear();
        _ingredientsController.clear();
        _instructionsController.clear();
        _selectedMealType = null;
      });
    } else {
      _scaffoldMessengerKey.currentState?.showSnackBar(
        SnackBar(content: Text("食谱推荐上传失败。")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldMessenger(
      key: _scaffoldMessengerKey,
      child: Scaffold(
        appBar: AppBar(
          title: Text('上传食谱推荐'),
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.all(16.0),
          child: Column(
            children: [
              ElevatedButton(
                onPressed: _pickFoodImage,
                child: Text('选择食物图片'),
              ),
              if (_foodImage != null)
                Image.file(
                  _foodImage!,
                  height: 200,
                ),
              TextField(
                controller: _nameController,
                decoration: InputDecoration(labelText: '菜名'),
              ),
              TextField(
                controller: _caloriesController,
                decoration: InputDecoration(labelText: '卡路里'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: _nutrientsController,
                decoration: InputDecoration(labelText: '作用'),
              ),
              TextField(
                controller: _ingredientsController,
                decoration: InputDecoration(labelText: '所需材料（用逗号分隔）'),
              ),
              TextField(
                controller: _instructionsController,
                decoration: InputDecoration(labelText: '制作过程'),
                maxLines: 5,
              ),
              DropdownButtonFormField<String>(
                value: _selectedMealType,
                items: _mealTypes.map((String mealType) {
                  return DropdownMenuItem<String>(
                    value: mealType,
                    child: Text(mealType),
                  );
                }).toList(),
                decoration: InputDecoration(labelText: '餐类型'),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedMealType = newValue;
                  });
                },
                validator: (value) => value == null ? '请选择餐类型' : null,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _uploadRecipeRecommendation,
                child: Text('上传食谱推荐'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
