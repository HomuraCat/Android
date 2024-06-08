import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '食谱建议',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: RecipeListPage(),
    );
  }
}

class RecipeListPage extends StatefulWidget {
  @override
  _RecipeListPageState createState() => _RecipeListPageState();
}

class _RecipeListPageState extends State<RecipeListPage> {
  // 此处为食谱数据列表示例
  List<Map<String, dynamic>> recipes = [];
  @override
  void initState() {
    super.initState();
    fetchRecipes();
  }

  Future<void> fetchRecipes() async {
    var url = Uri.parse('http://10.0.2.2:5001/recipes');
    var response = await http.get(url);
    if (response.statusCode == 200) {
      var jsonData = jsonDecode(response.body);
      setState(() {
        recipes = List<Map<String, dynamic>>.from(jsonData);
      });
    } else {
      throw Exception('Failed to load recipes');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('食谱列表'),
      ),
      body: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.8,
        ),
        itemCount: recipes.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => RecipeDetailPage(recipe: recipes[index]),
                ),
              );
            },
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30)
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.all(Radius.circular(30)), // 设置所有角的圆角
                    child: Image.asset(
                      recipes[index]['image'],
                      fit: BoxFit.cover, // 图片填充方式
                    ),
                  ),
                ),
                  Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      recipes[index]['name'],
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
    );
  }
}

class RecipeListItem extends StatelessWidget {
  final Map<String, dynamic> recipe;
  final ValueChanged<bool?> onCompletedChanged;

  RecipeListItem({required this.recipe, required this.onCompletedChanged});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Image.asset(recipe['image'], width: 50, height: 50),
        title: Text(recipe['name']),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => RecipeDetailPage(recipe: recipe),
            ),
          );
        },
        trailing: Checkbox(
          value: recipe['completed'],
          onChanged: onCompletedChanged,
        ),
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
  late VideoPlayerController _videoPlayerController;
  ChewieController? _chewieController;
  bool isCompleted = false;

  @override
  void initState() {
    super.initState();
    _initializeVideoPlayer();
  }

  Future<void> _initializeVideoPlayer() async {
    _videoPlayerController = VideoPlayerController.asset(widget.recipe['video']);
    await _videoPlayerController.initialize();
    _createChewieController();
    setState(() {});
  }

  void _createChewieController() {
    _chewieController = ChewieController(
      videoPlayerController: _videoPlayerController,
      autoPlay: false,
      looping: false,
    );
  }

  @override
  void dispose() {
    _videoPlayerController.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.recipe['name']),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.asset(widget.recipe['image']),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                '热量: ${widget.recipe['calories']}\n营养素含量: ${widget.recipe['nutrients']}\n',
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
                widget.recipe['ingredients'].join(', '),
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
            SizedBox(
              height: 200, // 设置视频播放器高度
              child: _chewieController != null &&
                      _videoPlayerController!.value.isInitialized
                  ? Chewie(
                      controller: _chewieController!,
                    )
                  : Center(
                      child: CircularProgressIndicator(),
                    ),
            ),
            SizedBox(height: 16),
             
            //Padding(
            //  padding: EdgeInsets.only(left: 16, right: 16, bottom: 16),
            //  child: ElevatedButton(
            //    style: ButtonStyle(
            //      backgroundColor: MaterialStateProperty.resolveWith<Color>((Set<MaterialState> states) {
            //        if (states.contains(MaterialState.pressed))
            //          return isCompleted ? Colors.green[800]! : Colors.blue[800]!; // Pressed color
            //        return isCompleted ? Colors.green : Colors.blue; // Default color
            //      }),
            //      foregroundColor: MaterialStateProperty.all<Color>(Colors.white), // Text color
            //      minimumSize: MaterialStateProperty.all<Size>(Size(double.infinity, 50)), // Button width and height
            //    ),
            //    onPressed: () {
            //      setState(() {
            //        isCompleted = !isCompleted;
            //        widget.recipe['completed'] = isCompleted;
            //        // Additional logic can be added here, e.g., updating the database
            //      });
            //    },
            //    child: Text(isCompleted ? '已制作' : '待制作'),
            //  ),
            //),
            // 如果有更多信息，请在此处添加
          ],
        ),
      ),
    );
  }
}