import 'package:bookify/controller/users/categories_controller.dart';
import 'package:bookify/core/classes/staterequest.dart';
import 'package:bookify/view/screen/users/category_content_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(CategoriesControllerImp());

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'التصنيفات',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.teal,
        centerTitle: true,
        elevation: 0,
      ),
      body: GetBuilder<CategoriesControllerImp>(
        builder: (controller) {
          if (controller.staterequest == Staterequest.loading) {
            return const Center(
              child: CircularProgressIndicator(
                color: Colors.teal,
              ),
            );
          }

          if (controller.staterequest == Staterequest.failure) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    color: Colors.red,
                    size: 60,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'فشل تحميل التصنيفات',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () => controller.getAllCategories(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                    ),
                    child: const Text('إعادة المحاولة'),
                  ),
                ],
              ),
            );
          }

          if (controller.categories.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.category_outlined,
                    color: Colors.grey,
                    size: 60,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'لا توجد تصنيفات متاحة',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              await controller.getAllCategories();
            },
            color: Colors.teal,
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: controller.categories.length,
              itemBuilder: (context, index) {
                final category = controller.categories[index];
                return Card(
                  elevation: 2,
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    leading: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.teal.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.category,
                        color: Colors.teal,
                        size: 28,
                      ),
                    ),
                    title: Text(
                      category.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: category.description != null &&
                            category.description!.isNotEmpty
                        ? Text(
                            category.description!,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          )
                        : null,
                    trailing: const Icon(
                      Icons.arrow_forward_ios,
                      color: Colors.teal,
                      size: 18,
                    ),
                    onTap: () {
                      Get.to(
                        () => CategoryContentScreen(
                          categoryId: category.categoryId,
                          categoryName: category.name,
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
