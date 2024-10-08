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
      imagePath: 'assets/fitness_app/breakfast.png',
      titleTxt: '早餐',
      kacl: 226,
      meals: <String>['高蛋白','美味'],
      startColor: '#FA7D82',
      endColor: '#FFB295',
    ),
    MealsListData(
      imagePath: 'assets/fitness_app/breakfast.png',
      titleTxt: '早餐加餐',
      kacl: 150,
      meals: <String>['健康','零食'],
      startColor: '#FA7D82',
      endColor: '#FFB295',
    ),
    MealsListData(
      imagePath: 'assets/fitness_app/lunch.png',
      titleTxt: '午餐',
      kacl: 602,
      meals: <String>['高能量','均衡'],
      startColor: '#738AE6',
      endColor: '#5C5EDD',
    ),
    MealsListData(
      imagePath: 'assets/fitness_app/lunch.png',
      titleTxt: '午餐加餐',
      kacl: 250,
      meals: <String>['活力', '小吃'],
      startColor: '#738AE6',
      endColor: '#5C5EDD',
    ),
    MealsListData(
      imagePath: 'assets/fitness_app/snack.png',
      titleTxt: '晚餐',
      kacl: 114,
      meals: <String>['易消化', '温和'],
      startColor: '#FE95B6',
      endColor: '#FF5287',
    ),
    MealsListData(
      imagePath: 'assets/fitness_app/snack.png',
      titleTxt: '晚餐加餐',
      kacl: 180,
      meals: <String>['新鲜', '水果'],
      startColor: '#FE95B6',
      endColor: '#FF5287',
    ),  
  ];
}