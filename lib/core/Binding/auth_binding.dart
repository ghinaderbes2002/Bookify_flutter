import 'package:bookify/controller/auth/login_controller.dart';
import 'package:get/get.dart';

class AuthBinding extends Bindings {
  @override
  void dependencies() {
    // هون منسجّل الكنترولر مرة وحدة فقط
    Get.put(LoginControllerImp(), permanent: true);
  }
}
