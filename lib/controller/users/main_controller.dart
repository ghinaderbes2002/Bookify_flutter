import 'package:get/get.dart';

class MainController extends GetxController {
  int currentIndex = 0;

  void changePage(int index) {
    currentIndex = index;
    update(); // تحديث الـ GetBuilder
  }
}
