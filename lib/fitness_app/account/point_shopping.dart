import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../config.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../utils/Spsave_module.dart';
import 'package:flutter/cupertino.dart';

class PointShoppingPage extends StatefulWidget {
  final String? selectedMealType;

  PointShoppingPage({this.selectedMealType});

  @override
  _PointShoppingPageState createState() => _PointShoppingPageState();
}

class _PointShoppingPageState extends State<PointShoppingPage> {
  List<Map<String, dynamic>> shopping_lists = [];
  String _userID = "", point = "";

  @override
  void initState() {
    super.initState();
    fetchRecipes();
    fetchUserData().then((_) {
        GetPoint(context);
    });
  }

  Future<void> fetchUserData() async {
    Map<String, dynamic>? account = await SpStorage.instance.readAccount();
    if (account != null) {
      _userID = account['patientID'];
    } else {
      print('No account information found');
    }
  }

  Future<void> fetchRecipes() async {
    final String apiUrl = Config.baseUrl + '/point_shopping';
    var url = Uri.parse(apiUrl);
    var response = await http.get(url);
    if (response.statusCode == 200) {
      var jsonData = jsonDecode(response.body);
      setState(() {
        shopping_lists = List<Map<String, dynamic>>.from(jsonData);
      });
    } else {
      throw Exception('Failed to load recipes');
    }
  }

  Future<void> GetPoint(BuildContext context) async {
    final String apiUrl = Config.baseUrl + '/getPoint';
    var url = Uri.parse(apiUrl);

    var response = await http.post(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{'patientID': _userID}),
    );
    
    if (response.statusCode == 200) {
      setState(() => point = response.body);
    }
      else setState(() => point = "ERROR");
  }

  Widget buildPointField() {
    return Padding(
        padding: EdgeInsets.only(left: 5),
        child: Text(
          '积分: ${point}',
          style: TextStyle(fontSize: 20),
        ));
  }

  @override
  Widget build(BuildContext context) {
    // Determine the width of each grid item
    double gridItemWidth = MediaQuery.of(context).size.width / 2;
    // Adjust the height based on your preference
    double gridItemHeight = gridItemWidth + 60; // Add extra space for the text

    return Scaffold(
      appBar: AppBar(
        title: Text('商城列表'),
      ),
      body: Column(
        children: [
          buildPointField(),
          Expanded(
            child: shopping_lists.isEmpty
                ? Center(child: CircularProgressIndicator())
                : GridView.builder(
                    itemCount: shopping_lists.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: gridItemWidth / gridItemHeight,
                    ),
                    itemBuilder: (context, index) {
                      // 构建完整的图片 URL
                      String imageUrl = Config.baseUrl +
                          '/' +
                          shopping_lists[index]['image'];

                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => RecipeDetailPage(
                                shopping_list: shopping_lists[index],
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
                                  shopping_lists[index]['name'],
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Text(
                                  "所需积分：" + shopping_lists[index]['points'],
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
  final Map<String, dynamic> shopping_list;

  RecipeDetailPage({required this.shopping_list});

  @override
  _RecipeDetailPageState createState() => _RecipeDetailPageState();
}

class _RecipeDetailPageState extends State<RecipeDetailPage> {
  bool isCompleted = false;
  String _userID = "", point = "";
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _recipientController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchUserData().then((_) {
        GetPoint(context);
    });
  }

  @override
  void dispose() {
    _recipientController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> fetchUserData() async {
    Map<String, dynamic>? account = await SpStorage.instance.readAccount();
    if (account != null) {
      _userID = account['patientID'];
    } else {
      print('No account information found');
    }
  }

  Future<void> GetPoint(BuildContext context) async {
    final String apiUrl = Config.baseUrl + '/getPoint';
    var url = Uri.parse(apiUrl);

    var response = await http.post(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{'patientID': _userID}),
    );
    
    if (response.statusCode == 200) {
      setState(() => point = response.body);
    }
      else setState(() => point = "ERROR");
  }

  Future<void> deletePoint(String recipient, String phone, String address, String name, String points_to_delete) async {
    final String apiUrl = Config.baseUrl + '/deletePoint';
    var url = Uri.parse(apiUrl);

    var response = await http.post(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{'id': _userID, 'points_to_delete': points_to_delete}),
    );
    
    if (response.statusCode == 200) {
      setState(() => point = response.body);
      addOrders(recipient, phone, address, name);
    }
      else _showDialog(context, "购买发生错误！");
  }

  Future<void> addOrders(String recipient, String phone, String address, String name) async {
    final String apiUrl = Config.baseUrl + '/upload_orders';
    var url = Uri.parse(apiUrl);

    var response = await http.post(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{'name': name, 'id': _userID, 'recipient': recipient, 'phone': phone, 'address': address}),
    );
    
    if (response.statusCode == 200 && response.body == "1") {
      _showDialog(context, "购买成功！");
    }
      else _showDialog(context, "购买发生错误！");
  }

  @override
  Widget build(BuildContext context) {
    // 构建图片 URL
    String imageUrl = Config.baseUrl + '/' + widget.shopping_list['image'];
    String instructions = widget.shopping_list['instructions'] ?? '暂无介绍';

    // 获取屏幕宽度
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.shopping_list['name']),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
                '所需积分: ${widget.shopping_list['points']}',
                style: TextStyle(fontSize: 18),
              ),
            ),
            Divider(),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                '物品介绍:',
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
            Divider(),
            const SizedBox(height: 20),
            buildBuyButton(context),
          ],
        ),
      ),
    );
  }

  Widget buildBuyButton(BuildContext context) {
    return Align(
      child: SizedBox(
        height: 40,
        width: 250,
        child: FloatingActionButton(
          backgroundColor: Colors.blue,
          child: Text('购买',
              style: Theme.of(context).primaryTextTheme.headlineSmall),
          onPressed: () {
            if (int.parse(point) >= int.parse(widget.shopping_list['points'])) _showAddressDialog();
              else _showDialog(context, "您的积分余额不足！");
          },
        ),
      ),
    );
  }

  void _showAddressDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('填写收货信息'),
          content: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: _recipientController,
                    decoration: const InputDecoration(
                      labelText: '收件人',
                      prefixIcon: Icon(Icons.person),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return '请输入收件人姓名';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _phoneController,
                    decoration: const InputDecoration(
                      labelText: '手机号',
                      prefixIcon: Icon(Icons.phone),
                    ),
                    keyboardType: TextInputType.phone,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return '请输入手机号码';
                      }
                      if (!RegExp(r'^1[0-9]\d{9}$').hasMatch(value)) {
                        return '请输入有效的手机号码';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _addressController,
                    decoration: const InputDecoration(
                      labelText: '详细地址',
                      prefixIcon: Icon(Icons.location_on),
                    ),
                    maxLines: 3,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return '请输入详细地址';
                      }
                      if (value.length < 10) {
                        return '地址信息太简短';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('取消'),
            ),
            ElevatedButton(
              onPressed: _submitForm,
              child: const Text('提交'),
            ),
          ],
        );
      },
    );
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final recipient = _recipientController.text;
      final phone = _phoneController.text;
      final address = _addressController.text;
      final name = widget.shopping_list['name'], points = widget.shopping_list['points'];
      deletePoint(recipient, phone, address, name, points);
      
      //print('提交信息: $recipient, $phone, $address, $name, $points');

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('地址信息提交成功!')),
      );

      Navigator.pop(context);

      _recipientController.clear();
      _phoneController.clear();
      _addressController.clear();
    }
  }

  void _showDialog(BuildContext context, String message) {
    showCupertinoDialog(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: Text("Message"),
          content: Text(message),
          actions: <Widget>[
            CupertinoDialogAction(
              child: Text("Close"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
