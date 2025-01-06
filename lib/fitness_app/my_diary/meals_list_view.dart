// lib/fitness_app/my_diary/knowledge_learning/meals_list_view.dart

import 'package:flutter/material.dart';
import 'package:best_flutter_ui_templates/fitness_app/fitness_app_theme.dart';
import 'package:best_flutter_ui_templates/fitness_app/models/meals_list_data.dart';
import 'package:best_flutter_ui_templates/fitness_app/my_diary/recipe/recipe.dart';

class MealsListView extends StatefulWidget {
  final AnimationController? mainScreenAnimationController;
  final Animation<double>? mainScreenAnimation;

  const MealsListView({
    Key? key,
    this.mainScreenAnimationController,
    this.mainScreenAnimation,
  }) : super(key: key);

  @override
  _MealsListViewState createState() => _MealsListViewState();
}

class _MealsListViewState extends State<MealsListView>
    with TickerProviderStateMixin {

  late AnimationController animationController;
  // 1. 用一个列表来保存生成后的 mealsListData
  List<MealsListData> mealsListData = [];

  @override
  void initState() {
    super.initState();

    // 初始化本地动画控制器
    animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    // 2. 异步获取后端用户信息并生成餐次列表
    fetchAndGenerateMeals();
  }

  // 2-1. 从后端获取数据并生成餐次列表
  Future<void> fetchAndGenerateMeals() async {
    // a) 创建一个 MealsListData 对象
    final MealsListData dataHelper = MealsListData();

    // b) 异步获取用户数据(内含 BMR 计算)
    await dataHelper.fetchUserData();

    // c) 生成餐次列表
    final generatedList = dataHelper.generateMealsList();

    // d) setState 触发UI刷新
    setState(() {
      mealsListData = generatedList;
    });

    // e) 播放动画
    animationController.forward();
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 如果这里需要动画，一定要确保 mainScreenAnimationController 非空
    return AnimatedBuilder(
      animation: widget.mainScreenAnimationController ?? animationController,
      builder: (BuildContext context, Widget? child) {
        // 使用 widget.mainScreenAnimation 进行动画透明度变化
        return FadeTransition(
          opacity: widget.mainScreenAnimation ?? AlwaysStoppedAnimation(1.0),
          child: Transform(
            transform: Matrix4.translationValues(
              0.0,
              30 * (1.0 - (widget.mainScreenAnimation?.value ?? 1.0)),
              0.0,
            ),
            child: SizedBox(
              height: 420,
              width: double.infinity,
              child: GridView.builder(
                padding: const EdgeInsets.only(
                  top: 0, bottom: 0, right: 16, left: 16),
                itemCount: mealsListData.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 1.7,
                ),
                scrollDirection: Axis.horizontal,
                itemBuilder: (BuildContext context, int index) {
                  // 根据 index 获取单项数据
                  final MealsListData data = mealsListData[index];
                  final Animation<double> anim = Tween<double>(
                    begin: 0.0, end: 1.0,
                  ).animate(
                    CurvedAnimation(
                      parent: animationController,
                      curve: Interval(
                        (1 / mealsListData.length) * index,
                        1.0,
                        curve: Curves.fastOutSlowIn,
                      ),
                    ),
                  );
                  return MealsView(
                    mealsListData: data,
                    animation: anim,
                    animationController: animationController,
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) =>
                            RecipeListPage(selectedMealType: data.titleTxt),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }
}

// ----------------------------
// 下面是 MealsView 的单项组件
// ----------------------------
class MealsView extends StatelessWidget {
  final MealsListData mealsListData;
  final Animation<double> animation;
  final AnimationController animationController;
  final VoidCallback onTap;

  const MealsView({
    Key? key,
    required this.mealsListData,
    required this.animation,
    required this.animationController,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animationController,
      builder: (BuildContext context, Widget? child) {
        return 
        MediaQuery(
    data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
    child:
        GestureDetector(
          onTap: onTap, // 点击后跳转到 RecipeListPage
          child: FadeTransition(
            opacity: animation,
            child: Transform(
              transform: Matrix4.translationValues(
                100 * (1.0 - animation.value), 0.0, 0.0),
              child: SizedBox(
                width: 130,
                child: Stack(
                  children: <Widget>[
                    // 背景容器
                    Padding(
                      padding: const EdgeInsets.only(
                        top: 32, left: 8, right: 8, bottom: 24),
                      child: Container(
                        decoration: BoxDecoration(
                          boxShadow: <BoxShadow>[
                            BoxShadow(
                              color: HexColor(mealsListData.endColor)
                                  .withOpacity(0.6),
                              offset: const Offset(1.1, 4.0),
                              blurRadius: 8.0,
                            ),
                          ],
                          gradient: LinearGradient(
                            colors: [
                              HexColor(mealsListData.startColor),
                              HexColor(mealsListData.endColor),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: const BorderRadius.only(
                            bottomRight: Radius.circular(20.0),
                            bottomLeft: Radius.circular(20.0),
                            topLeft: Radius.circular(20.0),
                            topRight: Radius.circular(20.0),
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.only(
                            top: 54, left: 16, right: 16, bottom: 8),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              // 标题
                              Text(
                                mealsListData.titleTxt,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontFamily: FitnessAppTheme.fontName,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                  letterSpacing: 0.2,
                                  color: FitnessAppTheme.white,
                                ),
                              ),
                              // 卡路里显示
                              mealsListData.kacl != 0
                                  ? Row(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: <Widget>[
                                        Text(
                                          mealsListData.kacl.toString(),
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(
                                            fontFamily: FitnessAppTheme.fontName,
                                            fontWeight: FontWeight.w500,
                                            fontSize: 18,
                                            letterSpacing: 0.2,
                                            color: FitnessAppTheme.white,
                                          ),
                                        ),
                                        const Padding(
                                          padding: EdgeInsets.only(
                                              left: 4, bottom: 3),
                                          child: Text(
                                            '卡路里',
                                            style: TextStyle(
                                              fontFamily:
                                                  FitnessAppTheme.fontName,
                                              fontWeight: FontWeight.w500,
                                              fontSize: 12,
                                              letterSpacing: 0.2,
                                              color: FitnessAppTheme.white,
                                            ),
                                          ),
                                        ),
                                      ],
                                    )
                                  : Container(),
                            ],
                          ),
                        ),
                      ),
                    ),
                    // 左上角圆圈
                    Positioned(
                      top: 0,
                      left: 0,
                      child: Container(
                        width: 84,
                        height: 84,
                        decoration: BoxDecoration(
                          color: FitnessAppTheme.nearlyWhite.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                    // 左上角餐图
                    Positioned(
                      top: 8,
                      left: 8,
                      child: SizedBox(
                        width: 70,
                        height: 70,
                        child: Image.asset(mealsListData.imagePath),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),);
      },
    );
  }
}

// 辅助转换颜色的类
class HexColor extends Color {
  static int _getColorFromHex(String hexColor) {
    String color = hexColor.toUpperCase().replaceAll("#", "");
    if (color.length == 6) {
      color = "FF$color";
    }
    return int.parse(color, radix: 16);
  }

  HexColor(final String hexColor) : super(_getColorFromHex(hexColor));
}
