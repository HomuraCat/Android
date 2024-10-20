import 'package:flutter/material.dart';

class TabIconData {
  TabIconData({
    this.imagePath = '',
    this.index = 0,
    this.selectedImagePath = '',
    this.isSelected = false,
    this.animationController,
  });

  String imagePath;
  String selectedImagePath;
  bool isSelected;
  int index;

  AnimationController? animationController;

  static List<TabIconData> tabIconsList = <TabIconData>[
    TabIconData(
      imagePath: 'assets/fitness_app/tab_1.jpg',
      selectedImagePath: 'assets/fitness_app/tab_1s.jpg',
      index: 0,
      isSelected: true,
      animationController: null,
    ),
    TabIconData(
      imagePath: 'assets/fitness_app/tab_2.jpg',
      selectedImagePath: 'assets/fitness_app/tab_2s.jpg',
      index: 1,
      isSelected: false,
      animationController: null,
    ),
    TabIconData(
      imagePath: 'assets/fitness_app/tab_3.jpg',
      selectedImagePath: 'assets/fitness_app/tab_3s.jpg',
      index: 2,
      isSelected: false,
      animationController: null,
    ),
    TabIconData(
      imagePath: 'assets/fitness_app/tab_4.jpg',
      selectedImagePath: 'assets/fitness_app/tab_4s.jpg',
      index: 3,
      isSelected: false,
      animationController: null,
    ),
  ];
}
