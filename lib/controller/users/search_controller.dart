import 'package:bookify/controller/users/categories_controller.dart';
import 'package:bookify/core/classes/api_client.dart';
import 'package:bookify/core/classes/staterequest.dart';
import 'package:bookify/core/constant/App_link.dart';
import 'package:bookify/model/categories_model.dart';
import 'package:bookify/model/content_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

abstract class SearchController extends GetxController {
  searchContent(String query);
  filterByType(String? type);
  filterByCategory(int? categoryId);
  clearFilters();
}

class SearchControllerImp extends SearchController {
  // State Management
  Staterequest staterequest = Staterequest.none;

  // Search Data
  List<ContentModel> allContent = [];
  List<ContentModel> searchResults = [];
  TextEditingController searchTextController = TextEditingController();

  // Filters
  String? selectedType; // null, 'book', 'magazine', 'podcast', 'audiobook', 'video'
  int? selectedCategoryId;
  String searchQuery = '';

  // Categories
  List<CategoriesModel> categories = [];

  // API
  ApiClient api = ApiClient();
  final serverConfig = ServerConfig();

  @override
  void onInit() {
    super.onInit();
    _loadAllContent();
    _loadCategories();
  }

  @override
  void onClose() {
    searchTextController.dispose();
    super.onClose();
  }

  Future<void> _loadAllContent() async {
    staterequest = Staterequest.loading;
    update();

    try {
      final response = await api.getData(
        url: '${serverConfig.serverLink}/api/user/content',
      );

      print('Search - All Content Response: ${response.statusCode}');

      if (response.statusCode == 200) {
        if (response.data is List) {
          allContent = (response.data as List)
              .map((item) => ContentModel.fromJson(item))
              .toList();

          searchResults = List.from(allContent);
          staterequest = Staterequest.success;

          print('Search - Content Loaded: ${allContent.length}');
        } else {
          staterequest = Staterequest.failure;
        }
      } else {
        staterequest = Staterequest.failure;
      }
    } catch (e) {
      print('Search - Load Content Error: $e');
      staterequest = Staterequest.failure;
    }

    update();
  }

  Future<void> _loadCategories() async {
    try {
      // محاولة الحصول على الـ categories من الـ CategoriesController إذا كان موجود
      if (Get.isRegistered<CategoriesControllerImp>()) {
        final categoriesController = Get.find<CategoriesControllerImp>();
        categories = categoriesController.categories;
        print('Search - Categories from controller: ${categories.length}');
      } else {
        // جلب الـ categories من الـ API
        final response = await api.getData(
          url: '${serverConfig.serverLink}/api/user/categories',
        );

        if (response.statusCode == 200 && response.data is List) {
          categories = (response.data as List)
              .map((item) => CategoriesModel.fromJson(item))
              .toList();
          print('Search - Categories from API: ${categories.length}');
        }
      }
    } catch (e) {
      print('Search - Load Categories Error: $e');
    }
  }

  @override
  Future<void> searchContent(String query) async {
    searchQuery = query.trim().toLowerCase();
    _applyFilters();
  }

  @override
  void filterByType(String? type) {
    selectedType = type;
    _applyFilters();
  }

  @override
  void filterByCategory(int? categoryId) {
    selectedCategoryId = categoryId;
    _applyFilters();
  }

  @override
  void clearFilters() {
    selectedType = null;
    selectedCategoryId = null;
    searchQuery = '';
    searchTextController.clear();
    searchResults = List.from(allContent);
    update();
  }

  void _applyFilters() {
    List<ContentModel> filtered = List.from(allContent);

    // فلترة حسب البحث النصي (في العنوان أو المؤلف)
    if (searchQuery.isNotEmpty) {
      filtered = filtered.where((content) {
        final titleMatch = content.title.toLowerCase().contains(searchQuery);
        final authorMatch = content.author?.toLowerCase().contains(searchQuery) ?? false;
        return titleMatch || authorMatch;
      }).toList();
    }

    // فلترة حسب النوع
    if (selectedType != null) {
      filtered = filtered.where((content) {
        return _matchContentType(content.contentType, selectedType!);
      }).toList();
    }

    // فلترة حسب التصنيف
    // ملاحظة: هذا يتطلب أن يكون الـ ContentModel يحتوي على category_id
    // إذا لم يكن موجوداً، يجب إضافته للـ model
    if (selectedCategoryId != null) {
      // TODO: تنفيذ الفلترة حسب التصنيف عندما يكون متوفراً في الـ model
      // filtered = filtered.where((content) => content.categoryId == selectedCategoryId).toList();
    }

    searchResults = filtered;

    // تحديث الحالة
    if (searchResults.isEmpty && (searchQuery.isNotEmpty || selectedType != null || selectedCategoryId != null)) {
      staterequest = Staterequest.empty;
    } else {
      staterequest = Staterequest.success;
    }

    print('Search Results: ${searchResults.length}');
    update();
  }

  bool _matchContentType(String contentType, String filterType) {
    final type = contentType.toLowerCase();
    final filter = filterType.toLowerCase();

    // المطابقة المباشرة
    if (type == filter) return true;

    // المطابقة بين العربي والإنجليزي
    if (filter == 'book' && (type == 'كتاب' || type == 'book')) return true;
    if (filter == 'magazine' && (type == 'مجلة' || type == 'magazine')) return true;
    if (filter == 'podcast' && (type == 'بودكاست' || type == 'podcast')) return true;
    if (filter == 'audiobook' && (type == 'كتاب صوتي' || type == 'audiobook' || type == 'صوتي')) return true;
    if (filter == 'video' && (type == 'فيديو' || type == 'video')) return true;
    if (filter == 'article' && (type == 'مقالة' || type == 'article')) return true;

    return false;
  }

  // Helper: الحصول على عدد النتائج لكل فلتر
  int getTypeFilterCount(String type) {
    return allContent.where((content) => _matchContentType(content.contentType, type)).length;
  }

  int getCategoryFilterCount(int categoryId) {
    // TODO: تنفيذ عندما يكون categoryId متوفراً في الـ model
    return 0;
  }

  // Helper: هل هناك فلاتر نشطة؟
  bool get hasActiveFilters {
    return selectedType != null || selectedCategoryId != null || searchQuery.isNotEmpty;
  }
}
