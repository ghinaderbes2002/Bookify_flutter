import 'package:bookify/controller/users/search_controller.dart';
import 'package:bookify/core/classes/staterequest.dart';
import 'package:bookify/core/constant/App_link.dart';
import 'package:bookify/model/content_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(SearchControllerImp());

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'البحث',
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
      body: GetBuilder<SearchControllerImp>(
        builder: (controller) {
          return Column(
            children: [
              // Search Bar
              _buildSearchBar(controller),

              // Type Filters
              _buildTypeFilters(controller),

              // Category Filters (if categories available)
              if (controller.categories.isNotEmpty)
                _buildCategoryFilters(controller),

              // Active Filters & Clear Button
              if (controller.hasActiveFilters)
                _buildActiveFiltersBar(controller),

              // Results
              Expanded(
                child: _buildSearchResults(controller),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSearchBar(SearchControllerImp controller) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.teal.shade50,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: controller.searchTextController,
        onChanged: (value) => controller.searchContent(value),
        decoration: InputDecoration(
          hintText: 'ابحث عن كتاب، مؤلف، أو محتوى...',
          prefixIcon: const Icon(Icons.search, color: Colors.teal),
          suffixIcon: controller.searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, color: Colors.grey),
                  onPressed: () {
                    controller.searchTextController.clear();
                    controller.searchContent('');
                  },
                )
              : null,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.teal, width: 2),
          ),
        ),
      ),
    );
  }

  Widget _buildTypeFilters(SearchControllerImp controller) {
    final types = [
      {'key': null, 'label': 'الكل', 'icon': Icons.apps},
      {'key': 'book', 'label': 'كتب', 'icon': Icons.book},
      {'key': 'magazine', 'label': 'مجلات', 'icon': Icons.article},
      {'key': 'podcast', 'label': 'بودكاست', 'icon': Icons.mic},
      {'key': 'audiobook', 'label': 'كتب صوتية', 'icon': Icons.headphones},
      {'key': 'video', 'label': 'فيديو', 'icon': Icons.video_library},
    ];

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: types.map((type) {
            final isSelected = controller.selectedType == type['key'];
            final count = type['key'] == null
                ? controller.allContent.length
                : controller.getTypeFilterCount(type['key'] as String);

            return Padding(
              padding: const EdgeInsets.only(left: 8),
              child: _buildFilterChip(
                label: type['label'] as String,
                icon: type['icon'] as IconData,
                count: count,
                isSelected: isSelected,
                onTap: () => controller.filterByType(type['key'] as String?),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildCategoryFilters(SearchControllerImp controller) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade200),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'التصنيفات',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                // All Categories
                Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: _buildCategoryChip(
                    label: 'جميع التصنيفات',
                    isSelected: controller.selectedCategoryId == null,
                    onTap: () => controller.filterByCategory(null),
                  ),
                ),
                // Individual Categories
                ...controller.categories.map((category) {
                  final isSelected = controller.selectedCategoryId == category.categoryId;
                  return Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: _buildCategoryChip(
                      label: category.name,
                      isSelected: isSelected,
                      onTap: () => controller.filterByCategory(category.categoryId),
                    ),
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required IconData icon,
    required int count,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? Colors.teal : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? Colors.teal : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.teal.withValues(alpha: 0.3),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ]
              : [],
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
            const SizedBox(width: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: isSelected ? Colors.white.withValues(alpha: 0.3) : Colors.teal.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                count.toString(),
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.teal,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.teal.shade100 : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? Colors.teal : Colors.grey.shade300,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.teal.shade900 : Colors.grey.shade700,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  Widget _buildActiveFiltersBar(SearchControllerImp controller) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.amber.shade50,
        border: Border(
          bottom: BorderSide(color: Colors.amber.shade200),
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.filter_list, size: 18, color: Colors.amber.shade700),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'عدد النتائج: ${controller.searchResults.length}',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.amber.shade900,
              ),
            ),
          ),
          TextButton.icon(
            onPressed: controller.clearFilters,
            style: TextButton.styleFrom(
              foregroundColor: Colors.amber.shade700,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            ),
            icon: const Icon(Icons.clear_all, size: 16),
            label: const Text(
              'مسح الفلاتر',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResults(SearchControllerImp controller) {
    if (controller.staterequest == Staterequest.loading) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.teal),
      );
    }

    if (controller.staterequest == Staterequest.failure) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 60, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              'حدث خطأ في تحميل المحتوى',
              style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
            ),
          ],
        ),
      );
    }

    if (controller.searchResults.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              controller.hasActiveFilters ? Icons.search_off : Icons.search,
              size: 80,
              color: Colors.grey.shade300,
            ),
            const SizedBox(height: 16),
            Text(
              controller.hasActiveFilters
                  ? 'لم يتم العثور على نتائج'
                  : 'ابحث عن المحتوى المفضل لديك',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              controller.hasActiveFilters
                  ? 'جرب تغيير الفلاتر أو كلمات البحث'
                  : 'استخدم شريط البحث أو الفلاتر أعلاه',
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

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: controller.searchResults.length,
      itemBuilder: (context, index) {
        return _buildContentCard(controller.searchResults[index]);
      },
    );
  }

  Widget _buildContentCard(ContentModel content) {
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
                  child: content.coverUrl != null && content.coverUrl!.isNotEmpty
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            '${serverConfig.serverLink}${content.coverUrl}',
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Center(
                                child: Text(
                                  content.getContentTypeIcon(),
                                  style: const TextStyle(fontSize: 40),
                                ),
                              );
                            },
                          ),
                        )
                      : Center(
                          child: Text(
                            content.getContentTypeIcon(),
                            style: const TextStyle(fontSize: 40),
                          ),
                        ),
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
                          '${content.getContentTypeIcon()} ${content.getContentTypeLabel()}',
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
                        content.title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),

                      // Author
                      if (content.author != null && content.author!.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.person_outline, size: 14, color: Colors.grey.shade600),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                content.author!,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey.shade600,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],

                      // Description
                      if (content.description != null && content.description!.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Text(
                          content.description!,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade500,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],

                      // Publisher & Language
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          if (content.publisher != null) ...[
                            Icon(Icons.business, size: 12, color: Colors.grey.shade400),
                            const SizedBox(width: 4),
                            Text(
                              content.publisher!,
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey.shade500,
                              ),
                            ),
                            const SizedBox(width: 12),
                          ],
                          if (content.language != null) ...[
                            Icon(Icons.language, size: 12, color: Colors.grey.shade400),
                            const SizedBox(width: 4),
                            Text(
                              content.language!,
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey.shade500,
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
      ),
    );
  }
}
