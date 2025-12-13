import 'package:bookify/controller/auth/login_controller.dart';
import 'package:bookify/core/classes/staterequest.dart';
import 'package:bookify/core/constant/App_routes.dart';
import 'package:bookify/core/function/validinput.dart';
import 'package:bookify/core/them/app_colors.dart';
import 'package:bookify/view/widget/auth/CustomButton.dart';
import 'package:bookify/view/widget/auth/CustomTextFormFiled.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';


class Login extends StatelessWidget {
  const Login({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(LoginControllerImp());

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.grey[50],
        body: SafeArea(
          child: GetBuilder<LoginControllerImp>(
            builder: (_) {
              return SingleChildScrollView(
                child: Container(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 30),

                      // Logo

                      // Main Card
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              spreadRadius: 2,
                              blurRadius: 15,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(30.0),
                          child: Form(
                            key: controller.formState,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Header
                                Center(
                                  child: Column(
                                    children: [
                                      Text(
                                        'مرحباً بك',
                                        style: TextStyle(
                                          fontSize: 28,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.primary,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'قم بتسجيل الدخول للمتابعة',
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.grey[600],
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 40),

                                // email Field
                                CustomTextFormField(
                                  controller: controller.email,
                                  label: ' البريد الالكتروني ',
                                  hintText: 'أدخل البريد الالكتروني',
                                  prefixIcon: Icons.person_outline,
                                  validator: (val) =>
                                      validInput(val!, 3, 100, "email"),
                                  isDarkMode: false,
                                ),
                                const SizedBox(height: 20),

                                // Password Field
                                CustomTextFormField(
                                  controller: controller.password,
                                  label: "كلمة المرور",
                                  hintText: "********",
                                  prefixIcon: Icons.lock_outline,
                                  isPassword: controller.isPasswordHidden,
                                  onPasswordToggle:
                                      controller.togglePasswordVisibility,
                                  isDarkMode: false,
                                ),
                                const SizedBox(height: 12),

                                // Login Button
                                CustomButton(
                                  text: 'تسجيل الدخول',
                                  onPressed: () => controller.login(),
                                  isLoading:
                                      controller.staterequest ==
                                      Staterequest.loading,
                                ),

                                 const SizedBox(height: 30),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(" ليس لديك حساب ؟"),
                                    SizedBox(width: 5),
                                    GestureDetector(
                                      onTap: () =>
                                          Get.offAllNamed(AppRoute.signup),
                                      child: Row(
                                        mainAxisSize: MainAxisSize
                                            .min, // مهم حتى ما ياخد كل عرض الشاشة
                                        children: [
                                          Text(
                                            " إنشاء حساب",
                                            style: TextStyle(
                                              color: AppColors.primary,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          SizedBox(width: 4),
                                          Icon(
                                            Icons.person_add,
                                            size: 18,
                                            color: AppColors.primary,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
