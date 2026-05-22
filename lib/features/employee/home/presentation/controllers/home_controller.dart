import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

class HomeController extends GetxController {
  final RxInt selectedTab = 0.obs;

  void switchTab(int index) {
    if (selectedTab.value == index) return;
    FocusManager.instance.primaryFocus?.unfocus();
    selectedTab.value = index;
  }
}
