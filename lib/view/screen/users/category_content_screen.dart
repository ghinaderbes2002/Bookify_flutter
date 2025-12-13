import 'package:bookify/controller/users/content_controller.dart';
import 'package:bookify/core/classes/staterequest.dart';
import 'package:bookify/core/constant/App_link.dart';
import 'package:bookify/view/screen/users/content_details_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CategoryContentScreen extends StatelessWidget {
  final int categoryId;
  final String categoryName;

  const CategoryContentScreen({
    super.key,
    required this.categoryId,
    required this.categoryName,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ContentControllerImp());
    final serverConfig = ServerConfig();
    controller.getContentByCategory(categoryId);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          categoryName,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.teal,
        centerTitle: true,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: GetBuilder<ContentControllerImp>(
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
                    'فشل تحميل المحتوى',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () => controller.getContentByCategory(categoryId),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                    ),
                    child: const Text('إعادة المحاولة'),
                  ),
                ],
              ),
            );
          }

          if (controller.staterequest == Staterequest.empty ||
              controller.contents.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.article_outlined,
                    color: Colors.grey.shade400,
                    size: 80,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'لا يوجد محتوى في هذا التصنيف حالياً',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'سيتم عرض الكتب والمقالات المتعلقة بهذا التصنيف هنا',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              await controller.getContentByCategory(categoryId);
            },
            color: Colors.teal,
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: controller.contents.length,
              itemBuilder: (context, index) {
                final content = controller.contents[index];
                return Card(
                  elevation: 2,
                  margin: const EdgeInsets.only(bottom: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () {
                      Get.to(
                        () => ContentDetailsScreen(
                          contentId: content.contentId,
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 80,
                            height: 110,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              color: Colors.grey.shade200,
                              image: content.coverUrl != null
                                  ? DecorationImage(
                                      image: NetworkImage(
                                        '${serverConfig.serverLink}${content.coverUrl}',
                                      ),
                                      fit: BoxFit.cover,
                                    )
                                  : null,
                            ),
                            child: content.coverUrl == null
                                ? Center(
                                    child: Text(
                                      content.getContentTypeIcon(),
                                      style: const TextStyle(fontSize: 32),
                                    ),
                                  )
                                : null,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.teal.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    content.getContentTypeLabel(),
                                    style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.teal,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  content.title,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                if (content.author != null) ...[
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.person_outline,
                                        size: 14,
                                        color: Colors.grey,
                                      ),
                                      const SizedBox(width: 4),
                                      Expanded(
                                        child: Text(
                                          content.author!,
                                          style: const TextStyle(
                                            fontSize: 13,
                                            color: Colors.grey,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                                if (content.description != null &&
                                    content.description!.isNotEmpty) ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    content.description!,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: Colors.grey,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    if (content.pagesCount != null) ...[
                                      const Icon(
                                        Icons.book_outlined,
                                        size: 14,
                                        color: Colors.grey,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        '${content.pagesCount} صفحة',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                    ],
                                    if (content.language != null) ...[
                                      const Icon(
                                        Icons.language,
                                        size: 14,
                                        color: Colors.grey,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        content.language!,
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
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
