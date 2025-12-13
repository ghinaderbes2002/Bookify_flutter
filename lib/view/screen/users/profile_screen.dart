import 'dart:convert';
import 'package:bookify/controller/auth/login_controller.dart';
import 'package:bookify/model/UserModel.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final LoginControllerImp controller = Get.find<LoginControllerImp>();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'الملف الشخصي',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.teal,
        centerTitle: true,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Profile Header
            _buildProfileHeader(controller),

            const SizedBox(height: 20),

            // Menu Items
            _buildMenuSection(),
          ],
        ),
      ),
    );
  }

Widget _buildProfileHeader(LoginControllerImp controller) {
    // قراءة بيانات المستخدم من SharedPreferences
    final String? userJson = controller.myServices.sharedPref.getString("user");
    UserModel? user;
    if (userJson != null) {
      user = UserModel.fromJson(jsonDecode(userJson));
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.teal,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Avatar
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              border: Border.all(color: Colors.white, width: 4),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(Icons.person, size: 50, color: Colors.teal),
          ),
          const SizedBox(height: 16),
          // User Name
          Text(
            user?.fullName ?? 'اسم المستخدم',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          // User Email
          Text(
            user?.email ?? 'user@example.com',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withValues(alpha: 0.9),
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildMenuSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // _buildMenuItem(
          //   icon: Icons.person_outline,
          //   title: 'معلوماتي',
          //   subtitle: 'عرض وتعديل المعلومات الشخصية',
          //   color: Colors.blue,
          //   onTap: () {
          //     // TODO: Navigate to My Info
          //     Get.snackbar(
          //       'قريباً',
          //       'صفحة معلوماتي قيد التطوير',
          //       backgroundColor: Colors.orange.withValues(alpha: 0.8),
          //       colorText: Colors.white,
          //     );
          //   },
          // ),
          // const Divider(height: 1),
          _buildMenuItem(
            icon: Icons.rate_review_outlined,
            title: 'تقييماتي',
            subtitle: 'مراجعاتك وتقييماتك للمحتوى',
            color: Colors.amber,
            onTap: () {
              Get.toNamed('/my-reviews');
            },
          ),
          const Divider(height: 1),
          _buildMenuItem(
            icon: Icons.favorite_border,
            title: 'قائمة الأمنيات',
            subtitle: 'المحتوى المفضل لديك',
            color: Colors.red,
            onTap: () {
              Get.toNamed('/my-wishlist');
            },
          ),
          const Divider(height: 1),
          _buildMenuItem(
            icon: Icons.cloud_upload_outlined,
            title: 'ملفاتي',
            subtitle: 'الملفات التي قمت برفعها',
            color: Colors.purple,
            onTap: () {
              Get.toNamed('/my-uploads');
            },
          ),
          const Divider(height: 1),
       _buildMenuItem(
            icon: Icons.logout,
            title: 'تسجيل الخروج',
            subtitle: 'الخروج من الحساب',
            color: Colors.red.shade700,
            isLogout: true,
            onTap: () {
              Get.dialog(
                AlertDialog(
                  title: const Text(
                    'تسجيل الخروج',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  content: const Text('هل أنت متأكد من تسجيل الخروج؟'),
                  actions: [
                    TextButton(
                      onPressed: () => Get.back(),
                      child: const Text(
                        'إلغاء',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Get.back(); // إغلاق الحوار
                        //  controller.logout();
                        // ⭐ استدعاء دالة تسجيل الخروج
                        Get.find<LoginControllerImp>().logout();
                      },
                      child: const Text(
                        'تأكيد',
                        style: TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),

        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
    bool isLogout = false,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Icon Container
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: color,
                size: 26,
              ),
            ),
            const SizedBox(width: 16),
            // Title & Subtitle
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isLogout ? color : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            // Arrow Icon
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Colors.grey[400],
            ),
          ],
        ),
      ),
    );
  }

}
