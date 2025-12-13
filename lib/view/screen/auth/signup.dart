import 'package:bookify/controller/auth/signup_controller.dart';
import 'package:bookify/core/classes/staterequest.dart';
import 'package:bookify/core/function/validinput.dart';
import 'package:bookify/core/them/app_colors.dart';
import 'package:bookify/view/screen/auth/login.dart';
import 'package:bookify/view/widget/auth/CustomButton.dart';
import 'package:bookify/view/widget/auth/CustomTextFormFiled.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Signup extends StatelessWidget {
  const Signup({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(SignupControllerImp());

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.grey[50],
        body: SafeArea(
          child: GetBuilder<SignupControllerImp>(
            builder: (_) {
              return SingleChildScrollView(
                child: Container(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      const SizedBox(height: 30),

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
                              children: [
                                Text(
                                  "إنشاء حساب جديد",
                                  style: TextStyle(
                                    fontSize: 26,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primary,
                                  ),
                                ),
                                const SizedBox(height: 20),

                                // full name
                                CustomTextFormField(
                                  controller: controller.fullName,
                                  label: "الاسم الكامل",
                                  hintText: "اكتب اسمك",
                                  prefixIcon: Icons.person,
                                  validator: (val) =>
                                      validInput(val!, 3, 100, "name"),
                                  isDarkMode: false,
                                ),
                                const SizedBox(height: 20),

                                // email
                                CustomTextFormField(
                                  controller: controller.email,
                                  label: "البريد الإلكتروني",
                                  hintText: "example@gmail.com",
                                  prefixIcon: Icons.email_outlined,
                                  validator: (val) =>
                                      validInput(val!, 3, 100, "email"),
                                  isDarkMode: false,
                                ),
                                const SizedBox(height: 20),

                                // password
                                CustomTextFormField(
                                  controller: controller.password,
                                  label: "كلمة المرور",
                                  hintText: "********",
                                  prefixIcon: Icons.lock_outline,
                                  isPassword: controller.isPasswordHidden,
                                  onPasswordToggle:
                                      controller.togglePasswordVisibility,
                                  validator: (val) =>
                                      validInput(val!, 6, 100, "password"),
                                  isDarkMode: false,
                                ),
                                const SizedBox(height: 30),

                                CustomButton(
                                  text: "إنشاء الحساب",
                                  onPressed: () => controller.signup(),
                                  isLoading:
                                      controller.stateRequest ==
                                      Staterequest.loading,
                                ),
                                 const SizedBox(height: 30),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text("لديك حساب بالفعل؟"),
                                    SizedBox(width: 5),
                                    GestureDetector(
                                      onTap: () => Get.to(() => Login()),
                                      child: Row(
                                        mainAxisSize: MainAxisSize
                                            .min, // مهم حتى ما ياخد كل عرض الشاشة
                                        children: [
                                          Text(
                                            "تسجيل الدخول",
                                            style: TextStyle(
                                              color: AppColors.primary,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          SizedBox(width: 4),
                                          Icon(
                                            Icons.login,
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

                      const SizedBox(height: 20),
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
