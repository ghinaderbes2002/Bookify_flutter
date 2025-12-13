import 'package:bookify/core/Binding/auth_binding.dart';
import 'package:bookify/core/constant/App_routes.dart';
import 'package:bookify/core/services/SharedPreferences.dart';
import 'package:bookify/routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // تحميل الخدمات
  await initialServices();
  final myServices = await Get.putAsync(() => MyServices().init());

  bool isLoggedIn = myServices.sharedPref.getBool("isLoggedIn") ?? false;

  runApp(MyApp(isLoggedIn: isLoggedIn));
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;

  const MyApp({super.key, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: "HR App",
      initialBinding: AuthBinding(), // ⭐️ إضافة مهمة جداً

      initialRoute: isLoggedIn ? AppRoute.mainScreen : AppRoute.login,
      getPages: routes,
    );
  }
}
