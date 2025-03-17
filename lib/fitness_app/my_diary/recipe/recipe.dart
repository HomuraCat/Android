import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../../config.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../utils/Spsave_module.dart';

class RecipeListPage extends StatefulWidget {
  final String? selectedMealType;

  RecipeListPage({this.selectedMealType});

  @override
  _RecipeListPageState createState() => _RecipeListPageState();
}

class _RecipeListPageState extends State<RecipeListPage> {
  List<Map<String, dynamic>> recipes = [];
  List<Map<String, dynamic>> filteredRecipes = [];
  late String selectedMealType;

  @override
  void initState() {
    super.initState();
    selectedMealType = widget.selectedMealType ?? '全部';
    fetchRecipes();
  }

  Future<void> fetchRecipes() async {
    final String apiUrl = Config.baseUrl + '/recipes';
    var url = Uri.parse(apiUrl);
    var response = await http.get(url);
    if (response.statusCode == 200) {
      var jsonData = jsonDecode(response.body);
      print('Fetched Recipes: $jsonData'); // 调试信息
      setState(() {
        recipes = List<Map<String, dynamic>>.from(jsonData);
        filterRecipes(selectedMealType);
      });
    } else {
      throw Exception('Failed to load recipes');
    }
  }

  void filterRecipes(String mealType) {
    setState(() {
      selectedMealType = mealType;
      if (mealType == '全部') {
        filteredRecipes = recipes;
      } else {
        filteredRecipes = recipes
            .where((recipe) => recipe['mealType'] == mealType)
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Determine the width of each grid item
    double gridItemWidth = MediaQuery.of(context).size.width / 2;
    // Adjust the height based on your preference
    double gridItemHeight = gridItemWidth + 60; // Add extra space for the text

    return Scaffold(
      appBar: AppBar(
        title: Text('食谱列表'),
      ),
      body: Column(
        children: [
          // 下拉选择不同类型的餐
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: DropdownButton<String>(
              value: selectedMealType,
              icon: Icon(Icons.arrow_downward),
              isExpanded: true,
              onChanged: (String? newValue) {
                filterRecipes(newValue!);
              },
              items: <String>[
                '全部',
                '早餐',
                '午餐',
                '晚餐',
                '早餐加餐',
                '午餐加餐',
                '晚餐加餐'
              ].map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value, style: TextStyle(fontSize: 20)),
                );
              }).toList(),
            ),
          ),
          // 网格列表展示食谱
          Expanded(
            child: recipes.isEmpty
                ? Center(child: CircularProgressIndicator())
                : GridView.builder(
                    itemCount: filteredRecipes.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: gridItemWidth / gridItemHeight,
                    ),
                    itemBuilder: (context, index) {
                      // 构建完整的图片 URL
                      String imageUrl = Config.baseUrl +
                          '/' +
                          filteredRecipes[index]['image'];

                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => RecipeDetailPage(
                                recipe: filteredRecipes[index],
                              ),
                            ),
                          );
                        },
                        child: Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: <Widget>[
                              Expanded(
                                child: ClipRRect(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(15)),
                                  child: CachedNetworkImage(
                                    imageUrl: imageUrl,
                                    fit: BoxFit.cover,
                                    placeholder: (context, url) =>
                                        CircularProgressIndicator(),
                                    errorWidget: (context, url, error) =>
                                        Icon(Icons.error),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Text(
                                  filteredRecipes[index]['name'],
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class RecipeDetailPage extends StatefulWidget {
  final Map<String, dynamic> recipe;

  RecipeDetailPage({required this.recipe});

  @override
  _RecipeDetailPageState createState() => _RecipeDetailPageState();
}

class _RecipeDetailPageState extends State<RecipeDetailPage> {
  VideoPlayerController? _videoPlayerController;
  ChewieController? _chewieController;

  bool isCompleted = false;
  String? _userID;

  @override
  void initState() {
    super.initState();
    // 1. 先获取本地 userID
    fetchUserData().then((_) {
      // 2. 获取到 userID 后，向后端查询该用户是否完成了此食谱
      if (_userID != null) {
        _fetchRecipeStatus(widget.recipe['id'], _userID!);
      }
    });

    // 如果有视频字段，则初始化视频播放器
    if (widget.recipe['video'] != null && widget.recipe['video'] != '') {
      _initializeVideoPlayer();
    }
  }

  // 从本地存储读取 patientID（或 userID）
  Future<void> fetchUserData() async {
    Map<String, dynamic>? account = await SpStorage.instance.readAccount();
    if (account != null) {
      _userID = account['patientID'];
    } else {
      // 如果没有账户信息，可以在这里处理错误或提示
      print('No account information found');
    }
  }

  // 调用后端 /getRecipeStatus 接口，查询该用户是否已完成这个食谱
  Future<void> _fetchRecipeStatus(int recipeId, String userID) async {
    final String apiUrl = Config.baseUrl + '/getRecipeStatus';
    var url = Uri.parse(apiUrl);

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'id': recipeId,
          'userID': userID,
        }),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        bool fetchedIsCompleted = data['isCompleted'];
        setState(() {
          isCompleted = fetchedIsCompleted;
        });
      } else {
        print('Failed to fetch recipe status: ${response.statusCode}');
      }
    } catch (error) {
      print('Error fetching recipe status: $error');
    }
  }

  Future<void> _initializeVideoPlayer() async {
    String videoUrl = widget.recipe['video'];
    if (!videoUrl.startsWith('http')) {
      videoUrl = Config.baseUrl + '/' + videoUrl;
    }

    _videoPlayerController = VideoPlayerController.network(videoUrl);
    await _videoPlayerController!.initialize();
    _createChewieController();
    setState(() {});
  }

  void _createChewieController() {
    _chewieController = ChewieController(
      videoPlayerController: _videoPlayerController!,
      autoPlay: false,
      looping: false,
    );
  }

  @override
  void dispose() {
    _videoPlayerController?.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  // 点击按钮更新后端 /updateRecipeStatus 接口
  Future<void> updateRecipeStatus(
      int recipeId, bool iscompleted, String? userID) async {
    final String apiUrl = Config.baseUrl + '/updateRecipeStatus';
    var url = Uri.parse(apiUrl);
    var response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'id': recipeId,
        'completed': iscompleted ? 1 : 0,
        'userID': userID,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update recipe status');
    }
  }

  Widget _buildVideoPlayer() {
    if (_chewieController != null &&
        _videoPlayerController!.value.isInitialized) {
      return Chewie(
        controller: _chewieController!,
      );
    } else if (widget.recipe['video'] != null &&
        widget.recipe['video'] != '') {
      return Center(child: CircularProgressIndicator());
    } else {
      return Center(child: Text('没有可用的视频'));
    }
  }

  @override
  Widget build(BuildContext context) {
    // 解析材料
    List<String> ingredients = [];
    if (widget.recipe['ingredients'] is String) {
      // 如果 ingredients 是字符串，用逗号分隔
      ingredients = widget.recipe['ingredients']
          .split(',')
          .map((e) => e.trim())
          .toList();
    } else if (widget.recipe['ingredients'] is List) {
      ingredients = List<String>.from(widget.recipe['ingredients']);
    }

    // 获取制作过程
    String instructions = widget.recipe['instructions'] ?? '暂无制作过程';
    String source = widget.recipe['source'] ?? '暂无';
    // 构建图片 URL
    String imageUrl = Config.baseUrl + '/' + widget.recipe['image'];

    // 获取屏幕宽度
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.recipe['name']),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 顶部食谱图片
            SizedBox(
              width: screenWidth,
              height: screenWidth,
              child: Image.network(
                imageUrl,
                fit: BoxFit.fill,
              ),
            ),
            Divider(),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                '热量: ${widget.recipe['calories']}',
                style: TextStyle(fontSize: 18),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                '作用: ${widget.recipe['nutrients']}',
                style: TextStyle(fontSize: 18),
              ),
            ),
            Divider(),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                '所需材料:',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                ingredients.join(', '),
                style: TextStyle(fontSize: 18),
              ),
            ),
            Divider(),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                '制作过程:',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                instructions,
                style: TextStyle(fontSize: 18),
              ),
            ),
            SizedBox(height: 16),
            
            Divider(),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                '信息来源:',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                source,
                style: TextStyle(fontSize: 18),
              ),
            ),
            SizedBox(height: 16),
            // “已制作 / 待制作” 按钮
            Padding(
              padding: EdgeInsets.only(left: 16, right: 16, bottom: 16),
              child: ElevatedButton(
                style: ButtonStyle(
                  backgroundColor:
                      MaterialStateProperty.resolveWith<Color>((states) {
                    return isCompleted ? Colors.green : Colors.blue;
                  }),
                  minimumSize:
                      MaterialStateProperty.all<Size>(Size(double.infinity, 50)),
                ),
                onPressed: () async {
                  setState(() {
                    // 本地先切换
                    isCompleted = !isCompleted;
                    widget.recipe['completed'] = isCompleted ? 1 : 0;
                  });

                  try {
                    await updateRecipeStatus(
                      widget.recipe['id'],
                      isCompleted,
                      _userID,
                    );
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('状态更新成功')),
                    );
                  } catch (error) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('状态更新失败，请稍后重试')),
                    );
                    // 回滚本地状态
                    setState(() {
                      isCompleted = !isCompleted;
                      widget.recipe['completed'] = isCompleted ? 1 : 0;
                    });
                  }
                },
                child: Text(isCompleted ? '已制作' : '待制作'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
