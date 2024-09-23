import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../../config.dart';
import 'package:cached_network_image/cached_network_image.dart';

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
    
    return Scaffold(
      appBar: AppBar(
        title: Text('食谱列表'),
      ),
      body: Column(
        children: [
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
          Expanded(
            child: recipes.isEmpty
                ? Center(child: CircularProgressIndicator())
                : GridView.builder(
                    gridDelegate:
                        SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.8,
                    ),
                    itemCount: filteredRecipes.length,
                    itemBuilder: (context, index) {
                      // 打印图片路径
                      print('Image path: ${filteredRecipes[index]['image']}');

                      // 构建完整的图片 URL
                      String imageUrl = Config.baseUrl + '/' + filteredRecipes[index]['image'];

                      // 可选地，打印完整的图片 URL
                      print('Full image URL: $imageUrl');

                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => RecipeDetailPage(
                                  recipe: filteredRecipes[index]),
                            ),
                          );
                        },
                        child: Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.stretch,
                            children: <Widget>[
                              Expanded(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.all(
                                      Radius.circular(15)),
                                  child: CachedNetworkImage(
                                    imageUrl: imageUrl,
                                    fit: BoxFit.cover,
                                    placeholder: (context, url) =>
                                        CircularProgressIndicator(),
                                    errorWidget:
                                        (context, url, error) =>
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

  @override
  void initState() {
    super.initState();
    if (widget.recipe['video'] != null &&
        widget.recipe['video'] != '') {
      _initializeVideoPlayer();
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
    List<String> ingredients = [];
    if (widget.recipe['ingredients'] is String) {
      // 如果 ingredients 是字符串，用逗号分隔
      ingredients = widget.recipe['ingredients'].split(',').map((e) => e.trim()).toList();
    } else if (widget.recipe['ingredients'] is List) {
      ingredients = List<String>.from(widget.recipe['ingredients']);
    }

    // 获取制作过程
    String instructions = widget.recipe['instructions'] ?? '暂无制作过程';

    // 构建图片 URL
    String imageUrl = Config.baseUrl + '/' + widget.recipe['image'];

    // 打印图片 URL
    print('Recipe Detail Image URL: $imageUrl');

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.recipe['name']),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.network(
              imageUrl,
              width: double.infinity,
              height: 200,
              fit: BoxFit.cover,
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
                '营养素含量: ${widget.recipe['nutrients']}',
                style: TextStyle(fontSize: 18),
              ),
            ),
            Divider(),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                '所需材料:',
                style: TextStyle(
                    fontSize: 22, fontWeight: FontWeight.bold),
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
                style: TextStyle(
                    fontSize: 22, fontWeight: FontWeight.bold),
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
            Padding(
              padding:
                  EdgeInsets.only(left: 16, right: 16, bottom: 16),
              child: ElevatedButton(
                style: ButtonStyle(
                  backgroundColor:
                      MaterialStateProperty.resolveWith<Color>(
                          (states) {
                    return isCompleted ? Colors.green : Colors.blue;
                  }),
                  minimumSize: MaterialStateProperty.all<Size>(
                      Size(double.infinity, 50)),
                ),
                onPressed: () {
                  setState(() {
                    isCompleted = !isCompleted;
                    widget.recipe['completed'] = isCompleted ? 1 : 0;
                    // 可以在这里添加更多逻辑，例如更新数据库
                  });
                },
                child: Text(isCompleted ? '已制作' : '待制作'),
              ),
            ),
            // 如果有更多信息，可以在这里添加
          ],
        ),
      ),
    );
  }
}
