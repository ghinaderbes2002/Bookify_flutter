import 'dart:convert';
import 'package:bookify/core/classes/api_client.dart';
import 'package:bookify/core/classes/staterequest.dart';
import 'package:bookify/core/constant/App_link.dart';
import 'package:bookify/core/constant/App_routes.dart';
import 'package:bookify/core/services/SharedPreferences.dart';
import 'package:bookify/model/UserModel.dart';
import 'package:bookify/view/screen/users/mainScreen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

abstract class LoginController extends GetxController {
  login();
  logout();
}

class LoginControllerImp extends LoginController {
  GlobalKey<FormState> formState = GlobalKey<FormState>();

  late TextEditingController email;
  late TextEditingController password;

  final myServices = Get.find<MyServices>();

  Staterequest staterequest = Staterequest.none;
  bool isPasswordHidden = true;

 @override
  login() async {
    if (!formState.currentState!.validate()) return;

    staterequest = Staterequest.loading;
    update();

    ApiClient api = ApiClient();

    try {
      ApiResponse response = await api.postData(
        url: "${ServerConfig().serverLink}/auth/login",
        data: {"email": email.text.trim(), "password": password.text.trim()},
      );

      print("Response: ${response.data}");
      print("Status: ${response.statusCode}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;

        // 🔥 التعديل هنا
        final token = data["token"]; // ✔️ اسم صحيح
        final userData = data["user"]; // ✔️ موجود فعلاً

        if (token == null || userData == null) {
          Get.snackbar("خطأ", "الرد لا يحتوي على بيانات مستخدم");
          return;
        }

        // 🔥 تحويل لموديل
        UserModel user = UserModel.fromJson(userData);

        // 🔥 حفظ كل البيانات
        await myServices.sharedPref.setString("token", token);

        await myServices.sharedPref.setString(
          "user",
          jsonEncode(user.toJson()),
        );

        await myServices.sharedPref.setString("role", user.role);
        await myServices.sharedPref.setBool("isLoggedIn", true);

        // 🔥 حفظ userId
        final userId = user.userId;
        await myServices.sharedPref.setInt("userId", userId);

        print("LOGIN SUCCESS → ROLE: ${user.role}");

        // 🔥 الانتقال حسب الدور
        if (user.role == "USER") {
          Get.offAll(() => const MainScreen());
        } else {
          Get.snackbar("خطأ", "دور غير معروف: ${user.role}");
        }
      } else {
        Get.snackbar("خطأ", "فشل تسجيل الدخول: ${response.statusCode}");
      }
    } catch (e) {
      Get.snackbar("خطأ", "حدث خطأ غير متوقع: $e");
    } finally {
      staterequest = Staterequest.none;
      update();
    }
  }

  @override

  void logout() async {
    await myServices.sharedPref.remove("token");
    await myServices.sharedPref.remove("user");
    await myServices.sharedPref.remove("role");
    await myServices.sharedPref.remove("userId");
    await myServices.sharedPref.setBool("isLoggedIn", false);

    print("LOGOUT SUCCESS → user data cleared");

    // الانتقال لصفحة تسجيل الدخول
    Get.offAllNamed(AppRoute.login);
  }



  void togglePasswordVisibility() {
    isPasswordHidden = !isPasswordHidden;
    update();
  }

  @override
  void onInit() {
    email = TextEditingController();
    password = TextEditingController();
    super.onInit();
  }

  @override
  void dispose() {
    email.dispose();
    password.dispose();
    super.dispose();
  }
}
