class MealsListData {
  MealsListData({
    this.imagePath = '',
    this.titleTxt = '',
    this.startColor = '',
    this.endColor = '',
    this.meals,
    this.kacl = 0,
  });

  String imagePath;
  String titleTxt;
  String startColor;
  String endColor;
  List<String>? meals;
  int kacl;

  static List<MealsListData> tabIconsList = <MealsListData>[
    MealsListData(
      imagePath: 'assets/fitness_app/breakfast.jpg',
      titleTxt: '早餐',
      kacl: 226,
      meals: <String>['高蛋白','美味'],
      startColor: '#FFA62C',
      endColor: '#FFA62C',
    ),
    MealsListData(
      imagePath: 'assets/fitness_app/breakfast.jpg',
      titleTxt: '早餐加餐',
      kacl: 150,
      meals: <String>['健康','零食'],
      startColor: '#FFA62C',
      endColor: '#FFA62C',
    ),
    MealsListData(
      imagePath: 'assets/fitness_app/lunch.jpg',
      titleTxt: '午餐',
      kacl: 602,
      meals: <String>['高能量','均衡'],
      startColor: '#CF9F6E',
      endColor: '#CF9F6E',
    ),
    MealsListData(
      imagePath: 'assets/fitness_app/lunch.jpg',
      titleTxt: '午餐加餐',
      kacl: 250,
      meals: <String>['活力', '小吃'],
      startColor: '#CF9F6E',
      endColor: '#CF9F6E',
    ),
    MealsListData(
      imagePath: 'assets/fitness_app/dinner.jpg',
      titleTxt: '晚餐',
      kacl: 114,
      meals: <String>['易消化', '温和'],
      startColor: '#BFB9AC',
      endColor: '#BFB9AC',
    ),
    MealsListData(
      imagePath: 'assets/fitness_app/dinner.jpg',
      titleTxt: '晚餐加餐',
      kacl: 180,
      meals: <String>['新鲜', '水果'],
      startColor: '#BFB9AC',
      endColor: '#BFB9AC',
    ),  
  ];
}