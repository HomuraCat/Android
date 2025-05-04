import 'package:flutter/material.dart';
import 'dart:convert'; // 用于 jsonDecode
import 'package:http/http.dart' as http; // 用于 HTTP 请求
import '../../config.dart'; // 导入配置文件

// --- 定义食谱模型 ---
// 根据你的后端 GET /recipes 接口实际返回的字段调整此类
class Recipe {
  final int id; // 假设 'id' 是主键且为整数
  final String name; // 假设有一个 'name' 字段
  // 你可以添加其他想显示或使用的字段（可选）
  // final String imageUrl;
  // final List<String> ingredients;

  Recipe({
    required this.id,
    required this.name,
    // required this.imageUrl,
    // required this.ingredients,
  });

  // 工厂构造函数，用于从 JSON 创建 Recipe 对象
  factory Recipe.fromJson(Map<String, dynamic> json) {
    // 对必需字段进行基本的错误处理
    if (json['id'] == null || json['name'] == null) {
      throw FormatException("无效的食谱 JSON 格式：缺少 'id' 或 'name'");
    }
    return Recipe(
      id: json['id'] as int, // 确保 ID 解析为整数
      name: json['name'] as String, // 确保 name 解析为字符串
      // 其他字段示例：
      // imageUrl: json['image_url'] ?? 'default_placeholder.png', // 处理缺失的可选字段
      // ingredients: List<String>.from(json['ingredients'] ?? []), // 处理可能缺失的列表
    );
  }
}


// --- 管理食谱页面 Widget ---
class ManageRecipesPage extends StatefulWidget {
  @override
  _ManageRecipesPageState createState() => _ManageRecipesPageState();
}

class _ManageRecipesPageState extends State<ManageRecipesPage> {
  List<Recipe> _recipes = [];
  bool _isLoading = true;
  String? _error;

  // 从配置文件读取基础 URL
  final String _baseUrl = Config.baseUrl;

  @override
  void initState() {
    super.initState();
    _fetchRecipes();
  }

  // --- 从后端获取食谱 ---
  Future<void> _fetchRecipes() async {
    setState(() {
      _isLoading = true;
      _error = null; // 获取时重置错误信息
    });
    try {
      // 设置超时时间，防止请求一直挂起 (可选但推荐)
      final response = await http.get(Uri.parse('$_baseUrl/recipes')).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        // 安全地解码响应体 (使用 utf8 解码以支持中文)
        final dynamic decodedBody = jsonDecode(utf8.decode(response.bodyBytes));

        // 确保解码后的 body 是一个列表
        if (decodedBody is List) {
          // 将 JSON 列表映射为 List<Recipe>
          // 为单个项目解析添加错误处理
          List<Recipe> fetchedRecipes = [];
          for (var item in decodedBody) {
              if (item is Map<String, dynamic>) {
                 try {
                    fetchedRecipes.add(Recipe.fromJson(item));
                 } catch (e) {
                    print("解析食谱项时出错: $item, 错误: $e");
                    // 可以选择向用户显示部分数据加载的消息
                 }
              } else {
                  print("跳过无效的食谱列表项: $item");
              }
          }
          // 检查 widget 是否仍然挂载在树上，防止在异步操作完成后调用 setState 时出错
          if(mounted) {
            setState(() {
              _recipes = fetchedRecipes;
              _isLoading = false;
            });
          }
        } else {
           throw Exception('期望收到食谱列表，但收到了：${decodedBody.runtimeType}');
        }
      } else {
        throw Exception('加载食谱失败。状态码：${response.statusCode}');
      }
    } catch (e) {
      print("获取食谱时出错: $e");
       if(mounted) {
          setState(() {
          // 简化错误信息，避免显示过多技术细节给用户
          _error = "加载食谱失败，请检查网络连接或稍后重试。";
          _isLoading = false;
          });
       }
    }
  }

  // --- 删除食谱函数 ---
  Future<void> _deleteRecipe(int recipeId) async {
    // (可选) 显示加载指示器或禁用按钮，提升用户体验

    try {
      final response = await http.delete(
        Uri.parse('$_baseUrl/recipes/$recipeId'),
      ).timeout(const Duration(seconds: 10));

      if (!mounted) return; // 检查 widget 是否还存在

      if (response.statusCode == 200 || response.statusCode == 204) {
        // 删除成功
        setState(() {
          // 从本地列表中移除该食谱
          _recipes.removeWhere((recipe) => recipe.id == recipeId);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('食谱删除成功！'),
            backgroundColor: Colors.green,
          ),
        );
      } else if (response.statusCode == 404) {
         ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('服务器上未找到该食谱。'),
            backgroundColor: Colors.orange,
          ),
        );
         // 可选：重新获取食谱以同步状态（如果需要）
         _fetchRecipes();
      }
      else {
        // 处理其他错误状态码
         print('删除食谱失败。状态码：${response.statusCode}');
         print('响应体: ${response.body}');
         // 尝试解码错误信息
         String errorMessage = '未知错误';
         try {
            final errorData = jsonDecode(response.body);
            errorMessage = errorData['error'] ?? '未知错误';
         } catch(_){
            // 如果响应体不是有效的 JSON，则使用默认错误信息
         }

         throw Exception('删除食谱失败: $errorMessage');
      }
    } catch (e) {
      print("删除食谱时出错: $e");
      if (!mounted) return; // 检查 widget 是否还存在
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          // 简化错误信息
          content: Text('删除食谱失败，请稍后重试。'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      // (可选) 隐藏加载指示器
    }
  }

  // --- 显示确认删除对话框 ---
  Future<void> _showDeleteConfirmationDialog(Recipe recipe) async {
    // 在调用 showDialog 前检查 mounted 状态
    if (!mounted) return;

    return showDialog<void>(
      context: context,
      barrierDismissible: false, // 用户必须点击按钮！
      builder: (BuildContext dialogContext) { // 使用 dialogContext 避免歧义
        return AlertDialog(
          title: Text('确认删除'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('您确定要删除食谱 "${recipe.name}" 吗？'),
                SizedBox(height: 8), // 添加一点间距
                Text('此操作无法撤销。', style: TextStyle(color: Colors.grey[600])),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('取消'),
              onPressed: () {
                Navigator.of(dialogContext).pop(); // 关闭对话框
              },
            ),
            TextButton(
              child: Text('删除', style: TextStyle(color: Colors.red)),
              onPressed: () {
                Navigator.of(dialogContext).pop(); // 关闭对话框
                _deleteRecipe(recipe.id); // 调用删除函数
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
        title: Text('管理食谱'), // 标题已是中文
        actions: [
          // 添加刷新按钮
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _isLoading ? null : _fetchRecipes, // 加载时禁用
            tooltip: '刷新', // 中文提示
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  // --- 根据状态构建 Body ---
  Widget _buildBody() {
    if (_isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
             mainAxisAlignment: MainAxisAlignment.center,
             children: [
                Icon(Icons.error_outline, color: Colors.red, size: 50),
                SizedBox(height: 10),
                Text('加载数据时出错', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)), // 中文
                SizedBox(height: 10),
                Text(_error!, textAlign: TextAlign.center),
                SizedBox(height: 20),
                ElevatedButton(
                   onPressed: _fetchRecipes,
                   child: Text('重试'), // 中文
                )
             ]
          ),
        ),
      );
    }

    if (_recipes.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
              Icon(Icons.list_alt_outlined, size: 60, color: Colors.grey), // 添加图标
              SizedBox(height: 15),
              Text('未找到任何食谱。'), // 中文
              SizedBox(height: 10),
              ElevatedButton(
                 onPressed: _fetchRecipes,
                 child: Text('刷新'), // 中文
              )
          ],
        )
      );
    }

    // --- 显示食谱列表 ---
    return ListView.builder(
      itemCount: _recipes.length,
      itemBuilder: (context, index) {
        final recipe = _recipes[index];
        return Card( // 使用卡片以获得更好的视觉分隔
          margin: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
          child: ListTile(
            title: Text(recipe.name),
            // 你可以添加副标题: Text('ID: ${recipe.id}') 或其他信息
            trailing: IconButton(
              icon: Icon(Icons.delete_outline, color: Colors.redAccent),
              tooltip: '删除食谱', // 中文
              onPressed: () {
                _showDeleteConfirmationDialog(recipe);
              },
            ),
            // 可选：添加 onTap 以导航到食谱详情页
            // onTap: () { /* 导航到食谱详情 */ },
          ),
        );
      },
    );
  }
}