import 'package:bookify/core/classes/api_client.dart';
import 'package:bookify/core/classes/staterequest.dart';
import 'package:bookify/core/constant/App_link.dart';
import 'package:bookify/core/services/SharedPreferences.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

abstract class SignupController extends GetxController {
  signup();
}

class SignupControllerImp extends SignupController {
  GlobalKey<FormState> formState = GlobalKey<FormState>();

  late TextEditingController fullName;
  late TextEditingController email;
  late TextEditingController password;

  final myServices = Get.find<MyServices>();

  Staterequest stateRequest = Staterequest.none;
  bool isPasswordHidden = true;


 @override
 @override
  signup() async {
    if (!formState.currentState!.validate()) return;

    stateRequest = Staterequest.loading;
    update();

    ApiClient api = ApiClient();

    try {
      ApiResponse response = await api.postData(
        url: "${ServerConfig().serverLink}/auth/register",
        data: {
          "full_name": fullName.text.trim(),
          "email": email.text.trim(),
          "password": password.text.trim(),
          "role": "USER",
        },
      );

      print("Signup Response: ${response.data}");
      print("Status: ${response.statusCode}");

      // ✅ لو التسجيل ناجح
      if (response.statusCode == 200 || response.statusCode == 201) {
        Get.snackbar(
          "نجاح",
          response.data["message"] ?? "تم إنشاء الحساب بنجاح!",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.shade600,
          colorText: Colors.white,
          margin: const EdgeInsets.all(10),
          duration: const Duration(seconds: 3),
        );

        await Future.delayed(const Duration(seconds: 3));
        Get.back(); // الرجوع لصفحة تسجيل الدخول
        return;
      }
      // ⚠️ لو هناك خطأ من السيرفر (مثل البريد مستخدم مسبقًا)
      else {
        Get.snackbar(
          "خطأ",
          response.data["message"] ?? "حدث خطأ غير معروف",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.shade600,
          colorText: Colors.white,
          margin: const EdgeInsets.all(10),
          duration: const Duration(seconds: 3),
        );
      }
    } catch (e) {
      Get.snackbar(
        "خطأ",
        "حدث خطأ غير متوقع: $e",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade600,
        colorText: Colors.white,
        margin: const EdgeInsets.all(10),
        duration: const Duration(seconds: 3),
      );
    } finally {
      stateRequest = Staterequest.none;
      update();
    }
  }

  void togglePasswordVisibility() {
    isPasswordHidden = !isPasswordHidden;
    update();
  }

  @override
  void onInit() {
    fullName = TextEditingController();
    email = TextEditingController();
    password = TextEditingController();
    super.onInit();
  }

  @override
  void dispose() {
    fullName.dispose();
    email.dispose();
    password.dispose();
    super.dispose();
  }
}
