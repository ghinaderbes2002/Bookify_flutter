import 'package:bookify/controller/users/library_controller.dart';
import 'package:bookify/core/classes/staterequest.dart';
import 'package:bookify/core/constant/App_link.dart';
import 'package:bookify/view/screen/users/content_details_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MyLibraryScreen extends StatelessWidget {
  const MyLibraryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(LibraryControllerImp());

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'مكتبتي',
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
      body: GetBuilder<LibraryControllerImp>(
        builder: (controller) {
          return Column(
            children: [
              // Filter Section
              _buildFilterSection(controller),

              // Content List
              Expanded(
                child: _buildContentList(controller),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildFilterSection(LibraryControllerImp controller) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.teal.shade50,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.2),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildFilterChip(
              label: 'الكل',
              icon: Icons.list,
              isSelected: controller.selectedFilter == null,
              onTap: () => controller.filterByType(null),
            ),
            const SizedBox(width: 8),
            _buildFilterChip(
              label: 'كتب',
              icon: Icons.book,
              isSelected: controller.selectedFilter == 'book',
              onTap: () => controller.filterByType('book'),
            ),
            const SizedBox(width: 8),
            _buildFilterChip(
              label: 'مجلات',
              icon: Icons.article,
              isSelected: controller.selectedFilter == 'magazine',
              onTap: () => controller.filterByType('magazine'),
            ),
            const SizedBox(width: 8),
            _buildFilterChip(
              label: 'بودكاست',
              icon: Icons.mic,
              isSelected: controller.selectedFilter == 'podcast',
              onTap: () => controller.filterByType('podcast'),
            ),
            const SizedBox(width: 8),
            _buildFilterChip(
              label: 'كتب صوتية',
              icon: Icons.headphones,
              isSelected: controller.selectedFilter == 'audiobook',
              onTap: () => controller.filterByType('audiobook'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.teal : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? Colors.teal : Colors.grey.shade300,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected ? Colors.white : Colors.teal,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.teal,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContentList(LibraryControllerImp controller) {
    if (controller.staterequest == Staterequest.loading) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.teal),
      );
    }

    if (controller.staterequest == Staterequest.failure ||
        controller.staterequest == Staterequest.serverfailure) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 60, color: Colors.red.shade300),
            const SizedBox(height: 16),
            const Text(
              'فشل تحميل المكتبة',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => controller.getLibrary(),
              icon: const Icon(Icons.refresh),
              label: const Text('إعادة المحاولة'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      );
    }

    if (controller.filteredItems.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.library_books_outlined,
                size: 80, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text(
              controller.selectedFilter == null
                  ? 'مكتبتك فارغة'
                  : 'لا يوجد محتوى من هذا النوع',
              style: const TextStyle(
                fontSize: 18,
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'ابدأ بإضافة محتوى إلى مكتبتك',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        await controller.getLibrary();
      },
      color: Colors.teal,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Recently Accessed Section
          if (controller.selectedFilter == null &&
              controller.getRecentlyAccessed().isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'آخر ما تم الوصول إليه',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade700,
                ),
              ),
            ),
            SizedBox(
              height: 200,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: controller.getRecentlyAccessed().length,
                itemBuilder: (context, index) {
                  final item = controller.getRecentlyAccessed()[index];
                  return _buildRecentCard(item, controller);
                },
              ),
            ),
            const Divider(height: 32),
          ],

          // All Library Items
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              'جميع المحتويات (${controller.filteredItems.length})',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade700,
              ),
            ),
          ),

          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: controller.filteredItems.length,
              itemBuilder: (context, index) {
                final item = controller.filteredItems[index];
                return _buildLibraryCard(item, controller);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentCard(item, LibraryControllerImp controller) {
    final serverConfig = ServerConfig();

    return GestureDetector(
      onTap: () {
        controller.updateLastAccess(item.userLibraryId);
        Get.to(() => ContentDetailsScreen(contentId: item.contentId));
      },
      child: Container(
        width: 140,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(alpha: 0.2),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cover Image
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(12)),
              child: item.coverImageUrl != null
                  ? Image.network(
                      '${serverConfig.serverLink}${item.coverImageUrl}',
                      height: 140,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          height: 140,
                          color: Colors.teal.shade100,
                          child:
                              const Icon(Icons.book, size: 50, color: Colors.teal),
                        );
                      },
                    )
                  : Container(
                      height: 140,
                      color: Colors.teal.shade100,
                      child: const Icon(Icons.book, size: 50, color: Colors.teal),
                    ),
            ),

            // Title
            Padding(
              padding: const EdgeInsets.all(8),
              child: Text(
                item.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLibraryCard(item, LibraryControllerImp controller) {
    final serverConfig = ServerConfig();

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          controller.updateLastAccess(item.userLibraryId);
          Get.to(() => ContentDetailsScreen(contentId: item.contentId));
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Cover Image
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: item.coverImageUrl != null
                    ? Image.network(
                        '${serverConfig.serverLink}${item.coverImageUrl}',
                        width: 80,
                        height: 110,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: 80,
                            height: 110,
                            color: Colors.teal.shade100,
                            child: const Icon(Icons.book,
                                size: 40, color: Colors.teal),
                          );
                        },
                      )
                    : Container(
                        width: 80,
                        height: 110,
                        color: Colors.teal.shade100,
                        child:
                            const Icon(Icons.book, size: 40, color: Colors.teal),
                      ),
              ),

              const SizedBox(width: 12),

              // Content Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Text(
                      item.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const SizedBox(height: 6),

                    // Author
                    if (item.author != null)
                      Text(
                        item.author!,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),

                    const SizedBox(height: 8),

                    // Type Badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.teal.shade50,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${item.getContentTypeIcon()} ${item.getContentTypeLabel()}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.teal,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),

                    const SizedBox(height: 8),

                    // Added Date
                    Text(
                      'أضيف: ${_formatDate(item.addedAt)}',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade500,
                      ),
                    ),

                    // Last Accessed
                    if (item.lastAccessedAt != null)
                      Text(
                        'آخر دخول: ${_formatDate(item.lastAccessedAt!)}',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade500,
                        ),
                      ),
                  ],
                ),
              ),

              // Remove Button
              IconButton(
                onPressed: () {
                  _showRemoveDialog(item, controller);
                },
                icon: const Icon(Icons.delete_outline, color: Colors.red),
                tooltip: 'إزالة من المكتبة',
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showRemoveDialog(item, LibraryControllerImp controller) {
    Get.dialog(
      AlertDialog(
        title: const Text('إزالة من المكتبة'),
        content: Text('هل تريد إزالة "${item.title}" من مكتبتك؟'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              controller.removeFromLibrary(item.userLibraryId);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('إزالة'),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        if (difference.inMinutes == 0) {
          return 'الآن';
        }
        return 'منذ ${difference.inMinutes} دقيقة';
      }
      return 'منذ ${difference.inHours} ساعة';
    } else if (difference.inDays == 1) {
      return 'أمس';
    } else if (difference.inDays < 7) {
      return 'منذ ${difference.inDays} أيام';
    } else if (difference.inDays < 30) {
      return 'منذ ${(difference.inDays / 7).floor()} أسابيع';
    } else if (difference.inDays < 365) {
      return 'منذ ${(difference.inDays / 30).floor()} شهر';
    } else {
      return 'منذ ${(difference.inDays / 365).floor()} سنة';
    }
  }
}
