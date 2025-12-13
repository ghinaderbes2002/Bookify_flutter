import 'package:bookify/controller/users/wishlist_controller.dart';
import 'package:bookify/controller/users/library_controller.dart';
import 'package:bookify/core/classes/staterequest.dart';
import 'package:bookify/core/constant/App_link.dart';
import 'package:bookify/model/wishlist_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MyWishlistScreen extends StatelessWidget {
  const MyWishlistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(WishlistControllerImp());

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'قائمة الأمنيات',
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
      body: GetBuilder<WishlistControllerImp>(
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

  Widget _buildFilterSection(WishlistControllerImp controller) {
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

  Widget _buildContentList(WishlistControllerImp controller) {
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
            Icon(Icons.error_outline, size: 60, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              'حدث خطأ في تحميل القائمة',
              style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => controller.getWishlist(),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              icon: const Icon(Icons.refresh),
              label: const Text('إعادة المحاولة'),
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
            Icon(Icons.favorite_border, size: 80, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text(
              controller.selectedFilter == null
                  ? 'قائمة الأمنيات فارغة'
                  : 'لا يوجد محتوى من هذا النوع',
              style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
            ),
            if (controller.selectedFilter == null) ...[
              const SizedBox(height: 8),
              Text(
                'ابدأ بإضافة محتوى مفضل لديك',
                style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
              ),
            ],
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        await controller.getWishlist();
      },
      color: Colors.teal,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: controller.filteredItems.length,
        itemBuilder: (context, index) {
          return _buildWishlistItem(
            controller.filteredItems[index],
            controller,
          );
        },
      ),
    );
  }

  Widget _buildWishlistItem(
      WishlistItemModel item, WishlistControllerImp controller) {
    final serverConfig = ServerConfig();

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            // TODO: Navigate to content details
            // Get.toNamed(AppRoute.contentDetails, arguments: {'contentId': item.contentId});
          },
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Cover Image
                Container(
                  width: 80,
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: item.coverImageUrl != null &&
                          item.coverImageUrl!.isNotEmpty
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            '${serverConfig.serverLink}${item.coverImageUrl}',
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return _buildPlaceholder(item);
                            },
                          ),
                        )
                      : _buildPlaceholder(item),
                ),
                const SizedBox(width: 12),

                // Content Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Type Badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.teal.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
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

                      // Title
                      Text(
                        item.title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),

                      // Author
                      if (item.author != null && item.author!.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          item.author!,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],

                      // Description
                      if (item.description != null &&
                          item.description!.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Text(
                          item.description!,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade500,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],

                      const SizedBox(height: 8),

                      // Time
                      Row(
                        children: [
                          Icon(Icons.access_time,
                              size: 14, color: Colors.grey.shade500),
                          const SizedBox(width: 4),
                          Text(
                            item.getTimeSinceAdded(),
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 8),

                      // Action Buttons
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          // Move to Library Button
                          TextButton.icon(
                            onPressed: () {
                              _showMoveToLibraryDialog(controller, item);
                            },
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.teal,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                            ),
                            icon: const Icon(Icons.library_add, size: 18),
                            label: const Text(
                              'نقل إلى مكتبتي',
                              style: TextStyle(fontSize: 13),
                            ),
                          ),
                          const SizedBox(width: 4),
                          // Remove Button
                          IconButton(
                            onPressed: () {
                              _showRemoveDialog(controller, item);
                            },
                            icon: const Icon(
                              Icons.delete_outline,
                              color: Colors.red,
                              size: 22,
                            ),
                            tooltip: 'إزالة من القائمة',
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholder(WishlistItemModel item) {
    return Center(
      child: Text(
        item.getContentTypeIcon(),
        style: const TextStyle(fontSize: 40),
      ),
    );
  }

  void _showRemoveDialog(
      WishlistControllerImp controller, WishlistItemModel item) {
    Get.dialog(
      AlertDialog(
        title: const Text(
          'إزالة من القائمة',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Text('هل تريد إزالة "${item.title}" من قائمة الأمنيات؟'),
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
              Get.back();
              controller.removeFromWishlist(item.wishlistItemId);
            },
            child: const Text(
              'إزالة',
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  void _showMoveToLibraryDialog(
      WishlistControllerImp controller, WishlistItemModel item) {
    Get.dialog(
      AlertDialog(
        title: Row(
          children: [
            Icon(Icons.library_books, color: Colors.teal, size: 28),
            const SizedBox(width: 12),
            const Text(
              'نقل إلى المكتبة',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('هل تريد نقل "${item.title}" إلى مكتبتك؟'),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.teal.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.teal.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, size: 18, color: Colors.teal),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'سيتم إضافة المحتوى إلى مكتبتك وإزالته من قائمة الأمنيات',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.teal.shade700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text(
              'إلغاء',
              style: TextStyle(color: Colors.grey),
            ),
          ),
          ElevatedButton.icon(
            onPressed: () async {
              Get.back();
              await _moveToLibrary(controller, item);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.teal,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            icon: const Icon(Icons.library_add, size: 18),
            label: const Text(
              'نقل',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _moveToLibrary(
      WishlistControllerImp wishlistController, WishlistItemModel item) async {
    // الحصول على أو إنشاء LibraryController
    LibraryControllerImp libraryController;
    if (Get.isRegistered<LibraryControllerImp>()) {
      libraryController = Get.find<LibraryControllerImp>();
    } else {
      libraryController = Get.put(LibraryControllerImp());
    }

    // إضافة إلى المكتبة
    final success = await libraryController.addToLibrary(item.contentId);

    // إذا نجحت الإضافة، نزيل من قائمة الأمنيات
    if (success) {
      await wishlistController.removeFromWishlist(item.wishlistItemId);
    }
  }
}
