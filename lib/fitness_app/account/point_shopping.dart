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

  final List<String> _provinceList = [
    '北京市', '天津市', '上海市', '重庆市',
    '河北省', '山西省', '辽宁省', '吉林省', '黑龙江省',
    '江苏省', '浙江省', '安徽省', '福建省', '江西省',
    '山东省', '河南省', '湖北省', '湖南省', '广东省',
    '海南省', '四川省', '贵州省', '云南省', '陕西省',
    '甘肃省', '青海省', '台湾省',
    '内蒙古自治区', '广西壮族自治区', '西藏自治区',
    '宁夏回族自治区', '新疆维吾尔自治区',
    '香港特别行政区', '澳门特别行政区',
  ];

  final Map<String, List<String>> _cityMap = {
    '北京市': ['北京市'],
    '天津市': ['天津市'],
    '上海市': ['上海市'],
    '重庆市': ['重庆市'],
    '河北省': ['石家庄市', '唐山市', '秦皇岛市', '邯郸市', '邢台市', '保定市', '张家口市', '承德市', '沧州市', '廊坊市', '衡水市'],
    '山西省': ['太原市', '大同市', '阳泉市', '长治市', '晋城市', '朔州市', '晋中市', '运城市', '忻州市', '临汾市', '吕梁市'],
    '辽宁省': ['沈阳市', '大连市', '鞍山市', '抚顺市', '本溪市', '丹东市', '锦州市', '营口市', '阜新市', '辽阳市', '盘锦市', '铁岭市', '朝阳市', '葫芦岛市'],
    '吉林省': ['长春市', '吉林市', '四平市', '辽源市', '通化市', '白山市', '松原市', '白城市', '延边朝鲜族自治州'],
    '黑龙江省': ['哈尔滨市', '齐齐哈尔市', '鸡西市', '鹤岗市', '双鸭山市', '大庆市', '伊春市', '佳木斯市', '七台河市', '牡丹江市', '黑河市', '绥化市', '大兴安岭地区'],
    '江苏省': ['南京市', '无锡市', '徐州市', '常州市', '苏州市', '南通市', '连云港市', '淮安市', '盐城市', '扬州市', '镇江市', '泰州市', '宿迁市'],
    '浙江省': ['杭州市', '宁波市', '温州市', '嘉兴市', '湖州市', '绍兴市', '金华市', '衢州市', '舟山市', '台州市', '丽水市'],
    '安徽省': ['合肥市', '芜湖市', '蚌埠市', '淮南市', '马鞍山市', '淮北市', '铜陵市', '安庆市', '黄山市', '滁州市', '阜阳市', '宿州市', '六安市', '亳州市', '池州市', '宣城市'],
    '福建省': ['福州市', '厦门市', '莆田市', '三明市', '泉州市', '漳州市', '南平市', '龙岩市', '宁德市'],
    '江西省': ['南昌市', '景德镇市', '萍乡市', '九江市', '新余市', '鹰潭市', '赣州市', '吉安市', '宜春市', '抚州市', '上饶市'],
    '山东省': ['济南市', '青岛市', '淄博市', '枣庄市', '东营市', '烟台市', '潍坊市', '济宁市', '泰安市', '威海市', '日照市', '临沂市', '德州市', '聊城市', '滨州市', '菏泽市'],
    '河南省': ['郑州市', '开封市', '洛阳市', '平顶山市', '安阳市', '鹤壁市', '新乡市', '焦作市', '濮阳市', '许昌市', '漯河市', '三门峡市', '南阳市', '商丘市', '信阳市', '周口市', '驻马店市'],
    '湖北省': ['武汉市', '黄石市', '十堰市', '宜昌市', '襄阳市', '鄂州市', '荆门市', '孝感市', '荆州市', '黄冈市', '咸宁市', '随州市', '恩施土家族苗族自治州'],
    '湖南省': ['长沙市', '株洲市', '湘潭市', '衡阳市', '邵阳市', '岳阳市', '常德市', '张家界市', '益阳市', '郴州市', '永州市', '怀化市', '娄底市', '湘西土家族苗族自治州'],
    '广东省': ['广州市', '韶关市', '深圳市', '珠海市', '汕头市', '佛山市', '江门市', '湛江市', '茂名市', '肇庆市', '惠州市', '梅州市', '汕尾市', '河源市', '阳江市', '清远市', '东莞市', '中山市', '潮州市', '揭阳市', '云浮市'],
    '海南省': ['海口市', '三亚市', '三沙市', '儋州市', '五指山市', '琼海市', '文昌市', '万宁市', '东方市', '定安县', '屯昌县', '澄迈县', '临高县', '白沙黎族自治县', '昌江黎族自治县', '乐东黎族自治县', '陵水黎族自治县', '保亭黎族苗族自治县', '琼中黎族苗族自治县'],
    '四川省': ['成都市', '自贡市', '攀枝花市', '泸州市', '德阳市', '绵阳市', '广元市', '遂宁市', '内江市', '乐山市', '南充市', '眉山市', '宜宾市', '广安市', '达州市', '雅安市', '巴中市', '资阳市', '阿坝藏族羌族自治州', '甘孜藏族自治州', '凉山彝族自治州'],
    '贵州省': ['贵阳市', '六盘水市', '遵义市', '安顺市', '毕节市', '铜仁市', '黔西南布依族苗族自治州', '黔东南苗族侗族自治州', '黔南布依族苗族自治州'],
    '云南省': ['昆明市', '曲靖市', '玉溪市', '保山市', '昭通市', '丽江市', '普洱市', '临沧市', '楚雄彝族自治州', '红河哈尼族彝族自治州', '文山壮族苗族自治州', '西双版纳傣族自治州', '大理白族自治州', '德宏傣族景颇族自治州', '怒江傈僳族自治州', '迪庆藏族自治州'],
    '陕西省': ['西安市', '铜川市', '宝鸡市', '咸阳市', '渭南市', '延安市', '汉中市', '榆林市', '安康市', '商洛市'],
    '甘肃省': ['兰州市', '嘉峪关市', '金昌市', '白银市', '天水市', '武威市', '张掖市', '平凉市', '酒泉市', '庆阳市', '定西市', '陇南市', '临夏回族自治州', '甘南藏族自治州'],
    '青海省': ['西宁市', '海东市', '海北藏族自治州', '黄南藏族自治州', '海南藏族自治州', '果洛藏族自治州', '玉树藏族自治州', '海西蒙古族藏族自治州'],
    '台湾省': ['台北市', '高雄市', '基隆市', '台中市', '台南市', '新竹市', '嘉义市'],
    '内蒙古自治区': ['呼和浩特市', '包头市', '乌海市', '赤峰市', '通辽市', '鄂尔多斯市', '呼伦贝尔市', '巴彦淖尔市', '乌兰察布市', '兴安盟', '锡林郭勒盟', '阿拉善盟'],
    '广西壮族自治区': ['南宁市', '柳州市', '桂林市', '梧州市', '北海市', '防城港市', '钦州市', '贵港市', '玉林市', '百色市', '贺州市', '河池市', '来宾市', '崇左市'],
    '西藏自治区': ['拉萨市', '日喀则市', '昌都市', '林芝市', '山南市', '那曲市', '阿里地区'],
    '宁夏回族自治区': ['银川市', '石嘴山市', '吴忠市', '固原市', '中卫市'],
    '新疆维吾尔自治区': ['乌鲁木齐市', '克拉玛依市', '吐鲁番市', '哈密市', '昌吉回族自治州', '博尔塔拉蒙古自治州', '巴音郭楞蒙古自治州', '阿克苏地区', '克孜勒苏柯尔克孜自治州', '喀什地区', '和田地区', '伊犁哈萨克自治州', '塔城地区', '阿勒泰地区'],
    '香港特别行政区': ['香港岛', '九龙', '新界'],
    '澳门特别行政区': ['澳门半岛', '氹仔岛', '路环岛', '路氹城'],
  };

  String fullAddress = "";

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
    String selectedProvince = '北京市';
    String selectedCity = '北京市';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('填写收货信息'),
              content: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      DropdownButtonFormField<String>(
                        value: selectedProvince,
                        decoration: const InputDecoration(
                          labelText: '省份',
                          prefixIcon: Icon(Icons.map),
                        ),
                        items: _provinceList
                            .map((prov) => DropdownMenuItem(
                                  value: prov,
                                  child: Text(prov),
                                ))
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedProvince = value!;
                            selectedCity = _cityMap[selectedProvince]!.first;
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: selectedCity,
                        decoration: const InputDecoration(
                          labelText: '城市',
                          prefixIcon: Icon(Icons.location_city),
                        ),
                        items: _cityMap[selectedProvince]!
                            .map((city) => DropdownMenuItem(
                                  value: city,
                                  child: Text(city),
                                ))
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedCity = value!;
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _recipientController,
                        decoration: const InputDecoration(
                          labelText: '收件人',
                          prefixIcon: Icon(Icons.person),
                        ),
                        validator: (value) =>
                            value == null || value.isEmpty ? '请输入收件人姓名' : null,
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
                          if (value == null || value.isEmpty) return '请输入手机号码';
                          if (!RegExp(r'^1[0-9]\d{9}$').hasMatch(value)) return '请输入有效的手机号码';
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
                          if (value == null || value.isEmpty) return '请输入详细地址';
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
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      fullAddress = '$selectedProvince $selectedCity ${_addressController.text}';
                      _submitForm();
                    }
                  },
                  child: const Text('提交'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final recipient = _recipientController.text;
      final phone = _phoneController.text;
      final name = widget.shopping_list['name'], points = widget.shopping_list['points'];
      deletePoint(recipient, phone, fullAddress, name, points);
      
      print('提交信息: $recipient, $phone, $fullAddress, $name, $points');

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
